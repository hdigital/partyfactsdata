library(tidyverse)
library(countrycode)

# Load the data + specify the variables to be used
ches_countries <- read_csv("ches-party-codebooks.csv", na = "") |> select(countrycode, countryshort, countryname) |> distinct()

ches_party_codebook <- read_csv("ches-party-codebooks.csv", na = "") |> mutate(party_id = as.numeric(party_id))

ches_trend_1999_2019 <- read_csv("source__data/1999-2019_CHES_dataset_means(v3).csv", na = "") |> select(countrycode = country, party_id, year)
ches_candidate_2007 <- read_csv("source__data/2007_CHES-candidates_dataset_means.csv", na = "") |> select(countrycode = country, party_id, year)
ches_candidate_2014 <- read_csv("source__data/Candidate_Ukraine_2014.csv", na = "") |> select(countrycode = country, party_id) |> mutate(year = 2014)
ches_candidate_2019 <- read_csv("source__data/Mean_Candidate_2019.csv", na = "") |> select(countryname = country, party_id) |> mutate(year = 2019)
ches_flash_2017 <- read_csv("source__data/CHES_means_2017.csv", na = "") |> select(countryshort = country, party_id, year)
ches_covid_2020 <- read_csv("source__data/CHES_COVID.csv", na = "") |> select(countrycode = country, party_id) |> mutate(year = 2020)
ches_ukraine_2023 <- read_csv("source__data/CHES_Ukraine_March_2024.csv", na = "") |> select(countryname = country, party_id) |> mutate(year = 2023)

ches_latin_2020 <- read_csv("source__data/ches_la_2020_aggregate_level_v01.csv", na = "")  |> mutate(countryshort = countrycode(country_en, "country.name", "iso3c")) |> select(countryshort, party_id, party_short = party_abb, party_name = party, party_name_english = party_en) |> mutate(year = 2020)

ches_israel_2021 <- read_csv("source__data/CHES_ISRAEL_means_2021_2022.csv", na = "") |> mutate(countryshort = "ISR", year = 2021,party_short = party_name, party_name = NA, party_name_english = NA) |> select(countryshort, year, party_id, party_short, party_name, party_name_english)

# Keep only one codebook observation for each party
ches_party_codebook_clean <- 
    ches_party_codebook |> 
    slice(1L, .by = c(countrycode, party_id)) |> 
    select(party_id, party_short, party_name, party_name_english)

ches_party_codebook_clean$party_id |> duplicated() |> any()

# Bind European data
ches_europe <- 
    bind_rows(
        ches_trend_1999_2019 |> left_join(ches_countries, by = c("countrycode")) |> select(countryshort, year, party_id),
        ches_candidate_2007 |> left_join(ches_countries, by = c("countrycode")) |> select(countryshort, year, party_id),
        ches_candidate_2014 |> left_join(ches_countries, by = c("countrycode")) |> select(countryshort, year, party_id),
        ches_candidate_2019 |> mutate(countryshort = countrycode(countryname, "country.name", "iso3c", custom_match = c("Kosovo" = "XKX"))) |> select(countryshort, year, party_id),
        ches_flash_2017 |> mutate(countryshort = countrycode(str_to_upper(countryshort), "iso3c", "iso3c", custom_match = c("CZ" = "CZE", "FR" = "FRA", "GER" = "DEU", "GR" = "GRC", "IT" = "ITA", "NL" = "NLD", "POR" = "PRT", "SLO" = "SVK", "UK" = "GBR"))) |> select(countryshort, year, party_id),
        ches_covid_2020 |> left_join(ches_countries, by = c("countrycode")) |> select(countryshort, year, party_id),
        ches_ukraine_2023 |> mutate(countryshort = countrycode(countryname, "country.name", "iso3c", custom_match = c("Kosovo" = "XKX"))) |> select(countryshort, year, party_id),
    ) |> 
    left_join(ches_party_codebook_clean, by = c("party_id")) |> 
    filter(!is.na(party_short))

# Bind non-European data
ches_all <- 
    bind_rows(
        ches_europe,
        ches_latin_2020,
        ches_israel_2021
    )

# Extract party appearances
ches <- 
    ches_all |> 
    mutate(
        year_first = min(year, na.rm = TRUE),
        year_last = max(year, na.rm = TRUE),
        .by = c(party_id)
    ) |> 
    select(-year) |> 
    distinct() |> 
    drop_na(party_short)

ches$party_id |> duplicated() |> any()

# Add Party Facts ID (if available)
partyfacts <-
    read_csv("https://partyfacts.herokuapp.com/download/external-parties-csv/", na = "")  |>
    filter(dataset_key == "ches") |>
    select(dataset_party_id, partyfacts_id) |>
    mutate(dataset_party_id = as.numeric(dataset_party_id)) |>
    distinct()

ches_partyfacts <- 
    ches |> 
    left_join(partyfacts, by = c("party_id" = "dataset_party_id"))

# Save the data
write_csv(ches_partyfacts, "ches.csv", na = "")
