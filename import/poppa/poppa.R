library(tidyverse)
library(countrycode)

raw_poppa <- 
  read_csv("source__poppa_integrated.csv", na = "NA")

poppa <- 
  raw_poppa |> 
  select(wave, country_short, party_short, party_name_english, party_name_original, poppa_id, partyfacts_id) |> 
  mutate(
    year = as.numeric(str_extract(wave, "[:digit:]{4}$")),
    year_first = min(year, na.rm = T),
    year_last = max(year, na.rm = T),
    .by = c("poppa_id")
  ) |> 
  select(-wave, -year) |> 
  distinct()

poppa |> select(poppa_id) |> duplicated() |> any()

write_csv(poppa, "poppa.csv", na = "")
