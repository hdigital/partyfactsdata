library(tidyverse)
library(countrycode)

share_min <- 5

ab <- read_csv("afrobarometer.csv")

ab_out <- ab %>% 
  mutate(country_short = countrycode(country, "country.name", "iso3c")) %>% 
  filter(share >= share_min)

write_csv(ab_out, "afro.csv", na = "")
