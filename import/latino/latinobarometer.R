library(tidyverse)
library(haven)
library(foreign)
library(countrycode)


## 1995
lb95_id <- read_dta("source__Latinobarometro_1995_data_english_v2014_06_27.dta") %>%
  select("p33") %>%
  `colnames<-`("party_key")

lb95 <- readstata13::read.dta13("source__Latinobarometro_1995_data_english_v2014_06_27.dta", fromEncoding = "UTF-8") %>%
  select(pais, p33) %>%
  cbind(lb95_id) %>%
  mutate(
    country = countrycode(pais, origin = "country.name", destination = "iso3c"),
    year = 1995
  ) %>%
  select(country, year, p33, party_key) %>%
  `colnames<-`(c("country", "year", "party", "party_key"))


## 1996
lb96_id <- read_dta("source__Latinobarometro_1996_datos_english_v2014_06_27.dta") %>%
  select("p40") %>%
  `colnames<-`("party_key")

lb96 <- readstata13::read.dta13("source__Latinobarometro_1996_datos_english_v2014_06_27.dta", fromEncoding = "UTF-8") %>%
  select(pais, p40) %>%
  cbind(lb96_id) %>%
  mutate(
    country = countrycode(pais, origin = "country.name", destination = "iso3c"),
    year = 1996
  ) %>%
  select(country, year, p40, party_key) %>%
  `colnames<-`(c("country", "year", "party", "party_key"))


## 1997
lb97_id <- read_dta("source__Latinobarometro_1997_datos_english_v2014_06_27.dta") %>%
  select("sp58") %>%
  `colnames<-`("party_key")

lb97 <- readstata13::read.dta13("source__Latinobarometro_1997_datos_english_v2014_06_27.dta", fromEncoding = "UTF-8") %>%
  select(idenpa, sp58) %>%
  cbind(lb97_id) %>%
  mutate(
    country = countrycode(idenpa, origin = "country.name", destination = "iso3c"),
    year = 1997
  ) %>%
  select(country, year, sp58, party_key) %>%
  `colnames<-`(c("country", "year", "party", "party_key"))


## 1998
lb98_id <- read_dta("source__Latinobarometro_1998_datos_english_v2014_06_27.dta") %>%
  select("sp53") %>%
  `colnames<-`("party_key")

lb98 <- readstata13::read.dta13("source__Latinobarometro_1998_datos_english_v2014_06_27.dta", fromEncoding = "UTF-8") %>%
  select(idenpa, sp53) %>%
  cbind(lb98_id) %>%
  mutate(
    country = countrycode(idenpa, origin = "country.name", destination = "iso3c"),
    year = 1998
  ) %>%
  select(country, year, sp53, party_key) %>%
  `colnames<-`(c("country", "year", "party", "party_key"))


## 2000
lb00_id <- read_dta("source__Latinobarometro_2000_datos_eng_v2014_06_27.dta") %>%
  select("P54ST") %>%
  `colnames<-`("party_key")

lb00 <- readstata13::read.dta13("source__Latinobarometro_2000_datos_eng_v2014_06_27.dta", fromEncoding = "UTF-8") %>%
  select(idenpa, P54ST) %>%
  cbind(lb00_id) %>%
  mutate(
    country = countrycode(idenpa, origin = "country.name", destination = "iso3c"),
    year = 2000
  ) %>%
  select(country, year, P54ST, party_key) %>%
  `colnames<-`(c("country", "year", "party", "party_key"))


## 2001
lb01_id <- read_dta("source__Latinobarometro_2001_datos_english_v2014_06_27.dta") %>%
  select("p55st") %>%
  `colnames<-`("party_key")

lb01 <- readstata13::read.dta13("source__Latinobarometro_2001_datos_english_v2014_06_27.dta", fromEncoding = "UTF-8") %>%
  select(idenpa, p55st) %>%
  cbind(lb01_id) %>%
  mutate(
    country = countrycode(idenpa, origin = "country.name", destination = "iso3c"),
    year = 2001
  ) %>%
  select(country, year, p55st, party_key) %>%
  `colnames<-`(c("country", "year", "party", "party_key"))


## 2002
lb02_id <- read_dta("source__Latinobarometro_2002_datos_eng_v2014_06_27.dta") %>%
  select("p45st") %>%
  `colnames<-`("party_key")

lb02 <- readstata13::read.dta13("source__Latinobarometro_2002_datos_eng_v2014_06_27.dta", fromEncoding = "UTF-8") %>%
  select(idenpa, p45st) %>%
  cbind(lb02_id) %>%
  mutate(
    country = countrycode(idenpa, origin = "country.name", destination = "iso3c"),
    year = 2002
  ) %>%
  select(country, year, p45st, party_key) %>%
  `colnames<-`(c("country", "year", "party", "party_key"))


## 2003
lb03_id <- read_dta("source__Latinobarometro_2003_datos_eng_v2014_06_27.dta") %>%
  select("p54st") %>%
  `colnames<-`("party_key")

lb03 <- readstata13::read.dta13("source__Latinobarometro_2003_datos_eng_v2014_06_27.dta", fromEncoding = "UTF-8") %>%
  select(idenpa, p54st) %>%
  cbind(lb03_id) %>%
  mutate(
    country = countrycode(idenpa, origin = "country.name", destination = "iso3c"),
    year = 2003
  ) %>%
  select(country, year, p54st, party_key) %>%
  `colnames<-`(c("country", "year", "party", "party_key"))


## 2004
lb04_id <- read_dta("source__Latinobarometro_2004_datos_eng_v2014_06_27.dta") %>%
  select("p30st") %>%
  `colnames<-`("party_key")

lb04 <- readstata13::read.dta13("source__Latinobarometro_2004_datos_eng_v2014_06_27.dta", fromEncoding = "UTF-8") %>%
  select(idenpa, p30st) %>%
  cbind(lb04_id) %>%
  mutate(
    country = countrycode(idenpa, origin = "country.name", destination = "iso3c"),
    year = 2004
  ) %>%
  select(country, year, p30st, party_key) %>%
  `colnames<-`(c("country", "year", "party", "party_key"))


## 2005
lb05_id <- read_dta("source__Latinobarometro_2005_datos_eng_v2014_06_27.dta") %>%
  select("p48st") %>%
  `colnames<-`("party_key")

lb05 <- readstata13::read.dta13("source__Latinobarometro_2005_datos_eng_v2014_06_27.dta", fromEncoding = "UTF-8") %>%
  select(idenpa, p48st) %>%
  cbind(lb05_id) %>%
  mutate(
    country = countrycode(idenpa, origin = "country.name", destination = "iso3c"),
    year = 2005
  ) %>%
  select(country, year, p48st, party_key) %>%
  `colnames<-`(c("country", "year", "party", "party_key"))


## 2006
lb06_id <- read_dta("source__Latinobarometro_2006_datos_eng_v2014_06_27.dta") %>%
  select("p38st") %>%
  `colnames<-`("party_key")

lb06 <- readstata13::read.dta13("source__Latinobarometro_2006_datos_eng_v2014_06_27.dta", fromEncoding = "UTF-8") %>%
  select(idenpa, p38st) %>%
  cbind(lb06_id) %>%
  mutate(
    country = countrycode(idenpa, origin = "country.name", destination = "iso3c"),
    year = 2006
  ) %>%
  select(country, year, p38st, party_key) %>%
  `colnames<-`(c("country", "year", "party", "party_key"))


## 2007
lb07_id <- read_dta("source__Latinobarometro_2007_datos_eng_v2014_06_27.dta") %>%
  select("p64st") %>%
  `colnames<-`("party_key")

lb07 <- readstata13::read.dta13("source__Latinobarometro_2007_datos_eng_v2014_06_27.dta", fromEncoding = "UTF-8") %>%
  select(idenpa, p64st) %>%
  cbind(lb07_id) %>%
  mutate(
    country = countrycode(idenpa, origin = "country.name", destination = "iso3c"),
    year = 2007
  ) %>%
  select(country, year, p64st, party_key) %>%
  `colnames<-`(c("country", "year", "party", "party_key"))


## 2008
lb08_id <- read_dta("source__Latinobarometro_2008_datos_eng_v2014_06_27.dta") %>%
  select("p61st") %>%
  `colnames<-`("party_key")

lb08 <- readstata13::read.dta13("source__Latinobarometro_2008_datos_eng_v2014_06_27.dta", fromEncoding = "UTF-8") %>%
  select(idenpa, p61st) %>%
  cbind(lb08_id) %>%
  mutate(
    country = countrycode(idenpa, origin = "country.name", destination = "iso3c"),
    year = 2008
  ) %>%
  select(country, year, p61st, party_key) %>%
  `colnames<-`(c("country", "year", "party", "party_key"))


## 2009
lb09_id <- read_dta("source__Latinobarometro_2009_datos_eng_v2014_06_27.dta") %>%
  select("p35st") %>%
  `colnames<-`("party_key")

lb09 <- readstata13::read.dta13("source__Latinobarometro_2009_datos_eng_v2014_06_27.dta", fromEncoding = "UTF-8") %>%
  select(idenpa, p35st) %>%
  cbind(lb09_id) %>%
  mutate(
    country = countrycode(idenpa, origin = "country.name", destination = "iso3c"),
    year = 2009
  ) %>%
  select(country, year, p35st, party_key) %>%
  `colnames<-`(c("country", "year", "party", "party_key"))


## 2010
lb10_id <- read_dta("source__Latinobarometro_2010_datos_eng_v2014_06_27.dta") %>%
  select("P29ST") %>%
  `colnames<-`("party_key")

lb10 <- readstata13::read.dta13("source__Latinobarometro_2010_datos_eng_v2014_06_27.dta", fromEncoding = "UTF-8") %>%
  select(idenpa, P29ST) %>%
  cbind(lb10_id) %>%
  mutate(
    country = countrycode(idenpa, origin = "country.name", destination = "iso3c"),
    year = 2010
  ) %>%
  select(country, year, P29ST, party_key) %>%
  `colnames<-`(c("country", "year", "party", "party_key"))


## 2011
lb11_id <- read_dta("source__Latinobarometro_2011_eng.dta") %>%
  select("P38ST") %>%
  `colnames<-`("party_key")

lb11 <- readstata13::read.dta13("source__Latinobarometro_2011_eng.dta") %>%
  select(idenpa, P38ST) %>%
  cbind(lb11_id) %>%
  mutate(
    country = countrycode(idenpa, origin = "country.name", destination = "iso3c"),
    year = 2011
  ) %>%
  select(country, year, P38ST, party_key) %>%
  `colnames<-`(c("country", "year", "party", "party_key"))


## 2013
lb13_id <- read_dta("source__Latinobarometro2013Eng.dta") %>%
  select("P22TGBSM") %>%
  `colnames<-`("party_key")

lb13 <- readstata13::read.dta13("source__Latinobarometro2013Eng.dta", fromEncoding = "UTF-8") %>%
  select(idenpa, P22TGBSM) %>%
  cbind(lb13_id) %>%
  mutate(
    country = countrycode(idenpa, origin = "country.name", destination = "iso3c"),
    year = 2013
  ) %>%
  select(country, year, P22TGBSM, party_key) %>%
  `colnames<-`(c("country", "year", "party", "party_key"))


## 2015
lb15_id <- read_dta("source__Latinobarometro_2015_Eng.dta") %>%
  select("P23TGBSM") %>%
  `colnames<-`("party_key")

lb15 <- readstata13::read.dta13("source__Latinobarometro_2015_Eng.dta", fromEncoding = "UTF-8") %>%
  select(idenpa, P23TGBSM) %>%
  cbind(lb15_id) %>%
  mutate(
    country = countrycode(idenpa, origin = "country.name", destination = "iso3c"),
    year = 2015
  ) %>%
  select(country, year, P23TGBSM, party_key) %>%
  `colnames<-`(c("country", "year", "party", "party_key"))


## 2016
lb16_id <- read_dta("source__Latinobarometro2016Eng_v20170205.dta") %>%
  select("P15STGBS") %>%
  `colnames<-`("party_key")

lb16 <- readstata13::read.dta13("source__Latinobarometro2016Eng_v20170205.dta", fromEncoding = "UTF-8") %>%
  select(idenpa, P15STGBS) %>%
  cbind(lb16_id) %>%
  mutate(
    country = countrycode(idenpa, origin = "country.name", destination = "iso3c"),
    year = 2016
  ) %>%
  select(country, year, P15STGBS, party_key) %>%
  `colnames<-`(c("country", "year", "party", "party_key"))


## 2017
lb17_id <- read_dta("source__Latinobarometro2017Eng_v20180117.dta") %>%
  select("P16STGBS") %>%
  `colnames<-`("party_key")

lb17 <- readstata13::read.dta13("source__Latinobarometro2017Eng_v20180117.dta", fromEncoding = "UTF-8") %>%
  select(idenpa, P16STGBS) %>%
  cbind(lb17_id) %>%
  mutate(
    country = countrycode(idenpa, origin = "country.name", destination = "iso3c"),
    year = 2017
  ) %>%
  select(country, year, P16STGBS, party_key) %>%
  `colnames<-`(c("country", "year", "party", "party_key"))


## 2018
lb18_id <- read_dta("source__Latinobarometro_2018_Eng_Stata_v20190303.dta") %>%
  select("P21STGBS.A") %>%
  `colnames<-`("party_key")

lb18 <- readstata13::read.dta13("source__Latinobarometro_2018_Eng_Stata_v20190303.dta", fromEncoding = "UTF-8") %>%
  select(IDENPA, "P21STGBS.A") %>%
  cbind(lb18_id) %>%
  mutate(
    country = countrycode(IDENPA, origin = "country.name", destination = "iso3c"),
    year = 2018
  ) %>%
  select(country, year, "P21STGBS.A", party_key) %>%
  `colnames<-`(c("country", "year", "party", "party_key"))



## combine all years
lb_temp <- do.call("rbind", list(lb95, lb96, lb97, lb98, lb00, lb01, lb02, lb03,
                                 lb04, lb05, lb06, lb07, lb08, lb09, lb10, lb11,
                                 lb13, lb15, lb16, lb17, lb18))


## remove everything except lb_temp
rm(list = (ls()[ls() != "lb_temp"]))


## fix some missing countries
lb_temp2 <- lb_temp %>%
  mutate(
    cntry = str_extract(party, "[:alpha:]{2}"),
    country = case_when(
      cntry == "BR" ~ "BRA",
      cntry == "DO" ~ "DOM",
      TRUE ~ country
    )
  )


## filter technicals & calculate share
lb <- lb_temp2 %>%
  filter(
    party_key != -7 &
      party_key != -4 &
      party_key != -3 &
      party_key != -2 &
      party_key != -1 &
      party_key != 92 &
      party_key != 93 &
      party_key != 94 &
      party_key != 95 &
      party_key != 96 &
      party_key != 97
  ) %>%
  group_by(year, country) %>%
  mutate(
    t = n()
  ) %>%
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
lb_parties <- lb %>%
  mutate(
    party = str_extract(party, "(?<=[:punct:]).*"),
    name = str_extract(party, "[[:space:][:alpha:][:space]]*"),
    name_short = str_extract(party, "(?<=\\()[[:alpha:][:space:]\\/]*")
  ) %>%
  select(country, name_short, name, year_first, year_last, share, year, party_key) %>%
  distinct() %>%
  `colnames<-`(
    c(
    "country", "name_short", "name", "year_first", "year_last", "share", "share_year", "party_id"
    )
  )


## write csv
write.csv(lb_parties, "latino-parties.csv", fileEncoding = "UTF-8", row.names = FALSE, na = "")
