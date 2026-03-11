## Source

- Zulianello, M. (2025). The PopulisTree: A Systematic Taxonomy and Dataset to Study Populist Parties in Europe. European Union Politics: https://doi.org/10.1177/14651165251395309
- Zulianello, M. (2025). The PopulisTree: A New Tool to Explore the Varieties of Populism in Europe. www.populistree.org. DOI 10.17605/OSF.IO/2KNGY

## Variables

- `countrycode` -- ISO 3166-1 alpha-3
- `name_short` -- party abbreviation based on `Party_name_short` (see *populistree.R*)
- `name_english` -- party name english based on `Party_name_eng` (see *populistree.R*)
- `name` -- party name based on `Party_name` (see *populistree.R*)
- `year_first` -- first dataset appearance of party
- `year_last` -- last dataset appearance of party
- `share` -- votes received in an election
- `share_year` -- year the party received `share`
- `party_id` -- `countrycode`-`Party_name_short` (see *populistree.R*)
- `partyfacts_id` -- provided by `Partyfacts_id` (see *populistree.R*)