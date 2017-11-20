library(tidyverse)

share_filter <- 10

parties_file <- "wvs-parties.csv"

if( ! file.exists(parties_file)) {
  url <- "https://docs.google.com/spreadsheets/d/1cbWV1CX1kzkw2_bEVtLoaR_qhIOzSDVLFc7fHOYzw4w/pub?output=csv"
  download.file(url, parties_file, mode="wb")
}

wvs_all <- read_csv(parties_file)

share_all <- read_csv("wvs-share.csv")
linked_all <- read_csv("wvs-linked-2017-03-12.csv")

linked <- linked_all %>% filter( ! is.na(partyfacts_id))

share <- share_all %>%
  group_by(party) %>% 
  mutate(year_first = min(year) - 4, year_last = max(year),
         share_max = max(share),
         waves = paste(sort(wave), collapse = " ")) %>%
  filter(share == share_max) %>% 
  distinct(party, .keep_all = TRUE) %>% 
  select(id=party, year_first, year_last, share_max, share_year=year, waves)

wvs <- wvs_all %>%
  filter(ignore == 0, is.na(id_duplicate)) %>% 
  select(-ignore, -id_duplicate) %>%
  left_join(share) %>% 
  arrange(id) %>% 
  filter(! is.na(share_max),         # exclude parties with no respondents 
         (share_max >= share_filter  # size filter import
          | (share_max >= 1.0 & id %in% linked$dataset_party_id)))  # already linked

wvs <- wvs %>% mutate_at(vars(starts_with("year_")), as.integer)
write_csv(wvs, "wvs.csv", na = "")
