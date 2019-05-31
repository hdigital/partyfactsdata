library(tidyverse)

## Get and load CSES data ----

cses_file_name <- "source__cses_imd.rdata"

if( ! cses_file_name %in% list.files()) {
  download.file("http://www.cses.org/datacenter/imd/data/cses_imd_r.zip", "tmp.zip")
  unzip("tmp.zip")
  fs::file_move("cses_imd.rdata", )
  fs::file_delete("tmp.zip", cses_file_name)
}

load(cses_file_name)

cses_cb <- read_csv("cses-codebook.csv") %>%
  mutate(
    party_id = as.numeric(str_remove(party_id, "\\#"))
  )


## Create party data ----

# add codebook party informations
# generate share for each year
cses <- cses_imd %>%
  select(IMD1006_NAM, IMD1008_YEAR, IMD3002_LH_PL) %>%
  left_join(cses_cb, by = c("IMD3002_LH_PL" = "party_id")) %>%
  drop_na(country) %>%
  group_by(country, IMD1008_YEAR) %>%
  mutate(
    total_number = n()
  ) %>%
  group_by(country, IMD1008_YEAR, IMD3002_LH_PL) %>%
  mutate(
    number = n(),
    share = round(number / total_number * 100, 2)
  ) %>%
  ungroup()

# keep only relevant variables & one observation for each party
# get max share and year informations
cses <- cses %>% 
  select(
    country_short, party_short, party_name, IMD1008_YEAR, share,
    IMD3002_LH_PL, comment, polity_notes
  ) %>%
  distinct() %>%
  group_by(IMD3002_LH_PL) %>%
  mutate(
    year_first = min(IMD1008_YEAR),
    year_last = max(IMD1008_YEAR)
  ) %>%
  arrange(-share) %>% 
  slice(1L) %>%
  ungroup()

# filter parties above 1 percent
cses <- cses %>% 
  filter(share >= 1) %>%
  select(
    country_short, party_short, party_name, year_first, year_last,
    IMD1008_YEAR, share, IMD3002_LH_PL, comment, polity_notes
  )

# rename columns
colnames(cses) <- c(
  "country", "name_short", "name_english", "year_first", "year_last",
  "share_year", "share", "party_id", "comment", "polity_note"
)


## Final check and data ----

duplicated(cses$party_id) %>% any()

write.csv(cses, "cses.csv", fileEncoding = "UTF-8", na = "", row.names = FALSE)
