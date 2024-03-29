library(tidyverse)

## Read data ----

file_out <- "ess-labels.csv"

# "CP1252" for ESS 1-8 and "UTF-8" for ESS 9
raw_ess <- haven::read_dta("ESS1e06_6.dta", encoding = "CP1252")


## ESS labels ----

get_ess_labels <- function(ess_var) {
  labels <- attr(pull(raw_ess, ess_var), "labels")

  if(! is.null(labels)) {
    tibble(variable = ess_var, label = names(labels), value = as.character(labels))
  } else {
    NULL
  }
}

# get_ess_labels("cntry")
ess_label_all <- map_df(names(raw_ess), get_ess_labels)

ess_label_pa <-
  ess_label_all %>%
  filter(str_starts(variable, "prtv|prtc")) %>%
  mutate(essid = as.integer(value)) %>%
  select(variable, essid, party=label) %>%
  drop_na()


## Final data ----

write_csv(ess_label_pa, file_out, na = "")
