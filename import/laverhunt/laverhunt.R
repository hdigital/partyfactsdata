library(tidyverse)

lh_raw <- read_csv("source__laver_hunt_1992/laver_hunt_1992.csv")

lh <- 
  lh_raw %>% 
  select(country:partyname) %>% 
  distinct() %>% 
  arrange(country, party) %>% 
  group_by(country) %>% 
  mutate(party_id = paste(country, party, sep = "-"))

duplicated(lh$party_id) %>% any()

write_csv(lh, "laverhunt.csv")
