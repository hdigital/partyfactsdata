library(tidyverse)
library(countrycode)

huber_raw <- read_csv("huber_inglehart_1995.csv")

huber <- huber_raw %>%
  rename(huber_id=id) %>%
  mutate(country_name_short = countrycode(country, "country.name", "iso3c",
                                          custom_match = c(`NORTHERN IRELAND`="NIR")))

write_csv(huber, "huber.csv", na = "")
