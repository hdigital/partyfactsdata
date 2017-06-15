library(tidyverse)
library(countrycode)

ees_raw <- read_csv("parties-ees-ches-ess.csv")

ees <- ees_raw %>%
  mutate(country_iso3 = countrycode(country, "iso2c", "iso3c",
                                    custom_match = c(UK="GBR")))

write_csv(ees, "ees14.csv", na = "")
