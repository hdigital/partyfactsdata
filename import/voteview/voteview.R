library(tidyverse)

vv_raw <- read_csv("sources__HSall_parties.csv")


## Clean-up raw data ----

vv <- 
  vv_raw %>% 
  filter(chamber == "House") %>% 
  group_by(congress) %>% 
  mutate(share = round(100 * n_members / sum(n_members), 1),
         year = 1787 + congress*2) %>% 
  select(year, congress, party_code, party_name, n_members, share) %>% 
  ungroup()


## Party level information ----

vv_first_last <- 
  vv %>% 
  group_by(party_code) %>% 
  summarise(year_first = min(year),
            year_last  = max(year) + 2)

vv_share_max <- 
  vv %>% 
  group_by(party_code) %>% 
  filter(share == max(share)) %>% 
  distinct(party_code, share, year) %>% 
  rename(share_max = share, share_year = year)

vv_party <- 
  vv %>% 
  distinct(party_code, party_name) %>% 
  left_join(vv_first_last) %>% 
  left_join(vv_share_max) %>% 
  distinct(party_code, .keep_all = TRUE) %>% 
  arrange(party_name)


## Final data ----

vv_out <- 
  vv_party %>% 
  mutate(country = "USA") %>% 
  relocate(country) %>% 
  filter(share_max >= 1.0)

write_csv(vv_out, "voteview.csv", na = "")


## Graph ----

pl_dt <- 
  vv %>% 
  mutate(party = fct_other(factor(party_name), keep = c("Democrat", "Republican"))) %>% 
  group_by(year, party) %>% 
  summarise(share = sum(share))

pl <- ggplot(pl_dt, aes(x=year, y=share, fill=party)) +
  geom_area(position = "stack") +
  scale_fill_manual(values = c("blue", "red", "grey70"))

pl

ggsave("voteview.png", pl, width = 20, height = 15, units = "cm")
