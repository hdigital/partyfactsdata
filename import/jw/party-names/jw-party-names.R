library(tidyverse)
library(readxl)

file_name <- "source__Jennings_Wlezien_2018.xlsx"

party_raw <- read_excel(file_name, sheet = "party")
country_raw <- read_excel(file_name, sheet = "country")

party <-
  party_raw %>%
  rename_all(~ .x %>% tolower() %>% str_replace(" ", "")) %>%
  rename(partyid = id) %>%
  select(-row)

country <-
  country_raw %>%
  rename_all(tolower) %>%
  select(countryid = id, country, -row)

party_out <-
  country %>%
  right_join(party) %>%
  arrange(country, partyname)


write_csv(party_out, "jw-party-names.csv")
