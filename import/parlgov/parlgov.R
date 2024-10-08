library(tidyverse)
library(dbplyr)


# Get/read data ----

db_file <- "source__parlgov-stable.db"
if (!file.exists(db_file)) {
  url <- "https://www.parlgov.org/data/parlgov-development.db"
  download.file(url, db_file, mode = "wb")
}

con <- DBI::dbConnect(RSQLite::SQLite(), db_file)
tbl_parlgov <- function(table) tbl(con, table) |> as_tibble()

party_pg <- tbl_parlgov("view_party")
elec_pg <- tbl_parlgov("view_election")
cab_pg <- tbl_parlgov("view_cabinet")
party_raw <- tbl_parlgov("party")


# Summarize information ----

# calculate first and last year each party
elec_year <- elec_pg |>
  mutate(year = substr(election_date, 1, 4)) |>
  group_by(party_id) |>
  summarise(first = min(year, na.rm = TRUE), last = max(year, na.rm = TRUE)) |>
  select(party_id, first, last)

# calculate max vote share each party
get_elec_share <- function(elec_type = "parliament") {
  elec_share <- elec_pg |>
    filter(election_type == elec_type) |>
    group_by(party_id) |>
    mutate(
      election_n = n(),
      seats = ifelse(seats >= 2, seats, 0), # ignore 1 seats parties
      share = ifelse(vote_share, vote_share, 100 * seats / seats_total),
      share_max = max(share, na.rm = TRUE)
    ) |>
    filter(share == share_max) |>
    distinct(party_id, .keep_all = TRUE) |>
    ungroup() |>
    mutate(
      share_max = round(share_max, 1),
      share_max_year = substr(election_date, 1, 4)
    ) |>
    select(party_id, election_n, share_max_year, share_max)
}

elec_share_parl <- get_elec_share("parliament")
elec_share_ep <- get_elec_share("ep") |> filter(!party_id %in% elec_share_parl$party_id)
elec_share <- elec_share_parl |> bind_rows(elec_share_ep)

# number of cabinet memberships
cab_n <-
  cab_pg |>
  filter(cabinet_party == 1) |>
  count(party_id) |>
  rename(cabinet_n = n)

# party information
`%notin%` <- Negate(`%in%`)

parlgov_url <- "https://parlgov.fly.dev/data/parties/%s/%d"
party_info <-
  party_pg |>
  select(party_id, country_name_short:family_name, -country_name, -party_name_ascii, -family_name) |>
  filter(party_name_short %notin% c("none", "no-seat", "one-seat", "etc")) |>
  mutate(url = sprintf(parlgov_url, tolower(country_name_short), party_id)) |>
  rename(country = country_name_short, family = family_name_short)


# Create dataset ----

# Combine ParlGov information
parlgov <-
  party_info |>
  left_join(elec_year) |>
  left_join(cab_n) |>
  left_join(elec_share) |>
  left_join(party_raw |> select(id, wikipedia), by = c("party_id" = "id")) |>
  arrange(country, party_name)

# recode Denmark autonomous regions
parlgov <- parlgov |>
  mutate(
    country = case_when(
      str_detect(party_name_english, fixed("(Faroe Islands)")) ~ "FRO",
      str_detect(party_name_english, fixed("(Greenland)")) ~ "GRL",
      TRUE ~ country
    )
  )


# Select parties ----

# specify filter criteria to ignore small parties
parlgov_out <-
  parlgov |>
  filter(share_max >= 1 | election_n >= 3 | cabinet_n >= 1)

write_csv(parlgov_out, "parlgov.csv", na = "")


# Figure map ----

library(sf)

map <- read_rds("../worldmap.rds") # Natural Earth based world map

map_pa <-
  map |>
  inner_join(parlgov_out |> count(country, name = "parties"))

pl <- ggplot() +
  geom_sf(data = map, lwd = 0.1, fill = "grey85") +
  geom_sf(data = map_pa, aes(fill = parties), lwd = 0.25) +
  # coord_sf(crs = "+proj=robin") +  # World
  coord_sf(
    crs = "+proj=lcc +lat_1=43 +lat_2=62 +lat_0=30 +lon_0=10", # LCC Europe parameters
    xlim = c(-1700000, 1750000), ylim = c(750000, 4000000)
  ) + # set map limits
  scale_fill_gradient2() +
  theme_bw()

print(pl)
ggsave("parlgov-map.png", pl, width = 8, height = 6)


# Figure bar chart ----

pl_dt <-
  parlgov_out |>
  left_join(party_pg |> select(country_name, party_id)) |>
  mutate(country_name = fct_infreq(country_name) |> fct_rev())

pl <-
  ggplot(pl_dt, aes(x = country_name)) +
  geom_bar() +
  coord_flip() +
  theme(axis.title.x = element_blank(), axis.title.y = element_blank())

print(pl)
ggsave("parlgov.png", pl, width = 20, height = 15, units = "cm")
