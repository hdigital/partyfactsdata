library(tidyverse)
library(readxl)
library(countrycode)

file_in_s <- 
  read_csv("source__PAGED-basic-party-dataset-Dec-2023.csv", na = "")

file_in_c <-
  read_xlsx("source__PAGED-basic-party-dataset-Dec-2023.xlsx", na = "") |> 
  select(party_id)


paged <- 
  file_in_s |> 
  rename(party_name = party_id) |> 
  bind_cols(file_in_c) |> 
  select(country_id, party_name, party_id, elecdate, seats_party, seats, partyfacts_id) |> 
  mutate(
    countrycode = countrycode(country_id, "country.name", "iso3c"),
    year = as.numeric(str_extract(elecdate, "[:digit:]{4}")),
    seat_share = round(seats_party / seats * 100, 1)
  ) |>
  select(-country_id, -elecdate, -seats_party, -seats) |> 
  mutate(
    year_first = min(year, na.rm = T),
    year_last = max(year, na.rm = T),
    .by = c(party_id)
  ) |> 
  arrange(-seat_share) |> 
  slice(1L, .by = c(party_id)) |> 
  mutate(drop = if_else(str_detect(party_name,"98|99"), 1, 0)) |> 
  filter(drop == 0) |> 
  select(-drop) |> 
  mutate(
    party_name = case_when(
      party_id == 30021 ~ NA_character_,
      party_id == 60011 ~ "DA-FVP",
      party_id == 70003 ~ "SPAD",
      party_id == 70005 ~ "OIKEN",
      T ~ party_name
    )
  ) |> 
  drop_na(party_name) |> 
  filter(seat_share >= 5) |> 
  select(countrycode, party_name, party_id, year_first, year_last, seat_share, year, partyfacts_id) |> 
  distinct()


write_csv(paged, "paged.csv", na = "")
