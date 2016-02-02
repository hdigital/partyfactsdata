library('dplyr')

thomas <- read.csv('thomas-parties.csv', fileEncoding='utf-8', as.is=TRUE)
country <- read.csv('../country.csv', fileEncoding = 'utf-8', as.is = TRUE)

# replace UK and RUS with proper country names
thomas$country[thomas$country == "Great Britain"] <- "United Kingdom"
thomas$country[thomas$country == "USSR"] <- "Russia"

thomas <- thomas %>%
  filter(party != "Status quo") %>%
  group_by(country, party) %>%
  summarise(year_first = min(time), year_last = max(time)) %>%
  left_join(country %>% select(name, name_short), by = c('country' = 'name')) %>%
  select(name = party, year_first, year_last, country, country_short=name_short)

thomas$id <- 1:nrow(thomas)

write.csv(thomas, 'thomas.csv', na='', row.names = FALSE, fileEncoding='utf-8')