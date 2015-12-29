# QP Application analysis

library()

load("/Users/ds3918/Dropbox/3_year_FALL/PoliSci_application_Dec15/ma_paper_2015/application_qp/results/default_app_output.RData")
load("/Users/ds3918/Dropbox/3_year_FALL/PoliSci_application_Dec15/ma_paper_2015/application_qp/results/mlda_application_output.RData")

# default_app_output is a list with 2 elements: 1 - optNumTopics, 2 - LDA-class object
# mlda_application_output is a list with 2 elements: 1 - optNumTopics (BEFORE clustering), 2 - LDA-class object


############## Sum in log-domain ##############
sumAnyNumbersInLogDomain <- function(...) {
  sumInLogDomain <- function(arg1, arg2) {
    return(max(arg1, arg2) + log(1 + exp(-abs(arg1-arg2))))
  }
  dots <- as.vector(unlist(list(...)))
  running <- sumInLogDomain(dots[1], dots[2])
  for (i in 3:length(dots)) {
    running <- sumInLogDomain(running, dots[i])
  }
  return(running)
}
###############################################

# row is a topic. Entries are logPr(word | topic). Sum in log-domain should be 0
dim(mlda_application_output[[2]]@beta)
rowsums <- apply(mlda_application_output[[2]]@beta, 1, sumAnyNumbersInLogDomain)
str(rowsums)
# Row sums in log domain are not 0, since @beta are not really probabilities: I averaged cond.probs without making sure they sum up to 1 (!!!!!)


#############################################################################################################################
################################################ Extract most probable words ################################################
#############################################################################################################################

#### MLDA
# Extract words with the highest log prob within a topic
setwd("/Users/ds3918/Dropbox/3_year_FALL/PoliSci_application_Dec15/ma_paper_2015/application_qp/results")
fitted_mlda <- mlda_application_output[[2]]
for (i in 1:dim(fitted_mlda@beta)[1]) {
  curTop <- fitted_mlda@beta[i,]
  ii <- order(curTop, decreasing=T)
  names <- fitted_mlda@terms[ii]
  newCurTop <- cbind(names, curTop[ii])
  most <- newCurTop[1:25,1]
  write(most, paste0("MLDAtopic_", i, ".txt"), sep="\n") 
}


#### Default (see code in: /Users/ds3918/Dropbox/MA_text/2_Attempt/Code/for polisci app.R)
words <- get_terms(default_app_output[[2]], 25)
str(words)

for (i in 1:dim(default_app_output[[2]]@beta)[1]) {
  write(words[,i], paste0("Defaultopic_", i, ".txt"), sep="\n")
  
}


View(words[,1:4])
View(words[,5:8])
View(words[,9:12])
View(words[,13:16])
View(words[,17:20])
View(words[,21:24])
View(words[,25:28])
View(words[,29:32])
View(words[,33:36])
View(words[,37:40])
View(words[,41:44])
View(words[,45:47])




######### Common elements in topics
mlda_words_by_topics <- list()
for (i in 1:dim(fitted_mlda@beta)[1]) {
  curTop <- fitted_mlda@beta[i,]
  ii <- order(curTop, decreasing=T)
  names <- fitted_mlda@terms[ii]
  newCurTop <- cbind(names, curTop[ii])
  most <- newCurTop[1:25,1]
  mlda_words_by_topics[[i]] <- most
}

default_words_by_topics <- lapply(1:ncol(words), function(i) words[,i])

number_words = 25
matrix_intersec <- matrix(NA, nrow = length(mlda_words_by_topics), ncol = length(default_words_by_topics))
for (i in 1:length(mlda_words_by_topics)) {
  for (j in 1:length(default_words_by_topics)) {
    matrix_intersec[i,j] <- sum(mlda_words_by_topics[[i]] %in% default_words_by_topics[[j]])/number_words
  }
}

for (i in 1:nrow(matrix_intersec)) {
  print(paste0(i, ": max intersection is ", max(matrix_intersec[i,]), "; it's with default topic ", which.max(matrix_intersec[i,])))
}



number_words = 25
matrix_intersec2 <- matrix(NA, nrow = length(default_words_by_topics), ncol = length(mlda_words_by_topics))
for (i in 1:length(default_words_by_topics)) {
  for (j in 1:length(mlda_words_by_topics)) {
    matrix_intersec2[i,j] <- sum(default_words_by_topics[[i]] %in% mlda_words_by_topics[[j]])/number_words
  }
}

for (i in 1:nrow(matrix_intersec2)) {
  print(paste0(i, ": max intersection is ", max(matrix_intersec2[i,]), "; it's with default topic ", which.max(matrix_intersec2[i,])))
}





