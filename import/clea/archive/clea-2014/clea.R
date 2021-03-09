library(dplyr)

party_raw <- read.csv("clea_national_party.csv", fileEncoding = 'utf-8', as.is = TRUE)

## Adding party names from CLEA Appendix II

name <-read.csv("source__clea/appendix_II/clea-appendix_II.csv", fileEncoding = 'utf-8', as.is = TRUE)
name <- name %>%
  select(-row) %>%
  mutate(country = replace(country, country == "United Kingdom", "UK"),
         country = replace(country, country == "United States of America", "US"))                

party <- party_raw %>% left_join(name, by = c("ctr_n"="country", "pty"="code"))

## Adding Party Facts country codes

pf_country <-read.csv("../country.csv", fileEncoding = 'utf-8', as.is = TRUE)
pf_country <- pf_country %>%
  rename(country = name_short) %>%
  select(country, iso_numeric)

party <- party %>% left_join(pf_country, by = c("ctr" = "iso_numeric"))

# recode country for unknown or missing values
party <- party %>% mutate(country = replace(country, ctr %in% c(841:843), "USA"))
country_recode <- c("TWN" = 1001, "XKX" = 1002, "SOM" = 1003)
for(country_select in names(country_recode)) {
  party <- party %>% mutate(country = replace(country, ctr == country_recode[[country_select]], country_select))
}
party %>% filter(is.na(country) | ! country %in% pf_country$country) %>% select(ctr_n, ctr) %>% distinct()

## Data for Party Facts import

write.csv(party, 'clea.csv', na='', fileEncoding = "utf-8", row.names = FALSE)
