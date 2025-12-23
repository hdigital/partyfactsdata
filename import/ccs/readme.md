# Comparative Candidates Survey (CCS)

## Source

* CCS 2016. Comparative Candidates Survey Module I – 2005-2013 [Dataset – cumulative file]. Distributed by FORS, Lausanne, 2016.
* CCS 2018. Comparative Candidates Survey Wave II – 2013-2018 [Dataset – cumulative file]. Distributed by FORS, Lausanne, 2018. https://doi.org/10.23662/FORS-DS-886-2

## Import

* imported only first `party_id` of a party across waves and years
* extracted information from codebook (no script provided)
* party information are extracted from the codebooks question "A1.For which party did you stand as a candidate?"
* `party_id` consist of `wave_number-T1-A1-T3`
  + `wave_number` -- no variable in the dataset
  + "dataset_620" is wave 1
  + "dataset_886" is wave 2
  + `T1` "Country ID" / "Study ID"
  + `A1` "For which party did you stand as a candidate?" / "Party stood for in this election"
  + `T3` "Year of election"

## Linking

* For linking the CCS data, please use `ccs-partyfacts.csv` in our GitHub Repository. There are all `party_id` for all waves and years with a `partyfacts_id`. Imported were only the first occurred `party_id` of a party.

## Note

* `ccs-partyfacts.R` provided to add party short name to `ccs-partyfacts.csv` for double checking
