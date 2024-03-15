library(tidyverse)
library(readstata13)
library(countrycode)

file_in <- 
  read_csv("source__PAGED-basic-party-dataset-Dec-2023.csv", na = "")

paged <- 
  file_in |> 
  mutate(
    party_abbr = if_else(party_abbr == "Other minor parties and/or independents", "Others/Indep.", party_abbr),
    countrycode = countrycode(country_id_iso, "iso3n", "iso3c"),
    year = as.numeric(str_extract(elecdate, "[:digit:]{4}")),
    seat_share = round(seats_party / seats * 100, 1),
    year_first = min(year, na.rm = T),
    year_last = max(year, na.rm = T),
    .by = c(party_id)
  ) |> 
  arrange(-seat_share) |> 
  slice(1L, .by = c(party_id)) |> 
  filter(seat_share >= 2.5 | !is.na(partyfacts_id)) |> 
  select(countrycode, party_abbr, party_id, year_first, year_last, seat_share, year) |> 
  distinct() |> 
  mutate(
    countrycode = case_when(
      countrycode == "THA" ~ "NLD",
      countrycode == "ARE" ~ "GBR",
      T ~ countrycode
    )
  )

write_csv(paged, "paged.csv", na = "")
