library(tidyverse)

ccs_parties <- read_csv("ccs-parties.csv")                      # harmonized party list
pf_tech <- read_csv("pf-technical.csv") %>% select(-country)    # pf-core with only technicals

# wide dataset of CCS party IDs
ccs_party_id <- read_csv("ccs-parties-all.csv") %>% 
  select(partyfacts_id, party_id) %>% 
  group_by(partyfacts_id) %>% 
  mutate(wave = paste0("party_id_", row_number())) %>% 
  spread(wave, party_id) %>% 
  ungroup()

# combine all information
ccs <- ccs_parties %>% 
  select(-party_id) %>% 
  left_join(ccs_party_id, by = "partyfacts_id") %>% 
  left_join(pf_tech, by = "partyfacts_id") %>% 
  filter(is.na(technical)) %>%                        # filter technicals
  select_if(~sum(!is.na(.)) > 0)                      # drop empty columns

write_csv(ccs, "ccs.csv", na = "")
