library(tidyverse)
library(countrycode)


## load PIP
raw_pip <- read_csv("source__pip_ts_csv.zip", locale = locale(encoding = "latin1"))


## load external Party Facts information
partyfacts <- 
  read.csv("https://partyfacts.herokuapp.com/download/external-parties-csv/") %>%
  filter(dataset_key == "manifesto") %>%
  mutate(dataset_party_id = as.numeric(as.character(dataset_party_id))) %>%
  select(dataset_party_id, name_english, partyfacts_id)


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
  select(country, name_english, year_first, year_last, p101, p102, partyfacts_id) %>%
  distinct() %>% 
  filter(!is.na(p102) | !is.na(name_english))

pip <- 
  pip_temp_2 %>% 
  group_by(p101) %>% 
  arrange(p102) %>% 
  slice(1L) %>% 
  ungroup() %>% 
  filter(p102 != "NONA" | is.na(p102)) %>% 
  rename(party_id = p101, name_short = p102)


## check duplicated party_id
duplicated(pip$party_id) %>% any()


## write csv
write_csv(pip, "pip.csv", na = "")