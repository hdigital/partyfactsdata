library(tidyverse)

manifesto <- read_csv("source__MPDataset_MPDS2018a.csv", guess_max = 100000) %>%
  select(party, country, countryname, date, pervote) %>%
  bind_rows(read_csv("source__MPDataset_MPDSSA2018a.csv", guess_max = 100000) %>% 
              mutate(pervote = if_else(is.na(pervote), presvote, pervote)) %>%
              select(party, country, countryname, date, pervote))

pa_share <- manifesto %>%
  select(party, country, countryname, date, pervote) %>%
  mutate(year = date %/% 100) %>%
  group_by(party) %>%
  mutate(pervote_max = max(pervote, na.rm = TRUE)) %>%
  filter(pervote == pervote_max | (is.na(pervote) & is.infinite(pervote_max))) %>%
  distinct(party, .keep_all = TRUE) %>%
  mutate(pervote_max = if_else(!is.infinite(pervote_max), round(pervote_max, 1), NA_real_)) %>%
  arrange(party) %>%
  select(party, pervote_max_year = year, pervote_max)

write_csv(pa_share, "manifesto-share.csv", na = "")
