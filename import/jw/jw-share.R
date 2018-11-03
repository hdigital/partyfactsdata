library(tidyverse)

library(haven)

if( ! exists("jw_raw")) {
  jw_raw <- read_dta("source__Jennings_Wlezien_2018.dta.zip", encoding = "latin1")
}

party <- 
  jw_raw %>% 
  filter(election == "Legislative") %>% 
  group_by(countryid, partyid) %>% 
  mutate(
    share_max = max(vote_, na.rm = TRUE),
    year = substr(polldate, 1, 4),
    year_first = min(year, na.rm = TRUE),
    year_last = max(year, na.rm = TRUE)
    ) %>% 
  filter(vote_ == share_max) %>% 
  distinct(countryid, partyid, .keep_all = TRUE) %>%
  ungroup() %>% 
  mutate(share_max = round(share_max, 1)) %>% 
  select(country, countryid, partyid, year_first, year_last, share_year = year, share_max)

write_csv(party, "jw-share.csv")
