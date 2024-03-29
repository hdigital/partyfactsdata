library(dplyr)

max_share <- 2.0

# Stata exported csv file
# clea <- read.csv("clea.csv", fileEncoding = "cp1252", na.strings = "Missing data", as.is = TRUE)
# saveRDS(clea, file="clea.Rda", ascii = TRUE)

# read CLEA data only once
if( ! exists("clea_raw")) {
  clea_raw <- readRDS(file="source__clea/clea.Rda")
}
clea <- clea_raw

# convert data types -- if necessary
clea$pv1 <- as.integer(clea$pv1)

pa_info <- clea %>%
  group_by(ctr, pty) %>%
  summarise(yr_first = min(yr, na.rm=T),
            yr_last = max(yr, na.rm=T) )

pa_name <- clea %>%
  select(ctr_n, ctr, pty_n, pty) %>%
  group_by(ctr, pty) %>%
  filter(nchar(pty_n) == max(nchar(pty_n))) %>%
  distinct(ctr, pty)

elec <- clea %>%
  group_by(ctr, yr, mn, pty) %>%
  summarize(pv1 = sum(pv1, na.rm=T)) %>%
  group_by(ctr, yr, mn) %>%
  mutate(pv1_share = round(pv1 / sum(pv1) * 100, 1))

pa_share <- elec %>%
  group_by(ctr, pty) %>%
  mutate(n_election = n()) %>%
  filter(pv1_share == max(pv1_share)) %>%
  distinct(ctr, pty) %>%
  select(ctr, pty, pv1_share_max = pv1_share, pv1_share_max_yr = yr, n_election)

party <- pa_name %>%
  left_join(pa_info) %>%
  left_join(pa_share) %>%
  arrange(ctr_n, pty_n)


## National election data

elec_out <- pa_name %>%
  right_join(elec) %>%
  group_by() %>%
  arrange(ctr_n,  yr, mn, -pv1_share)

write.csv(elec_out, 'source__clea/clea_national_vote.csv',
          na = '', fileEncoding = "utf-8", row.names = FALSE)


## Party information for Party Facts data import

# filter none, others, alliances, independents
# higher threshold because of votes not in 'pv1' parties
party_out <- party %>%
  mutate(ctr_pty = ctr*1000000 + pty) %>%
  filter(pty < 3996, pv1_share_max >= max_share)

write.csv(party_out, 'clea_national_party.csv', na='', fileEncoding = "utf-8", row.names = FALSE)
