library(tidyverse)
library(readxl)

# country codes
country_code <-
  tibble(
    country_id = c(1,2,3,4,5,6,7,8,9,10,12,13,14,15,16,17,18,20,21,22,23,24,26,27,28,29,30),
    countrycode = c("AUT", "BEL", "DNK", "FIN", "FRA", "DEU", "GRC", "ISL", "IRL", "ITA", "NLD", "NOR", "PRT", "ESP", "SWE", "GBR", "BGR", "CZE", "EST", "HUN", "LVA", "LTU", "POL", "ROU", "SVK", "SVN", "HRV")
  )

# import datasets
paged_s <- 
  read_xlsx("source__dataset CEE+Croatia party dataset (string codes).xlsx", na = "") |> 
  select(party_id_s = party_id)

paged_c <- 
  read_xlsx("source__dataset WE+CEE+Croatia party dataset (party codes).xlsx", na = "") 

# prepare data
paged <- 
  paged_c |> 
  cbind(paged_s) |> 
  left_join(country_code, by = "country_id") |> 
  mutate(
    party_name = if_else(str_length(party_id_s) >= 25, party_id_s, NA_character_),
    party_id_s = if_else(str_length(party_id_s) >= 25, NA_character_, party_id_s),
    seat_share = round(party_seats / seats * 100, 1),
    year = str_extract(elecdate, "[:digit:]{4}"),
    second_partyfacts_id = if_else(str_detect(partyfacts_id, "\\;"), as.numeric(str_extract(partyfacts_id, "(?<=\\;)[:digit:]*")), NA_real_),
    partyfacts_id = if_else(str_detect(partyfacts_id, "\\;"), as.numeric(str_extract(partyfacts_id, "[:digit:]*(?=\\;)")), as.numeric(partyfacts_id)),
  ) |> 
  mutate(
    max_share = max(seat_share, na.rm = F),
    year_first = min(year, na.rm = T),
    year_last = max(year, na.rm = T),
    .by = c(party_id)
  ) |> 
  filter(seat_share == max_share) |> 
  slice(1L, .by = c(party_id)) |> 
  select(countrycode, cab_name, party_id, party_id_s, year_first, year_last, seat_share, party_seats, year, partyfacts_id, second_partyfacts_id) %>% 
  filter(seat_share >= 1) # high threshold to avoid small parliamentary groups

write_csv(paged, "paged.csv", na = "")

