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


## Create party data -----------------------------------------------------------------------------

## parties which are named in variable IMD3002_LH_PL

# add codebook party information
# generate share for each year
cses_share_temp <- cses_imd %>%
  select(IMD1006_NAM, IMD1008_YEAR, IMD3002_LH_PL, IMD3002_LH_DC, IMD3002_PR_1) %>%
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
# get max share and year information
cses_share <- cses_share_temp %>%
  mutate(party_id = IMD3002_LH_PL) %>%
  select(
    IMD1006_NAM,
    country_short, party_short, party_name, IMD1008_YEAR, share,
    party_id, comment, polity_notes
  ) %>%
  distinct() %>%
  group_by(party_id) %>%
  mutate(
    year_first = min(IMD1008_YEAR),
    year_last = max(IMD1008_YEAR)
  ) %>%
  arrange(-share) %>%
  slice(1L) %>%
  ungroup()


## -----------------------------------------------------------------------------------------------

## six most popular parties/coalitions + supplemental parties

cses_top <- cses_imd %>%
  select(IMD1006_NAM, IMD1008_YEAR, starts_with("IMD5000_")) %>%
  distinct() %>%
  gather(key = "key", value = "party_id", starts_with("IMD5000_")) %>%
  distinct() %>%
  left_join(cses_cb, by = "party_id") %>%
  group_by(party_id) %>%
  mutate(
    year_first = min(IMD1008_YEAR),
    year_last = max(IMD1008_YEAR)
  ) %>%
  ungroup() %>%
  select(country_short, IMD1006_NAM, party_short, party_name, year_first, year_last, party_id, comment, polity_notes) %>%
  distinct()


## -----------------------------------------------------------------------------------------------

## combine parties with share above 1% and the six most popular parties/coalitions + supplemental parties

cses_top_and_share <- cses_share %>%
  filter(share >= 1) %>%
  select(country_short, IMD1006_NAM, party_short, party_name, year_first, year_last, party_id, comment, polity_notes) %>%
  distinct() %>%
  rbind(cses_top) %>%
  distinct() %>%
  drop_na(country_short)


## share information
cses_share_merge <- cses_share %>%
  select(party_id, share, IMD1008_YEAR)


## merge share information to data
cses <- cses_top_and_share %>%
  select(-IMD1006_NAM) %>%
  left_join(cses_share_merge, by = c("party_id" = "party_id")) %>%
  select(country_short, party_short, party_name, year_first, year_last, IMD1008_YEAR, share, party_id, comment, polity_notes) %>%
  distinct() %>%
  group_by(party_id) %>%
  slice(1L) %>%
  ungroup() %>%
  filter(share >= 1 | is.na(share))


# rename columns
colnames(cses) <- c(
  "country", "name_short", "name_english", "year_first", "year_last",
  "share_year", "share", "party_id", "comment", "polity_note"
)


## Final check and data ----

duplicated(cses$party_id) %>% any()


write.csv(cses, "cses.csv", fileEncoding = "UTF-8", na = "", row.names = FALSE)
