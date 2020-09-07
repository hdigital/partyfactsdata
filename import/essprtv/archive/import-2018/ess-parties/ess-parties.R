library(tidyverse)

## Read data

if( ! exists("ess_raw") | ! exists("ess")) {
  ess_raw <- haven::read_dta("source__ESS1-7e01-dta.zip")
  ess <- ess_raw %>%
    haven::as_factor() %>% 
    mutate(essround = as.integer(essround))
}


## Extract party names from party variables

get_ess_party <- function(prt_var) {
  quo_prt_var <- rlang::sym(prt_var)
  ess %>% 
  select(cntry, essround, !!quo_prt_var) %>% 
  na.omit() %>% 
  mutate(variable = rlang::quo_text(quo_prt_var),
         ess_id = as.integer(!!quo_prt_var),
         party = as.character(!!quo_prt_var)) %>% 
  count(cntry, essround, variable, ess_id, party)
}

# get_ess_party("prtvtse")

prt_vars <- ess %>% select(starts_with("prtvt")) %>% names()
party_all <- map_df(prt_vars, get_ess_party) %>% bind_rows()

write_csv(party_all, "ess-parties-round.csv", na = "")


## Create unique party list

pa_ignore <- c("Don't know", "No answer", "Not applicable", "Other", "Refusal")

party_round <- party_all %>%
  filter( ! party %in% pa_ignore) %>% 
  mutate(ess_key = sprintf("%s -- %s", cntry, party) %>% tolower()) %>%
  group_by(cntry, essround, variable) %>% 
  mutate(share = round(100 * n / sum(n), 1))

party <- party_round %>% 
  group_by(ess_key) %>% 
  mutate(ess_first = min(essround), ess_last = last(essround)) %>%
  top_n(1, share) %>%
  distinct(ess_key, .keep_all = TRUE) %>% 
  select(-variable, -n) %>% 
  arrange(ess_key)
  
write_csv(party, "ess-parties.csv", na = "")

