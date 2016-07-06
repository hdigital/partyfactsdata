library('dplyr')

url <- 'http://www.parlgov.org/static/data/development-utf-8/'
tables <- c('view_party.csv', 'view_election.csv', 'party.csv')
lapply(tables, function(x) download.file(paste0(url, x),  x) )

party <- read.csv('view_party.csv', fileEncoding='utf-8', as.is=TRUE)
elec <- read.csv('view_election.csv', fileEncoding='utf-8', as.is=TRUE)
party_raw <- read.csv('party.csv', fileEncoding='utf-8', as.is=TRUE)

# calculate first and last year each party
elec_year <- elec %>%
  mutate(year = substr(elec$election_date, 1, 4)) %>%
  group_by(party_id) %>%
  summarise(first = min(year, na.rm = TRUE), last = max(year, na.rm = TRUE)) %>%
  select(party_id, first, last)

# calculate max vote share each party
elec_share <- elec %>%
  filter(election_type == 'parliament') %>%
  group_by(party_id) %>%
  mutate(vote_share_max = max(vote_share, na.rm = TRUE)) %>%
  filter(vote_share == vote_share_max) %>%
  distinct(party_id, .keep_all = TRUE) %>%
  ungroup() %>%
  mutate(vote_share_max = round(vote_share_max, 1),
         vote_share_max_year = substr(election_date, 1, 4)) %>%
  select(party_id, vote_share_max_year, vote_share_max)

parlgov_url <- 'http://www.parlgov.org/explore/%s/party/%d/'
parlgov <- party %>%
  select(party_id, country_name_short:family_name, -country_name, -party_name_ascii, -family_name) %>%
  filter(family_name_short != 'none') %>%
  mutate(url = sprintf(parlgov_url, tolower(country_name_short), party_id)) %>%
  left_join(elec_year) %>%
  left_join(elec_share) %>%
  left_join(party_raw %>% select(id, wikipedia), by = c('party_id' = 'id')) %>%
  arrange(country_name_short, party_name)

# create import file and remove downloaded source files
write.csv(parlgov, 'parlgov.csv', na='', fileEncoding='utf-8', row.names = FALSE)
lapply(tables, file.remove)
