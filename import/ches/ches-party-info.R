library("dplyr")
library("stringr")

url <- "http://www.chesdata.eu/1999-2014/1999-2014_CHES_dataset_means.csv"
file_name <- paste0("source__", str_replace(url, ".+/", ""))
if( ! file.exists(file_name)) {
  download.file(url, file_name, mode="wb")
}
trend_raw <- read.csv(file_name, fileEncoding="utf-8", as.is=TRUE)

trend <- trend_raw %>%
  group_by(party_id) %>%
  mutate(vote = round(vote, 1),
         vote_max = max(vote, na.rm = TRUE),
         year_first = min(year, na.rm = TRUE),
         year_last = max(year, na.rm = TRUE),
         country = toupper(country)) %>%
  filter(vote == vote_max) %>%
  distinct(party_id) %>%
  select(country, party_id, party, cmp_id, electionyear, vote, year_first, year_last)

write.csv(trend, "ches-party-info.csv", na="", row.names = FALSE, fileEncoding="utf-8")

