
rm(list = ls())

library(quanteda)
library(ggplot2)
library(gridExtra)
library(scales)

setwd("/Users/ds3918/Dropbox/papers/ma_paper_2015/Code/cluster_code/application_qp/input/")

load("mycorpus.RData")

# Select data rows corresponding to speeches only
speech <- subset(mycorpus, party == "UR" | party == "JR" | party == "LDPR" | party == "KPRF")
# Make tge dfm
dfm_speech <- dfm(speech, verbose = T, language = "russian") # 10,612 x 127,812
dim(dfm_speech)
save(dfm_speech, file = "dfm_speech.RData")
# dfm_speech is a sparse matrix (Matrix class), so matrix operations are allowed

# Make a dfm for LDA in "topicmodels"
ldadfm <- convert(dfm_speech, to="topicmodels")

save(ldadfm, file = "ldadfm.RData")





