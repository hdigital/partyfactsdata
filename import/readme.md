# Documentation

In Party Facts, we only include party information and not the entire original data source.

All original datasets are ignored in version control with the prefix `source__` in the local copy.

Files are UTF-8 encoded.

Import of data into the Party Facts database is done by the project maintainers.

For a detailed instruction how to contribute your dataset, see [our import guide](https://github.com/hdigital/partyfacts/blob/master/import/import-guide.md).


# R packages and snippets

Most of the data preparation is done in R. Some scripts may require additional packages. We have a strong preference for [RStudio R packages](https://www.rstudio.com/products/rpackages/) (esp. [tidyverse](http://tidyverse.org/)). `run-all.R` includes information about used packages.

Please use the [tidyverse R Style Guide](http://style.tidyverse.org/) when writing code in R.  

Party Facts import requires ISO3 country codes. `country.csv` includes the respective information. Recode country names with the R-package `countrycode`

```r
# Example country recoding from Marpor import
marpor <- marpor %>%
  mutate(country = countrycode(countryname, 'country.name', 'iso3c',
                            custom_match = c(`Northern Ireland`='NIR')))
if(any(is.na(marpor$country))) {
  warning("Country name clean-up needed")
}
```


# Template

Template for dataset readme.md files

```Markdown
## Source

 * (...) reference in APSR style

## Credits (optional)

 * (...) name -- institution -- year(s)

## Import

 * (...) short description of data preparation pipeline

## Comments (optional)

 * (...)

## Todo later -- (optional)

 * (...)
```
