library(tidyverse)
library(countrycode)

manifesto_raw <- read_csv("manifesto-parties.csv")
manifesto_share <- read_csv("manifesto-share.csv")

manifesto <- manifesto_raw %>% select(-country) %>% inner_join(manifesto_share)

# add Party Facts country codes
country_custom <- c(`German Democratic Republic` = "DDR",
                    `Northern Ireland` = "NIR")

manifesto <- manifesto %>%
  mutate(country = countrycode(
    countryname, "country.name", "iso3c", custom_match = country_custom
    ),
    dummy_nir = if_else(countryname == "NIR", 1, 0),
    countryname = case_when(
      countryname == "NIR" ~ "GBR",
      TRUE ~ countryname
    )
  )

if(any(is.na(manifesto$country))) {
  warning("Country name clean-up needed")
}

# replace party short longer than 25 chars
manifesto[nchar(manifesto$abbrev) > 25 & ! is.na(manifesto$abbrev), "abbrev"] <- NA

write_csv(manifesto, "manifesto.csv", na = "")
