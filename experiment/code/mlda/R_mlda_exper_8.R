# Name: 	Denis Stukal
# Date: 	December 25, 2015
# Summary: 	MLDA analysis of experimental data. To be used after /Users/ds3918/Dropbox/papers/ma_paper_2015/Code/cluster_code/experiment/R_cluster_exper_generate.R
#			Input: 		myCorpusDTMList* files produced by R_cluster_exper_generate.R AND RELOCATED TO /scratch/ds3918/ma_paper/experiment/results
#			Analysis: 	performs MLDA with optimal topic selection
#			Output: 	/scratch/ds3918/ma_paper/experiment/results/NAME.RData files in the form of "mlda_texts30_words500_for_10topics_with_100000vocsize.RData"

library(Rmpfr)
library(Rmpi)
library(doMPI)
library(topicmodels)

setwd("/scratch/ds3918/ma_paper/experiment/results")



defIter = 2000
defBurnin = 0
defKeep = 50

min_topic_num = 2
max_topic_num = 30
reps = 10
sequ <- rep(seq(min_topic_num, max_topic_num, 1), each=reps) 

# Harmonic mean
harmonicMean <- function(logLikelihoods, precision=2000L) {
  llMed <- median(logLikelihoods)
  as.double(llMed - log(mean(exp(-mpfr(logLikelihoods, prec = precision) + llMed))))
}


files_to_load <- list.files(pattern = "myCorpusDTMList")
print(paste0("There are ", length(files_to_load), " files to load!"))



cl <- startMPIcluster(verbose=FALSE)
registerDoMPI(cl)




# Results for MLDA (8)
load(files_to_load[8])
num_experiments = length(myCorpusDTMList)

st <- proc.time()
mlda_results <- foreach(i = 1:num_experiments, .packages=c('topicmodels','Rmpfr')) %dopar% {
  fitted_mlda <- lapply(sequ, function(k) LDA(myCorpusDTMList[[i]], k = k, method = "Gibbs",control = list(burnin = defBurnin, iter = defIter, keep = defKeep) ))
  # extract logliks from each topic
  logLiks_mlda <- lapply(fitted_mlda, function(L)  L@logLiks[-c(1:(defBurnin/defKeep))])
  hm_mlda <- sapply(logLiks_mlda, function(h) harmonicMean(h))
  myMat <- matrix(hm_mlda, nrow=reps, byrow=F)
  hm_mlda_averaged <- apply(myMat, 2, function(x) sum(x) / length(x))
  optimNumber <- which.max(hm_mlda_averaged)+(min_topic_num-1)
  
  for (i in 0:(reps-1)) {
    print(i)
    cond = (optimNumber == dim(as.matrix(fitted_mlda[[reps*(optimNumber - (min_topic_num-1)) - i]]@beta))[1])
    if (cond) {
      break
    }
  }
  (min_dis = i)
  
  
  TopicProbMatrix <- as.matrix(fitted_mlda[[reps*(optimNumber - (min_topic_num-1)) - min_dis]]@beta)
  # Building a matrix with rows for LDA-topics, cols - words (i.e. Pr(w|LDA-topic))
  for ( j in (min_dis+1): (reps-1) ) {
    TopicProbMatrix <- rbind( TopicProbMatrix, as.matrix(fitted_mlda[[reps*(optimNumber - (min_topic_num-1)) - j]]@beta ) )
  }
  dim(TopicProbMatrix)
  colnames(TopicProbMatrix) <- fitted_mlda[[reps*(optimNumber - (min_topic_num-1)) - 0]]@terms
  
  distList <- list()
  for (j in min_dis:(reps-1)) {
    distList[[j+1]] <- dist(TopicProbMatrix[ (1 + optimNumber*j):(optimNumber + optimNumber*j) , ], 
                            method='manhattan')
  }
  
  # Now, make a list with min distances in every LDA-run
  minDist <- sapply(distList, min)
  
  # Finally, average them to get the threshold
  threshold <- mean(minDist)
  
  ### Clustering TopicProbMatrix using complete linkage, manhattan distance,
  ### and cutting the tree at threshold distance
  fullDist <- dist(TopicProbMatrix, method='manhattan')
  myClust <- hclust(fullDist, method='complete')
  myDendro <- as.dendrogram(myClust)
  newClusters <- cutree(myClust, h=threshold)
  # newClusters is a (optimNumber*reps)-vector containing numbers of clusters
  
  # Find cluster numbers with more than 1 element
  notSingle <- which(table(newClusters) !=1)
  # Find indices of objects from those clusters
  selectRows <- which(newClusters %in% notSingle)
  # Select rows with those indices
  TopicProbMatrixSelected <- TopicProbMatrix[selectRows,]
  # Add cluster number to the reduced probability matrix
  TopicProbMatrixSelected <- cbind(newClusters[selectRows], 
                                   TopicProbMatrixSelected)
  TopicProbMatrixSelected <- as.matrix(TopicProbMatrixSelected)
  # Name the first column of the reduced prob.matrix as "cluster_num"
  colnames(TopicProbMatrixSelected)[1] <- c("cluster_num")
  # Average probability distributions within clusters that are not singletons
  # Take all cols except the first (TopicProbMatrixSelected[,-1])
  # Split it by the first col (TopicProbMatrixSelected[,1])
  # Average cols within each split
  averageList <- by(TopicProbMatrixSelected[,-1], TopicProbMatrixSelected[,1], colMeans)
  finalTopics <- matrix( unlist(averageList), 
                         ncol=dim(TopicProbMatrixSelected[,-1])[2], byrow=T)
  
  fitted_mlda[[reps*(optimNumber - (min_topic_num-1)) - 0]]@beta <- finalTopics
  return(c("optnumber_raw" = optimNumber, "optnumber" = dim(finalTopics)[1], "fitted" = fitted_mlda[[reps*(optimNumber - (min_topic_num-1)) - 0]]))
}
fin <- proc.time()

split_origin <- unlist(strsplit(files_to_load[8], split = "_"))
n_te <- unlist(strsplit(split_origin[3], split = "x"))[2]
n_wo <- paste(unlist(strsplit(unlist(strsplit(split_origin[4], split = "\\."))[1], split = ""))[-1], collapse = "")
un <- unlist(strsplit(split_origin[2], split = "top"))
n_to <- unlist(strsplit(un[2], split = "voc"))[1]
n_voc <- unlist(strsplit(un[2], split = "voc"))[2]
output_name <- paste0("mlda_texts", n_te, "_words", n_wo, "_for_", n_to, "topics_with_", n_voc, "vocsize.RData")

save(mlda_results, file = output_name)


tot_time_hours = (fin-st)/(60*60)
print(paste0("total time in hours: ", tot_time_hours[3]))

closeCluster(cl)

