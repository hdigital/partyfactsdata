library(tidyverse)


load("source__cses_imd.rdata")

cses_cb <- read.csv("cses-codebook.csv") %>%
  mutate(
    party_id = as.numeric(str_remove(party_id, "\\#"))
  )

cses <- cses_imd %>%
  select(IMD1006_NAM, IMD1008_YEAR, IMD3002_LH_PL) %>%
  left_join(cses_cb, by = c("IMD3002_LH_PL" = "party_id")) %>%
  drop_na(country) %>%
  group_by(country, IMD1008_YEAR) %>%
  mutate(
    total_number = n()
  ) %>%
  group_by(country, IMD1008_YEAR, IMD3002_LH_PL) %>%
  mutate(
    number = n(),
    share = round(number / total_number * 100, 2)
  ) %>%
  ungroup() %>%
  select(
    country_short, party_short, party_name, IMD1008_YEAR, share,
    IMD3002_LH_PL, comment, polity_notes
  ) %>%
  distinct() %>%
  group_by(IMD3002_LH_PL) %>%
  mutate(
    share_max = max(share),
    year_first = min(IMD1008_YEAR),
    year_last = max(IMD1008_YEAR)
  ) %>%
  slice(1L) %>%
  ungroup() %>%
  filter(share == share_max) %>%
  filter(share >= 1) %>%
  select(
    country_short, party_short, party_name, year_first, year_last, IMD1008_YEAR,
    share, IMD3002_LH_PL, comment, polity_notes
  )


## rename columns
colnames(cses) <- c(
  "country", "name_short", "name_english", "year_first", "year_last",
  "share_year", "share", "party_id", "comment", "polity_note"
)


## check for duplicated IDs
duplicated(cses$party_id) %>% any()


## write csv
write.csv(cses, "cses.csv", fileEncoding = "UTF-8", na = "", row.names = FALSE)
