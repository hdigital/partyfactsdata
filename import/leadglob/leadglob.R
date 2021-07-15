library(tidyverse)


raw_leadglob <- read_csv("source__leaders-global-release.csv", na = "")


# HoS information
leadglob_hos <- 
  raw_leadglob %>% 
  select(country_short, year, HoS_party_short:HoS_technical) %>% 
  filter(is.na(HoS_technical)) %>%
  rename(name_short = HoS_party_short, name_english = HoS_party_english,
         party_source = HoS_party_source, party_id = HoS_party_id) %>% 
  select(-HoS_technical) %>% 
  drop_na(name_short)

# HoG information
leadglob_hog <- 
  raw_leadglob %>% 
  select(country_short, year, HoG_party_short, HoG_party_english,
         HoG_party_source, HoG_party_id, HoG_technical) %>% 
  filter(is.na(HoG_technical)) %>% 
  rename(name_short = HoG_party_short, name_english = HoG_party_english,
         party_source = HoG_party_source, party_id = HoG_party_id) %>% 
  select(-HoG_technical) %>% 
  drop_na(party_id)


# first HoS
hos_first <- 
  raw_leadglob %>% 
  distinct(country_short, HoS_party_id, .keep_all = TRUE) %>% 
  mutate(
    hos_first = glue::glue("{year} {HoS_name} ({HoS_title})"),
  ) %>% 
  select(HoS_party_id, hos_first) %>% 
  filter(!is.na(HoS_party_id))

# first HoG
hog_first <- 
  raw_leadglob %>% 
  distinct(country_short, HoG_party_id, .keep_all = TRUE) %>% 
  mutate(
    hog_first = glue::glue("{year} {HoG_name} ({HoS_title})"),
  ) %>% 
  select(HoG_party_id, hog_first) %>% 
  filter(!is.na(HoG_party_id))

  
# final file
file_out <- 
  leadglob_hos %>% 
  bind_rows(leadglob_hog) %>% 
  group_by(party_id) %>% 
  mutate(
    year_first = min(year),
    year_last = max(year),
    name_english = case_when(
      is.na(name_english) ~ party_source,
      TRUE ~ name_english
    )
  ) %>% 
  ungroup() %>% 
  select(-year, -party_source) %>% 
  left_join(hos_first, by = c("party_id" = "HoS_party_id")) %>% 
  left_join(hog_first, by = c("party_id" = "HoG_party_id")) %>% 
  filter(!is.na(party_id)) %>% 
  distinct()



write_csv(file_out, "leadglob.csv", na = "")  
