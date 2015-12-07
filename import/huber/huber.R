library('dplyr')

rm(list = ls())

# reading huber data and renaming 'id' to 'party_id'
party_raw <- read.csv('huber_inglehart_1995.csv', as.is=TRUE)
party <- party_raw %>% rename(party_id=id)

# reading contry data and convert 'country_name' to upper-case characters
country_raw <- read.csv('../country.csv', fileEncoding = 'utf-8', as.is=TRUE)
country <- country_raw %>%
  rename(country_name_short = name_short) %>%
  mutate(country = toupper(name))

# merging country and huber data to get 'country_name_short'
party <- party %>% left_join(country %>% select(country_name_short, country), by='country')

# adding missing country abbreviations
country_update <- list('BRITAIN'='GBR', 'SOUTH KOREA'='KOR', 'USA'='USA')
for (to_update in names(country_update)) {
  party[party$country == to_update, 'country_name_short']  <- country_update[[to_update]]
}
if(any(is.na(party$country_name_short))) warning("Not all observations have country keys")

# creating the csv file
write.csv(party, 'huber.csv', na='', fileEncoding='utf-8', row.names = FALSE)
