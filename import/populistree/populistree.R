library(tidyverse)
library(readxl)
library(countrycode)

# LOAD DATA
raw_data_national <- read_xlsx("source__ok_dataset_national-elections.xlsx")
raw_data_european <- read_xlsx("source__dataset_European_Parliament-elections.xlsx")

# PREPARE EUROPEAN DATA
data_european <- 
  raw_data_european |> 
  mutate(
    countrycode = countrycode(Country, "country.name", "iso3c", custom_match = c("United Kindgom" = "GBR")),
    name_short = Party_name_short,
    name_english = Party_name_eng,
    name = Party_name,
    year_first = min(Year, na.rm = T),
    year_last = max(Year, na.rm = T),
    share = max(Vote_share, na.rm = T),
    share_year = Year,
    party_id = paste(countrycode, name_short, sep = "-"),
    partyfacts_id = Partyfacts_id,
    .by = c(Country, Party_name_short)
  ) |> 
  filter(Vote_share == share) |> 
  select(countrycode, name_short, name_english, name, year_first, year_last, share, share_year, party_id, partyfacts_id) |> 
  distinct() |> 
  slice(1L, .by = c(party_id))

# PREPARE NATIONAL DATA
data_national <- 
  raw_data_national |> 
  mutate(
    Populist_start = if_else(Populist_start == 1900, 1989, Populist_start),
    Populist_end = if_else(Populist_end == 2100, 2022, Populist_end),
    countrycode = countrycode(Country, "country.name", "iso3c"),
    name_short = Party_name_short,
    name_english = Party_name_eng,
    name = Party_name,
    year_first = min(Populist_start, na.rm = T),
    year_last = max(Populist_end, na.rm = T),
    share = NA_integer_,
    share_year = NA_integer_,
    party_id = paste(countrycode, name_short, sep = "-"),
    partyfacts_id = Partyfacts_id,
  ) |> 
  select(countrycode, name_short, name_english, name, year_first, year_last, share, share_year, party_id, partyfacts_id) |> 
  distinct() |> 
  slice(1L, .by = c(party_id))

# COMBINE DATA AND CLEAN
data <- 
  rbind(data_european, data_national) |>
  mutate(
    name_short = if_else(                                                       # Shorten name_short to 24 character
      str_length(name_short) > 24,
      str_sub(name_short, 1, 24),
      name_short
    ),
    partyfacts_id = if_else(partyfacts_id == 2368, NA, partyfacts_id)           # Remove partyfacts_id from Benin
  ) |>
  slice(1L, .by = party_id)

# CHECK FOR DUPLICATES
data$party_id |> duplicated() |> any()

# WRITE DATA
write_csv(data, "populistree.csv", na = "")
