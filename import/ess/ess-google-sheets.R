rm(list = ls())

pack_core <- c("dplyr")
pack_other <- c("RCurl", "stringi")  # specify package functions with "::"
lapply(c(pack_core, pack_other), suppressMessages(require), character.only=TRUE, quietly=TRUE)

link <- getURL("https://docs.google.com/spreadsheets/d/1KN6_jhur5LVHBSZ4Ij5eZHgrL4X4O1W1_Gq55lpC5TU/pub?output=csv", .encoding = "UTF-8")
ess <- read.csv(textConnection(link), encoding = "UTF-8", as.is=TRUE)
ess_ids <- ess$id

ess_name_check <- ess %>% select(contains('ess_round_')) %>% apply(1, paste0, collapse = "")
if("" %in% ess_name_check) {
  stop("Empty rows in ESS data")
}

## ESS parties ------------------------

# check if every party of ESS source occurs in party list
ess_source_parties <- read.csv("ess-parties.csv", fileEncoding = "UTF-8", as.is=TRUE)
ess_source_parties$partyname <- stri_trim_both(ess_source_parties$partyname)
for (i in 1:6) {
  round_nr <- i
  
  ess_party_round <- select(ess, country_short, get(paste0("ess_round_", round_nr)))
  ess_party_round$party_merge <- paste(ess_party_round[[1]], ess_party_round[[2]])
  
  ess_source_party_round <- filter(ess_source_parties, essround == round_nr) 
  ess_source_party_round <- mutate(ess_source_party_round, party_merge = paste(countrynameshort, partyname))
  
  missing_parties <- ess_source_party_round[which( ! ess_source_party_round$party_merge %in% 
                                                     ess_party_round$party_merge), ]
  missing_parties <- select(missing_parties, -essround, -year, -party_merge)
  colnames(missing_parties) <- c(paste0("ess_round_", round_nr), "country", "country_short")
  
  ess <- bind_rows(ess, missing_parties)
}

# adding IDs if not existing
add_id <- is.na(ess$id)
ess[add_id, "id"] <- max(ess$id, na.rm = TRUE) + 1:(add_id %>% as.integer %>% sum)


## Data consistency check ------------------------

party_name <- ess %>%
  select(contains('ess_round_')) %>%
  apply(1, . %>% .[ ! . %in% c("", NA)] %>% rev %>% .[1])

add_name <- apply(ess %>% select(party_short:party_name), 1, function(.) all(is.na(.)))
ess[add_name, "party_name"] <- party_name[add_name]

# extract 'name' for each party -- native or english or short
ess$name <- party_name %>%
  stri_trans_tolower %>%
  stri_replace_all_regex("\\W+", " ") %>%
  stri_trim_both
  
name_dupl <- paste(ess$country_short, ess$name) %>% .[duplicated(.)] %>% unique
if(length(name_dupl) >= 1) {
  warning("Duplicate party names")
  paste(name_dupl, collapse = " -- ")
}

# replace ESS years based on first and last ESS observation
get_ess_years <- function(vec, first_year = 2002, wave_diff = 2) {
  names(vec) <- seq(first_year, first_year + wave_diff * length(vec) - wave_diff, by = wave_diff)
  year <- vec[! vec %in% c("", NA)] %>% names %>% as.integer
  return(c(year[1], rev(year)[1]))
}
ess_years <- ess %>% select(contains('ess_round_')) %>% apply(1, get_ess_years) %>% t
ess[, c("year_first", "year_last")] <- ess_years

ess_codebook <- ess %>% filter (id %in% ess_ids) %>% arrange(country_short, name)
ess_to_add <- ess %>% filter ( ! id %in% ess_ids) %>% arrange(country_short, name)
write.csv(ess_codebook, "ess.csv", fileEncoding = 'utf-8', na='', row.names = FALSE)
write.csv(ess_to_add, "source__ess-add-to-codebook.csv", fileEncoding = 'utf-8', na='', row.names = FALSE)

