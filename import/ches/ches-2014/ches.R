library(tidyverse)

party <- read_csv("ches-parties.csv", na = "")
country <- read_csv("ches-country.csv", na = "")
info <- read_csv("ches-party-info.csv", na = "")

year_default <- 2014 # for countries not in trendfile

ches <- party %>%
  left_join(country %>% select(country = abbr, country_iso3 = iso3)) %>%
  left_join(info %>% select(-country, -party)) %>%
  mutate(
    year_first = ifelse(is.na(year_first), year_default, year_first),
    year_last = ifelse(is.na(year_last), year_default, year_last)
  )

write_csv(ches, "ches.csv", na = "")
