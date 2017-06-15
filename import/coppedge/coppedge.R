library(tidyverse)

parties_file <- "coppedge-parties.csv"

if( ! file.exists(parties_file)) {
  url <- "https://docs.google.com/spreadsheets/d/1KwaCELyZ4qhVwSYPYl5z_DK2gO_UTmDgfFvxKvHbekk/pub?output=csv"
  download.file(url, parties_file, mode="wb")
}

coppedge_raw <- read_csv(parties_file)

# remove duplicates and add first/last year
coppedge <- coppedge_raw %>%
  mutate(id = ifelse(is.na(id_duplicate), id, id_duplicate)) %>%
  rename(first = year_first, last = year_last) %>%
  group_by(id) %>%
  mutate(year_first = min(first), year_last = max(last)) %>%
  distinct(id, .keep_all = TRUE) %>%
  select(-id_duplicate, -first, -last)

# filter parties to ignore and short lived parties
coppedge <- coppedge %>%
  filter(ignore_partyfacts == 0, year_first != year_last) %>%
  select(-ignore_partyfacts)

# filter Argentina parties more restrictivly
coppedge <- coppedge[ ! with(coppedge, country == "ARG" & year_last - year_first < 20) , ]

write.csv(coppedge, "coppedge.csv", na = "")
