library(tidyverse)
library(glue)
library(lubridate)

## Prepare raw data ----

chisols_raw <- read_csv("source__chisolsll_4/chisolsll4_0/CHISOLSll4_0.csv")


## Chisols clean-up ----

# affiliation to be based on yearly data with all change dates

chisols <-
  chisols_raw %>%
  filter(! is.na(begyr)) %>%
  mutate(
    id = row_number(),
    begin = as_date(paste(begyr, begmo, begday, sep = "-")),
    parties = str_split(affiliation, " *[/,]+ *"),
    coalitions = str_split(affiliation, ", ")
  )


## Leaders ----

leader_out <-
  chisols %>%
  mutate(party = str_replace(affiliation, "/.*", "")) %>%
  select(statename, begin, leader, leaderpos, party, id) %>%
  arrange(statename, begin)

write_csv(leader_out, "source__chisols-data/chisols-leader.csv", na = "")

leader_first <-
  leader_out %>%
  mutate(
    year = year(begin),
    chisols_first = glue::glue("{year} {leader} ({party})")
    ) %>%
  group_by(statename, party) %>%
  slice_head() %>%
  select(statename, party, chisols_first) %>%
  ungroup()

write_csv(leader_first, "chisols-leader-first.csv", na = "")


## Coalitions ----

coal <-
  chisols %>%
  select(id, coalitions) %>%
  mutate(
    coalitions = map(coalitions, ~ data.frame(coalitions=.x, index=seq_along(.x)))
  ) %>%
  unnest(cols = c(coalitions))


## Final data ----

coal_out <-
  coal %>%
  mutate(coalitions = str_split(coalitions, "/")) %>%
  unnest(cols = c(coalitions)) %>%
  rename(party = coalitions)

write_csv(coal_out, "source__chisols-data/chisols-coalition.csv", na = "")
