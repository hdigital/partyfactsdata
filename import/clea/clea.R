library(dplyr)
library(readr)
library(countrycode)

party_raw <- read_csv("source__clea/clea_20161024_appendix_II.csv")

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
                            custom_match = c(Kosovo='XKX', Zambia='ZWB')))
if(any(is.na(party$country))) {
  warning("Country name clean-up needed")
}

# clean-up CLEA data for import
party[nchar(party$abbr) > 25 & ! is.na(party$abbr), "abbr"] <- NA
party[party$ctr_pty == 380000035, "name_english"] <- NA

write.csv(party, 'clea.csv', na='', fileEncoding = "utf-8", row.names = FALSE)
