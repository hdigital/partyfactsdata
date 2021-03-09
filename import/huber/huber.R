library(tidyverse)
library(countrycode)

huber_raw <- read_csv("huber_inglehart_1995.csv")

huber <- huber_raw %>%
  rename(huber_id=id) %>%
  mutate(country_short = countrycode(
    country, "country.name", "iso3c", custom_match = c(`NORTHERN IRELAND`="NIR")
    ),
    dummy_nir = if_else(country_short == "NIR", 1, 0),
    country_short = case_when(
      country_short == "NIR" ~ "GBR",
      TRUE ~ country_short
    )
  )

write_csv(huber, "huber.csv", na = "")
