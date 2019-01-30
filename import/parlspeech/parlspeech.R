library(tidyverse)
library(glue)

ps_all <- read_csv("parlspeech-mps.csv")

# summarize party information from ParlSpeech
ps_party <- ps_all %>% 
  mutate(
    party = case_when(
      country == "SWE" & party == "L" ~ "FP",
      country == "SWE" & party == "T" ~ "KD",
      TRUE ~ party
      ),
    party_id = glue("{country}-{party}")
    ) %>% 
  group_by(party_id, country, party) %>% 
  summarise(
    year_first = str_extract(date_first, "\\d*") %>% min(), 
    year_last = str_extract(date_last, "\\d*") %>% max()
    ) %>%
  arrange(country, party, year_first)

write_csv(ps_party, "parlspeech.csv")
