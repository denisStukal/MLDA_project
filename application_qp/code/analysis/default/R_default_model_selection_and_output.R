# Name:     Denis Stukal
# Date:     December 25, 2015
# Summary:  Model selection (post-analysis) for the default LDA object produced by 
#           /Users/ds3918/Dropbox/papers/ma_paper_2015/Code/cluster_code/application_qp/code/analysis/default/app_default.q 
#           or /scratch/ds3918/ma_paper/app_qp/code/app_default.q
#           Runs ON CLUSTER (!)


library(Rmpfr)
library(topicmodels)

defIter = 2000
defBurnin = 0
defKeep = 50

min_topic_num = 20
max_topic_num = 99

sequ <- seq(min_topic_num, max_topic_num, 1) 

# Harmonic mean
harmonicMean <- function(logLikelihoods, precision=2000L) {
  llMed <- median(logLikelihoods)
  as.double(llMed - log(mean(exp(-mpfr(logLikelihoods, prec = precision) + llMed))))
}

setwd("/scratch/ds3918/ma_paper/app_qp/results")
load("default_foreach_results.RData")
# loads an object called default_results
ls()
format(object.size(default_results), units="GB")

print(paste0("Does sequ correspond to the loaded object? ", length(default_results) == length(sequ)))


logLiks <- lapply(default_results, function(L) L@logLiks[-c(1:(defBurnin/defKeep))]  )
hm <- sapply(logLiks, function(h) harmonicMean(h))
print(paste0("hm length is ", length(hm)))
optnumber <- sequ[which.max(hm)] 
default_app_output <- list("optnumber" = optnumber, "fitted" = default_results[[which.max(hm)]])

save(default_app_output, file = "default_app_output.RData")

