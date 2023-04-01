library(tidyverse)
library(glue)


raw_ess_clean <- read_csv("02-ess-harmonize.csv")


## Party Facts information ----

if (!exists("pf_party")) {
  # time intense so avoiding rereading
  url <- "https://partyfacts.herokuapp.com/download"
  
  raw_pf_core <- read_csv(glue("{url}/core-parties-csv/"), na = "")
  raw_pf_ext <-
    read_csv(glue("{url}/external-parties-csv/"),
             na = "",
             guess_max = 50000)
  
  pf_ext <-
    raw_pf_ext %>%
    filter(str_starts(dataset_key, "essprt")) %>%
    select(partyfacts_id, first_ess_id = dataset_party_id)
  
  pf_party <-
    raw_pf_core %>%
    select(country,
           name_short,
           name,
           name_english,
           partyfacts_id,
           technical) %>%
    inner_join(pf_ext)
}


## ESS preparation ----

# add some variables needed below
prt <-
  raw_ess_clean %>%
  mutate(
    prt_var = str_extract(ess_variable, "prtv|prtc"),
    year = essround * 2 + 2000,
    essround = paste0("R", essround)
  ) %>%
  unite(ess_info,
        essround,
        ess_variable,
        ess_party,
        sep = " --- ",
        remove = FALSE) %>%
  select(-essround, -ess_variable)

# collapse ESS rounds at the party level
prt_info <-
  prt %>%
  group_by(prt_var, first_ess_id) %>%
  summarise(
    first_ess_name = first(ess_party),
    year_first = min(year),
    year_last = max(year),
    ess_ids = paste(ess_id, collapse = " "),
    ess_info = paste(ess_info, collapse = "\n")
  ) %>%
  mutate(ess_ids = str_replace_all(ess_ids, " +", " "))

prt_out <-
  prt %>%
  distinct(first_ess_id) %>%
  inner_join(prt_info) %>%
  inner_join(pf_party) %>%
  relocate(partyfacts_id, .before = country)


## Link files ----

# question vote intention (prtv*)
prt_out %>%
  filter(prt_var == "prtv") %>%
  select(-prt_var) %>%
  write_csv("essprtv.csv", na = "")

# question party close to (prtc*)
prt_out %>%
  filter(prt_var == "prtc") %>%
  select(-prt_var) %>%
  write_csv("../essprtc/essprtc.csv", na = "")

# all ESS prt* variables
prt_out_all <-
  raw_ess_clean %>%
  left_join(pf_party) %>%
  relocate(partyfacts_id, .before = country) %>%
  arrange(ess_cntry, essround, ess_variable, ess_party_id)

write_csv(prt_out_all, "essprt-all.csv", na = "")


## Plot ESS-prtv  ----

pl_dt <-
  prt_out_all %>%
  filter(is.na(technical), str_ends(ess_id, "v")) %>%
  distinct(country, essround, ess_id) %>%
  count(country, essround, sort = TRUE) %>%
  mutate(country = factor(country) %>% fct_rev(),
         essround = factor(essround))

pl <-
  ggplot(pl_dt, aes(y = country, x = essround, size = n)) +
  geom_point(colour = "darkgrey") +
  scale_y_discrete(name = "") +
  scale_x_discrete(name = "ESS Round") +
  scale_size_continuous(name = "n (prtv*)") +
  theme_bw() +
  theme(axis.ticks.y = element_blank()) +
  guides(color = F)

# plot(pl)
ggsave("essprtv.png",
       pl,
       width = 20,
       height = 25,
       units = "cm")
