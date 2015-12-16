library('dplyr')

thomas_raw <- read.csv('thomas-parties.csv', fileEncoding='utf-8', as.is=TRUE)
country_raw <- read.csv('../country.csv', fileEncoding = 'utf-8', as.is = TRUE)

# Remove 'Status Quo' information
thomas <- filter(thomas_raw, party !="Status quo")

# Replace UK and RUS with proper country names
thomas$country[thomas$country == "Great Britain"] <- "United Kingdom"
thomas$country[thomas$country == "USSR"] <- "Russia"

# Aggregate parties first and last year
thomas <- group_by(thomas, country, party)
thomas <- mutate(thomas, year_first = min(time), year_last = max(time))
thomas <- ungroup(thomas)

# Get country name iso shortcut
country <- select(country_raw, name, name_short)
thomas <- left_join(thomas, country, by = c('country' = 'name'))

# Distinct parties and polish variables
thomas <- distinct(thomas, party)
thomas <- select(thomas, name = party, year_first, year_last, country, country_short = name_short)

write.csv(thomas, 'thomas.csv', na='', row.names = FALSE, fileEncoding='utf-8')