############################################
# Arthur Spirling
####  Yale, Nov 15, 2019
####  TEXT-AS-DATA
####  Part II

# pathway is wherever you are holding your data for class
pathway = "C:/Users/arthur spirling/Dropbox/Yale_Text_Class/data/"


#################
#Getting Started#
#################

#install quanteda and readtext
library(quanteda)
library(readtext)

#we'll also need ldadtuning and topicmodels, later
library(topicmodels)
library(ldatuning)


#let's grab the UK manifestos and create a corpus
manifestos <- readtext(paste0(pathway, "UK_manifestos/*.txt"), docvarsfrom=c("filenames"))
manifestos_corpus <- corpus(manifestos) 
docnames(manifestos_corpus) <- manifestos$doc_id

#and let's grab SOTU too
sotu <- readtext(paste0(pathway,"sotu/*.txt"),docvarsfrom=c("filenames"))
sotu_corpus <- corpus(sotu)
docnames(sotu_corpus) <- sotu$doc_id


########################
####### DICTIONARIES  ##
########################



##############################
# sENTIMENT USING HU and LIU #
##############################
pos<-read.table(paste0(pathway,"dictionaries/positive-words.txt"), as.is=T)
neg <-read.table(paste0(pathway, "dictionaries/negative-words.txt"), as.is=T)

#function just to do simple arithmatic
sentiment<-function(words=c("really great good stuff bad")){
  require(quanteda)
  tok <- tokens(words)
  pos.count <- sum(tok[[1]]%in%pos[,1])
  cat("\n positive words:",tok[[1]][which(tok[[1]]%in%pos[,1])],"\n")
  
  neg.count <- sum(tok[[1]]%in%neg[,1])
  cat("\n negative words:",tok[[1]][which(tok[[1]]%in%neg[,1])],"\n\n")
  out <- (pos.count - neg.count)/(pos.count+neg.count)
  out
}

#review examples
movie <-  "Director and co-screenwriter Adam McKay (Step Brothers) bungles a great 
opportunity to savage the architects of the 2008 financial crisis in The Big Short, 
wasting an A-list ensemble cast in the process. Steve Carell, Brad Pitt, Christian 
Bale and Ryan Gosling play various tenuously related members of the finance industry,
men who made made a killing by betting against the housing market, which at that point
had superficially swelled to record highs. All of the elements are in place for a 
lacerating satire, but almost every aesthetic choice in the film is bad, 
from the U-Turn-era Oliver Stone visuals to Carell's sketch-comedy performance
to the cheeky cutaways where Selena Gomez and Anthony Bourdain explain complex 
financial concepts. After a brutal opening half, it finally settles into a groove, 
and there's a queasy charge in watching a credit-drunk America walking towards that 
cliff's edge, but not enough to save the film."

yelp<- "this guy mat the owner is a scam do not use him you will regret doing business 
with this company I'm going to court he is a scam customers please beware he 
will destroy your floors he is nothing by a liar he robs customers, 
and promises you everything if you want s--- then go with him if you like nice work 
find another he is A SCAM LIAR BULL----ER,"

wolfshirt <-"This item has wolves on it which makes it intrinsically sweet and worth
5 stars by itself, but once I tried it on, that's when the magic happened. 
After checking to ensure that the shirt would properly cover my girth, 
I walked from my trailer to Wal-mart with the shirt on and was immediately 
approached by women. The women knew from the wolves on my shirt that I, 
like a wolf, am a mysterious loner who knows how to 'howl at the moon' 
from time to time (if you catch my drift!). The women that approached
me wanted to know if I would be their boyfriend and/or give them money for 
something they called mehth. I told them no, because they didn't have enough teeth,
and frankly a man with a wolf-shirt shouldn't settle for the first thing that comes
to him."



################
# WORD SCORES  #
################

#use the 1983 and 1987 manifestos and left-right training cases
#--> see if we can predict Labour 1997 manifesto
dfm<- dfm(manifestos_corpus, verbose=FALSE)
dfm_5 <- dfm[c("Con1983.txt", "Con1987.txt", "Lab1983.txt", "Lab1987.txt", "Lab1997.txt")]

#rescale the scores, and provide a prediction for Lab1997...
predicted_97 <- predict( textmodel_wordscores(dfm_5, y=c(1, 1, -1,-1,  NA), smooth=1), rescaling="lbg" )


######################
# TOPIC MODELS: LDA  #
######################

#make a dfm
DFM<- dfm(manifestos_corpus, remove_punct=TRUE) 
#for now just using post war Lab and Con ones
DFM2 <- DFM[c(8:23, 31:46),]
#we'll be a little more aggressive about preprocessing -- get rid of stopwords too
DFM3 <- dfm(DFM2, remove=c(stopwords()))

#let's start with basic 10 topic model, using LDA
# (takes 2 or 3 minutes)
lda.model <- LDA(DFM3, k=10)

#let's get the estimated topic mix of each document...
topicProbabilities <- as.data.frame(lda.model@gamma) 
#not that rowSums(topicProbabilities) is as expected

#now, let's grab the terms and see what topic they were assigned to
termassignments <- as.data.frame(t(posterior(lda.model)$terms))
#for example, what topic(s) would we expect to find words in
x11()
par(mfrow=c(1,2))
barplot(as.numeric(termassignments["taxation",])) #everywhere
barplot(as.numeric(termassignments["1919",])) #one place

#let's try to label the topics
topTerms <- terms(lda.model, 6)
#hmm, may be helpful, may be not

#let's find out how many topics is optimal for our model (just check 2 to 15)
# this take a while -- 8 minutes or so
how.many.topics <- FindTopicsNumber(DFM3,  topics = seq(from = 2, to = 15, by = 1))


#plot the result (larger number is better in this metric)
x11()
FindTopicsNumber_plot(how.many.topics)








###############################################################################
#                           More Ideas/techniques                             # 
###############################################################################



################
# NAIVE BAYES ##
################

#?textmodel_nb
email1 <- "money inherit prince"
email2 <- "prince inherit amount"
email3 <- "inherit plan money"
email4 <- "cost amount amazon"
email5 <-  "prince william news"
newemail <- "prince prince money"

trainingset<- dfm(c(email1, email2, email3, email4, email5, newemail))

trainingclass <- factor(c("spam", "spam", "ham", "ham", "ham" , NA), ordered = T)
## replicate example from lecture
NB_model <- textmodel_nb(trainingset, trainingclass, smooth=0, prior=c("docfreq"))
predict(NB_model, newdata = trainingset[6, ])

##problem of sparsity: suppose new email includes term never seen in spam
newemail2 <- "plan inherit prince"
trainingset2<- dfm(c(email1, email2, email3, email4, email5, newemail2))
trainingclass2 <- factor(c("spam", "spam", "ham", "ham", "ham" , NA), ordered = T)
NB_model2 <- textmodel_nb(trainingset2, trainingclass2, smooth=0, prior=c("docfreq"))
predict(NB_model2, newdata = trainingset2[6, ])
##oh dear... can 'correct' this by adding smooth=1
NB_model3 <- textmodel_nb(trainingset2, trainingclass2, smooth=1, prior=c("docfreq"))
predict(NB_model3, newdata = trainingset2[6, ])

