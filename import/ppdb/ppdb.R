library(tidyverse)
library(haven)
library(countrycode)

ppdb <- haven::read_spss("source__PPDB-Round_1a-1.sav")

names(ppdb) <- tolower(names(ppdb))  # lower-case variable names

first_last <- ppdb %>%
  group_by(ptyid) %>%
  summarise(year_first = min(year), year_last = max(year))

party <- ppdb %>%
  distinct(ptyid, .keep_all = TRUE) %>%
  select(ctryid, country, ptyid, ptyname, share_year_first = cr5seats2) %>%
  mutate(share_year_first = ifelse(share_year_first >= 0, round(share_year_first, 1), NA)) %>%
  left_join(first_last) %>%
  mutate(country_short = countrycode(country, "country.name", "iso3c"))

# recoding party names with unicode issues
party[party$ptyid == 4003, "ptyname"] <- "Bloc Québécois"
party[party$ptyid == 11003, "ptyname"] <- "Fianna Fáil"
party[party$ptyid == 11003, "ptyname"] <- "Sinn Féin"

write_csv(party, "ppdb.csv", na = "")
