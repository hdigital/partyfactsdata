library(tidyverse)

raw_mudde <- read_csv("source__mudde.csv")

mudde <- raw_mudde %>% 
  mutate(
    party_id = paste(country, name_short, year_first, sep = "-")
  )

duplicated(mudde$party_id) %>% any()

write_csv(mudde, "mudde.csv", na = "")
