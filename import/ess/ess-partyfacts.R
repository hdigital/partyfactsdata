library(tidyverse)

## Read data ----

ess_pa_raw <- read_csv("ess.csv")
ess_sh_raw <- read_csv("ess-sheet.csv")
ess_round_raw <- read_csv("ess-parties/ess-parties-round.csv")


## ESS Round parties ----

ess_pa <- 
  ess_round_raw %>% 
  group_by(cntry, essround) %>% 
  mutate(
    share = round(100*n/sum(n), 1),
    ess_key = paste(cntry, party, sep = " -- ") %>% tolower()
    ) %>% 
  ungroup() %>% 
  select(-n)


## Google Sheet data ----

ess_sh <- 
  ess_sh_raw %>% 
  mutate(
    party_id = ifelse(is.na(duplicate), party_id, duplicate),
    ess_key = paste(cntry, party, sep = " -- ") %>% tolower(),
    name_gsheet = paste(party_short, party_name, party_english),
    name_gsheet = str_replace_all(name_gsheet, " *NA *", " "),
    name_gsheet = str_trim(name_gsheet)
  ) %>% 
  select(party_id, ess_key, name_gsheet)


## Party Facts link data ----

# read Party Facts mapping table once
if( ! exists("pf_core") |  ! exists("pf_link")) {
  url <- "https://partyfacts.herokuapp.com/download/"
  pf_core <- read_csv(paste0(url, "core-parties-csv/"), guess_max = 30000)
  pf_link <- read_csv(paste0(url, "external-parties-csv/"), guess_max = 30000)
}

pf_ess_all <- 
  pf_link %>% 
  filter(dataset_key == "ess", ! is.na(partyfacts_id))

pf_ess <- 
  pf_ess_all %>% 
  select(party_id=dataset_party_id, partyfacts_id) %>% 
  left_join(pf_core %>% select(partyfacts_id, partyfacts_name=name_short))


## Final data ----

ess_out <- 
  ess_pa %>% 
  left_join(ess_sh) %>% 
  left_join(pf_ess) %>% 
  select(-ess_key)

all(ess_pa_raw$party_id %in% ess_out$party_id)

write_csv(ess_out, "ess-partyfacts.csv")
