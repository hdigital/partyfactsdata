library(tidyverse)
library(stringr)

data_raw <- read_csv("source__partylevel_20130907.csv")

data <- data_raw %>%
  select(country:partysize) %>%
  mutate(id = paste(ccodewb, partynum, sep="-"),
         partysize = round(partysize, 1),
         country = ccodewb,
         country = recode(country, ROM="ROU"))

# clean-up party acronym -- conditionally replace "pnatacro" with "pengacro"
data <- data %>% mutate(pnatacro = ifelse(str_detect(pnatacro, regex("^[\\? ]+$")), pengacro, pnatacro))

data_out <- data %>% select(-ccode, -ccodecow, -ccodewb)
write_csv(data_out, "kitschelt.csv", na = "")
