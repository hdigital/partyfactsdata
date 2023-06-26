library(tidyverse)
library(countrycode)

file_in <- 
  readxl::read_xlsx("source__AutocraticRulingPartiesDataset.xlsx", na = c("", "N"))

cust_country <- 
  c("Czechoslovakia" = "CZE", "Germany (East)" = "DDR", "Vietnam (South)" = "VNR", "Yemen (South)" = "YMD", "Yemen (North)" = "YEM", "Yugoslavia" = "SRB")

file_out <- 
  file_in %>% 
  mutate(index = 1:nrow(file_in)) %>% 
  drop_na(Party) %>% 
  mutate(country = countrycode(Country, "country.name", "iso3c", custom_match = cust_country)) %>% 
  select(country, Party, `Year Founded`, `Last Year of Power`, `Renaming?`, index) %>% 
  mutate(
    name_short = str_extract(Party, "(?<=\\()[[:alpha:][:space:]\\-\\']*"),
    name_short = str_extract(name_short, "[:upper:]*"),
    name_english = str_remove(Party, "\\(.*\\)"),
    year_first = `Year Founded`,
    year_last = `Last Year of Power`,
    year_renamed = `Renaming?`,
    party_id = paste(country, index, sep = "-")
  ) %>% 
  select(country, party_id, name_short, name_english, year_first, year_last,year_renamed, Party, party_id)


write_csv(file_out, "arpd.csv", na = "")


# clean-up of party names
if(F){
file_out <- 
  arpd %>% 
  mutate(
    name_short = case_when(
      party_id == "CRI-119" ~ "PRN",
      party_id == "FJI-163" ~ NA_character_,
      party_id == "FJI-165" ~ NA_character_,
      party_id == "ARG-15" ~ NA_character_,
      party_id == "BGD-35" ~ NA_character_,
      party_id == "COD-114" ~ NA_character_,
      party_id == "HTI-204" ~ NA_character_,
      party_id == "HTI-206" ~ NA_character_,
      party_id == "HTI-207" ~ NA_character_,
      T ~ name_short
    ),
    name_english = case_when(
      party_id == "CRI-119" ~ "(Independent) National Republican Party",
      party_id == "ARG-15" ~ "National Democratic Party - Concordance Alliance",
      party_id == "COD-114" ~ "Association of the Bakongo People - Bakongos' Alliance",
      party_id == "HTI-204" ~ "Lavalas Family",
      party_id == "HTI-206" ~ "Hope Front",
      party_id == "HTI-207" ~ "Patriotic Unity",
      T ~ name_english
    ),
    name = case_when(
      party_id == "FJI-163" ~ "Soqosoqo ni Vakavulewa ni Taukei",
      party_id == "FJI-165" ~ "Soqosoqo Duavata ni Lewenivanua",
      party_id == "BGD-35" ~ "Ershad",
      party_id == "HTI-204" ~ "Fanmi Lavalas",
      party_id == "HTI-206" ~ "Lespwa",
      party_id == "HTI-207" ~ "Inite",
      T ~ name
    )
  )
}
