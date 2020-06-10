library(tidyverse)
library(countrycode)

hix_raw <- read_csv("hix-parties.csv")

hix <- 
  hix_raw %>% 
  mutate(
    abbrev = ifelse(nchar(abbrev) > 25, substr(abbrev, 1, 25), abbrev),
    national_party = ifelse(nchar(national_party) > 200,
                            substr(national_party, 1, 200),
                            national_party),
    country = countrycode(country_name, "country.name", "iso3c", 
                          custom_match = c(Drance = "FRA"))
  ) %>% 
  select(country, member_state, country_name, code, abbrev, everything())

write_csv(hix, "hix.csv")
