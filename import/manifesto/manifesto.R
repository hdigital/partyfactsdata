library(tidyverse)
library(countrycode)

manifesto <- read_csv("source__parties_MPDataset_MPDS2023a.csv", guess_max = 10000, show_col_types = FALSE) %>%
  mutate(across(c(max_pervote, max_presvote), ~round(.x, 1))) %>%
  select(countryname, party, abbrev,
         orig_name = name, partyname = name_english,
         min_year = year_min, max_year = year_max,
         pervote_max_year = year_max_pervote, pervote_max = max_pervote,
         presvote_max_year = year_max_presvote, presvote_max = max_presvote,
         is_alliance)

# add Party Facts country codes
country_custom <- c(`German Democratic Republic` = "DDR",
                    `Northern Ireland` = "NIR")

manifesto <- manifesto %>%
  mutate(country = countrycode(
    countryname, "country.name", "iso3c", custom_match = country_custom
  ),
  dummy_nir = if_else(country == "NIR", 1, 0),
  country = case_when(
    country == "NIR" ~ "GBR",
    TRUE ~ country
  )
  )

if(any(is.na(manifesto$country))) {
  warning("Country name clean-up needed")
}

# replace party short longer than 25 chars
manifesto[nchar(manifesto$abbrev) > 25 & ! is.na(manifesto$abbrev), "abbrev"] <- NA

write_csv(manifesto, "manifesto.csv", na = "")
