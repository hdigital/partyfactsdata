library(tidyverse)
library(readxl)

xls_file <- "source__mep_info_26Jul11.xls"


## Read MEP party data ----

party <- read_excel(xls_file, sheet = "Codes-National Parties")
country <- read_excel(xls_file, sheet = "Codes-Member States")
# read roll call votes sheets and combine into one dataframe
mep <-map_df(1:5, ~ read_excel(xls_file, sheet = paste0("EP", .x)) %>% mutate(ep_term = .x))

# create cleaned-up variable names
clean_names <- function(.) {
  stringr::str_replace_all(names(.), "\\W", "_") %>% tolower()
}
names(party) <- clean_names(party)
names(mep) <- clean_names(mep)
names(country) <- clean_names(country)


## Data preparation ----

# add some information and adjust variable names for merging

mep <- mep %>% mutate(year = 1979 + (ep_term - 1) * 5)
party <- party %>% mutate(code = as.integer(code))

country <-
  country %>%
  select(code_country = code, country_name = member_state)

pa_years <-
  mep %>%
  group_by(national_party) %>%
  summarise(year_first = min(year), year_last = max(year))

pa_size <-
  mep %>%
  group_by(member_state, national_party, year) %>%
  summarise(seats = n()) %>%
  group_by(member_state, year) %>%
  mutate(share = round(100 * seats / sum(seats, na.rm = TRUE), 1),
         share_year = year) %>%
  group_by(member_state, national_party) %>%
  filter(share == max(share, na.rm = TRUE)) %>%
  ungroup() %>%
  distinct(national_party, .keep_all = TRUE) %>%
  select(national_party, share_year, share)


## Create party list ----

pa_out <-
  party %>%
  inner_join(country, by = c("member_state" = "code_country")) %>%
  inner_join(pa_years, by = c("code" = "national_party")) %>%
  inner_join(pa_size, by = c("code" = "national_party"))

write_csv(pa_out, "hix-parties.csv", na = "")
