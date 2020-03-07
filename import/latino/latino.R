library(tidyverse)

## load latino-parties
latino_parties <- read_csv("latino-parties.csv")

## filter share
latino <-
  latino_parties %>%
  filter(share >= 5)

## check for duplicates
duplicated(latino$party_id) %>% any()

## write csv
write_csv(latino, "latino.csv", na = "")
