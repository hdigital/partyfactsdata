library(tidyverse)
library(countrycode)

pa_raw <- read_csv("source__morgan_1976_appendix.csv")

pa <- 
  pa_raw %>%
  select(id:comment) %>%
  group_by(country, name_short) %>%
  mutate(first = min(year_first, na.rm = TRUE),
         last = max(year_last, na.rm = TRUE)) %>%
  select(-year_first, -year_last) %>%
  ungroup() %>%
  distinct(country, name_short, .keep_all = TRUE)

pa <- pa %>%
  mutate(country_short = countrycode(country, "country.name", "iso3c")) %>%
  arrange(id)

write_csv(pa, "morgan.csv", na = "")
