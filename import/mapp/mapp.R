library(tidyverse)
library(countrycode)


## Get/read data ----

mapp_file <- "source__MAPP_dataset_-_Version_2.0.xlsx"

if(! mapp_file %in% list.files()) {
  download.file("https://zenodo.org/record/61234/files/MAPP_dataset_-_Version_2.0.xlsx",
                mapp_file)
}

raw_mapp <- readxl::read_xlsx(mapp_file)

# dataset with Party Facts and ParlGov IDs
if(FALSE) {
  read.csv("partyfacts-external-parties.csv") %>%
    filter(dataset_key == "parlgov") %>%
    select(partyfacts_id, parlgov_id = dataset_party_id) %>%
    write_csv("partyfacts-parlgov.csv")
}

raw_pfext <- read.csv("partyfacts-parlgov.csv") %>%
  mutate(parlgov_id = as.character(parlgov_id))


## Extract information ----

mapp_temp <- raw_mapp %>%
  select(
    `Party ID (MAPP)`, `PartyID (ParlGov)`, Country, `Party acronym`,
    `Full name (original language)`, `Full name (English translation)`,
    `Year founded`, `Year disappearance`
  ) %>%
  mutate(
    country_short = countrycode(
      Country,
      origin = "country.name",
      destination = "iso3c"
    ),
    party_id = paste(`Party ID (MAPP)`),
    name = case_when(
      country_short == "CYP" ~ NA_character_,
      TRUE ~ `Full name (original language)`
    )
  )

# add partyfacts_id via parlgov_id's
mapp_temp2 <- mapp_temp %>%
  left_join(raw_pfext, by = c("PartyID (ParlGov)" = "parlgov_id")) %>%
  select(
    country_short, `Party acronym`, name,
    `Full name (English translation)`, `Year founded`, `Year disappearance`,
    party_id, partyfacts_id
  ) %>%
  group_by(party_id) %>%
  slice(1L) %>%  # keep only once the party_id of MAPP
  ungroup()      # although party had different names


# rename columns
colnames(mapp_temp2) <- c(
  "country", "name_short", "name", "name_english",
  "year_first", "year_last", "party_id",
  "partyfacts_id"
)

# fix unicode issue
mapp <- mapp_temp2 %>%
  mutate(
    name = case_when(
      country == "ROU" & name_short %in% c("PPPS", "FSN") ~ NA_character_,
      country == "CYP" & name_short == "EDEK" ~ NA_character_,
      TRUE ~ name
    )
  )


write.csv(mapp, "mapp.csv", row.names = FALSE, fileEncoding = "UTF-8", na = "")


## Data checks ----

# check wether there are any duplicates or differences in the number of
# party_id after the manipulation
duplicated(mapp$party_id) %>% any()
