library(tidyverse)
library(dbplyr)

url <- "http://www.parlgov.org/static/data/parlgov-development.db"
db_file <- "source__parlgov.db"
if( ! file.exists(db_file)) {
  download.file(url, db_file, mode = "wb")
}

con <- DBI::dbConnect(RSQLite::SQLite(), db_file)
tbl_parlgov <- function(table) tbl(con, table) %>% as_tibble()

party <- tbl_parlgov("view_party")
elec <- tbl_parlgov("view_election")
party_raw <- tbl_parlgov("party")

# calculate first and last year each party
elec_year <- elec %>%
  mutate(year = substr(elec$election_date, 1, 4)) %>%
  group_by(party_id) %>%
  summarise(first = min(year, na.rm = TRUE), last = max(year, na.rm = TRUE)) %>%
  select(party_id, first, last)

# calculate max vote share each party
elec_share <- elec %>%
  filter(election_type == "parliament") %>%
  group_by(party_id) %>%
  mutate(vote_share_max = max(vote_share, na.rm = TRUE)) %>%
  filter(vote_share == vote_share_max) %>%
  distinct(party_id, .keep_all = TRUE) %>%
  ungroup() %>%
  mutate(vote_share_max = round(vote_share_max, 1),
         vote_share_max_year = substr(election_date, 1, 4)) %>%
  select(party_id, vote_share_max_year, vote_share_max)

parlgov_url <- "http://www.parlgov.org/explore/%s/party/%d/"
parlgov <- party %>%
  select(party_id, country_name_short:family_name, -country_name, -party_name_ascii, -family_name) %>%
  filter(family_name_short != "none") %>%
  mutate(url = sprintf(parlgov_url, tolower(country_name_short), party_id)) %>%
  left_join(elec_year) %>%
  left_join(elec_share) %>%
  left_join(party_raw %>% select(id, wikipedia), by = c("party_id" = "id")) %>%
  arrange(country_name_short, party_name)

# recode Denmark autonomous regions
parlgov <- parlgov %>% 
  mutate(
    country_name_short = case_when(
      str_detect(party_name_english, fixed("(Faroe Islands)")) ~ "FRO",
      str_detect(party_name_english, fixed("(Greenland)")) ~ "GRL",
      TRUE ~ country_name_short
    )
  )

write_csv(parlgov, "parlgov.csv", na = "")
