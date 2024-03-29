library(tidyverse)
library(countrycode)

rm(list = ls())

pa_ess <- read_csv("ess-parties/ess-parties.csv")

url <- "https://docs.google.com/spreadsheets/d/e/2PACX-1vShN6niFbUoafOKmngESbROIHBIyvzVP_H7FXU5COSnQRb_YgYjZq24iv27Emj_kZAu5EBndMnSJrAa/pub?output=csv"
pa_sheet <- read_csv(url)
write_csv(pa_sheet, "ess-sheet.csv", na = "")

if( ! all(pa_ess$ess_key %in% pa_sheet$ess_key)) {
  warning("Not all ESS keys in Google Sheet party list")
}

pa_years <- pa_ess %>%
  mutate(party_id = sprintf("%s-%d-%d", cntry, essround, ess_id)) %>%
  mutate_at(vars(essround, ess_first, ess_last), funs(. * 2 + 2000)) %>%
  select(share_year=essround, share, ess_first, ess_last, party_id, ess_key)

pa_dup <- pa_sheet %>%
  group_by(duplicate) %>%
  summarise(duplicate_ids = paste0(party_id, collapse = " ")) %>%
  rename(party_id = duplicate)

pa_out <- pa_sheet %>%
  filter(is.na(duplicate), is.na(ignore)) %>%
  mutate(country = countrycode(cntry, "iso2c", "iso3c"),
         country = replace(country, stringr::str_detect(ess_key, "\\(nir\\)$"), "NIR")) %>%
  select(-duplicate, -ignore, -party) %>%
  left_join(pa_dup) %>%
  left_join(pa_years)

write_csv(pa_out, "ess.csv", na = "")
