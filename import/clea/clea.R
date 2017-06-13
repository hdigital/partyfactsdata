library(tidyverse)
library(stringr)
library(countrycode)

clea_version <- '20170530'

path <- str_interp("source__clea/clea_${clea_version}/clea_${clea_version}_appendix_II.csv")
party_raw <- read_csv(path)

# add CLEA data variable names to party information and clean-up data for import
party <- party_raw
names(party) <- c('ctr_n', 'pty', 'abbr', 'name', 'name_english', 'information')

# add time and size information and select larger parties
vote <- read_csv("clea-national-vote.csv")
party <- party %>%
  mutate(pty = as.integer(pty)) %>%
  inner_join(vote)

# add Party Facts country codes
party <- party %>%
  mutate(country = countrycode(ctr_n, 'country.name', 'iso3c',
                            custom_match = c(Kosovo='XKX', Zambia='ZMB')))
if(any(is.na(party$country))) {
  warning("Country name clean-up needed")
}

# clean-up CLEA data for import
party[nchar(party$abbr) > 25 & ! is.na(party$abbr), "abbr"] <- NA

write_csv(party, 'clea.csv', na = '')
