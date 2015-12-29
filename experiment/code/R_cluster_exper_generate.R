###################################################################################
# Title:    Simulation_august
# Author:   Denis Stukal
# Date:     December 25, 2015
# Summary:  Uses topicsGenerator() function to create a given
#           number of topics from a given vocabulary size.
#           
#           Uses textGenerator() function to create a 
#           given number of texts (.txt) of a given size.
#           
#           Uses topicsDistance() function to compute distance between the
#           true and estimated topics (vectors of probabilities).
#           
#           Performs LDA of 3 types (default, many iterations, many seeds)
###################################################################################

rm(list = ls())

##### Loading packages and functions
library(foreign)
library(topicmodels)
library(Rmpfr)
library(filehash)
library(foreach)
library(Rmpi)
library(doMPI)
library(quanteda)


setwd("/scratch/ds3918/ma_paper/experiment/generated")

load("/scratch/ds3918/ma_paper/experiment/code/textGenerator.R")
load("/scratch/ds3918/ma_paper/experiment/code/topicsGenerator.R")


##### Setting number of topics (top) and vocabulary size (voc)
set_num_topics <- c(10, 50, 100)
set_voc_size <- c(5000, 10000, 50000, 100000)
num_words_in_texts = 500
num_texts = 30
num_experiments = 50


dbCreate("db_for_topics")
topicsDB <- dbInit("db_for_topics")

cl <- startMPIcluster(verbose=TRUE)
registerDoMPI(cl)


st.time <- proc.time()
foreach(t = 1:length(set_num_topics), .packages=c("filehash")) %:% 
  foreach(v = 1:length(set_voc_size), .packages=c("filehash")) %dopar% {
    topicsGenerator(set_num_topics[t], set_voc_size[v]) # saves an .RData file with a "topicsFinal" list inside
    load(paste0("topics", set_num_topics[t], "_vocab", set_voc_size[v], "/topicsFinal_", set_num_topics[t], "topics_", set_voc_size[v], "words.RData")) # loads the "topicsFinal" list
    dbInsert(topicsDB, paste0("topics_", set_num_topics[t], "words", set_voc_size[v]), topicsFinal) # stores the "topicsFinal" list in the database with an appropriate name
    for (i in 1:num_experiments) {
      textGenerator(topicsFinal, numTexts = num_texts, numWordPlaces = num_words_in_texts, numTopics = set_num_topics[t], vocSize = set_voc_size[v]) # uses the current "topicsFinal" list to produce texts as .txt files
    }
  }
fin.time <- proc.time()

tot_time_minutes <- (fin.time - st.time)/(60)
print(paste0("Generation of texts and topics took ", tot_time_minutes[3], " minutes"))




# Generate DTMs to be used on cluster
for (top in set_num_topics) {
  for (voc in set_voc_size) {
    myCorpusList <- lapply(1:num_experiments, function(x) corpus(textfile(file = (paste0(getwd(), "/TEXTS_", x, "_texts", num_texts, "_words", num_words_in_texts, "_for_", top, "topics_with_", voc, "vocsize/*.txt" )) )) )
    myCorpusDTMList <- lapply(myCorpusList, function(x) dfm(x, verbose=FALSE))
    save(myCorpusDTMList, file=paste0("/scratch/ds3918/ma_paper/experiment/results/myCorpusDTMList_top", top, "voc", voc, "_tex", num_texts, "_w", num_words_in_texts, ".RData"))
    rm(myCorpusList, myCorpusDTMList)
  }
}





