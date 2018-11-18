library(tidyverse)
library(glue)
library(readxl)

get_ejpr_parties <- function(file_path) {
  party <- read_excel(file_path, sheet = "info_parties2")
  names(party)[1] <- "ejpr_id"
  names(party) <- tolower(names(party))
  party %>%
    select(1:8) %>%
    filter(ejpr_id != 0, ! is.na(ejpr_id))
}

sources_path <- glue("source__ejpr-pdy/{list.files('source__ejpr-pdy')}")
party <- map(sources_path, get_ejpr_parties) %>% bind_rows()

party_out <-
  party %>%
  filter(max_vote >= 0.01, ! is.na(max_vote)) %>%
  mutate_at(vars(contains("year")), funs(substr(., 1, 4) %>% as.integer)) %>%
  mutate(
    max_vote = round(max_vote * 100, 1),
    country = toupper(country),
    first_pdy_year = case_when(first_pdy_year == 1899 ~ NA_integer_, TRUE ~ first_pdy_year)
  )

write_csv(party_out, "ejpr.csv", na = "")
