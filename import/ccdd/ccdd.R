library(tidyverse)
library(countrycode)

file_in <- read_csv("source__ccdd.csv", na = "")

file_out <- 
  file_in %>% 
  mutate(
    country = countrycode(country_name, origin = "country.name", destination = "iso3c"),
    party_id = paste0(country, "-", ID)
  ) %>% 
  select(country, name_short, name_english, name, year_only, party_id, note)

duplicated(file_out$party_id) %>% any()

write_csv(file_out, "ccdd.csv", na = "")
