# Documentation

In Party Facts, we only include party information and not the entire original data source.

All original datasets are ignored in version control with the prefix `source__` in the local copy.

Files are UTF-8 encoded.

Import of data into the Party Facts database is done by the project maintainers.

For a detailed instruction how to contribute your dataset, see [our import guide](https://github.com/hdigital/partyfacts/blob/master/import/import-guide.md).


# R packages and snippets

Most of the data preparation is done in R. Some scripts may require additional packages. We have a strong preference for [RStudio R packages](https://www.rstudio.com/products/rpackages/) (esp. [dplyr](https://github.com/hadley/dplyr)). `run-all.R` includes information about used packages.

Party Facts import requires ISO3 country codes. `country.csv` includes the respective information. Some country names may need to be recoded -- see snippet.

```R
# minimal example -- works only for values that are valid R variable names
recode <- c(a = "aa", z = "zz", "a 1" = NA)
sapply(letters, function(.) ifelse(. %in% names(recode), recode[[.]], .))
```

Please make usage of [Hadley Wickhams R Style Guide](http://adv-r.had.co.nz/Style.html) when writing code in R.  
This will lead to more continuity across the import scripts.

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
