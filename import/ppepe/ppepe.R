library(countrycode)
library(tidyverse)

raw_ppepe <- read_csv("source__ppepe.csv")


## Prepare data ----

ppepe <- 
  raw_ppepe %>% 
  mutate(country_short = countrycode(country, origin = 'country.name', destination = 'iso3c')) %>% 
  group_by(country_short, party_name_short) %>% 
  mutate(
    first = min(year),
    last = max(year),
    share_max = max(vote_share),
    share_year = if_else(vote_share == share_max, year, NA_real_)
  ) %>% 
  ungroup()


## Import dataset ----

ppepe_out <- 
  ppepe %>% 
  filter(! is.na(share_year)) %>% 
  distinct(country_short, party_name_short, .keep_all = TRUE) %>% 
  mutate(
    party_short = str_replace(party_name_short, "( \\+ )(.+)", ""),
    party_id = paste(country_short, party_name_short, sep = "-")
    ) %>% 
  relocate(country_short, party_id, party_short, .before = country) %>% 
  select(country_short:party_eng, first:share_year)

duplicated(ppepe_out$party_id) %>% any()

write_csv(ppepe_out, "ppepe.csv")


## Figure ----

pl <- 
  ppepe_out %>%
  mutate(country = fct_infreq(country) %>% fct_rev()) %>% 
  ggplot(aes(x = country)) +
  geom_bar() +
  coord_flip() +
  theme(axis.title.x = element_blank(), axis.title.y = element_blank()) 

print(pl)
ggsave("ppepe.png", pl, width = 20, height = 15, units = "cm")
