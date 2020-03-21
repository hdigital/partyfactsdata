# ParlSpeech

## Source

Rauh, Christian and Jan Schwalbach 2020. "The ParlSpeech V2 data set: Full-text corpora of 6.3 million parliamentary speeches in the key legislative chambers of nine representative democracies", https://doi.org/10.7910/DVN/L4OAKN, Harvard Dataverse, V1

## Import

 * MP data extracted from corpus -- `parlspeech-mps.R`
 * party information based on MP data -- `parlspeech.R`
   + recoded some duplicate party names (e.g. SWE: T -> KD, L -> MD)
