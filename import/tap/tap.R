library(tidyverse)

raw_tap <- read_csv("source__TAP.csv", na = "")

# wide to long format
tap_temp1 <-
  raw_tap %>%
  gather(key = "year", value = "vote_share", "1980":"2020") %>%
  group_by(COUNTRY, `FULL PARTY NAME`) %>%
  mutate(
    vote_share = as.numeric(vote_share),
    share = max(vote_share, na.rm = TRUE),
    share_year = if_else(share == vote_share, year, NA_character_)
  ) %>%
  ungroup() %>%
  select(COUNTRY, PARTY, `FULL PARTY NAME`, FOUNDED, DISBANDED, share, share_year) %>%
  drop_na(share_year)


tap_temp2 <-
  tap_temp1 %>%
  rename(
    country = COUNTRY,
    name_short = PARTY,
    name = `FULL PARTY NAME`,
    year_first = FOUNDED,
    year_last = DISBANDED
  ) %>%
  mutate(
    name_short = if_else(str_detect(name_short, fixed("?")), NA_character_, name_short),
    party_id = if_else(is.na(name_short),
      str_extract_all(name, "[A-Z]") %>% map_chr(paste, collapse = ""),
      name_short
    ),
    party_id = paste(country, party_id)
  ) %>%
  distinct(country, name, .keep_all = TRUE)


tap <-
  tap_temp2 %>%
  mutate(
    country = case_when(
      country == "BUL" ~ "BGR",
      country == "CRO" ~ "HRV",
      country == "DEN" ~ "DNK",
      country == "GRE" ~ "GRC",
      country == "GER" ~ "DEU",
      country == "ICE" ~ "ISL",
      country == "IRE" ~ "IRL",
      country == "LAT" ~ "LVA",
      country == "LIT" ~ "LTU",
      country == "NET" ~ "NLD",
      country == "POR" ~ "PRT",
      country == "ROM" ~ "ROU",
      country == "SER" ~ "SRB",
      country == "SLK" ~ "SVK",
      country == "SLN" ~ "SVN",
      country == "SWI" ~ "CHE",
      country == "UK" ~ "GBR",
      T ~ country
    )
  ) %>%
  filter(share >= 1) %>%
  arrange(country, name)

write_csv(tap, "tap.csv", na = "")
