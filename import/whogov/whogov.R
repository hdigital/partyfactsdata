library(tidyverse)


raw_whogov <- read_csv("source__whogov/whogov.zip", na = "NA")


## PF-Data linked ----

# keep data below inclusion threshold but linked by automatic import previously

if(FALSE) {
  read_csv("source__whogov/partyfacts-external-parties.csv", 
           na = "",
           guess_max = 50000) %>% 
    filter(dataset_key == "whogov") %>% 
    select(dataset_party_id, partyfacts_id) %>% 
    write_csv("partyfacts-whogov.csv", na = "")
}

pf_ext <- read_csv("partyfacts-whogov.csv", na = "")


## Select variables ----

whogov <- 
  raw_whogov %>% 
  drop_na(party) %>% 
  select(country_isocode, country_name, year, party, party_english, party_otherlanguage) %>% 
  distinct() %>% 
  mutate(
    party_id = paste(country_isocode, party, sep = "-"),
    country_isocode = case_when(
      country_isocode == "YUG" ~ "SRB",
      country_isocode == "SUN" ~ "RUS",
      country_isocode == "YPR" ~ "YMD",
      country_isocode == "DVN" ~ "VNM",
      country_isocode == "RVN" ~ "VNR",
      TRUE ~ country_isocode
    ),
    party_english = case_when(
      party_id == "AFG-nca" ~ "National Coalition of Afghanistan",
      party_id == "BGD-jeb" ~ "Bangladesh Jamaat-e-Islami",
      T ~ party_english
    ),
    party_otherlanguage = case_when(
      str_detect(party_otherlanguage, "<U+") ~ NA_character_,
      T ~ party_otherlanguage
    )
  ) %>% 
  group_by(party_id) %>% 
  mutate(
    year_first = min(year, na.rm = T),
    year_last = max(year, na.rm = T),
    n = n()
  ) %>% 
  select(-year)


duplicated(whogov$party_id) %>% any()


## First minister ----

wg_first <- 
  raw_whogov %>% 
  distinct(country_isocode, party, .keep_all = TRUE) %>% 
  mutate(
    minister_first = glue::glue("{year} {name} ({position})"),
    minister_first = str_replace(minister_first, fixed("Min. Of "), "Minister of ")
    ) %>% 
  select(country_isocode, party, minister_first)


# Final data ----

file_out <- 
  whogov %>% 
  left_join(wg_first) %>% 
  left_join(pf_ext, by = c("party_id" = "dataset_party_id")) %>% 
  distinct() %>% 
  drop_na(party) %>% 
  group_by(party_id) %>% 
  slice(1L) %>% 
  ungroup() %>% 
  mutate(name_short = toupper(party)) %>% 
  rename(
    country_short = country_isocode,
    country = country_name,
    name_english = party_english,
    name = party_otherlanguage
  ) %>% 
  relocate(name_short, .before = name_english) %>% 
  filter( ! party %in% c("unknown")) %>% 
  filter(n > 5 | ! is.na(partyfacts_id))


duplicated(file_out$party_id) %>% any()


write.csv(file_out, "whogov.csv", na = "", fileEncoding = "UTF-8", row.names = FALSE)


## Figure ----

library(sf)  # for plot world map


world <- 
  read_rds("../worldmap.rds") %>% 
  select(country_short = country) %>% 
  left_join(file_out) %>% 
  count(country, name = "parties")

pl <- 
  ggplot(world) + 
  geom_sf(aes(fill = parties), lwd = 0.1, colour = "darkgrey") +
  coord_sf(crs = "+proj=robin") +
  viridis::scale_fill_viridis(option="magma", direction = -1, na.value="lightgrey") +
  theme_void()

ggsave("whogov.png", pl, width = 20, height = 15, units = "cm")
