library(dplyr)

party_raw <- read.csv("source__clea/clea_20160523_appendix_II.csv",
                      fileEncoding = "utf-8", as.is=TRUE)

# add CLEA data variable names to party information and clean-up data for import
party <- party_raw
names(party) <- c('ctr_n', 'pty', 'abbr', 'name', 'name_english', 'information')
party$pty <- as.integer(party$pty)
party[party$ctr_n == "United Kingdom", "ctr_n"] <- "UK"
party[party$ctr_n == "United States of America", "ctr_n"] <- "US"

# create dataset for adding Party Facts country short code to CLEA data
pf_country <- read.csv("country.csv", fileEncoding = 'utf-8', as.is = TRUE)
recode <- c("Korea (South)" = "Korea",
            "Russia" = "Russian Federation",
            "Saint Vincent and the Grenadines" = "St. Vincent and the Grenadines",
            "United Kingdom" = "UK",
            "United States" = "US")
recode_country <- Vectorize(function(.) ifelse(. %in% names(recode), recode[[.]], .))
country <- pf_country %>%
  mutate(name = recode_country(name)) %>% 
  select(ctr_n = name, country = name_short)

# add time and size information and select larger parties
vote <- read.csv("clea-national-vote.csv", fileEncoding = "utf-8", as.is=TRUE)
party <- party %>% left_join(country) %>% inner_join(vote)

# check country information and previous party list
if(nrow(party %>% filter(is.na(country))) > 0) {
  warning("Not all country names cleaned-up for import")
}
clea14 <- read.csv("clea-2014/clea.csv", fileEncoding = "utf-8", as.is=TRUE)
clea14 %>% filter( ! ctr_pty %in% party$ctr_pty) %>% .[['country']] %>% table

# clean-up CLEA data for import
party[party$ctr_pty == 380000035, "name_english"] <- NA
party[party$ctr_pty == 376000193, "abbr"] <- NA

write.csv(party, 'clea.csv', na='', fileEncoding = "utf-8", row.names = FALSE)
