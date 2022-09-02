library(tidyverse)

source_file <- "source__party-position-tags.csv"

if (FALSE) {
  url <- "https://raw.githubusercontent.com/hdigital/partypositions-wikitags/main/04-data-final/party-position-tags.csv"
  download.file(url, source_file)
}

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
    position, year_first:share_year, tags
  )

write_csv(wp, "wptags.csv", na = "")
