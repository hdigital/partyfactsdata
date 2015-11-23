library("foreign")
library("dplyr")
library("stringr")

# get local copy of data file
url <- "http://www.lsu.edu/faculty/lray2/data/1996survey/1996survey.sav?export=sav"
data_file_local <- "source__1996survey.sav"
if( ! file.exists(data_file_local)) {
  download.file(url, data_file_local, mode='wb')
}

# read, select and clean data
ray <- read.spss("source__1996survey.sav", to.data.frame = TRUE) %>%
  select(NATID:CMPCODE) %>%  # select party information
  mutate_each(funs(str_trim), NATION, PARTY, ENAME, NAME)  # trim whitespaces

# add country ISO codes
country <- read.csv('../country.csv', as.is=TRUE)
ray <- merge(ray, country[ , c('name', 'iso3')], by.x='NATID', by.y='name', all.x=TRUE)

# create unique party id from country id and party id
ray$NATID <- as.integer(ray$NATID)
ray$id <- as.integer(ray$NATID) * 1000 + ray$PARTYID

write.csv(ray, 'ray.csv', na='', row.names = FALSE, fileEncoding='utf-8')
