library(tidyverse)
library(stringr)
library(haven)
library(countrycode)

# get local copy of data file
url <- "http://www.lsu.edu/faculty/lray2/data/1996survey/1996survey.sav?export=sav"
data_file_local <- "source__1996survey.sav"
if( ! file.exists(data_file_local)) {
  download.file(url, data_file_local, mode = "wb")
}

# read, select and clean data
ray_raw <- haven::read_spss(data_file_local)
ray <- ray_raw %>%
  select(NATID:CMPCODE) %>%  # select party information
  mutate_at(vars(PARTY, ENAME, NAME), str_trim) %>%  # trim white space
  mutate(id = as.integer(NATID) * 1000 + PARTYID,    # create unique party id
         iso3 = countrycode(NATION, "country.name", "iso3c",
                            custom_match = c(Netherla="NLD", "UnitedKd"="GBR"))) %>%
  arrange(iso3, PARTY)

write_csv(ray, "ray.csv", na = "")
