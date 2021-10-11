library(tidyverse)
library(countrycode)

raw_gpd <- read_csv("source__GPD_20190625.csv", na = "")

gpd_temp1 <-
  raw_gpd %>%
  select(country, party, yearbegin, yearend) %>%
  group_by(country, party) %>%
  mutate(
    yearend = if_else(yearend == "present", 2019, as.numeric(yearend)),
    year_first = min(yearbegin, na.rm = T),
    year_last = max(yearend, na.rm = T)
  ) %>%
  ungroup() %>%
  select(-yearbegin, -yearend) %>%
  unique() %>%
  drop_na(party)

gpd <-
  gpd_temp1 %>%
  mutate(
    country = countrycode(country, origin = "country.name", destination = "iso3c"),
    party_id = str_extract_all(party, "[A-Z]") %>% map_chr(paste, collapse = ""),
    party_id = paste(country, party_id, year_first)
  ) %>%
  arrange(country)

duplicated(gpd$party_id) %>% any()

write_csv(gpd, "gpd.csv", na = "")
