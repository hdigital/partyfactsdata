library("foreign")
library("dplyr")
library("stringr")

rm(list = ls())

# get local copy of data file
url <- "http://www.lsu.edu/faculty/lray2/data/1996survey/1996survey.sav?export=sav"
data_file_local <- "source__1996survey.sav"
if( ! file.exists(data_file_local)) {
  download.file(url, data_file_local, mode="wb")
}

# read, select and clean data
ray_raw <- read.spss("source__1996survey.sav", to.data.frame = TRUE)
ray <- ray_raw %>%
  select(NATID:CMPCODE, -NATION) %>%  # select party information
  mutate_each(funs(str_trim), PARTY, ENAME, NAME) %>%  # trim white space
  mutate(id = as.integer(NATID) * 1000 + PARTYID,  # create unique party id
         natid_name = as.character(NATID), NATID = as.integer(NATID))

# add country ISO codes
country <- read.csv("../country.csv", as.is=TRUE) %>% select(name, iso3)
ray <- ray %>% left_join(country, by = c("natid_name" = "name")) %>% arrange(iso3, PARTY)

write.csv(ray, "ray.csv", na="", row.names = FALSE, fileEncoding="utf-8")
