## Source

European Social Survey. 2017. “ESS Cumulative File Rounds 1-7, Ed.1.0." NSD - Norwegian Centre for Research Data, Norway – Data Archive and Distributor of ESS Data for ESS ERIC.

http://www.europeansocialsurvey.org/data/round-index.html

## Credits

Holger Döring – University of Bremen – 2017, 2015  
Jan Fischer – University of Bremen – 2015  
Tomasz Żółtak – Polish Academy of Sciences, Poland – 2014

## Note

* merge file for all ESS rounds in [ess-partyfacts.csv](ess-partyfacts.csv)
* _German parties not included_ — vote intention question Germany not starting with "prtvt"

## Import

[ESS Cumulative Data](http://www.europeansocialsurvey.org/downloadwizard/) – Variables Politics

We use two scripts here:

* `ess-parties.R` –
  The script extracts all parties of the ESS dataset (Stata format) and puts them into `ess-parties-round.csv` and `ess-parties.csv`. We use the vote intention questions ("prtvt") only to extract parties and calculate the maximum size based on it.

* `ess.R` –
  The script combines `ess-parties.csv` with cleaned-up party information in a [Google Sheet document](https://docs.google.com/spreadsheets/d/e/2PACX-1vShN6niFbUoafOKmngESbROIHBIyvzVP_H7FXU5COSnQRb_YgYjZq24iv27Emj_kZAu5EBndMnSJrAa/pub) (`ess-sheet.csv`) used for import into Party Facts (`ess.csv`).

* `ess-partyfacts.R` –
  Script to create a merge file `ess-partyfacts.csv` for all ESS round IDs.

An initial script and dataset was created with significant support by [Tomasz Żółtak](mailto:t.zoltak@ibe.edu.pl).  

Tomasz also added Party Facts IDs to most parties, so that the identification of identical parties across ESS rounds was more easy.
