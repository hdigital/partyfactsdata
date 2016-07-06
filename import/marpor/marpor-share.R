library("dplyr")

marpor <- read.csv("source__MPDataset_MPDS2015a.csv", fileEncoding = "cp1252", as.is = TRUE)

pa_share <- marpor %>%
  mutate(year = date %/% 100) %>%
  group_by(party) %>%
  mutate(pervote_max = max(pervote, na.rm = TRUE)) %>%
  filter(pervote == pervote_max) %>%
  distinct(party, .keep_all = TRUE) %>%
  mutate(pervote_max = round(pervote_max, 1)) %>%
  arrange(countryname, party) %>%
  select(party, pervote_max_year = year, pervote_max)

write.csv(pa_share, "marpor-share.csv", na="", row.names = FALSE, fileEncoding = "utf-8")
