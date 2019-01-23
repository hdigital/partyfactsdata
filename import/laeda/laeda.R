library(tidyverse)

laeda_raw <- read_csv("laeda_parties.csv")

laeda <- 
  laeda_raw %>% 
  filter(
    share >= 5,
    ! duplicated(party_id)
    )

## check for duplicates
any(duplicated(laeda$party_id))

write_csv(laeda, "laeda.csv")
