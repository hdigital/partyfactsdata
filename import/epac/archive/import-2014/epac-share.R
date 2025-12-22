library("dplyr")
library("readstata13")

# extract partysize -- source__* files are ignored by .gitignore
data <- readstata13::read.dta13("source__EPAC_summary.dta")
share <- data %>%
  mutate(natstrength = round(natstrength, 1)) %>%
  select(party_id, natstrength)

write.csv(share, "epac-share.csv", na='', fileEncoding = "utf-8", row.names = FALSE)
