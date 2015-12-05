library("dplyr")

# based on Word file provided by Christina Zuber
epac_raw <- read.csv("epac-parties.csv", fileEncoding = "utf-8", as.is=TRUE)
share <- read.csv("epac-share.csv", fileEncoding = "utf-8", as.is=TRUE)
country_raw <- read.csv("../country.csv", fileEncoding = "utf-8", as.is=TRUE)
country <- select(country_raw, country_name=name, country_name_short=name_short)

epac <- epac_raw %>%
  left_join(country, by = c("country" = "country_name")) %>%
  filter(country_name_short!="DNK") %>%  # in codebook but not in dataset
  left_join(share, by = c("id" = "party_id"))

write.csv(epac, "epac.csv", na='', fileEncoding = "utf-8", row.names = FALSE)
