library(tidyverse)

file_in <- read_csv("nped.csv", na = "")

# add name_short & party_id
file_out <-
  file_in %>%
  mutate(
    name_short = str_remove_all(name_english, "[[:lower:]*[:space:]*[:punct:]*]"),
    party_id = paste(country, name_short, year_first, sep = "-"),
    party_id = case_when(
      name_english == "Francophone Socialist Party" ~ "BEL-FSP-1978-1",
      name_english == "Flemish Socialist Party" ~ "BEL-FSP-1978-2",
      TRUE ~ party_id
    )
  )

# check for duplicate party_id
duplicated(file_out$party_id) %>% any()

write_csv(file_out, "nped.csv", na = "")
