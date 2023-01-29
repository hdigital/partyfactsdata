library(tidyverse)
library(countrycode)

# source files
raw_pop_list <- 
  read_csv("source__Poll of Polls List of all parties in database.csv", na = "")


raw_pop_list_old <- 
  read_csv("source__Poll of Polls List of all parties old in database.csv", na = "")


raw_pop_elec_high <- 
  read_csv("source__elections_highest_result.csv", na = "NA")


raw_pop_elec_last <- 
  read_csv("source__elections_last_result.csv", na = "NA")


# party list
pop_list <- 
  raw_pop_list %>% 
  bind_rows(raw_pop_list_old) %>% # old polled parties
  select(-1) %>% 
  mutate(
    country = str_extract(election_code, "[:upper:]{2}"),
    country_code = countrycode(country, origin = "iso2c", destination = "iso3c", custom_match = c("EU" = "EUN")),
    code = paste(country, party_code, sep = "-")
  )

# election results highest
pop_elec_high <- 
  raw_pop_elec_high %>% 
  mutate(
    code = paste(country, party, sep = "-"),
    year = as.numeric(str_extract(date, "[:digit:]{4}"))
  ) %>% 
  group_by(code) %>% 
  slice(1L) %>% 
  ungroup() %>% 
  select(code, year, share = value)

# election results latest
pop_elec_last <- 
  raw_pop_elec_last %>% 
  mutate(
    code = paste(country, party, sep = "-"),
    year = as.numeric(str_extract(date, "[:digit:]{4}"))
  ) %>% 
  group_by(code) %>% 
  slice(1L) %>% 
  ungroup() %>% 
  select(code, year, share = value)


# election result
pop_elec <- 
  bind_rows(pop_elec_high, pop_elec_last) %>% 
  group_by(code) %>% 
  mutate(
    max_share = max(share, na.rm = T),
    keep = if_else(share == max_share , max_share, NA_real_)
  ) %>% 
  arrange(-share) %>% 
  slice(1L) %>% 
  ungroup() %>% 
  select(code, year, share)


# file out
file_out <- 
  pop_list %>% 
  left_join(pop_elec, by = "code") %>% 
  mutate(
    share = case_when(
      share > 1 ~ share,
      share < 1 ~ share * 100,
      share == 1 ~ 1,
      is.na(share) ~ NA_real_,
      T ~ NA_real_
    ),
    party_name = if_else(nchar(party_name) > 25, str_extract(party_name, "[[:digit:][:upper:]]*"), party_name)
  ) %>% 
  select(country, country_code, party_name, party_name_long, party_name_long_org, party_epgroup, year, share, party_id = code) %>% 
  filter(country_code != "EUN") # remove EU parties

# encoding problems
write_excel_csv(file_out, "pop.csv", na = "", append = F)

