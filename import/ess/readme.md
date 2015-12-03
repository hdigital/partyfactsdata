## Source

European Social Survery (ESS)  
http://www.europeansocialsurvey.org/data/round-index.html

## Credits

Jan Fischer -- University of Bremen -- 2015  
Tomasz Żółtak -- Polish Academy of Sciences, Poland -- 2014

Holger Döring -- University of Bremen -- 2015  

## Import

The initial version of the dataset was created with a script, with significant support by [Tomasz Żółtak](mailto:t.zoltak@ibe.edu.pl).  
Tomasz also added Party Facts IDs to most parties, so that the identification of identical parties across ESS rounds was more easy.  

We use two scripts here:
* `ess-extract.R`  
  This script extracts all parties of the original ESS datasets (SPSS format) and puts them into `ess-parties.csv`.  
  The data is in long format: Each row contains a party in a round.

* `ess-google-sheet.R`  
  This script checks if all parties of `ess-parties.csv` occur in a Google Sheet [ESS party list](https://docs.google.com/spreadsheets/d/1-Z9-Ng1t500scPHk5ikDMtHXUq19Uq1VS_Nnvak1S9g/pub?output=csv) used for clean-up.  
  It adds parties to this dataset when they are missing.
  It also does some data cleaning and exports the data into `ess.csv`.  
  This data is in wide format: Each row contains a party, with variables containing party names in each round.


## Todo later

 * add size information based on the number of respondents
