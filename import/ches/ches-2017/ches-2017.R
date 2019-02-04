library(tidyverse)

ches_pa <- read_csv("ches-2017-parties.csv")
ches_dt <- haven::read_dta("source__CHES_means_2017.dta")
country <- read_csv("country.csv")

ches_elec <- 
  ches_dt %>%
  select(party_id, vote, electionyear) %>%
  mutate(
    vote = round(vote, 1),
    year_first = 2017,
    year_last = 2017
  )

ches <- 
  ches_pa %>% 
  left_join(country) %>% 
  left_join(ches_elec) %>% 
  select(country, country_iso3 = iso3, everything())

write_csv(ches, "ches-2017.csv")