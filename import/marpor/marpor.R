library("dplyr")
library(countrycode)

marpor_raw <- read.csv("marpor-2016.csv", fileEncoding="utf-8", as.is=TRUE)
marpor <- marpor_raw %>% select(-country)

marpor_share <- read.csv("marpor-share.csv", fileEncoding="utf-8", as.is=TRUE)
marpor <- marpor %>% left_join(marpor_share)

# add Party Facts country codes
marpor <- marpor %>%
  mutate(country = countrycode(countryname, 'country.name', 'iso3c',
                            custom_match = c(`Northern Ireland`='NIR')))
if(any(is.na(marpor$country))) {
  warning("Country name clean-up needed")
}

marpor[marpor$abbrev == 'NDS-Z/LSV/ZZS/VMDK/ZZV/DLR', 'abbrev'] <- 'N/L/Z/V/Z/D'  # party short longer than 25 chars

write.csv(marpor, "marpor.csv", na="", row.names = FALSE, fileEncoding="utf-8")
