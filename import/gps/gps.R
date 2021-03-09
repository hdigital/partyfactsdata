library(tidyverse)


raw_gps <- 
  read_csv("source__Global Party Survey by Party SPSS V2_1_Apr_2020-2.csv", na = "")

gps <- 
  raw_gps %>% 
  select(
    country = ISO, 
    name_short = Partyabb, 
    name_english = Partyname,
    year = Elec_year,
    share = PartyPerVote,
    party_id = ID_GPS,
    ) %>% 
  mutate(
    share = round(share, 1),
    country = case_when(
      country == "MAC" ~ "MKD",
      TRUE ~ country
    ))

duplicated(gps$party_id) %>% any()

write_csv(gps, "gps.csv", na = "")
