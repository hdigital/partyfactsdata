library(tidyverse)
library(countrycode)


country_ignore <- c("Bahrain", "Qatar", "Saudi Arabia", "United Arab Emirates")
names_file <- "chisols-names.csv"


## Read data ----

party_raw <- read_csv("chisols-party.csv")

if (!file.exists(names_file)) {
  url <- "https://docs.google.com/spreadsheets/d/1qqwhoQGkPWGdwdGfSx49hScsO0bLtSDNCS20hcJFLhk/pub?output=csv"
  download.file(url, names_file, mode = "wb")
}
party_name <- read_csv(names_file)

leader_first <- read_csv("chisols-leader-first.csv")


## Clean-up data ----

country_custom = c(
   Czechoslovakia = "CZE",
  `German Democratic Republic` = "DDR",
   Kosovo = "XKX",
  `Republic of Vietnam` = "VNR",
  `Yemen Arab Republic` = "YEM",
  `Yemen People's Republic` = "YMD",
   Yugoslavia = "SRB"
)

party_all <-
  party_raw %>%
  rename(party = affiliation) %>% 
  filter(! statename %in% country_ignore) %>%  # ignore countries with no parties
  left_join(leader_first) %>% 
  mutate(country = countrycode(statename, "country.name", "iso3c", custom_match = country_custom))


## Final data ----

re_exclude <- "^mil|non-party|dynasty|house|unknown$"

party_out <-
  party_all %>%
  left_join(party_name %>% distinct(country, party, name_english, name)) %>%
  mutate(party_id = paste(country, party, sep = "-")) %>%
  filter(! str_detect(tolower(party), re_exclude)) %>%
  select(-party_id, everything()) %>% 
  relocate(chisols_first, .after = name) %>% 
  distinct(party_id, .keep_all = TRUE)

write.csv(party_out, "chisols.csv", na = "", row.names = FALSE)
