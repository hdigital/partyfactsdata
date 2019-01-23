library(tidyverse)
library(countrycode)

raw_laeda <- read_csv("source__multi_country_consolidates_lh_seats.csv")
laeda <- raw_laeda



colnames(laeda) <- c("country_name", "office_office", "date", "party_name_short", "party_name", "seats", "seats_total", "share1")

## Delete column 2
laeda <- laeda[,-2]

## added ISO3 
laeda <- laeda %>%
  mutate(country_short = countrycode(country_name, "country.name", "iso3c")) %>%
  arrange(country_name, party_name) %>%
  mutate(id = row_number())

## Sort columns
laeda <- laeda[,c(9,8,1,2,3,4,7,5,6)]

## Delete column "id" & "country_name"
laeda <- laeda[,-1]
laeda <- laeda[,-2]

## Time added
laeda <- laeda %>%
  mutate(share_year = substr(date, 8, 9))  %>%
  arrange(country_short, party_name) %>%
  mutate(id = row_number())

## Delete column "id"
laeda <- laeda[,-9]

## year added
laeda$share_year <- as.numeric(as.character(laeda$share_year))
laeda$share_year <- ifelse(laeda$share_year > 25, paste0(19, laeda$share_year), ifelse(laeda$share_year < 10, paste0(200, laeda$share_year), paste0(20, laeda$share_year)))


## vote_share added (without %)
laeda <- laeda %>%
  mutate(share = substr(share1, 1, 4))  %>%
  arrange(country_short, party_name) %>%
  mutate(id = row_number())

## Delete column "vote_share1"
laeda <- laeda[,-5]

## Delete column "id"
laeda <- laeda[,-9]

## Sort columns
laeda <- laeda[,c(1,7,2,3,4,8,5,6)]


## Aggregate parties max_share
share_laeda <- laeda %>%
  group_by(country_short, party_name_short, party_name) %>%
  mutate(max_share = max(share, na.rm = TRUE)) %>%
  filter(share == max_share) %>%
  distinct(party_name, party_name_short, .keep_all = TRUE) %>%
  ungroup()

## Aggregate parties first and last year (includes party_name_short)
year_laeda <- laeda %>%
  group_by(country_short, party_name_short, party_name) %>%
  summarise(year_first = min(share_year), year_last = max(share_year)) %>%
  ungroup()

## Merge share_laeda & year_laeda
final_laeda <- merge(share_laeda, year_laeda, by=c("country_short","party_name_short", "party_name"))

## sort columns
final_laeda <- final_laeda[,-9]
final_laeda <- final_laeda[,c(1,2,3,9,10,5,4,6,7,8)]

## convert share to us-version
final_laeda <- final_laeda %>%
  mutate(
    party_id = paste(country_short, party_name_short, party_name),
    share = str_replace(share, ",", ".") %>% as.numeric())

final_laeda %>% filter(duplicated(party_id)) %>% select(party_id)
final_laeda$date <- NULL

## write .csv
write_csv(final_laeda, "laeda_parties.csv", na = "")
