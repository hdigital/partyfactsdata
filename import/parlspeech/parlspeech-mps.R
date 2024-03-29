library(tidyverse)
library(glue)

# load ParlSpeech data and select variables
get_ps_data <- function(file_name) {
  read_rds(file_name) %>%
    select(iso3country, date, party, party.facts.id, speaker) %>%
    distinct()
}

ps_files <- fs::dir_ls("source__parlspeech", glob = "*_V2.rds")
ps_all <- map_df(ps_files, get_ps_data)

ps_out <-
  ps_all %>%
  group_by(iso3country, party, speaker) %>%
  summarise(
    date_first = min(date),
    date_last = max(date),
    party.facts.id = first(party.facts.id)
  ) %>%
  arrange(iso3country, speaker, date_first)

write_csv(ps_out, "parlspeech-mps.csv")
