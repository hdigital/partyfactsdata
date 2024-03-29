library(tidyverse)
library(countrycode)


## load PIP
raw_pip <- read_csv("source__pip_ts_csv.zip", locale = locale(encoding = "latin1"))


if(FALSE) {
  # make copy of Party Facts and Manifesto link file
  pf_raw <-
    read_csv("https://partyfacts.herokuapp.com/download/external-parties-csv/") %>%
    filter(dataset_key == "manifesto") %>%
    mutate(dataset_party_id = as.numeric(as.character(dataset_party_id))) %>%
    select(dataset_party_id, name_english, partyfacts_id)

  write_csv(pf_raw, "pf-manifesto-ids.csv")
}

## load external Party Facts information
partyfacts <- read_csv("pf-manifesto-ids.csv")


## keep only observation with already linked manifesto_id
## 71 of 624 observations have no partyfacts_id
## 553 of 624 observations have already a partyfacts_id
## party name is from Party Facts
pip_temp <-
  raw_pip %>%
  filter(p118 != 0 & !is.na(p118)) %>%
  select(g102, g103, p101, p102) %>%
  left_join(partyfacts, by = c("p101" = "dataset_party_id")) %>%
  group_by(p101) %>%
  mutate(
    country = countrycode(g102, origin = "country.name", destination = "iso3c"),
    year_first = min(g103),
    year_last = max(g103),
    p102 = if_else(p102 == "", NA_character_, as.character(p102))
  ) %>%
  ungroup()

pip_temp_2 <-
  pip_temp %>%
  select(country, name_short=p102, name_english, year_first, year_last, party_id=p101, partyfacts_id) %>%
  distinct() %>%
  filter(!is.na(name_short) | !is.na(name_english))

pip <-
  pip_temp_2 %>%
  group_by(party_id) %>%
  arrange(name_short) %>%
  slice(1L) %>%
  ungroup() %>%
  filter(name_short != "NONA" | is.na(name_short)) %>%
  arrange(country, name_english)


## check duplicated party_id
duplicated(pip$party_id) %>% any()


## write csv
write_csv(pip, "pip.csv", na = "")
