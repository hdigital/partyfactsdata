library(tidyverse)

file_ccs_all <- "ccs-partyfacts.csv"

raw_ccs_all <- read_csv(file_ccs_all)

if( ! exists("pf_core")) {
  url <- "https://partyfacts.herokuapp.com/download/"
  pf_core <- read_csv(paste0(url, "core-parties-csv/"), guess_max = 30000)
}

css_all <- 
  raw_ccs_all %>% 
  select(-partyfacts_name) %>% 
  left_join(pf_core %>% select(partyfacts_id, partyfacts_name=name_short))

write_csv(css_all, file_ccs_all, na = "")