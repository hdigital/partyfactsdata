library("dplyr")

marpor_raw <- read.csv("marpor-2016.csv", fileEncoding="utf-8", as.is=TRUE)
marpor <- marpor_raw %>% select(-country)

marpor_share <- read.csv("marpor-share.csv", fileEncoding="utf-8", as.is=TRUE)
marpor <- marpor %>% left_join(marpor_share)

# add country codes
country <- read.csv("../country.csv", as.is=TRUE) %>%
  select(country_name_short = name_short, country_name = name)
recode <- c("Bosnia-Herzegovina" = "Bosnia and Herzegovina",
            "Great Britain" = "United Kingdom",
            "South Korea" = "Korea (South)")
marpor$countryname <- sapply(marpor$countryname, function(.) ifelse(. %in% names(recode), recode[[.]], .))
if( ! all(marpor$countryname %in% country$country_name)) {
  warning("Not all Manifesto country names in country data")
}
marpor <- marpor %>%
  left_join(country, by = c("countryname" = "country_name")) %>%
  arrange(countryname, party)

marpor[marpor$abbrev == 'NDS-Z/LSV/ZZS/VMDK/ZZV/DLR', 'abbrev'] <- 'N/L/Z/V/Z/D'  # party short longer than 25 chars

write.csv(marpor, "marpor.csv", na="", row.names = FALSE, fileEncoding="utf-8")
