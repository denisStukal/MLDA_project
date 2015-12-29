# Name: 	Denis Stukal
# Date: 	December 25, 2015
# Summary: 	LDA analysis with MANY iterations of experimental data. To be used after /Users/ds3918/Dropbox/papers/ma_paper_2015/Code/cluster_code/experiment/R_cluster_exper_generate.R
#			Input: 		myCorpusDTMList* files produced by R_cluster_exper_generate.R AND RELOCATED TO /scratch/ds3918/ma_paper/experiment/results
#			Analysis: 	performs LDA with optimal topic selection
#			Output: 	/scratch/ds3918/ma_paper/experiment/results/NAME.RData files in the form of "many_texts30_words500_for_10topics_with_100000vocsize.RData"

library(Rmpfr)
library(Rmpi)
library(doMPI)
library(topicmodels)

setwd("/scratch/ds3918/ma_paper/experiment/results")


myIter = 20000 # 20 thous
myBurnin = 10000 # 10 thous
myKeep = 50

min_num_topic = 2
max_num_topic = 30

sequ <- seq(min_num_topic, max_num_topic, 1) 

# Harmonic mean
harmonicMean <- function(logLikelihoods, precision=2000L) {
  llMed <- median(logLikelihoods)
  as.double(llMed - log(mean(exp(-mpfr(logLikelihoods, prec = precision) + llMed))))
}

files_to_load <- list.files(pattern = "myCorpusDTMList")
print(paste0("There are ", length(files_to_load), " files to load!"))

cl <- startMPIcluster(verbose=TRUE)
registerDoMPI(cl)


# Results for many iterations (12)
load(files_to_load[12])
num_experiments = length(myCorpusDTMList)

st <- proc.time()
many_foreach <- foreach(i = 1:num_experiments, .packages = c("topicmodels", "Rmpfr")) %dopar% {
  fitted_many <- lapply(sequ, function(k) LDA(myCorpusDTMList[[i]], 
                                              k = k, method = "Gibbs",control = list(burnin = myBurnin, iter = myIter, keep = myKeep)))
  logLiks_many <- lapply(fitted_many, function(L) L@logLiks[-c(1:(myBurnin/myKeep))]  )
  hm_many <- sapply(logLiks_many, function(h) harmonicMean(h))
  optnumber_many <- sequ[which.max(hm_many)]
  return(c("optnumber" = optnumber_many, "fitted" = fitted_many[[optnumber_many-(min_num_topic-1)]]))
}
fin <- proc.time()

split_origin <- unlist(strsplit(files_to_load[12], split = "_"))
n_te <- unlist(strsplit(split_origin[3], split = "x"))[2]
n_wo <- paste(unlist(strsplit(unlist(strsplit(split_origin[4], split = "\\."))[1], split = ""))[-1], collapse = "")
un <- unlist(strsplit(split_origin[2], split = "top"))
n_to <- unlist(strsplit(un[2], split = "voc"))[1]
n_voc <- unlist(strsplit(un[2], split = "voc"))[2]
output_name <- paste0("many_texts", n_te, "_words", n_wo, "_for_", n_to, "topics_with_", n_voc, "vocsize.RData")

save(many_foreach, file = output_name)

tot_time_hours = (fin-st)/(60*60)
print(paste0("total time in hours: ", tot_time_hours[3]))


closeCluster(cl)


