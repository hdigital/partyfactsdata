library("dplyr")

party <- read.csv("ches-parties.csv", fileEncoding="utf-8", as.is=TRUE)
country <- read.csv("ches-country.csv", fileEncoding="utf-8", as.is=TRUE)
info <- read.csv("ches-party-info.csv", fileEncoding="utf-8", as.is=TRUE)

year_default <- 2014  # for countries not in trendfile

ches <- party %>%
  left_join(country %>% select(country=abbr, country_iso3=iso3)) %>%
  left_join(info %>% select(-country, -party)) %>%
  mutate(year_first = ifelse(is.na(year_first), year_default, year_first),
         year_last = ifelse(is.na(year_last), year_default, year_last))

write.csv(ches, "ches.csv", na="", row.names = FALSE, fileEncoding="utf-8")

