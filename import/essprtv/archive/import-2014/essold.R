library('digest')
library('plyr')
library('stringr')

rm(list = ls())

# read data
ess <- read.csv('partyfacts-ess-mapping.csv', fileEncoding = 'utf-8', as.is=TRUE)
country <- read.csv('../0-country.csv', fileEncoding = 'utf-8', as.is=TRUE)
english <- read.table('google-10000-english.txt', as.is=TRUE)
english <- english[ , 1]  # use vector of english words

# add three letter country ISO code used in Party Facts
ess <- merge(ess, country[ , c('iso2', 'iso3')], by.x='cntry', by.y='iso2', all.x=TRUE)

# remove survey answers
ess <- ess[ ! is.na(ess$id_partyfacts) & ess$id_partyfacts >= -1 , ]
# add first and last year
ess <- ddply(ess, .(cntry, id_partyfacts), transform, first = min(year), last = max(year) )

# remove duplicate Party Facts parties -- use longest label version
ess.labels <- ddply(ess[ess$id_partyfacts != -1 , ], .(cntry, id_partyfacts), summarize,
                    label_names=paste(sort(unique(label)), collapse=' --- ') )
ess <- ess[order(nchar(ess$label)) , ]
ess <- ess[ ! duplicated(ess$id_partyfacts) | ess$id_partyfacts == -1 , ]
ess <- merge(ess, ess.labels[ , -1], by.x='id_partyfacts', all.x=TRUE)

# create ESS party ID -- md5 hash of country and label
ess$ess_party <- tolower(paste(ess$cntry, ess$label))
ess <- ess[ ! duplicated(ess$ess_party) , ]  # remove duplicate (character case) labels
ess$ess_party_md5 <- sapply(ess$ess_party, digest, algo='md5')

# extract succeeding capital letters as short party name
ess$name_short <- str_extract(ess$label, perl('[A-Z]{2,}'))

# determine if party name is in English or native language
IsEnglish <- function(name) {
  words <- tolower(unlist(str_split(name, '\\W+')))
  words <- words[sapply(words, function(x) str_length(x)) > 3]  # minimal word length
  is.english <- any(sapply(words, function(x) x %in% english))
  return(is.english)
}
ess$name_is_english <- sapply(ess$label, IsEnglish)

# add party and english name
select.row <- ess$name_is_english
ess[select.row, 'name_english'] <- ess[select.row, 'label']
ess[ ! select.row, 'name'] <- ess[ ! select.row, 'label']

# list with unique party keys
write.csv(ess, 'ess.csv', na='', row.names = FALSE)

