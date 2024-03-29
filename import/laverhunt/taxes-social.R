library(tidyverse)
library(ggrepel)

lh_raw <- read_csv("source__laver_hunt_1992/laver_hunt_1992.csv")

pl_dt <-
  lh_raw %>%
  filter(scale == "Position Voters (L&H)") %>%
  mutate(country_name = countrycode::countrycode(country_iso, "iso3c", "country.name")) %>%
  select(country = country_name, party, dimension_name, mean) %>%
  spread(dimension_name, mean)

pl <-
  ggplot(pl_dt, aes(x = `Taxes v. Spending`, y = Social, label = party)) +
  geom_smooth(method = "lm", formula = y ~ x, se = FALSE, color = "grey80") +
  geom_point(color = "blue") +
  geom_text_repel(size = 2) +
  facet_wrap(~ country)

print(pl)
ggsave("taxes-social.png", pl, width = 20, height = 15, units = "cm")
