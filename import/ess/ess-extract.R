library("foreign")

library("dplyr")
library("tidyr")
library("stringr")


# Import original ESS files, this may take some time
ess_folder <- "ess_source"
files <- paste(getwd(), ess_folder, list.files(ess_folder), sep="/")
if ( ! exists("ess_round_raw")) {
  ess_round_raw <- lapply(files, read.spss, to.data.frame = TRUE)  
}

# Import country data files and select relevant variables, later needed for ISO country codes
country_list_raw <- read.csv("../country.csv", encoding="utf-8")
country_list <- select(country_list_raw, name, iso3)


# Function for finding parties in every round
FindParties <- function (round) {  
  
  # Remove all variables with only NA observations, 
  # as there are rounds with party variables for countries not mentioned in this round
  round <- round[ , colSums(is.na(round)) < nrow(round)]
  
  # Find Parties in all three variables
  party_close  <- lapply(round[grep("prtcl[a-z]+", colnames(round))], levels)
  party_member <- lapply(round[grep("prtmb[a-z]+", colnames(round))], levels)  
  party_vote   <- lapply(round[grep("^prtv[a-z]+[^2-3]$", colnames(round))], levels)
  
  # Reorder some Variables as there would be order issues when combining them later
  if (round$essround[1] == 5) {
    party_member <- c(party_member[1:3], party_member[5], party_member[4], party_member[6:27])
    party_vote <- c(party_vote[1:3], party_vote[5], party_vote[4], party_vote[6:27])
  }
  if (round$essround[1] == 2) {
    party_member <- c(party_member[1:4],party_member[6], party_member[5], party_member[7:25])
  }
  
  # Combine all Parties
  if (round$essround[1] != 6) {
    party <- mapply(c, party_close, party_member, party_vote)
  }
  # Special case as party_member does not occur in Round 6
  else {
    party <- mapply(c, party_close, party_vote) 
  }
  # Find unique (same) parties after collecting names from all variables
  party <- lapply(party, unique)
  
  return(party)
}


PartiesInRounds <- function (round) {
  # Find parties and detect observations (number of  all parties)
  party <- FindParties(round)
  observations <- sum(sapply(party, length)) 
  
  # Appropiate name for Russia
  round$cntry <- sub("Russian Federation", "Russia", round$cntry)
  # Find countrys
  countryname <- distinct(select(round, cntry), cntry)
  # Find countrycodes
  countrycode <- filter(country_list, name %in% round$cntry)
  # Merge corresponding values, ignore warnings
  countrymerge <- left_join(countryname, countrycode, by = c("cntry" = "name"))
  # Extract two vectors, now consisting of names and codes in order of the parties
  countryname <- as.character(unlist(countrymerge[1]))
  countrycode <- as.character(unlist(countrymerge[2]))
  # Fixing an ordering problem with Croatia in the fifth round
  if (round$essround[1] == 5) {
    countryname <- c(countryname[1:4], "Croatia", countryname[5:13], countryname[15:27])
    countrycode <- c(countrycode[1:4], "HRV", countrycode[5:13], countrycode[15:27])
  }
  
  # Create new table with only relevant variables and predefined observations
  round_new <- select(round, essround)
  round_new <- slice(round_new, 1:observations)
  # Add years of respective round
  year <- 2002 + round_new$essround[1] * 2 - 2
  round_new <- mutate(round_new, year=year)
  # Add parties
  round_new <- mutate(round_new, partyname = unlist(party))
  # Repeat countries to match their parties and then also add them
  countryname <- rep(countryname, sapply(party, length))
  round_new <- mutate(round_new, countryname=countryname)
  # Add country codes in the same way
  countrycode <- rep(countrycode, sapply(party, length))
  round_new <- mutate(round_new, countrynameshort=countrycode)
  
  return(round_new)                  
}

ess_round <- lapply(ess_round_raw, PartiesInRounds)

# Create new table containing all parties in all rounds
ess_all <- rbind_all(ess_round)
# Recode NIR parties, here coded as GBR
NIR_parties <- select(ess_all, partyname)
NIR_parties <- grep("(nir)", unlist(NIR_parties))
ess_all[NIR_parties, "countryname"] <- "Northern Ireland"
ess_all[NIR_parties, "countrynameshort"] <- "NIR"

write.csv(ess_all, "ess-parties.csv", row.names = FALSE, na = "", fileEncoding = "UTF-8")