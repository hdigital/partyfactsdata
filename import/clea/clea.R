library(tidyverse)
library(readxl)
library(countrycode)
# library(janitor)  # used once with "janitor::"


## Read raw data ----

load("source__clea/clea_20201216/clea_lc_20201216.rdata")
raw_clea <- clea_lc_20201216

raw_clea_appendix<- read_xlsx("source__clea/clea_20201216/clea_20201216_appendix_II.xlsx", na = "")
clea_appendix <- janitor::clean_names(raw_clea_appendix)


## PF-Data linked ----

if(FALSE) {
  read_csv("https://partyfacts.herokuapp.com/download/external-parties-csv/", 
           na = "",
           guess_max = 50000) %>% 
    filter(dataset_key == "clea") %>% 
    select(dataset_party_id, partyfacts_id) %>% 
    write_csv("partyfacts-clea.csv")
}

pf_ext <- read_csv("partyfacts-clea.csv", na = "")


## Prepare party list ----

country_custom <- c("Kosovo" = "XKX", "Madagscar" = "MDG", "Micronesia" = "FSM", "Somaliland" = "SML")

clea_appendix <- 
  clea_appendix %>% 
  drop_na(party_code) %>% 
  mutate(
    party_code = as.numeric(str_remove(party_code, "\\-")),
    country_short = countrycode(country,
                                origin = "country.name",
                                destination = "iso3c",
                                custom_match = country_custom),
    merge_id = paste(country_short, party_code, sep = "-")
  ) %>% 
  select(country_short, country, name_short = abbr, name = party_name, 
         name_english = party_name_in_english, merge_id)


## Data clean-up  ----

### party names ----

clea_appendix <- 
  clea_appendix %>% 
  mutate(
    name_english = case_when(
      country_short == "SGP" ~ name_short,
      nchar(name_short) > 25 ~ name_short,
      TRUE ~ name_english
    ),
    name_short = case_when(
      country_short == "SGP" ~ NA_character_,
      nchar(name_short) > 25 ~ NA_character_,
      TRUE ~ name_short
    ),
    name = str_extract(name, ".{0,200}"),
    name_english = str_extract(name_english, ".{0,200}")
  )


### remove duplicate party ids ----
  
# check for duplicate merge_id's
duplicated(clea_appendix$merge_id) %>% any()

clea_appendix <- 
  clea_appendix %>% 
  distinct(merge_id, .keep_all = TRUE)

### country codes separately ----
country_info <- 
  clea_appendix %>% 
  select(country, country_short) %>% 
  distinct() %>% 
  mutate(
    country = case_when(
      country_short == "GBR" ~ "UK",
      country_short == "USA" ~ "US",
      TRUE ~ country
    )
  )


## Create aggregate information ----

### year first/last ----
pa_info <- 
  raw_clea %>%
  group_by(ctr, pty) %>%
  summarise(
    yr_first = min(yr, na.rm = TRUE),
    yr_last = max(yr, na.rm = TRUE),
    .groups = "drop"
  )

### name ----
pa_name <- 
  raw_clea %>%
  select(ctr_n, ctr, pty_n, pty) %>%
  group_by(ctr, pty) %>%
  filter(nchar(pty_n) == max(nchar(pty_n))) %>%
  distinct(ctr, pty, .keep_all = TRUE) %>% 
  ungroup()

### elections ----
elec <- 
  raw_clea %>%
  group_by(ctr, yr, mn, pty) %>%
  summarize(pv1 = sum(pv1, na.rm = TRUE), .groups = "drop") %>%
  group_by(ctr, yr, mn) %>%
  mutate(pv1_share = round(pv1 / sum(pv1) * 100, 1)) %>% 
  ungroup()

### number elections, max vote share, year ----
pa_share <- 
  elec %>%
  group_by(ctr, pty) %>%
  mutate(n_election = n()) %>%
  filter(pv1_share == max(pv1_share)) %>%
  distinct(ctr, pty, .keep_all = TRUE) %>%
  select(ctr, pty, pv1_share_max = pv1_share, pv1_share_max_yr = yr, n_election) %>% 
  ungroup()

### combine previous steps ----
party <- 
  pa_name %>%
  left_join(pa_info) %>%
  left_join(pa_share) %>%
  arrange(ctr_n, pty_n)


## Final information ----

# fix share issues, create party_id and alliance indicator
clea_party <- 
  party %>% 
  left_join(country_info, by = c("ctr_n" = "country")) %>% 
  mutate(
    pv1_share_max = if_else(pv1_share_max < 0, pv1_share_max * -1, pv1_share_max),
    merge_id = paste(country_short, pty, sep = "-"),
    party_id = ctr*1000000 + pty,
    alliance = if_else(pty > 5000 & pty < 6000, 1, 0)
  )

# combine party list and party information
file_out <- 
  clea_appendix %>% 
  left_join(clea_party, by = c("merge_id")) %>% 
  left_join(pf_ext, by = c("party_id" = "dataset_party_id")) %>% 
  filter(pty < 4000 | pv1_share_max >= 25) %>%  # remove alliances
  filter(pv1_share_max >= 5 | ! is.na(partyfacts_id)) %>%  # temporary 5% threshold
  select(country_short = country_short.x, country, name_short, name, name_english,
         yr_first, yr_last, pv1_share_max, pv1_share_max_yr, n_election, alliance,
         ctr, pty, party_id)

duplicated(file_out$party_id) %>% any()


write_csv(file_out, "clea.csv", na = "")
