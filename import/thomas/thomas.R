library("dplyr")

thomas_raw <- read.csv("thomas-parties.csv", fileEncoding = "utf-8", as.is = TRUE)
country_raw <- read.csv("../country.csv", fileEncoding = "utf-8", as.is = TRUE)

# remove 'status quo' information
thomas <- thomas_raw %>% filter(party != "Status quo")

# replace UK and RUS with proper country names
thomas$country[thomas$country == "Great Britain"] <- "United Kingdom"
thomas$country[thomas$country == "USSR"] <- "Russia"

# aggregate parties first and last year
thomas <- thomas %>%
  group_by(country, party) %>%
  summarise(year_first = min(time), year_last = max(time)) %>% 
  ungroup()

# get country name iso shortcut
country <- country_raw %>% select(country_short = name_short, country = name)
thomas <- thomas %>%
  left_join(country) %>%
  arrange(country, party) %>% 
  mutate(id = row_number())

write.csv(thomas, "thomas.csv", na = "", row.names = FALSE, fileEncoding = "utf-8")
