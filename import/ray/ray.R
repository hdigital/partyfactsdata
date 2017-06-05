library("tidyverse")
library("stringr")
library("haven")

# get local copy of data file
url <- "http://www.lsu.edu/faculty/lray2/data/1996survey/1996survey.sav?export=sav"
data_file_local <- "source__1996survey.sav"
if( ! file.exists(data_file_local)) {
  download.file(url, data_file_local, mode="wb")
}

# read, select and clean data
ray_raw <- read_spss("source__1996survey.sav")
ray <- ray_raw %>%
  select(NATID:CMPCODE) %>%  # select party information
  mutate_each(funs(str_trim), PARTY, ENAME, NAME) %>%  # trim white space
  mutate(id = as.integer(NATID) * 1000 + PARTYID)  # create unique party id

# add country ISO codes
country <- read_csv("../country.csv") %>% select(name, iso3)
ray <- ray %>% left_join(country, by = c("NATION" = "name")) %>% arrange(iso3, PARTY)

write_csv(ray, "ray.csv", na = "")
