# run import scripts in all sub-folders

dataset_ignore <- c('', 'ess', 'kurep')
wd <- getwd()

for (dataset in list.dirs(full.names = FALSE)) {
  if(dataset %in% dataset_ignore) next
  print(paste("running --- ", dataset))
  setwd(paste(wd, dataset, sep = "/"))
  source(paste0(dataset, '.R'))
}

setwd(wd)
