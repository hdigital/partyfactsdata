library('dplyr')

ees <- read.csv('parties-ees-ches-ess.csv', fileEncoding = 'utf-8', as.is=TRUE)

country <- read.csv('../country.csv', fileEncoding = 'utf-8', as.is=TRUE)
country <- country %>% select(iso2, country_iso3 = iso3)

ees[ees$country == 'UK', 'country'] <- 'GB'
ees <- ees %>% left_join(country, by = c('country' = 'iso2'))

write.csv(ees, 'ees14.csv', na='', fileEncoding = 'utf-8', row.names = FALSE)
