library(fs)
library(callr)


## Remove out data ----

out_folder <- "source__chisols-data"

if(dir_exists(out_folder)) {
  file_delete(dir_ls(out_folder))
} else {
  dir_create(out_folder)
}

# remove data files in home folder
file_delete(dir_ls(".", glob = "*.csv"))


# Run R scripts ----

rscript("chisols-data-stryr.R")
rscript("chisols-data.R")
rscript("chisols.R")
