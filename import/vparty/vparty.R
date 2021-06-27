library(tidyverse)

# use Base R csv-import to avoid readr import issues
raw_vparty <- read.csv("source__V-Dem-CPD-Party-V1.csv", na = "", encoding="UTF-8")


## Clean-up data ----

vparty <-
  raw_vparty %>%
  select(country_text_id, v2pashname, v2paenname, year,
         v2pavote, v2paseatshare, v2paid, pf_party_id) %>%
  mutate(share = if_else(is.na(v2pavote), v2paseatshare, v2pavote)) %>%
  group_by(v2paid) %>%
  mutate(
    year_first = min(year, na.rm = T),
    year_last = max(year, na.rm = T)
  ) %>%
  arrange(-share) %>%
  slice(1L) %>%
  select(
    country = country_text_id,
    name_short = v2pashname,
    name_english = v2paenname,
    year_first,
    year_last,
    share,
    share_year = year,
    party_id = v2paid
  ) %>% 
  mutate(
    country = if_else(country == "VDR", "VNR", country),
    partyfacts_id = if_else(str_detect(name_english, "alliance:"), NA_integer_, party_id)
    ) %>% 
  ungroup()

vparty$party_id %>% duplicated() %>% any()

write_csv(vparty, "vparty.csv", na = "")


## Figure map ----

library(sf)

map <- read_rds("../worldmap.rds")  # Natural Earth based world map

map_pa <- 
  map %>% 
  inner_join(vparty %>% count(country, name = "parties"))

pl <- ggplot() + 
  geom_sf(data = map, lwd = 0.1, fill = "grey85") +
  geom_sf(data = map_pa, aes(fill = parties), lwd = 0.25) +
  coord_sf(crs = "+proj=robin") +  # World
  scale_fill_continuous(
    trans = "log",
    breaks = c(3, 6, 12, 25, 50, 100),
    low = "thistle2",
    high = "darkblue",
    # low="#fff7bc", high="#d95f0e",
    guide = "colorbar",
    na.value = "lightgrey"
  ) +
  theme_bw()

print(pl)
ggsave("vparty.png", pl, width = 8, height = 6)

