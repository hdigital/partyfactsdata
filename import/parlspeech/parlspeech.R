library(tidyverse)
library(lubridate)

ps_all <- read_csv("parlspeech-mps.csv")

# clean-up ParlSpeech MP data
ps_clean <- 
  ps_all %>% 
  rename(country = iso3country) %>% 
  mutate(
    country = case_when(
      country == "AUS" ~ "AUT",
      country == "DNK" & party %in% c("IA", "NQ") ~ "GRL",
      country == "DNK" & party %in% c("FF", "T", "JF") ~ "FRO",
      TRUE ~ country
    ), # LH, UP
    party = case_when(
      country == "SWE" & party == "L" ~ "FP",
      country == "SWE" & party == "T" ~ "KD",
      TRUE ~ party
      ),
    party_id = glue::glue("{country}-{party}")
    )

# summarize party information from ParlSpeech
ps_party <- 
  ps_clean %>% 
  filter( ! is.na(party)) %>% 
  group_by(party_id, country, party) %>% 
  summarise(
    year_first = year(date_first) %>% min(), 
    year_last = year(date_last) %>% max(),
    partyfacts_id = first(party.facts.id)  # rename needed for PF linking on import
    ) %>%
  arrange(country, party, year_first)

write_csv(ps_party, "parlspeech.csv", na = "")
