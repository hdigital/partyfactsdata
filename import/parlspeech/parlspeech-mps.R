library(tidyverse)
library(glue)

# set name of folder with ParlSpeech Dataverse data 
folder_parlspeech <- "source__parlspeech"

# information about ParlSpeech data for reading data
ps_info <- 
  tribble(
    ~country,  ~file_name,   ~object_name,
    "CZE", "PSP",            "psp",
    "DEU", "Bundestag",      "bt",
    "ESP", "Congresso",      "cong",
    "FIN", "Eduskundta",     "ed",
    "GBR", "HouseOfCommons", "hoc",
    "NLD", "TweedeKamer",    "tk",
    "SWE", "Riksdag",        "rd"
  )

# load ParlSpeech data, select variables, add country
get_ps_data <- function(country_name, file_name, object_name) {
  load(glue("{folder_parlspeech}/Corp_{file_name}.Rdata"))
  
  get(glue("{object_name}.corpus")) %>% 
    select(date, party, speaker) %>% 
    mutate(country = country_name) %>% 
    distinct()
}

# deu <- get_ps_data("DEU", "Bundestag", "bt")   # example for using 
ps_all <- pmap_df(ps_info, ~ get_ps_data(..1, ..2, ..3))

ps_out <- 
  ps_all %>% 
  group_by(country, party, speaker) %>% 
  summarise(
    date_first = min(date),
    date_last = max(date)
  ) %>% 
  arrange(country, speaker, date_first)

write_csv(ps_out, "parlspeech-mps.csv")
