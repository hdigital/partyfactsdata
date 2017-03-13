library("dplyr")

marpor <- read.csv("source__MPDataset_MPDS2016b.csv", fileEncoding = "utf-8", as.is = TRUE) %>%
  select(party, country, countryname, date, pervote) %>%
  bind_rows(read_csv("source__MPDataset_MPDSSA2016b.csv")) %>%
  select(party, country, countryname, date, pervote)

pa_share <- marpor %>%
  mutate(year = date %/% 100) %>%
  group_by(party) %>%
  mutate(pervote_max = max(pervote, na.rm = TRUE)) %>%
  filter(pervote == pervote_max) %>%
  distinct(party, .keep_all = TRUE) %>%
  mutate(pervote_max = round(pervote_max, 1)) %>%
  arrange(party) %>%
  select(party, pervote_max_year = year, pervote_max)

write.csv(pa_share, "marpor-share.csv", na="", row.names = FALSE, fileEncoding = "utf-8")
