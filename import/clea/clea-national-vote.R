library(tidyverse)
library(stringr)

clea_version <- "20170530"
max_share <- 2.0

path <- str_interp("source__clea/clea_${clea_version}")

# Stata exported RDS file to save disk space
clea_rdata <- str_interp("${path}/clea_${clea_version}.Rds")
if( ! file.exists(clea_rdata)) {
  library(haven)
  clea <- haven::read_dta(str_interp("${path}/clea_${clea_version}_stata.zip"))
  saveRDS(clea, file = clea_rdata, ascii = TRUE)
}

# read CLEA data only once
if( ! exists("clea_raw")) {
  clea_raw <- readRDS(file=str_interp("${path}/clea_${clea_version}.Rds"))
}
clea <- clea_raw %>%
  filter(pv1 > 0) %>%
  mutate(pv1 = as.numeric(pv1),
         mn = if_else(ctr == 840, 0, as.numeric(mn)))  # unify US election months

# convert data types -- if necessary

pa_info <- clea %>%
  group_by(ctr, pty) %>%
  summarise(yr_first = min(yr, na.rm=T),
            yr_last = max(yr, na.rm=T) )

pa_name <- clea %>%
  select(ctr_n, ctr, pty_n, pty) %>%
  group_by(ctr, pty) %>%
  filter(nchar(pty_n) == max(nchar(pty_n))) %>%
  distinct(ctr, pty, .keep_all = TRUE)

elec <- clea %>%
  group_by(ctr, yr, mn, pty) %>%
  summarize(pv1 = sum(pv1, na.rm=T)) %>%
  group_by(ctr, yr, mn) %>%
  mutate(pv1_share = round(pv1 / sum(pv1) * 100, 1))

pa_share <- elec %>%
  group_by(ctr, pty) %>%
  mutate(n_election = n()) %>%
  filter(pv1_share == max(pv1_share)) %>%
  distinct(ctr, pty, .keep_all = TRUE) %>%
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

write.csv(elec_out, "source__clea/clea_national_vote.csv",
          na = "", fileEncoding = "utf-8", row.names = FALSE)


## Party information for Party Facts data import

# filter none, others, alliances, independents
# higher threshold because of votes not in "pv1" parties
party_out <- party %>%
  mutate(ctr_pty = ctr*1000000 + pty) %>%
  filter(pty > 0, pty < 4000, pv1_share_max >= max_share)

write_csv(party_out, "clea-national-vote.csv", na = "")
