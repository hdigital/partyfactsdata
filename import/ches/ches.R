library(tidyverse)

ches14 <- read_csv("ches-2014/ches.csv")
ches17 <- read_csv("ches-2017/ches-2017.csv")
ches19 <- read_csv("ches-2019/ches-2019.csv")

# combined CHES data
ches_all <-
  ches14 %>%
  select(-cmp_id) %>%
  bind_rows(ches17) %>%
  bind_rows(ches19)

# first and last year
ches_first_last <-
  ches_all %>%
  group_by(party_id) %>%
  summarise(year_first = min(year_first), year_last = max(year_last))

# final data for PF import
ches_out <-
  ches_all %>%
  select(-year_first, -year_last) %>%
  distinct(party_id, .keep_all = TRUE) %>%
  mutate(electionyear = if_else(is.na(vote), NA_real_, electionyear)) %>%
  left_join(ches_first_last) %>%
  select(country_iso3, everything(), -country) %>%
  arrange(country_iso3, party_name)

write_csv(ches_out, "ches.csv", na = "")
