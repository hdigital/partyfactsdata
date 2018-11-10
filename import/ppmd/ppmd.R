library(tidyverse)
library(countrycode)

# reading source file
ppmd_raw <- read_csv("source__ppmd_summary_data.csv")

# one observation per party and unique
ppmd <- ppmd_raw %>% 
  mutate(id = paste(Country, Party, sep = "-"),
         country_short = countrycode(Country, "iso2c", "iso3c",
                                     custom_match = c(`UK`="GBR"))) %>% 
  distinct(Country, Party, .keep_all = TRUE) %>%
  arrange(Country, Party)

# writing new csv file
write_csv(ppmd, "ppmd.csv", na = "")
