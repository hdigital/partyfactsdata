library(tidyverse)
library(countrycode)

# reading source file
ppmd_raw <- read_csv("source__ppmd_summary_data.csv")

# one observation per party and unique
country_custom = c(`NI`= "NIR", `SR` = "SRB", `UK` = "GBR")

ppmd <- ppmd_raw %>% 
  mutate(
    id = paste(Country, Party, sep = "-"),
    country_short = countrycode(
      Country, "iso2c", "iso3c", custom_match = country_custom
      ),
    dummy_nir = if_else(country_short == "NIR", 1, 0),
    country_short = case_when(
      country_short == "NIR" ~ "GBR",
      TRUE ~ country_short
    )
    ) %>% 
  distinct(Country, Party, .keep_all = TRUE) %>%
  arrange(Country, Party)

# writing new csv file
write_csv(ppmd, "ppmd.csv", na = "")
