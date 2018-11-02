library(tidyverse)

ess_pa_raw <- read_csv("ess.csv")
ess_sh_raw <- read_csv("ess-sheet.csv")
ess_round_raw <- read_csv("ess-parties/ess-parties-round.csv")

ess_sh <- 
  ess_sh_raw %>% 
  mutate(
    party_id = ifelse(is.na(duplicate), party_id, duplicate),
    ess_key = paste(cntry, party, sep = " -- ") %>% tolower(),
    name_check = paste(party_short, party_name, party_english),
    name_check = str_replace_all(name_check, " *NA *", " "),
    name_check = str_replace_all(name_check, "^ | +| $", " ")
  ) %>% 
  select(party_id, ess_key, name_check)

ess_out <- 
  ess_round_raw %>% 
  mutate(ess_key = paste(cntry, party, sep = " -- ") %>% tolower()) %>% 
  left_join(ess_sh) %>% 
  select(-ess_key, -n)

all(ess_pa_raw$party_id %in% ess_out$party_id)

write_csv(ess_out, "ess-round-merge.csv")
