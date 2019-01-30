## Source

Rauh, Christian, Pieter De Wilde, and Jan Schwalbach. 2017. “The ParlSpeech Data Set: Annotated Full-Text Vectors of 3.9 Million Plenary Speeches in the Key Legislative Chambers of Seven European States.” https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/E4RSP9


## Import

 * MP data extracted from corpus -- `parlspeech-mps.R`
 * party information based on MP data -- `parlspeech.R`
   + recoded some duplicate party names (e.g. SWE: T -> KD, L -> MD)
