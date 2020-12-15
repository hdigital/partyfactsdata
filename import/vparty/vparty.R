library(tidyverse)

# use Base R csv-import to avoid readr import issues
raw_vparty <- read.csv("source__V-Dem-CPD-Party-V1.csv", na = "", encoding="UTF-8")


vparty <-
  raw_vparty %>%
  select(country_text_id, v2pashname, v2paenname, year,
         v2pavote, v2paseatshare, v2paid, pf_party_id) %>%
  mutate(share = if_else(is.na(v2pavote), v2paseatshare, v2pavote)) %>%
  group_by(v2paid) %>%
  mutate(
    year_first = min(year, na.rm = T),
    year_last = max(year, na.rm = T)
  ) %>%
  arrange(-share) %>%
  slice(1L) %>%
  select(
    country = country_text_id,
    name_short = v2pashname,
    name_english = v2paenname,
    year_first,
    year_last,
    share,
    share_year = year,
    party_id = v2paid
  ) %>% 
  mutate(
    country = if_else(country == "VDR", "VNR", country),
    partyfacts_id = if_else(str_detect(name_english, "alliance:"), NA_integer_, party_id)
    )

vparty$party_id %>% duplicated() %>% any()

write_csv(vparty, "vparty.csv", na = "")
