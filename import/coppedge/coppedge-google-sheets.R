library("RCurl")

link <- getURL("https://docs.google.com/spreadsheets/d/1KwaCELyZ4qhVwSYPYl5z_DK2gO_UTmDgfFvxKvHbekk/pub?output=csv", .encoding = "UTF-8")
coppedge <- read.csv(textConnection(link), encoding = "UTF-8", as.is=TRUE)

write.csv(coppedge, "coppedge-parties.csv", na='', fileEncoding = "utf-8", row.names = FALSE)