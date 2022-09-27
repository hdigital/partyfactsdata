library(tidyverse)

source_file <- "source__party-position-tags.csv"

if (FALSE) {
  url <- "https://raw.githubusercontent.com/hdigital/partypositions-wikitags/main/04-data-final/party-position-tags.csv"
  download.file(url, source_file)
}

## Create dataset ----

wp_raw <- read_csv(source_file)

wp <- wp_raw %>%
  filter(!is.na(position)) %>%
  mutate(
    left_right = round(position, 2),
    tags = glue::glue(
      "tags position: {tags_position}\n",
      "tags ideology: {tags_ideology}\n",
      "tags used: {tags_used}",
      .na = ""
    ),
  ) %>%
  select(
    country, partyfacts_id, starts_with("name"),
    left_right, year_first:share_year, tags
  )

write_csv(wp, "wptags.csv", na = "")


## Figure map ----

library(sf)

map <- read_rds("../worldmap.rds")  # Natural Earth based world map

map_pa <-
  map %>%
  inner_join(wp %>% count(country, name = "parties"))

pl <- ggplot() +
  geom_sf(data = map, lwd = 0.1, fill = "grey85") +
  geom_sf(data = map_pa, aes(fill = parties), lwd = 0.25) +
  coord_sf(crs = "+proj=robin") +  # World
  scale_fill_continuous(
    trans = "log",
    breaks = c(3, 6, 12, 25, 50, 100),
    low = "thistle2",
    high = "darkblue",
    # low="#fff7bc", high="#d95f0e",
    guide = "colorbar",
    na.value = "lightgrey"
  ) +
  theme_bw()

print(pl)
ggsave("wptags.png", pl, width = 8, height = 6)