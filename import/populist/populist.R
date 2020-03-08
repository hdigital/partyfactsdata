library(tidyverse)
library(countrycode)

raw_pop <- readxl::read_excel("source__populist-version-2-20202028.xlsx")

pop <-
  raw_pop %>%
  rename_all(tolower) %>%
  mutate(
    country_short = countrycode(country_name, "country.name", "iso3c"),
    country_short = if_else(
      str_detect(party_name_english, fixed("(Faroe Islands)")),
      "FRO",
      country_short
    ),
    party_id = paste0(
      country_short, "-",
      substr(str_remove_all(party_name_short, "\\W"), 1, 3)
    ) %>% tolower(),
    party_id = if_else(duplicated(party_id), paste0(party_id, "-1"), party_id)
  ) %>%
  select(party_name:party_name_short, partyfacts_id, country_short, party_id)

write_csv(pop, "populist.csv", na = "")
