library(tidyverse)
library(countrycode)

pa_names <- read_csv("party-names/jw-party-names.csv")
pa_share <- read_csv("jw-share.csv")

pa <- pa_names %>%
  inner_join(pa_share) %>% 
  mutate(
    party_short = partyname %>% 
                    str_extract_all("\\(.{1,10}?\\)") %>%
                    map(~ str_c(.x, collapse = "-")) %>%
                    str_remove_all("\\(|\\)"),
    party_short = ifelse(party_short == "character0", "", party_short),
    party_name = str_remove(partyname, " \\(.+?\\)$"),
    party_id = paste(countryid, partyid, sep = "-"),
    country_iso = countrycode(country, "country.name", "iso3c")
  ) %>% 
  select(country, everything())

pa_out <- pa %>% filter(! duplicated(party_id))

write_csv(pa_out, "jw.csv", na = "")
