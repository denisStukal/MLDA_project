topicsDistance <- function(realTopicsList, estimatedTopicsList) {
  euc <- function(x1, x2) {
    sqrt(sum((x1 - x2)^2))
  }
  
  output <- list()
  
  for (k in 1:length(estimatedTopicsList)) {
    estimatedTopics <- exp(estimatedTopicsList[[k]]@beta)
    colnames(estimatedTopics) <- estimatedTopicsList[[k]]@terms
    
    semitruth <- lapply(realTopicsList, function(x) data.frame("words" = x$words, "prob" = x$prob, stringsAsFactors = F))
    truth <- lapply(semitruth, function(x) x[order(x[,1]),])
    common <- intersect(truth[[1]]$words, colnames(estimatedTopics))
    fullTruth <- lapply(truth, function(x) x[x$words %in% common,])
    
    distances <- list()
    for (i in 1:dim(estimatedTopics)[1]) {
      distances[[i]] <- list()
      for (j in 1:length(fullTruth)) {
        distances[[i]][[j]]<- euc(estimatedTopics[i,], fullTruth[[j]]$prob)
      }
      distances[[i]] <- unlist(distances[[i]])
    }
    finalDist <- mean(unlist(lapply(distances, function(x) min(x))))
    output[[k]] <- finalDist
  }
  return(output)
}
