library(tidyverse)
library(countrycode)

guess_encoding("source__epac 2011-17 summary.csv")

file_in <- read.csv("source__epac 2011-17 summary.csv", na = c("", ".a"))

epac <-
  file_in |>
  ## select relevant variables
  select(
    country_name,
    party_id,
    party_accr,
    party_name,
    party_name_en,
    elecyear,
    natstrength,
    seat,
    regonly
  ) |>
  mutate(
    ## ISO3c country code
    countrycode = countrycode(
      country_name,
      "country.name",
      "iso3c",
      custom_match = c("Kosovo" = "XKX")
    ),
    ## either vote share or seat share (vote share preferred)
    share = round(
      if_else(is.na(natstrength), as.numeric(seat), as.numeric(natstrength)),
      2
    ),
    ## identify max share
    share_max = max(share, na.rm = T),
    ## first and last election participation
    year_first = min(elecyear, na.rm = T),
    year_last = max(elecyear, na.rm = T),
    # group by country and party ID
    .by = c("country_name", "party_id")
  ) |>
  ## keep observation with highest share for party
  filter(share == share_max) |>
  ## remove share for regional parties
  mutate(
    share = if_else(regonly == 1, NA, share),
    elecyear = if_else(regonly == 1, NA, elecyear)
  ) |>
  ## one observation per party ID
  slice(1L, .by = party_id) |>
  mutate(
    ## Fix encoding issue
    party_accr = if_else(party_id == 3108, "POc", party_accr),
    party_name = if_else(
      party_id == 8711,
      "Latvijas Pirmā partija/Latvijas Ceļš",
      party_name
    ),
    party_name = if_else(
      party_id == 3213,
      "Autonomie, Liberté, Participation, Écologie",
      party_name
    ),
    party_name = if_else(
      party_id == 8712,
      "Latvijas Krievu savienība",
      party_name
    ),
    party_name_en = if_else(
      party_id == 9105,
      "New Democratic Power – FORCA",
      party_name_en
    ),
    party_name_en = if_else(
      party_id == 9602,
      "Slovak Democratic and Christian Union – Democratic Party",
      party_name_en
    ),
    party_accr = str_trim(party_accr),
    party_name = str_trim(party_name),
    party_name_en = str_trim(party_name_en)
  ) |>
  ## select and rename variables
  select(
    countrycode,
    party_id,
    name_short = party_accr,
    name_english = party_name_en,
    year_first,
    year_last,
    share_year = elecyear,
    share,
    regonly
  ) |>
  ## order by countrycode and party ID
  arrange(countrycode, party_id)

write.csv(epac, "epac.csv", na = "", row.names = F, fileEncoding = "UTF-8")
