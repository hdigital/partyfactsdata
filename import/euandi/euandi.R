library(tidyverse)
library(countrycode)

euandi_raw <- read_csv("euandi-parties.csv")

euandi <-
  euandi_raw %>% 
  mutate(
    country = str_extract(ZA5970_Codebook, "[:alpha:]*"),
    country = case_when(
      country == "United" ~ "United Kingdom",
      country == "Czech" ~ "Czech Republic",
      TRUE ~ country
      ),
    country_short = countrycode(country, origin = "country.name", destination = "iso3c",
                                custom_match = c("Flanders" = "BEL", "Walonia" = "BEL")),
    name_short = str_extract(ZA5970_Codebook, "(?<=\\)[:space:])[[:alpha:][:alnum:]]*"),
    name = str_extract(ZA5970_Codebook, "(?<=\\)[:space:]).*"),
    name = str_extract(name, "(?<=[:space:]).*"),
    party_id = paste(country_short, name_short, sep = "-")
    ) %>% 
  select(-ZA5970_Codebook)

write_csv(euandi, "euandi.csv")
