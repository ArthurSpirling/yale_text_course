############################################
# Arthur Spirling
####  Yale, Nov 15, 2019
####  TEXT-AS-DATA
####  Part I


# pathway is wherever you are holding your data for class
pathway = "C:/Users/as9934/Dropbox/Yale_Text_Class/data/"


#################
#Getting Started#
#################

#install quanteda if don't already have it
#install.packages("quanteda")
library(quanteda)

#and let's grab readtext
#install.packages("readtext")
library(readtext)


#install lsa if don't have it
#install.packages("lsa")
#we load lsa, just because it has a nice cosine function
# (write your own if you like!)
library(lsa)

#install bursts if you don't have it
# install.packages("bursts")
library(bursts)



#let's grab the UK manifestos
# the argument docvarsfrom= allows us to use the filenames as document ids 
manifestos <- readtext(paste0(pathway,"UK_manifestos/*.txt"), docvarsfrom=c("filenames"))

# We need to turn the text files into a 'corpus' so that we can do more 
# interesting things with them
manifestos_corpus <- corpus(manifestos)
docnames(manifestos_corpus) <- manifestos$doc_id

# let's get a summary of this corpus
summary(manifestos_corpus, showmeta = T)

#let's inspect the Labour 1983 manifesto
texts(manifestos_corpus)[manifestos_corpus$documents$docvar1=="Lab1983"]
#hmm, quite a bit of annoying mark up.  We'll deal with that later...

#For now: how long was the 'longest suicide note in history'? (in sentences)
summary(corpus_subset(manifestos_corpus, docvar1=="Lab1983"))$Sentence

#what about the Tory manifesto that election?
summary(corpus_subset(manifestos_corpus, docvar1=="Con1983"))$Sentence

#are manifestos getting longer or shorter over time?
#well, let's get the number of sentences for each manifesto
num_sentences <- summary(manifestos_corpus)$Sentence

#need to grab the dates of the manifestos. We could have added that via docvars()<-
#but let's just do a bit of regex, so you've seen it at work
dates <- as.numeric( gsub('[^[:digit:]]','', summary(manifestos_corpus)$docvar1) )

dev.new() #just to force a new plot window (-- I think this works on a mac too?)
plot(dates, num_sentences, pch=16)
#looks like they're generally getting heftier.

#hmm, how about SOTU speeches?
sotu <- readtext(paste0(pathway,"sotu/*.txt"),docvarsfrom=c("filenames"))
sotu_corpus <- corpus(sotu)
docnames(sotu_corpus) <- sotu$doc_id
#summary(sotu_corpus)

#############################
#Vector Space Representation#
#############################

#let's make a document feature matrix
#AKA a document term matrix

#first, let's look at the options
?dfm 
# hmm, quite a lot of different stuff we could do!

#to see this stuff at work, let's grab the Labour 1983 manifesto and 
# work on it directly for a moment
Lab_1983 <- corpus_subset(manifestos_corpus, docvar1=="Lab1983")

#### TOKENS

#one of the things dfm does is 'tokenize'
# ?tokenize
#for now, let's use that directly just to see how it works.
#So, 
tokens_all <- tokens(Lab_1983) #this defaults to the /word/ level
#how many  are there?
length(tokens_all[[1]]) #~25.5k
#what about _unique_ tokens (basically the 'types' in this context)
length(unique(tokens_all[[1]])) #~3.6k


#let's not bother with punctuation: not very helpful generally
tokens_nopunc <- tokens(Lab_1983, remove_punct=TRUE)
#can check
length(tokens_nopunc[[1]]) #~22.5k



#and maybe we could remove numbers too: probably don't care about them either
tokens_nopunc_nonum <- tokens(Lab_1983, remove_punct=TRUE, remove_numbers=TRUE)
#can check
length(tokens_nopunc_nonum[[1]]) #~22.4k

#what if we wanted bigrams (only) instead of unigrams?
tokens_bigrams <- tokens(Lab_1983, ngrams= 2)

#### STEMS

#let's stem the document (uses Porter)
stemmed <- tokens_wordstem(tokens_all) #can inspect directly, if desired.
# to see what's happened in practice, let's compare 'family' and 'families'
# So, compare
tokens_all[[1]][grep("fam",tokens_all[[1]])]
# to
stemmed[[1]][grep("fam",stemmed[[1]])]

#### STOPWORDS

#what are they?
stopwords("english")
#and for that matter
stopwords("german")
# etc
# we'll use these in a minute...

##### MAKING A VECTOR
Lab1983_vector <- dfm(Lab_1983, stem=TRUE, remove=stopwords("english"), remove_punct=TRUE, remove_numbers=TRUE  )
#can take a look at it in longform via (well, first 10 terms at least)
as.matrix(Lab1983_vector, colnames=colnames(Lab1983_vector))[1, 1:10]

#alright, let's make a dfm of our whole collection
DTM <- dfm(manifestos_corpus, stem=T, remove=stopwords("english"),
           remove_punct=TRUE)
#what proportion of it is zeros?
sum(DTM==0)/length(DTM) #so, q a bit!

#we can use different weights if we like.  e.g. tfidf
DTM_tfidf <- dfm_tfidf(DTM)
#interesting to compare
topfeatures(DTM)
#with
topfeatures(DTM_tfidf)
#hmm, what happened here? looks like it upweighted typos!


#######################
# SIMILARITY MEASURES #
#######################


#example from lecture
doc1 <- c(5,4,3)
doc2 <- c(50,40,30)
doc3 <- c(3,3,4)

doc.mat <- rbind(doc1,doc2,doc3)

#euclidean distance
dist(doc.mat)

#cosine distance
# (note we are using LSA here -- we'll use quanteda in a minute)
cosine(doc1, doc2) #compare to euclidean

#how close were the Tory and Labour 1983 manifestos?
textstat_simil(DTM[c("Lab1983.txt","Con1983.txt"),], method='cosine')

#what about 1997?
textstat_simil(DTM[c("Lab1997.txt","Con1997.txt"),], method='cosine')
#NB: not exactly the same as lecture calcs, bec stemmed in slightly 
# different way -- but pretty close

#for completeness, let's look at Jaccard
textstat_simil(DTM[c("Lab1997.txt","Con1997.txt"),], method='jaccard')
#which should be a bit larger than
textstat_simil(DTM[c("Lab1983.txt","Con1983.txt"),], method='jaccard')

#########################
# Key Words in Context  #
#########################

kwic(manifestos_corpus, "socialism")
kwic(manifestos_corpus, pattern = phrase("poll tax") )
kwic(manifestos_corpus,pattern = phrase("community charge"))

#####################
# LEXICAL DIVERSITY #
#####################

#take a look at the type-token ratio for the manifestos
types <- summary(manifestos_corpus)$Types
tokens <- summary(manifestos_corpus)$Tokens
TTR <- types/tokens
#let's plot them over time
dates <- as.numeric( gsub('[^[:digit:]]','',rownames(DTM)) )
x11()
plot(dates, TTR, pch=16)
#seem to be getting less diverse!


###############
# READABILITY #
###############

FRE_manifestos <- textstat_readability(manifestos_corpus, measure='Flesch')
FRE_sotu <- textstat_readability(sotu_corpus, measure='Flesch')

x11()
plot(dates, FRE_manifestos$Flesch, pch=16, ylim=c(20,80), xlim=c(1918, 2001))
#no obvious pattern (?)
#What about compared to SOTU?
years_sotu <- as.numeric(gsub(".txt","",gsub("su","", FRE_sotu$document)))#v inefficient
lines(years_sotu, FRE_sotu$Flesch, col="red", lwd=2)

#what about other measures?
DC_manifestos <-textstat_readability(manifestos_corpus, measure="Dale.Chall")
cor(FRE_manifestos$Flesch, DC_manifestos$Dale.Chall) #look similar in practice

#weird things can happen --
sentance <- "These include capital expenditures by the Rural Electrification 
Administration and expenditures for resource development by other 
organizational units in the Department of Agriculture 
which are also mentioned above under 'agricultural programs.' "

textstat_readability(sentance, measure='Flesch')
#hmm...

#################
# BOOTSTRAPPING #
#################

#much more efficient ways to do this, but this lays out the logic
# First, write a function that bootstraps at the sentance level within a doc
boot_doc <- function(document=manifestos_corpus[1],nboot=200){
  #tokenize to the sent level
  toked_doc <- tokens(document, what='sentence')  
  #make it into a corpus
  sent_corpus<-corpus(unlist(toked_doc))
  
  #set up a vector to take mean of bootstrap stats
  means <- c()
  
  #sample the sentences (with replacement)
  #do this nboot times
  for(i in 1:nboot){
    samp_corpus <- sent_corpus[sample(1: nrow(summary(sent_corpus)), replace=T)]
    #apply FRE to each of those, take mean
    FRE_mean <- mean(textstat_readability(samp_corpus, measure='Flesch')$Flesch)
    means <- c(means, FRE_mean)
    mean_FRE <- mean(means)
    FRE_lower <- quantile(means, c(0.025))
    FRE_upper <- quantile(means, c(0.975))
    cat("done",i,"of",nboot,"resamples\n")
  }
  c(FRE_lower, mean_FRE, FRE_upper)
}

#so, for example, 
boot_Lib1918 <- boot_doc(manifestos_corpus[47], nboot=50) 
#gives the mean and basic CI for the first Lib manifesto

#whereas
boot_Lib1997 <- boot_doc(manifestos_corpus[68], nboot=50)
#gives that info for the Libs in 1997

#NB: Libs in 1997 have much more variable sentence lengths, but
# the manifesto is longer, so we are generally more certain

######################
# BASIC STYLOMETRICS #
######################

#some texts by Austen
austen <- corpus(readtext(paste0(pathway,"austen_texts/*.txt"), docvarsfrom=c("filenames")) )
#some texts by Dickens
dickens <- corpus(readtext(paste0(pathway,"dickens_texts/*.txt"),  docvarsfrom=c("filenames")) )

#a mystery text
mystery <- corpus(readtext(paste0(pathway,"mystery/*.txt" )))

#let's look at some key function words
# and make the DTMs with those in mind
# (from Peng and Hengartner)
func.words <- c('the', 'may', 'which', 'not', 'be', 'upon')


austen.dfm <- dfm(austen, select=func.words)
dickens.dfm <- dfm(dickens, select=func.words)
mystery.dfm <- dfm(mystery, select=func.words)

#then, inspect (takes means)
apply( austen.dfm/rowSums(as.matrix(austen.dfm)), 2, mean) 
#vs 
apply(dickens.dfm/rowSums(as.matrix(dickens.dfm)), 2, mean)
#vs
mystery.dfm/rowSums(as.matrix(mystery.dfm)) 
##--> who looks like most plausible author?


##############
# BURSTINESS #
##############
treaties <- readtext(paste0(pathway,"treaties/*.txt"), docvarsfrom=c("filenames"))
treaties_corpus <- corpus(treaties)

#grab the treaty dates
cases <- read.csv(paste0(pathway,"treaties/universecases.csv"))
date <- as.Date(as.character(cases$Date[1:365]), "%m-%d-%Y")
#put them on corpus
docvars(treaties_corpus)$Date <- date

DTM_treaties <- dfm(treaties_corpus)

#write a function to look at burstiness of given word
#this is a repurposing of some guts of kleinberg()
bursty<-function(word="sioux"){
  word.vec <- DTM_treaties[,which(colnames(DTM_treaties) == word)]
  word.times <- c(0,which(as.vector(word.vec)>0))
  kl <- kleinberg(word.times, gamma=.5)
  kl$start <- date[kl$start+1]
  kl$end <- date[kl$end]
  max_level <- max(kl$level)
  plot(c(kl$start[1], kl$end[1]), c(1,max_level), 
       type = "n", xlab = "Time", ylab = "Level", bty = "n", 
       xlim = c(kl$start[1], kl$end[1]), ylim = c(1, max_level), 
       yaxt = "n")
  axis(2, at = 1:max_level)
  arrows(kl$start, kl$level, kl$end, kl$level, code = 3, angle = 90, 
         length = 0.05)
  
  print(kl)
  #note deviation from standard defaults bec don't have that much data
}


