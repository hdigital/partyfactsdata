library(tidyverse)

if (!exists("pf_core")) {
  url <- "https://partyfacts.herokuapp.com/download/core-parties-csv/"
  pf_core <- read_csv(url)
}

world <- read_rds("figure_worldmap.rds") %>% mutate(id = iso3)

pf_dt <- pf_core %>% filter(is.na(technical))

pf_map <-
  pf_dt %>%
  group_by(country) %>%
  summarise(parties = n()) %>%
  select(country, parties) %>%
  full_join(world %>% select(country = id))

pl <-
  ggplot() +
  geom_map(
    data = world,
    map = world,
    aes(x = long, y = lat, map_id = id),
    fill = "#ffffff",
    color = "#ffffff",
    linewidth = 0.15
  ) +
  geom_map(
    data = pf_map,
    map = world,
    aes(fill = parties, map_id = country),
    color = "#ffffff",
    linewidth = 0.15
  ) +
  coord_equal() +
  ggthemes::theme_map() +
  scale_fill_continuous(
    trans = "log",
    breaks = c(3, 6, 12, 25, 50, 100),
    low = "thistle2",
    high = "darkblue",
    # low="#fff7bc", high="#d95f0e",
    guide = "colorbar",
    na.value = "lightgrey"
  ) +
  xlab("") +
  ylab("")


ggsave("figure_worldmap.png", pl, width = 8, height = 6)
print(pl)
