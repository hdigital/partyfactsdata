library(tidyverse)


if( ! exists("ab_raw")) {
  ab_raw <- haven::read_sav("source__afrobarometer/merged_r6_data_2016_36countries2.sav.zip")
}

ab <- ab_raw %>%
  filter(Q90A == 1) %>%
  select(country = COUNTRY, party = Q90B) %>%
  filter(party >= 100, party < 9000) %>%
  haven::as_factor() %>%
  mutate(party_id = as.integer(party)) %>%
  mutate_if(is.factor, funs(as.character))

ab_party <- ab %>%
  group_by(country, party, party_id) %>%
  summarise(n = n()) %>%
  group_by(country) %>%
  mutate(share = round(n / sum(n) * 100, 1)) %>%
  ungroup()

english <- read_table('source__afrobarometer/google-10000-english.txt') %>% as_vector()

check_is_english <- function(name) {
  words <- str_split(name, '\\W+') %>% unlist() %>% tolower()
  words <- words[map_int(words, function(x) str_length(x)) > 3]  # minimal word length
  is_english <- any(map_lgl(words, function(x) x %in% english))
  return(is_english)
}
check_is_english <- Vectorize(check_is_english)

ab_party <- ab_party %>%
  mutate(name_short = str_extract(party, "[A-Z]{2,}"),
         name = str_replace(ab_party$party, " *\\([A-Z]+\\)", ""),
         name_english = ifelse(check_is_english(name), name, NA),
         name = ifelse(is.na(name_english), name, NA),
         name = ifelse(! is.na(name_short) & name == name_short, NA, name)
         )

write_csv(ab_party, "afrobarometer.csv", na = "")
