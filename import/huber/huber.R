library(tidyverse)
library(countrycode)

huber_raw <- read_csv("huber_inglehart_1995.csv")

huber <- huber_raw %>%
  rename(huber_id=id) %>%
  mutate(country_short = countrycode(
    country, "country.name", "iso3c", custom_match = c(`NORTHERN IRELAND`="NIR")
    ),
    dummy_nir = if_else(country == "NIR", 1, 0),
    country = case_when(
      country == "NIR" ~ "GBR",
      TRUE ~ country
    )
  )

write_csv(huber, "huber.csv", na = "")
