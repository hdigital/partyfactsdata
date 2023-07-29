library(conflicted)
conflicts_prefer(dplyr::filter, .quiet = TRUE)

library(tidyverse)


file_ess_clean <- "02-ess-harmonize.csv"


##  Read initial data ----

raw_ess <- read_csv("01-ess-prt-raw.csv", na = "", show_col_types = FALSE)
raw_ess_clean <- read_csv(file_ess_clean, na = "", show_col_types = FALSE)

# add "ess" prefix to all variable names in ESS data
ess <-
  raw_ess |>
  rename_all(\(x) paste0("ess_", x)) |>
  rename_all(\(x) str_replace(x, "_ess", ""))

# select only harmonization variables and link id
ess_clean <-
  raw_ess_clean |>
  distinct(ess_id, first_ess_id, country)


## Update link file ----

# create updated ESS / Party Facts link file
ess_update <-
  ess |>
  left_join(ess_clean, by = "ess_id", multiple = "first") |>
  arrange(ess_cntry, essround, desc(ess_variable), ess_party_id)

# replace existing link file -- changes tracked with Git
write_csv(ess_update, file_ess_clean, na = "")


## Consistency checks ----

# raise warning message and show data with consistency issues
raise_warning <- function(df, msg) {
  if (nrow(df) > 0) {
    warning(msg)
    df
  }
}

check_first_id <-
  ess_update |>
  arrange(ess_cntry, essround, ess_variable, ess_party_id) |>
  group_by(first_ess_id) |>
  slice(1) |>
  filter(ess_id != first_ess_id) |>
  ungroup()

raise_warning(check_first_id, "Some 'first_ess_id' from the link file are not the first entry")

check_harmonized <-
  ess_update |>
  filter(is.na(first_ess_id) | is.na(country))

raise_warning(check_harmonized, "Some ESS observations are not harmonized")
