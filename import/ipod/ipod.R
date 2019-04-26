library(tidyverse)
library(countrycode)


## Load raw dataset ----

load("source__data_ipod.RData")
raw_ipod <- data_ipod
rm(data_ipod)


## Party Facts based link file for ParlGov IDs ----

if(FALSE) {
  pf_ext <- read_csv("source__partyfacts-external-parties.csv") %>%
    filter(dataset_key == "parlgov") %>%
    select(parlgov_id = dataset_party_id, partyfacts_id) %>% 
    write_csv("partyfacts-parlgov-ids.csv")
}

pf_ext <- read_csv("partyfacts-parlgov-ids.csv")
  

## Extract information ----

ipod <- raw_ipod %>%
  select(
    country_id, country_name, party_id, party_name_english, cmp, vote_share,
    seats, seats_total, election_date, year
  ) %>%
  mutate(
    share = if_else(
      is.na(vote_share),
      seats / seats_total * 100,
      vote_share
    ),
    share = round(share, 1),
    country = countrycode(
      country_name,
      origin = "country.name",
      destination = "iso3c"
    )
  )

ipod_party <- ipod %>% 
  group_by(party_id) %>%
  mutate(
    year_first = min(year),
    year_last = max(year),
    share_max = max(share, na.rm = TRUE),
    share_year = year
  ) %>%
  ungroup() %>%
  filter(share == share_max) %>%
  select(
    country, party_id, party_name_english, year_first,
    year_last, share, share_year
  )


## Final data ----

ipod_compl <- ipod_party %>% 
  left_join(pf_ext, by = c("party_id" = "parlgov_id")) %>%
  filter(share >= 1) %>% 
  distinct(party_id, .keep_all = TRUE)

write.csv(ipod_compl, "ipod.csv", fileEncoding = "UTF-8", row.names = FALSE, na = "")
