library(tidyverse)
library(countrycode)

file_in <- read_csv("source__epac 2011-17 summary.csv", na = c("", ".a"))

epac <- 
  file_in |> 
  select(country_name, party_id, party_accr, party_name, party_name_en, elecyear, natstrength, seat, regonly) |> 
  mutate(
    countrycode = countrycode(country_name, "country.name", "iso3c", custom_match = c("Kosovo" = "XKX")),
    share = round(if_else(is.na(natstrength), as.numeric(seat), as.numeric(natstrength)), 2),
    share_max = max(share, na.rm = T),
    year_first = min(elecyear, na.rm = T),
    year_last = max(elecyear, na.rm = T),
    .by = c("country_name", "party_id")
  ) |> 
  filter(share == share_max) |> 
  mutate(
    share = if_else(regonly == 1, NA, share),
    elecyear = if_else(regonly == 1, NA, elecyear)
  ) |> 
  slice(1L, .by = party_id) |> 
  select(countrycode, party_id, name_short = party_accr, name = party_name, name_english = party_name_en, year_first, year_last, share_year = elecyear, share, regonly) |> 
  arrange(countrycode, party_id)

epac$party_id |> duplicated() |> any()

write_csv(epac, "epac.csv", na = "")
