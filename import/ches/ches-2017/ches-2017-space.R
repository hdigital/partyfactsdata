library(tidyverse)
library(countrycode)
library(ggrepel)

ches <- haven::read_dta("source__CHES_means_2017.dta")
ches_pa <- read_csv("ches-2017.csv")

pl_dt <- 
  ches %>% 
  left_join(ches_pa %>% select(party_id, country_iso3)) %>% 
  filter(vote >= 5) %>% 
  mutate(
    country = countrycode(country_iso3, "iso3c", "country.name"),
    left_right = lrgen,
    EU_position = position
  )

pl <- ggplot(pl_dt, aes(x = left_right, y = EU_position, label = party)) +
  geom_point(aes(size = vote), color = "dodgerblue", shape = 20, alpha = 0.7) +
  geom_text_repel(size = 2.5) +
  facet_wrap(~ country)

print(pl)
ggsave("ches-2017-space.png", pl, width = 20, height = 15, units = "cm")
