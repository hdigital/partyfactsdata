library(tidyverse)
library(countrycode)

marpor_raw <- read_csv("marpor-2016.csv")
marpor_share <- read_csv("marpor-share.csv")

marpor <- marpor_raw %>% select(-country) %>% left_join(marpor_share)

# add Party Facts country codes
marpor <- marpor %>%
  mutate(country = countrycode(countryname, "country.name", "iso3c",
                            custom_match = c(`Northern Ireland`="NIR")))
if(any(is.na(marpor$country))) {
  warning("Country name clean-up needed")
}

# replace party short longer than 25 chars
marpor[nchar(marpor$abbrev) > 25 & ! is.na(marpor$abbrev), "abbrev"] <- NA

write_csv(marpor, "marpor.csv", na = "")
