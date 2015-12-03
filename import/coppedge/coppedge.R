library("dplyr")
library("RCurl")

coppedge_raw <- read.csv("coppedge-parties.csv", encoding = "UTF-8", as.is=TRUE)

# remove duplicates and add first/last year
coppedge <- coppedge_raw %>%
  mutate(id = ifelse(is.na(id_duplicate), id, id_duplicate)) %>%
  rename(first=year_first, last=year_last) %>%
  group_by(id) %>%
  mutate(year_first = min(first), year_last = max(last)) %>%
  distinct(id) %>%
  select(-id_duplicate, -first, -last)

# filter parties to ignore and short lived parties
coppedge <- coppedge %>%
  filter(ignore_partyfacts == 0, year_first != year_last) %>% 
  select(-ignore_partyfacts)

write.csv(coppedge, "coppedge.csv", na='', fileEncoding = "utf-8", row.names = FALSE)
