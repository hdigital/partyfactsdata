library(tidyverse)

## Read data ----

raw_elecglob <-
  read_csv("source__elections-global-release.csv", na = "")

pf_core <-
  read_csv("partyfacts-core-parties.csv") %>%
  select(partyfacts_id, technical, name_short)


## Clean-up ----

elecglob_a <-
  raw_elecglob %>%
  mutate(
    partyfacts_country = case_when(
      country == "HKG" ~ "HKG",
      country == "ZZB" ~ "ZZB",
      TRUE ~ partyfacts_country
      ),
    seat_share = round(seats / seats_total * 100, 1),
    share = if_else(is.na(vote_share), seat_share, vote_share)
  ) %>% 
  select(partyfacts_country, party, year, share, paris_id, partyfacts_id)

elecglob_b <- 
  elecglob_a %>% 
  group_by(partyfacts_country, party) %>%
  mutate(
    year_first = min(year, na.rm = T),
    year_last = max(year, na.rm = T)
  ) %>%
  arrange(-share) %>%
  slice(1L) %>%
  ungroup()

elecglob_c <- 
  elecglob_b %>% 
  arrange(partyfacts_country) %>%
  select(
    country = partyfacts_country,
    name_english = party,
    year_first,
    year_last,
    share,
    year_share = year,
    paris_id,
    partyfacts_id
  )


## Final data ----

elecglob <-
  elecglob_c %>%
  left_join(pf_core) %>%
  filter(is.na(technical) | technical %in% c(8, 15)) %>%
  select(-partyfacts_id, -technical) %>% 
  group_by(paris_id) %>% 
  slice(1L) %>% 
  ungroup()


elecglob$paris_id %>% duplicated() %>% any()


write_csv(elecglob, "elecglob.csv", na = "")

