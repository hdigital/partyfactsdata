library(dplyr)
library(readr)

ppdb <- read_tsv('source__PPDB-Round_1a-1.tab')

country_all <- read_csv("../country.csv")
country <- country_all %>% select(country_short = name_short, country = name)

names(ppdb) <- tolower(names(ppdb))  # lower-case variable names

first_last <- ppdb %>%
  group_by(ptyid) %>%
  summarise(year_first = min(year), year_last = max(year))

party <- ppdb %>%
  distinct(ptyid, .keep_all = TRUE) %>% 
  select(ctryid, country, ptyid, ptyname, share_year_first = cr5seats2) %>%
  mutate(share_year_first = ifelse(share_year_first >= 0, round(share_year_first, 1), NA)) %>%
  left_join(first_last) %>% 
  left_join(country)

write_csv(party, 'ppdb.csv', na = '')
