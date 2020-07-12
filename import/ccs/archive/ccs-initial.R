library(tidyverse)

raw_ccs_parties <- read_csv("ccs-parties.csv")  # harmonized party list
pf_tech <- read_csv("pf-technical.csv") %>% select(-country)  # pf-core with only technicals

raw_ccs_all <- read_csv("ccs-parties-all.csv")

# wide dataset of CCS party IDs
ccs_party_id <-
  raw_ccs_all %>%
  select(partyfacts_id, party_id) %>%
  group_by(partyfacts_id) %>%
  mutate(wave = paste0("party_id_", row_number())) %>%
  spread(wave, party_id) %>%
  ungroup()

# combine all information
ccs_temp <-
  raw_ccs_parties %>%
  select(-party_id) %>%
  left_join(ccs_party_id, by = "partyfacts_id") %>%
  left_join(pf_tech, by = "partyfacts_id") %>%
  filter(is.na(technical)) %>%                        # filter technicals
  select_if( ~ sum(!is.na(.)) > 0)                    # drop empty columns

# correct special case in Belgium
ccs <-
  ccs_temp %>%
  mutate(
    party_id_2 = case_when(
      (country == "BEL" & name_short %in% c("PVDA", "PTB")) ~ NA_character_,
      TRUE ~ party_id_2
    ),
    party_id_1 = case_when(
      (country == "BEL" & name_short == "PVDA") ~ "2-18-19-2014",
      TRUE ~ party_id_1
    )
  ) %>%
  group_by(party_id_1) %>%    # remove duplicate entries
  slice(1L) %>%
  ungroup()


write_csv(ccs, "ccs.csv", na = "")
