library(tidyverse)

ches_pa <- read_csv("ches-2019-parties.csv", na = "")
ches_dt <- read_csv("source__CHES2019V3.csv", na = "")
country <- read_csv("country.csv", na = "")

ches_elec <-
  ches_dt %>%
  select(country, party_id, party) %>%
  mutate(
    country = toupper(country),
    vote = NA_real_,
    electionyear = NA_real_,
    year_first = 2019,
    year_last = 2019
  )

ches <-
  ches_elec %>%
  left_join(country) %>%
  left_join(ches_pa) %>%
  select(country, country_iso3 = iso3, party_id, party_abbrev = name_short, party_name = name, party_name_english = name_english, vote, electionyear, year_first, year_last)

write_csv(ches, "ches-2019.csv", na = "")
