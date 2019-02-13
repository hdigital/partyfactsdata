## -----------------------------------------------------------------------
## Combine countries globalelections
##
## Datum: 03.11.2018
##
## Author: Paul Bederke
## -----------------------------------------------------------------------

library(tidyverse)
library(countrycode)
library(data.table)

## read all countries .csv

Albania <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/albania/national-lower-house")
Australia <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/australia/national-lower-house")
Austria <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/austria/national-lower-house")
Belgium <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/belgium/national-lower-house")
Bermuda <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/bermuda/national-lower-house")
Bolivian <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/bolivia/national-lower-house")
Bosnia_Herzegovina <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/bosnia-herzegovina/national-lower-house")
Botswana <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/botswana/national-lower-house")
Bulgaria <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/bulgaria/national-lower-house")
Canada <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/canada/national-lower-house")
Colombia <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/colombia/national-lower-house")
Costa_Rica <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/costa-rica/national-lower-house")
Croatia <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/croatia/national-lower-house")
Cyprus <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/cyprus/national-lower-house")
Czech_Republic <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/czech-republic/national-lower-house")
Czechoslovakia <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/czechoslovakia/national-lower-house")
Dominican_Republic <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/dominican-republic/national-lower-house")
Estonia <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/estonia/national-lower-house")
Finland <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/finland/national-lower-house")
France <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/france/national-lower-house")
Germany <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/germany/national-lower-house")
Hungary <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/hungary/national-lower-house")
Iceland <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/iceland/national-lower-house")
Indonesia <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/indonesia/national-lower-house")
Ireland <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/ireland/national-lower-house")
Israel <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/israel/national-lower-house")
Italy <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/italy/national-lower-house")
Latvia <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/latvia/national-lower-house")
Lithuania <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/lithuania/national-lower-house")
Luxembourg <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/luxembourg/national-lower-house")
Malaysia <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/malaysia/national-lower-house")
Malta <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/malta/national-lower-house")
Mauritius <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/mauritius/national-lower-house")
Mexico <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/mexico/national-lower-house")
Moldova <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/moldova/national-lower-house")
Netherlands <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/netherlands/national-lower-house")
New_Zealand <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/new-zealand/national-lower-house")
Niger <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/niger/national-lower-house")
Norway <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/norway/national-lower-house")
Poland <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/poland/national-lower-house")
Portugal <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/portugal/national-lower-house")
Romania <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/romania/national-lower-house")
Russia <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/russia/national-lower-house")
Slovakia <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/slovakia/national-lower-house")
Slovenia <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/slovenia/national-lower-house")
Solomon_Islands <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/solomon-islands/national-lower-house")
South_Africa <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/south-africa/national-lower-house")
Spain <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/spain/national-lower-house")
Sweden <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/sweden/national-lower-house")
Switzerland <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/switzerland/national-lower-house")
Trinidad_and_Tobago <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/trinidad-and-tobago/national-lower-house")
Turkey <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/turkey/national-lower-house")
United_Kingdom <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/united-kingdom/national-lower-house")
United_States <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/united-states/national-lower-house")
Venezuela <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/venezuela/national-lower-house")
Greece <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/greece/national-lower-house")
West_Germany <- fread("http://www.globalelectionsdatabase.com/index.php/tables/download/west-germany/national-lower-house")

ge_raw <- rbind(Albania,Australia,Austria,Belgium,Bermuda,Bolivian,Bosnia_Herzegovina,Botswana,Bulgaria,Canada,Colombia,Costa_Rica,Croatia,Cyprus,Czech_Republic,Czechoslovakia,Dominican_Republic,Estonia,Finland,France,Germany,Hungary,Iceland,Indonesia,Ireland,Israel,Italy,Latvia,Lithuania,Luxembourg,Malaysia,Malta,Mauritius,Mexico,Moldova,Netherlands,New_Zealand,Niger,Norway,Poland,Portugal,Romania,Russia,Slovakia,Slovenia,Solomon_Islands,South_Africa,Spain,Sweden,Switzerland,Trinidad_and_Tobago,Turkey,United_Kingdom,United_States,Venezuela,Greece,West_Germany)

## create copy
ge <- ge_raw

## round year
ge$year <- round(ge$year)

## delete "legid"
ge <- ge[,-3]

## reorder
ge <- ge[,c(1,2,5,3,6,7,4)]

## delete all rows with "NA" in column 2 & 3 (year & party)
ge <- ge[complete.cases(ge[,2:3]),]

## add iso3 -- !ISO3 code of Czechoslovakia needs to be CSK. Otherwise the party_id will be dublicated!
ge <- ge %>%
  mutate(country_short = countrycode(cnty, "country.name", "iso3c", custom_match = c(Czechoslovakia = "CSK"))) %>%
  arrange(cnty, party)

## add vote_share & round result
ge <- transform(ge, vote_share = votes / ElectionTotalVotes * 100) %>%
  mutate_if(is.numeric, ~round(., 1))

## reorder
ge <- ge[,c(8,1,2,3,4,5,9,6,7)]

## get party name without "P[:digits:]
ge <- ge %>%
  mutate(party_name = str_extract(party, "(?<=\\-).*"))

## extract number
ge$number <- ge$party %>%
  str_extract_all("P[:digit:]+", simplify = TRUE)

## mutate party_id (iso3 + number)
ge$party_id <- paste0(ge$country_short, ge$number)


## aggregate parties first and last year
year_ge <- ge %>%
  group_by(country_short, party) %>%
  summarise(year_first = min(year), year_last = max(year)) %>%
  ungroup()

## filter parties max vote_share
share_ge <- ge %>%
  group_by(country_short, party) %>%
  mutate(max_vote = max(vote_share, na.rm = TRUE)) %>%
  filter(vote_share == max_vote) %>%
  distinct(party, .keep_all = TRUE) %>%
  ungroup()

## merge share_ge & year_ge
final_ge <- merge(share_ge, year_ge, by=c("country_short", "party"))

## reorder
final_ge <- final_ge[,c(1,3,10,14,15,4,7,8,9,12,2)]

## year_first & year as character
final_ge$year_first <- final_ge$year_first %>%
  as.character()
final_ge$year <- final_ge$year %>%
  as.character()

final_ge$party <- NULL

colnames(final_ge)[6] <- "share_year"

## write .csv
write.csv(final_ge, "gloelec_parties.csv", na = "", row.names = FALSE, fileEncoding = "UTF-8")
