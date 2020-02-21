library(tidyverse)
library(countrycode)
library(haven)
library(readstata13)


get_lb_parties <- function(lb_file, var_country, var_party, year) {
  party_keys <- 
    read.dta13(lb_file, fromEncoding = "UTF-8", convert.factors = FALSE) %>%
    select(.data[[var_party]]) %>%
    pull()
  
  read.dta13(lb_file, fromEncoding = "UTF-8") %>%
    select(.data[[var_country]], .data[[var_party]]) %>%
    mutate(
      country = countrycode(.data[[var_country]], origin = "country.name", destination = "iso3c"),
      party_key = party_keys,
      year = year
    ) %>%
    rename(party = .data[[var_party]]) %>% 
    select(country, year, party, party_key)
}

get_lb_path <- function(file_part_path) {
  paste0("source__latinobarometer/Latinobarometro", file_part_path)
}

# tmp <- get_lb_parties(get_lb_path("_1995_data_english_v2014_06_27.dta"), "pais", "p33", 1995)

lb_params <- 
  tribble(
    ~lb_file, ~var_country, ~var_party, ~year,
    get_lb_path("_1995_data_english_v2014_06_27.dta"), "pais", "p33", 1995,
    get_lb_path("_1996_datos_english_v2014_06_27.dta"), "pais", "p40", 1996,
    get_lb_path("_1997_datos_english_v2014_06_27.dta"), "idenpa", "sp58", 1997,
    get_lb_path("_1998_datos_english_v2014_06_27.dta"), "idenpa", "sp53", 1998,
    get_lb_path("_2000_datos_eng_v2014_06_27.dta"), "idenpa", "P54ST", 2000,
    get_lb_path("_2001_datos_english_v2014_06_27.dta"), "idenpa", "p55st", 2001,
    get_lb_path("_2002_datos_eng_v2014_06_27.dta"), "idenpa", "p45st", 2002,
    get_lb_path("_2003_datos_eng_v2014_06_27.dta"), "idenpa", "p54st", 2003,
    get_lb_path("_2004_datos_eng_v2014_06_27.dta"), "idenpa", "p30st", 2004,
    get_lb_path("_2005_datos_eng_v2014_06_27.dta"), "idenpa", "p48st", 2005,
    get_lb_path("_2006_datos_eng_v2014_06_27.dta"), "idenpa", "p38st", 2006,
    get_lb_path("_2007_datos_eng_v2014_06_27.dta"), "idenpa", "p64st", 2007,
    get_lb_path("_2008_datos_eng_v2014_06_27.dta"), "idenpa", "p61st", 2008,
    get_lb_path("_2009_datos_eng_v2014_06_27.dta"), "idenpa", "p35st", 2009,
    get_lb_path("_2010_datos_eng_v2014_06_27.dta"), "idenpa", "P29ST", 2010,
    get_lb_path("_2011_eng.dta"), "idenpa", "P38ST", 2011,
    get_lb_path("2013Eng.dta"), "idenpa", "P22TGBSM", 2013,
    get_lb_path("_2015_Eng.dta"), "idenpa", "P23TGBSM", 2015,
    get_lb_path("2016Eng_v20170205.dta"), "idenpa", "P15STGBS", 2016,
    get_lb_path("2017Eng_v20180117.dta"), "idenpa", "P16STGBS", 2017,
    get_lb_path("_2018_Eng_Stata_v20190303.dta"), "IDENPA", "P21STGBS.A", 2018
)

lb_tmp <- pmap(lb_params, ~ get_lb_parties(..1, ..2, ..3, ..4)) %>% bind_rows()


## fix some missing countries
lb_tmp_2 <- 
  lb_tmp %>%
  mutate(
    cntry = str_extract(party, "[:alpha:]{2}"),
    country = case_when(
      cntry == "BR" ~ "BRA",
      cntry == "DO" ~ "DOM",
      TRUE ~ country
    )
  )


## filter technicals & calculate share
lb <- 
  lb_tmp_2 %>%
  filter( ! party_key %in% c(-7, -4, -3, -2, -1, 92:97)) %>%
  group_by(year, country) %>%
  mutate(t = n()) %>%
  group_by(year, country, party_key) %>%
  mutate(
    n = n(),
    share = round(n / t * 100, 1)
  ) %>%
  ungroup() %>%
  select(country, year, party, share, party_key) %>%
  distinct() %>%
  group_by(party_key) %>%
  mutate(
    year_first = min(year),
    year_last = max(year),
    max_share = max(share)
  ) %>%
  ungroup() %>%
  filter(share == max_share) %>%
  distinct() %>%
  group_by(party_key) %>%
  slice(1L)


## extract party name
lb_parties <- 
  lb %>%
  mutate(
    party = str_extract(party, "(?<=[:punct:]).*"),
    name = str_extract(party, "[[:space:][:alpha:][:space]]*"),
    name_short = str_extract(party, "(?<=\\()[[:alpha:][:space:]\\/]*")
  ) %>%
  select(country, name_short, name, year_first, year_last, share,
         share_year=year, party_id=party_key) %>%
  arrange(country, name) %>% 
  distinct()


## write csv
write_csv(lb_parties, "latino-parties.csv", na = "")
