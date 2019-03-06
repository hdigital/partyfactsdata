library(tidyverse)


gloelec_raw <- read_csv("gloelec-parties.csv")

gloelec <- 
  gloelec_raw %>% 
  filter(vote_share >= 5.0) %>% 
  mutate(country_short = ifelse(country_short == "CSK", "CZE", country_short)) %>% 
  rename(share_vote = vote_share) %>% 
  select(-seats, -TotalSeats)

any(duplicated(gloelec$party_id))   # check for duplicates

write_csv(gloelec, "gloelec.csv", na = "")
