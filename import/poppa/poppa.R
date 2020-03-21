library(tidyverse)
library(countrycode)

## Create ParlGov-PF-ID link file ----

if (FALSE) {
  # run only manually -- updated PF-IDs not needed after POPPA import into PF

  url <- "https://partyfacts.herokuapp.com/download/external-parties-csv/"

  pf_external <-
    read_csv(url, na = "", guess_max = 30000) %>%
    filter(dataset_key == "parlgov") %>%
    mutate(parlgov_id = as.integer(dataset_party_id)) %>%
    select(parlgov_id, partyfacts_id)

  write_csv(pf_external, "partyfacts-external_parlgov.csv")
}

# Create POPPA PF import ----

raw_poppa_pa <- read_csv("poppa-parties-codebook.csv", na = "")
raw_poppa_dt <- read_csv("source__party_means.csv", na = "")
pf_parlgov_link <- read_csv("partyfacts-external_parlgov.csv")

poppa_link <-
  raw_poppa_dt %>%
  select(party_id, parlgov_id) %>%
  left_join(pf_parlgov_link) %>%
  select(-parlgov_id)

poppa <-
  raw_poppa_pa %>%
  mutate(country_short = countrycode(country, "country.name", "iso3c")) %>%
  left_join(poppa_link)

write_csv(poppa, "poppa.csv", na = "")
