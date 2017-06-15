library(tidyverse)

marpor <- read_csv("source__MPDataset_MPDS2016b.csv")

pa_share <- marpor %>%
  select(party, country, countryname, date, pervote) %>%
  mutate(year = date %/% 100) %>%
  group_by(party) %>%
  mutate(pervote_max = max(pervote, na.rm = TRUE)) %>%
  filter(pervote == pervote_max) %>%
  distinct(party, .keep_all = TRUE) %>%
  mutate(pervote_max = round(pervote_max, 1)) %>%
  arrange(party) %>%
  select(party, pervote_max_year = year, pervote_max)

write_csv(pa_share, "marpor-share.csv", na = "")
