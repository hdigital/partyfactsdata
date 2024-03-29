library(tidyverse)
library(countrycode)

file_in <-
  readxl::read_xlsx("source__opamed.xlsx", na = "")

opamed <-
  file_in %>%
  select(country, name_short = party_tag, name_english = name_party, year) %>%
  mutate(
    country_code = countrycode(country, "country.name", "iso3c", custom_match = c("Azerbajan" = "AZE", "Belorussia" = "BLR", "Czechslovakia" = "CZE", "East Germany" = "DDR", "Kirgzhistan" = "KGZ", "Tadzikistan" = "TJK", "Yugoslavia" = "SRB")),
    party_id = paste(country_code, name_short, sep = "-")
  ) %>%
  group_by(party_id) %>%
  mutate(
    year_first = min(year, na.rm = T),
    year_last = max(year, na.rm = T)
  ) %>%
  ungroup() %>%
  select(country_code, name_short, name_english, year_first, year_last, party_id) %>%
  distinct()


opamed$party_id %>% duplicated() %>% any()


file_out <-
  opamed

write_csv(file_out, "opamed.csv", na = "")
