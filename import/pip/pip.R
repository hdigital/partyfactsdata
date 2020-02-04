library(tidyverse)
library(countrycode)


## load PIP
raw_pip <- read.csv("source__pip_ts.csv")


## load external Party Facts information
partyfacts <- read.csv("https://partyfacts.herokuapp.com/download/external-parties-csv/") %>%
  filter(dataset_key == "manifesto") %>%
  mutate(
    dataset_party_id = as.numeric(as.character(dataset_party_id))
  ) %>%
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

pip <- 
  pip_temp %>% 
  select(country, name_english, year_first, year_last, p101, p102, partyfacts_id) %>%
  distinct() %>% 
  filter(!is.na(p102) | !is.na(name_english)) %>% 
  group_by(p101) %>% 
  arrange(p102) %>% 
  slice(1L) %>% 
  ungroup() %>% 
  filter(p102 != "NONA" | is.na(p102))


## rename columns
colnames(pip) <- c(
  "country", "name_english", "year_first", "year_last", "party_id", "name_short", "partyfacts_id"
)


## check duplicated party_id
duplicated(pip$party_id) %>% any()


## write csv
write.csv(pip, "pip.csv", fileEncoding = "UTF-8", na = "", row.names = FALSE)
