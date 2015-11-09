# Documentation

In Party Facts, we only include party information and not the entire original data source.

All original datasets are ignored in version control with the prefix `source__` in the local copy.

Files are UTF-8 encoded.

Import of data into the Party Facts database is done by the project maintainers.


# R packages

Most of the data preparation is done in R. Some scripts may require additional packages.

```R
packages <- c("dplyr", "tidyr", "RCurl", "readxl", "stringr")
lapply(packages, function(pack) {
  if ( ! pack %in% installed.packages()[,"Package"]) {
    install.packages(pack, repos="http://cran.r-project.org")
  }
  require(pack, character.only=TRUE, quietly=TRUE)
})
update.packages(ask=FALSE)
```


# Template

Template for dataset readme.md files

```Markdown
## Source

 * (...)

## Credits (optional)

 * (...) name -- institution -- year(s)

## Import

 * (...)

## Comments (optional)

 * (...)

## Todo later -- (optional)

 * (...)
```
