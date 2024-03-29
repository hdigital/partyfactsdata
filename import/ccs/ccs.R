library(tidyverse)

raw_ccs <- read_csv("ccs.csv", na = "")

file_pf_ext <- "pf-ext.csv"

# update latest list of Party Facts external parties
if(F) {
  url <- "https://partyfacts.herokuapp.com/download/external-parties-csv/"
  read.csv(url, na = "") %>%
    select(dataset_key, dataset_party_id, partyfacts_id) %>%
    filter(dataset_key == "ccs") %>%
    select(-dataset_key) %>%
    write_csv(file_pf_ext, na = "")
}

pf_ext <- read.csv(file_pf_ext, na = "")


# update partyfacts_id in import file
ccs <-
  raw_ccs %>%
  select(-partyfacts_id) %>%
  left_join(pf_ext, by = c("party_id_1" = "dataset_party_id"))

write_csv(ccs, "ccs.csv", na = "")

# generate link file
ccs_partyfacts <-
  ccs %>%
  pivot_longer(party_id_1:party_id_4, values_to = "party_id", names_to = "numb") %>%
  select(-numb) %>%
  drop_na(party_id) %>%
  select()

write_csv(ccs_partyfacts, "ccs-partyfacts.csv", na = "")
