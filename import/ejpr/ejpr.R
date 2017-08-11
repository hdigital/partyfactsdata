library(tidyverse)
library(readxl)

get_ejpr_parties <- function(file_path) {
  party <- read_excel(file_path, sheet = "info_parties2")
  names(party)[1] <- "ejpr_id"
  names(party) <- tolower(names(party))
  party <- party[ , 1:8] %>% filter(ejpr_id != 0, ! is.na(ejpr_id))
  return(party)
}

path <- "source__ejpr-pdy/"
party <- bind_rows(lapply(paste0(path, list.files(path)), get_ejpr_parties))

party_out <- party %>%
  filter(max_vote >= 0.01, ! is.na(max_vote)) %>%
  mutate(max_vote = round(max_vote * 100, 1),
         country = toupper(country)) %>%
  mutate_at(vars(contains("year")), funs(substr(., 1, 4) %>% as.integer))

write_csv(party_out, "ejpr.csv", na = "")
