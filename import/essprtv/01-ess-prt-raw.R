library(conflicted)
conflicts_prefer(dplyr::filter, .quiet = TRUE)

library(tidyverse)
library(readstata13)


ess_dta_path <- "source__ESS/"  # path of ESS rounds Stata data


## ESS waves ----

# data file information for ESS Rounds
ess_dta_files <-
  c(
    "ESS1e06_6.dta",
    "ESS2e03_6.dta",
    "ESS3e03_7.dta",
    "ESS4e04_5.dta",
    "ESS5e03_4.dta",
    "ESS6e02_5.dta",
    "ESS7e02_2.dta",
    "ESS8e02_2.dta",
    "ESS9e03_1.dta",
    "ESS10.dta",
    "ESS10SC.dta"
  )

# function to get party name and party ID
get_ess_parties <- function(ess_dta) {
  data_path <- paste0(ess_dta_path, ess_dta)

  party <-
    read.dta13(data_path) |>
    select(cntry, essround, starts_with(c("prtv", "prtc"))) |>
    pivot_longer(c(-cntry, -essround),
                 names_to = "variable",
                 values_to = "party")

  party_id <-
    read.dta13(data_path, convert.factors = FALSE) |>
    select(cntry, essround, starts_with(c("prtv", "prtc"))) |>
    pivot_longer(c(-cntry, -essround),
                 names_to = "variable",
                 values_to = "party_id") |>
    pull(party_id)

  party["party_id"] <- party_id

  return(party)
}

# party name and party ID for ESS rounds -- time intense so avoiding rereading
if (! exists("ess_prt_raw")) {
  ess_prt_raw <-
    map(ess_dta_files, \(.x) get_ess_parties(.x), .progress = TRUE) |>
    bind_rows()
}


## ESS out ----

# combine and create 'ess_id'
ess_prt_out <-
  ess_prt_raw |>
  drop_na(party) |>
  distinct() |>
  mutate(ess_id = case_when(
    cntry %in% c("DE", "LT") & str_detect(variable, "prtv") ~ paste(
      cntry,
      essround,
      party_id,
      substr(variable, 4, 4),
      str_sub(variable, -3, -1),
      sep = "-"
      ),
    T ~ paste(
      cntry,
      essround,
      party_id,
      substr(variable, 4, 4),
      sep = "-"
      )
    )
  ) |>
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
