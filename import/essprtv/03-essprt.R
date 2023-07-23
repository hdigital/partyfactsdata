library(conflicted)
conflicts_prefer(dplyr::filter, .quiet = TRUE)

library(tidyverse)
library(glue)
library(countrycode)


raw_ess_clean <- read_csv("02-ess-harmonize.csv", na = "", show_col_types = FALSE)


## Party Facts information ----

if (! exists("pf_party")) {
  # potentially time intense so avoiding rereading
  url <- "https://partyfacts.herokuapp.com/download"

  raw_pf_core <-
    read_csv(glue("{url}/core-parties-csv/"),
             na = "",
             show_col_types = FALSE)

  raw_pf_ext_raw <-
    read_csv(glue("{url}/external-parties-csv/"),
             na = "",
             guess_max = 50000,
             show_col_types = FALSE)

  pf_ext <-
    raw_pf_ext_raw |>
    filter(str_starts(dataset_key, "essprt")) |>
    select(partyfacts_id, first_ess_id = dataset_party_id)

  pf_party <-
    raw_pf_core |>
    select(country,
           name_short,
           name,
           name_english,
           partyfacts_id,
           technical) |>
    inner_join(pf_ext, by = "partyfacts_id")
}


## ESS preparation ----

# add variables needed below
prt <-
  raw_ess_clean |>
  mutate(
    prt_var = str_extract(ess_variable, "prtv|prtc"),
    year = essround * 2 + 2000,
    essround = paste0("R", essround)
  ) |>
  unite(ess_info,
        essround,
        ess_variable,
        ess_party,
        sep = " --- ",
        remove = FALSE) |>
  select(-essround, -ess_variable)

# collapse ESS rounds at party level
prt_info <-
  prt |>
  summarise(
    first_ess_name = first(ess_party),
    year_first = min(year),
    year_last = max(year),
    ess_ids = paste(ess_id, collapse = " "),
    ess_info = paste(ess_info, collapse = "\n"),
    .by = c(prt_var, first_ess_id)
  ) |>
  mutate(ess_ids = str_replace_all(ess_ids, " +", " "))

prt_out <-
  prt |>
  distinct(first_ess_id) |>
  inner_join(prt_info, by = "first_ess_id") |>
  left_join(pf_party, by = "first_ess_id") |>
  relocate(partyfacts_id, .before = country) |>
  mutate(
    country_short = str_extract(first_ess_id, "[:alpha:]{2}"),
    country = if_else(
      is.na(country),
      countrycode(country_short, "iso2c", "iso3c", custom_match = c("XK" = "XKX")),
      country
    )
  ) |>
  select(-country_short)


## Check duplicates ----

# question vote intention (prtv*)
prtv_out_check <-
  prt_out |>
  filter(prt_var == "prtv") |>
  select(-prt_var) |>
  group_by(first_ess_id) |>
  mutate(dupl = n()) |>
  filter(dupl > 1)

# question party close to (prtc*)
prtc_out_check <-
  prt_out |>
  filter(prt_var == "prtc") |>
  select(-prt_var) |>
  group_by(first_ess_id) |>
  mutate(dupl = n()) |>
  filter(dupl > 1)


## Link data sets ----

# question vote intention (prtv*)
prt_out |>
  filter(prt_var == "prtv") |>
  select(-prt_var) |>
  write_csv("essprtv.csv", na = "")

# question party close to (prtc*)
prt_out |>
  filter(prt_var == "prtc") |>
  select(-prt_var) |>
  write_csv("../essprtc/essprtc.csv", na = "")

# all ESS prt* variables
prt_out_all <-
  raw_ess_clean |>
  left_join(pf_party, by = c("country", "first_ess_id")) |>
  relocate(partyfacts_id, .before = country) |>
  arrange(ess_cntry, essround, ess_variable, ess_party_id)

write_csv(prt_out_all, "essprt-all.csv", na = "")


## Plot ESS-prtv  ----

pl_dt <-
  prt_out_all |>
  filter(is.na(technical), str_ends(ess_id, "v")) |>
  distinct(country, essround, ess_id) |>
  count(country, essround, sort = TRUE) |>
  mutate(country = factor(country) |> fct_rev(),
         essround = factor(essround))

pl <-
  ggplot(pl_dt, aes(y = country, x = essround, size = n)) +
  geom_point(colour = "darkgrey") +
  scale_y_discrete(name = NULL) +
  scale_x_discrete(name = "ESS Round") +
  scale_size_continuous(name = "n (prtv*)") +
  theme_bw() +
  theme(axis.ticks.y = element_blank()) +
  guides(color = "none")

# plot(pl)
ggsave("essprtv.png",
       pl,
       width = 20,
       height = 25,
       units = "cm")

