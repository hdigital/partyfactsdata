library(tidyverse)

janda <- read_csv("janda-parties.csv")
country <- read_csv("janda-country.csv")

# extract country id from party id
janda <- janda %>%
  mutate(
    country_id = substr(janda_id, 1, nchar(janda_id) - 1) %>% as.integer,
    country_id = ifelse(janda_id >= 10, country_id, 0)  # add US country id "0"
    )

# merge parties and country list
janda <- janda %>%
  left_join(country, by = c("country_id" = "id")) %>%
  select(-country_id, country_short = short)

write_csv(janda, "janda.csv", na = "")
