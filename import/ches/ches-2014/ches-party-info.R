library(tidyverse)

url <- "https://www.chesdata.eu/s/1999-2014_CHES_dataset_means.csv"
file_name <- "source__1999-2014_CHES_dataset_means.csv"
if (!file.exists(file_name)) {
  download.file(url, file_name, mode = "wb")
}
trend_raw <- read_csv(file_name)

trend <- trend_raw %>%
  group_by(party_id) %>%
  mutate(
    vote = case_when(
      is.na(vote) ~ 0,
      T ~ vote
    ),
    vote_max = max(vote, na.rm = TRUE),
    year_first = min(year, na.rm = TRUE),
    year_last = max(year, na.rm = TRUE),
    country = toupper(country)
  ) %>%
  filter(vote == vote_max) %>%
  distinct(party_id, .keep_all = TRUE) %>%
  mutate(
    vote = case_when(
      vote == 0.00 ~ NA_real_,
      T ~ round(vote, 1)
    )
  ) %>%
  select(country, party_id, party, cmp_id, electionyear, vote, year_first, year_last)

write_csv(trend, "ches-party-info.csv", na = "")
