library(tidyverse)
library(readstata13)


ess_dta_path <- "source__ESS/"  # path of ESS rounds Stata data


## ESS 1-9 ----

# List of information for Round 1 - 9
ess_dta_files <-
  tribble(
    ~data,           ~encoding,
    "ESS1e06_6.dta", "CP1252",
    "ESS2e03_6.dta", "CP1252",
    "ESS3e03_7.dta", "CP1252",
    "ESS4e04_5.dta", "CP1252",
    "ESS5e03_4.dta", "CP1252",
    "ESS6e02_4.dta", "CP1252",
    "ESS7e02_2.dta", "CP1252",
    "ESS8e02_1.dta", "CP1252",
    "ESS9e01_2.dta", "UTF-8"
  )

# Function to get party name and party ID
get_ess_parties <- function(data, encoding) {
  data_path <- paste0(ess_dta_path, data)
  
  party <- 
    read.dta13(data_path, fromEncoding = encoding) %>%
    select(cntry, essround, starts_with(c("prtv", "prtc"))) %>%
    pivot_longer(c(-cntry, -essround), names_to = "variable", values_to = "party")
  
  party_id <- 
    read.dta13(data_path, convert.factors = FALSE, fromEncoding = encoding) %>%
    select(cntry, essround, starts_with(c("prtv", "prtc"))) %>%
    pivot_longer(c(-cntry, -essround), names_to = "variable", values_to = "party_id") %>% 
    pull(party_id)
  
  party["party_id"] <- party_id
  
  return(party)
}

# party name and party ID for round 1-9 -- time intense so avoiding rereading
if(! exists("ess_prt_raw")) {
  ess_prt_raw <-
    pmap(ess_dta_files, ~ get_ess_parties(..1, ..2)) %>%
    bind_rows()
}


## ESS out ----

# combine and create 'ess_id'
ess_prt_out <-
  ess_prt_raw %>%
  drop_na(party) %>%
  distinct() %>%
  mutate(ess_id = paste(cntry, essround, party_id, substr(variable, 4, 4), sep = "-")) %>% 
  arrange(cntry, essround, variable, party_id)

write_csv(ess_prt_out, "01-ess-prt-raw.csv", na = "")


## Data issues ESS ----

print("ESS variables with multipe prtv* variables per county -- duplicate 'ess_id'")
ess_prt_out %>% 
  filter(str_detect(variable, "prtv.+\\d")) %>% 
  pull(variable) %>% 
  unique() %>% 
  paste(collapse = ", ")


# find parties with different ids in prtv/prtc

prt_check <- 
  ess_prt_out %>% 
  select(ess_id, variable, party) %>% 
  mutate(variable = substr(variable, 1, 4)) %>% 
  distinct(ess_id, variable, .keep_all = TRUE) %>% 
  pivot_wider(names_from = variable, values_from = party)

prt_check_diff <- 
  prt_check %>% 
  drop_na() %>%
  filter(prtv != prtc)
