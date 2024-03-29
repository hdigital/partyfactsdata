library(tidyverse)
library(countrycode)

file_in <- readxl::read_xls("source__TAESD_Thin_Antiestablishment_Supply_Dataset_V_1_0_1220_xls.xls", na = "")

file_out <-
  file_in %>%
  group_by(id) %>%
  mutate(
    countrycode = countrycode(country, "iso2c", "iso3c"),
    year = as.numeric(paste0(20, str_extract(year, "[:digit:]{2}"))),
    year_first = min(year, na.rm = T),
    year_last = max(year, na.rm = T),
    max_share = max(vote, na.rm = T),
    share_year = if_else(vote == max_share, year, NA_real_),
    max_share = round(max_share, 3) * 100,
  ) %>%
  filter(!is.na(share_year)) %>%
  select(countrycode, year_first, year_last, name_short = party, year, vote_share = max_share, party_id = id)


file_out$party_id %>% duplicated() %>% any()

write_csv(file_out, "taesd.csv", na = "")
