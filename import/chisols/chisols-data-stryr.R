library(tidyverse)
library(lubridate)


## Prepare raw data ----

chisols_raw <- read_csv("source__chisolsll_4/chisolsstyr4_0/CHISOLSstyr4_0.csv")

chisols <- chisols_raw %>% mutate(id = row_number())


## Leaders, positions, affiliations ----

affi <-
  chisols %>%
  select(id, tmp=affiliation) %>%
  mutate(
    tmp = str_split(tmp, ", +"),
    tmp = map(tmp, ~ data.frame(tmp=.x, index=seq_along(.x)))
  ) %>%
  unnest(cols = c(tmp)) %>%
  mutate(tmp = str_replace(tmp, " \\(.+", "")) %>%
  rename(affiliation = tmp)

coal <-
  affi %>%
  mutate(affiliation = str_split(affiliation, "/")) %>%
  unnest(cols = c(affiliation))


## Dates ----

ymd_all <-
  chisols %>%
  select(id, starts_with("leaderch")) %>%
  gather(var, value, -id) %>%
  filter( ! is.na(value))

ymd_1 <-
  ymd_all %>%
  mutate(
    var_type = str_replace_all(var, "leaderch|\\d", ""),
    var_num = str_extract(var, "\\d") %>% as.integer() + 1
  )

ymd_2 <-
  ymd_1 %>%
  select(-var) %>%
  spread(var_type, value)

ymd_3 <-
  ymd_2 %>%
  mutate(date = ymd(paste(yr, mo, day))) %>%
  select(id, index = var_num, date)

ymd_add <-
  chisols %>%
  mutate(
    date = ymd(paste0(year, "-01-01")),
    index = 1
    ) %>%
  distinct(id, index, date)

ymd_4 <-
  ymd_3 %>%
  bind_rows(ymd_add) %>%
  arrange(id, date)


## Final data ----

coal_out <-
  ymd_4 %>%
  inner_join(coal) %>%
  left_join(chisols %>% distinct(id, statename)) %>%
  select(statename, date, affiliation, index)

write_csv(coal_out, "source__chisols-data/chisols-stryr-coalition.csv", na = "")


# Party information ----

party <-
  coal_out %>%
  mutate(year = year(date)) %>%
  group_by(statename, affiliation) %>%
  summarise(first = min(year), last = max(year))

write_csv(party, "chisols-party.csv", na = "")
