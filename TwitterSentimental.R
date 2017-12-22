library(rjson)
library(tm)
library(SentimentAnalysis)
library(twitteR)
a = readRDS("tweets.rds")
a
library(tm)
library(stringr)
library(wordcloud)
library(ROAuth)

tdataf =  twListToDF(a)
tdataf[190, c("id", "created", "screenName", "replyToSN", "favoriteCount", "retweetCount", "longitude", "latitude", "text")]
writeLines(strwrap(tdataf$text[190], 60))

mCor <- Corpus(VectorSource(tdataf$text)) 
mCor <- tm_map(mCor, content_transformer(tolower))
removeURL <- function(x) gsub("http[^[:space:]]*", "", x) 
mCor <- tm_map(mCor, content_transformer(removeURL)) 
removeNumPunct <- function(x) gsub("[^[:alpha:][:space:]]*", "", x) 
mCor <- tm_map(mCor, content_transformer(removeNumPunct)) 
myStopwords <- c(setdiff(stopwords('english'), c("r", "big")), "use", "see", "used", "via", "amp") 
mCor <- tm_map(mCor, removeWords, myStopwords) 
mCor <- tm_map(mCor, stripWhitespace)
mCorC <- mCor

mCor <- tm_map(mCor, stemDocument) 

stemCompletion2 <- function(x, dictionary) { 
  x <- unlist(strsplit(as.character(x), " ")) 
  x <- x[x != ""]
x <- stemCompletion(x, dictionary=dictionary) 
x <- paste(x, sep="", collapse=" ") 
PlainTextDocument(stripWhitespace(x)) 
} 

mCor <- lapply(mCor, stemCompletion2, dictionary=mCorC) 
mCor <- Corpus(VectorSource(mCor) 
writeLines(strwrap(mCor[[190]]$content, 60))


wordFreq <- function(corpus, word) { 
  results <- lapply(corpus, 
                    function(x) { grep(as.character(x), pattern=paste0("\\<",word)) } ) 
  sum(unlist(results)) }
n.miner <- wordFreq(mCorC, "miner") 
n.mining <- wordFreq(mCorC, "mining") 
cat(n.miner, n.mining)
replaceWord <- function(corpus, oldword, newword) { 
  tm_map(corpus, content_transformer(gsub), pattern=oldword, replacement=newword) 
}

mCor <- replaceWord(mCor, "miner", "mining") 
mCor <- replaceWord(mCor, "universidad", "university") 
mCor <- replaceWord(mCor, "scienc", "science")

tdm <- TermDocumentMatrix(mCor, control = list(wordLengths = c(1, Inf)))
tdm
idx <- which(dimnames(tdm)$Terms %in% c("r", "data", "mining")) 
as.matrix(tdm[idx, 21:30])
(freq.terms <- findFreqTerms(tdm, lowfreq = 20))
term.freq <- rowSums(as.matrix(tdm)) 
term.freq <- subset(term.freq, term.freq >= 20) 
df <- data.frame(term = names(term.freq), freq = term.freq)


library(ggplot2) 
ggplot(df, aes(x=term, y=freq)) + geom_bar(stat="identity") + xlab("Terms") + ylab("Count") + coord_flip() + theme(axis.text=element_text(size=7))
m <- as.matrix(tdm) 
word.freq <- sort(rowSums(m), decreasing = T) 
 pal <- brewer.pal(9, "BuGn")[-(1:4)]
 
 library(wordcloud) 
 wordcloud(words = names(word.freq), freq = word.freq, min.freq = 3, random.order = F, colors = pal)
 
 library(graph) 

 source("https://bioconductor.org/biocLite.R")
 biocLite("Rgraphviz")
 library(Rgraphviz)
 plot(tdm, term = freq.terms, corThreshold = 0.1, weighting = T)
 
 
 require(devtools) 
 install_github("sentiment140", "okugami79")
 
 library(sentiment) 
 sentiments <- sentiment(tdataf$text) 
 table(sentiments$polarity)
 
