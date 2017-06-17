library(tidyverse)
library(stringr)
library(countrycode)

clea_version <- "20170530"

path <- str_interp("source__clea/clea_${clea_version}/clea_${clea_version}_appendix_II.csv")
party_raw <- read_csv(path)
vote <- read_csv("clea-national-vote.csv")

# add CLEA data variable names to party information and clean-up data for import
party <- party_raw
names(party) <- c("ctr_n", "pty", "abbr", "name", "name_english", "information")

# vote %>% filter( ! ctr_n %in% party$ctr_n) %>% distinct(ctr_n)
vote <- vote %>%
  mutate(ctr_n = recode(ctr_n, Comoros="The Comoros", UK="United Kingdom",
                               US="United States of America"))

# add time and size information and select larger parties
party <- party %>%
  mutate(pty = as.integer(str_extract_all(pty, "\\d+"))) %>%
  inner_join(vote)

# add Party Facts country codes
party <- party %>%
  mutate(country = countrycode(ctr_n, "country.name", "iso3c",
                            custom_match = c(Kosovo="XKX", Zambia="ZMB")))
if(any(is.na(party$country)) | ! all(vote$ctr_n %in% party$ctr_n)) {
  warning("Country name clean-up needed")
}

# clean-up CLEA data for import
party[nchar(party$abbr) > 25 & ! is.na(party$abbr), "abbr"] <- NA

write_csv(party, "clea.csv", na = "")
