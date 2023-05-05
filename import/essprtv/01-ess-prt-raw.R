library(conflicted)

library(tidyverse)
conflicts_prefer(dplyr::filter, .quiet = TRUE)
library(readstata13)


ess_dta_path <- "source__ESS/"  # path of ESS rounds Stata data


## ESS waves ----

# data file information for ESS Rounds
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
    "ESS9e01_2.dta", "UTF-8",
    "ESS10e02_2.dta", "UTF-8"
  )

# function to get party name and party ID
get_ess_parties <- function(data, encoding) {
  data_path <- paste0(ess_dta_path, data)

  party <-
    read.dta13(data_path, fromEncoding = encoding) |>
    select(cntry, essround, starts_with(c("prtv", "prtc"))) |>
    pivot_longer(c(-cntry, -essround),
                 names_to = "variable",
                 values_to = "party")

  party_id <-
    read.dta13(data_path,
               convert.factors = FALSE,
               fromEncoding = encoding) |>
    select(cntry, essround, starts_with(c("prtv", "prtc"))) |>
    pivot_longer(c(-cntry, -essround),
                 names_to = "variable",
                 values_to = "party_id") |>
    pull(party_id)

  party["party_id"] <- party_id

  return(party)
}

# party name and party ID for round 1-9 -- time intense so avoiding rereading
if (! exists("ess_prt_raw")) {
  ess_prt_raw <-
    pmap(ess_dta_files, ~ get_ess_parties(..1, ..2), .progress = TRUE) %>%
    bind_rows()
}


## ESS out ----

# combine and create 'ess_id'
ess_prt_out <-
  ess_prt_raw |>
  drop_na(party) |>
  distinct() |>
  mutate(ess_id = paste(cntry,
                        essround,
                        party_id,
                        substr(variable, 4, 4),
                        sep = "-")) |>
  arrange(cntry, essround, variable, party_id)

write_csv(ess_prt_out, "01-ess-prt-raw.csv", na = "")


## Data issues ESS ----

print("ESS variables with multipe 'prtv*' variables per country -- duplicate 'ess_id'")
ess_prt_out |>
  filter(str_detect(variable, "prtv.+\\d")) |>
  pull(variable) |>
  unique() |>
  paste(collapse = ", ")


# find parties with different ids in prtv/prtc

prt_vc_different <-
  ess_prt_out |>
  mutate(variable = substr(variable, 1, 4),
         ess_id_vc = str_remove(ess_id, "-v$|-c$")) |>
  distinct(ess_id, variable, .keep_all = TRUE) |>
  select(ess_id_vc, variable, party) |>
  pivot_wider(names_from = variable, values_from = party) |>
  filter(prtv != prtc) |>
  drop_na()
