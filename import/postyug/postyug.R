library(tidyverse)

elec_raw <- read_csv("source__election-results.csv")

pa_info <-
  elec_raw %>%
  distinct(country, party_key, .keep_all = TRUE) %>%
  select(country, party_key, name_english=party_name_english,
         name=party_name_source, partyfacts_id)

pa_years <-
  elec_raw %>%
  group_by(country, party_key) %>%
  summarise(
    year_first = min(year, na.rm = TRUE),
    year_last = max(year, na.rm = TRUE)
  )

pa_size <-
  elec_raw %>%
  group_by(country, party_key) %>%
  mutate(share_max = max(share, na.rm = TRUE)) %>%
  filter(share == share_max) %>%
  select(country, party_key, share_max, share_year = year)

pa_out <-
  pa_info %>%
  left_join(pa_years) %>%
  left_join(pa_size) %>%
  mutate(
    party_id = paste(country, party_key, sep = "-"),
    country = case_when(
      str_detect(country, "^BIH-") ~ "BIH",
      country == "KOS" ~ "XKX",
      country == "SER" ~ "SRB",
      TRUE ~ country)
    ) %>%
  rename(name_short = party_key)

write_csv(pa_out, "postyug.csv", na = "")
