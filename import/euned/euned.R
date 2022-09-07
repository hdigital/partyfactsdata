library(tidyverse)
library(countrycode)

file_in <- read_csv("source__euned.csv", na = "NA")

euned <-
  file_in %>% 
  mutate(party_id = paste(country, party_abbreviation, sep = "-"))

euned$dup <- duplicated(euned$party_id)

file_out <-
  euned %>% 
  mutate(
    dup = as.character(dup),
    party_abbreviation = if_else(str_length(party_abbreviation) >= 25, NA_character_, party_abbreviation),
    country = case_when(
      country == "ROM" ~ "ROU",
      country == "LAT" ~ "LVA",
      country == "IRE" ~ "IRL",
      country == "DKN" ~ "DNK",
      T ~ country
    ),
    partyfacts_id = case_when(
      partyfacts_id == 469 ~ NA_real_,
      partyfacts_id == 2172 ~ NA_real_,
      T ~ partyfacts_id
    )
  ) %>% 
  filter(dup == "FALSE")

write_csv(file_out, "euned.csv", na = "")  

