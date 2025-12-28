library(tidyverse)
library(readxl)
library(countrycode)

epac_raw <- read_excel("epac-parties-2016.xlsx")
write_csv(epac_raw, "epac-parties-2016.csv", na = "")

# add Party Facts country codes
epac <- epac_raw %>%
  mutate(
    country = countrycode(
      country_name,
      "country.name",
      "iso3c",
      custom_match = c(Kosovo = "XKX")
    ),
    seat = round(seat, 1)
  )
if (any(is.na(epac$country))) {
  warning("Country name clean-up needed")
}

epac_2014_raw <- read_csv("import-2014/epac.csv")

epac_2014_add <- epac_2014_raw %>%
  rename(
    country = country_name_short,
    country_name = country,
    party_id = id,
    party_accr = accronym,
    party_name_en = party_name_english
  ) %>%
  mutate(round = 2011, pec = NA, elecyear = NA) %>%
  filter(!party_id %in% epac$party_id)

epac <- epac %>% bind_rows(epac_2014_add) %>% arrange(party_id)

write.csv(epac, "epac.csv", na = "", fileEncoding = "utf-8", row.names = FALSE)
