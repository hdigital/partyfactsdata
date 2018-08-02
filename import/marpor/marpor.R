library(tidyverse)
library(countrycode)

marpor_raw <- read_csv("marpor-parties.csv")
marpor_share <- read_csv("marpor-share.csv")

marpor <- marpor_raw %>% select(-country) %>% inner_join(marpor_share)

# add Party Facts country codes
country_custom <- c(`German Democratic Republic` = "DDR",
                    `Northern Ireland` = "NIR")
marpor <- marpor %>%
  mutate(country = countrycode(countryname, "country.name", "iso3c",
                               custom_match = country_custom))
if(any(is.na(marpor$country))) {
  warning("Country name clean-up needed")
}

# replace party short longer than 25 chars
marpor[nchar(marpor$abbrev) > 25 & ! is.na(marpor$abbrev), "abbrev"] <- NA

write.csv(marpor, "marpor.csv", na = "", fileEncoding = "utf-8", row.names = FALSE)
