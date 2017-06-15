library(tidyverse)
library(countrycode)

thomas_raw <- read_csv("thomas-parties.csv")

# remove "status quo" information
thomas <- thomas_raw %>% filter(party != "Status quo")

# replace UK and RUS with proper country names
thomas$country[thomas$country == "Great Britain"] <- "United Kingdom"
thomas$country[thomas$country == "USSR"] <- "Russia"

# aggregate parties first and last year
thomas <- thomas %>%
  group_by(country, party) %>%
  summarise(year_first = min(time), year_last = max(time)) %>%
  ungroup()

# get country name iso shortcut
thomas <- thomas %>%
  mutate(country_short = countrycode(country, "country.name", "iso3c")) %>%
  arrange(country, party) %>%
  mutate(id = row_number())

write_csv(thomas, "thomas.csv", na = "")
