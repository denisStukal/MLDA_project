# Name:     Denis Stukal
# Date:     December 25, 2015
# Summary:  Post-process, model selection and the cluster step of MLDA after app_mlda_20_59_split*.q were executed

library(Rmpfr)

setwd("/scratch/ds3918/ma_paper/app_qp/results")
#### Code to get the MLDA results ####
load("split_mlda_foreach_results1.RData")
load("split_mlda_foreach_results2.RData")
load("split_mlda_foreach_results3.RData")
load("split_mlda_foreach_results4.RData")
load("split_mlda_foreach_results5.RData")
load("split_mlda_foreach_results6.RData")
load("split_mlda_foreach_results7.RData")
load("split_mlda_foreach_results8.RData")
load("split_mlda_foreach_results9.RData")
load("split_mlda_foreach_results10.RData")

num_lda_runs = length(mlda_results1)
num_splits = 10

# Unpack and sort LDA objects so that they go: 20, 20, ..., 20, 21, 21, ...
mlda <- list()
count = 0
for (j in 1:num_lda_runs) {
  for (i in 1:num_splits) {
    count = count + 1
    mlda[[count]] <- get(paste0("mlda_results", i))[[j]]
  }
}

print(paste0("Is mlda of the right length? ", length(mlda) == num_lda_runs*num_splits))
print(paste0("mlda length is ", length(mlda))


# Check that LDA objects are stored in the right order in mlda
for (i in 1:length(mlda)) {
  print(mlda[[i]]@k)
}
save(mlda, file = "mlda_ordered_raw.RData") # "42.9 Gb"


# load("mlda_ordered_raw.RData") # "42.9 Gb"
# Apply the previously written code
defIter = 2000
defBurnin = 0
defKeep = 50

min_topic_num = 20
max_topic_num = 59

sequ <- seq(min_topic_num, max_topic_num, 1) 

reps = 10

harmonicMean <- function(logLikelihoods, precision=2000L) {
  llMed <- median(logLikelihoods)
  as.double(llMed - log(mean(exp(-mpfr(logLikelihoods, prec = precision) + llMed))))
}


logLiks <- lapply(mlda, function(L)  L@logLiks[-c(1:(defBurnin/defKeep))])
hm <- sapply(logLiks, function(h) harmonicMean(h))
print(paste0("hm length is ", length(hm)))

myMat <- matrix(hm, nrow=reps, byrow=F)
hm_averaged <- apply(myMat, 2, function(x) sum(x) / length(x))
(optimNumber <- which.max(hm_averaged)+(min_topic_num-1))  # since sequ does not start with 0

## Here, the optimal number of topics is 47

# Proceed with the clustering thing
# Find minimal displacement
for (i in 0:(reps-1)) {
  print(i)
  cond = (optimNumber == dim(as.matrix(mlda[[reps*(optimNumber - (min_topic_num-1)) - i]]@beta))[1])
  if (cond) {
    break
  }
}
(min_dis = i)

TopicProbMatrix <- as.matrix(mlda[[reps*(optimNumber - (min_topic_num-1)) - min_dis]]@beta)
# Building a matrix with rows for LDA-topics, cols - words (i.e. Pr(w|LDA-topic))
for ( j in (min_dis+1): (reps-1) ) {
  TopicProbMatrix <- rbind( TopicProbMatrix, as.matrix(mlda[[reps*(optimNumber - (min_topic_num-1)) - j]]@beta ) )
}
dim(TopicProbMatrix)

colnames(TopicProbMatrix) <- mlda[[reps*(optimNumber - (min_topic_num-1)) - 0]]@terms

distList <- list()
for (j in min_dis:(reps-1)) {
  distList[[j+1]] <- dist(TopicProbMatrix[ (1 + optimNumber*j):(optimNumber + optimNumber*j) , ], 
                          method='manhattan')
}

# Now, make a list with min distances in every LDA-run
(minDist <- sapply(distList, min))

# Finally, average them to get the threshold
(threshold <- mean(minDist))

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
str(TopicProbMatrixSelected)

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
# 68 topics

mlda[[reps*(optimNumber - (min_topic_num-1)) - 0]]@beta <- finalTopics
mlda_app_output <- list("optnumber" = optimNumber, "fitted" = mlda[[reps*(optimNumber - (min_topic_num-1)) - 0]])

save(mlda_app_output, file = "mlda_app_output.RData") # "138.3 Mb"

