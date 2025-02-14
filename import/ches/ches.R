library(tidyverse)
library(countrycode)

# Load the data + specify the variables to be used
ches_countries <- read_csv("ches-party-codebooks.csv", na = "", locale = locale(encoding = "UTF-8")) |> 
    select(countrycode, countryshort, countryname) |> 
    distinct()

ches_trend_1999_2019 <- read_csv("source__data/1999-2019_CHES_dataset_means(v3).csv", na = "", locale = locale(encoding = "ASCII")) |> 
    select(countrycode = country, party_id, party, year)

ches_candidate_2007 <- read_csv("source__data/2007_CHES-candidates_dataset_means.csv", na = "", locale = locale(encoding = "windows-1252")) |> 
    select(countrycode = country, party_id, party, year)

ches_candidate_2014 <- read_csv("source__data/Candidate_Ukraine_2014.csv", na = "", locale = locale(encoding = "ASCII")) |> 
    select(countrycode = country, party_id, party = party_name) |> 
    mutate(year = 2014)

ches_candidate_2019 <- read_csv("source__data/Mean_Candidate_2019.csv", na = "", locale = locale(encoding = "ASCII")) |> 
    select(countryname = country, party_id, party) |> 
    mutate(year = 2019)

ches_flash_2017 <- read_csv("source__data/CHES_means_2017.csv", na = "", locale = locale(encoding = "UTF-8")) |> 
    select(countryshort = country, party_id, party, year)

ches_covid_2020 <- read_csv("source__data/CHES_COVID.csv", na = "", locale = locale(encoding = "UTF-8")) |> 
    select(countrycode = country, party_id, party) |> 
    mutate(year = 2020)

ches_ukraine_2023 <- read_csv("source__data/CHES_Ukraine_March_2024.csv", na = "", locale = locale(encoding = "UTF-8")) |> 
    select(countryname = country, party_id, party) |> 
    mutate(year = 2023)

ches_latin_2020 <- read_csv("source__data/ches_la_2020_aggregate_level_v01.csv", na = "", locale = locale(encoding = "windows-1252")) |> 
    mutate(countryshort = countrycode(country_en, "country.name", "iso3c")) |> 
    select(countryshort, party_id, party = party_abb) |> 
    mutate(year = 2020)

ches_israel_2021 <- read_csv("source__data/CHES_ISRAEL_means_2021_2022.csv", na = "", locale = locale(encoding = "ASCII")) |> 
    mutate(countryshort = "ISR", year = 2021, party = party_name) |> 
    select(countryshort, year, party_id, party)

# Bind European data
ches_europe <- 
    bind_rows(
        ches_trend_1999_2019 |> left_join(ches_countries, by = c("countrycode")) |> select(countryshort, year, party_id, party),
        ches_candidate_2007 |> left_join(ches_countries, by = c("countrycode")) |> select(countryshort, year, party_id, party),
        ches_candidate_2014 |> left_join(ches_countries, by = c("countrycode")) |> select(countryshort, year, party_id, party),
        ches_candidate_2019 |> mutate(countryshort = countrycode(countryname, "country.name", "iso3c", custom_match = c("Kosovo" = "XKX"))) |> select(countryshort, year, party_id, party),
        ches_flash_2017 |> mutate(countryshort = countrycode(str_to_upper(countryshort), "iso3c", "iso3c", custom_match = c("CZ" = "CZE", "FR" = "FRA", "GER" = "DEU", "GR" = "GRC", "IT" = "ITA", "NL" = "NLD", "POR" = "PRT", "SLO" = "SVK", "UK" = "GBR"))) |> select(countryshort, year, party_id, party),
        ches_covid_2020 |> left_join(ches_countries, by = c("countrycode")) |> select(countryshort, year, party_id, party),
        ches_ukraine_2023 |> mutate(countryshort = countrycode(countryname, "country.name", "iso3c", custom_match = c("Kosovo" = "XKX"))) |> select(countryshort, year, party_id, party),
    )

# Bind non-European data
ches_all <- 
    bind_rows(
        ches_europe |> mutate(party_id = as.numeric(party_id)),
        ches_latin_2020 |> mutate(party_id = as.numeric(party_id)),
        ches_israel_2021 |> mutate(party_id = as.numeric(party_id))
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
    slice(1L, .by = c("party_id"))

ches$party_id |> duplicated() |> any()

# Add Party Facts ID (if available)
partyfacts <- 
    read_csv("https://partyfacts.herokuapp.com/download/external-parties-csv/", na = "", locale = locale(encoding = "UTF-8")) |> 
    filter(dataset_key == "ches") |> 
    select(dataset_party_id, partyfacts_id) |> 
    mutate(dataset_party_id = as.numeric(dataset_party_id)) |> 
    distinct()

ches_partyfacts <- 
    ches |> 
    left_join(partyfacts, by = c("party_id" = "dataset_party_id"))

encoding_info <- sapply(ches_partyfacts, function(x) {
    if (is.character(x)) unique(stri_enc_detect(x)[[1]]$Encoding) else NA
})

print(encoding_info)

write_csv(ches_partyfacts, "ches.csv", na = "")
