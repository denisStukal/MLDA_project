setwd("/scratch/ds3918/ma_paper/app_qp")

library(Rmpfr)
library(Rmpi)
library(doMPI)
library(topicmodels)
load("ldadfm.RData")


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
cl <- startMPIcluster(verbose=TRUE)
registerDoMPI(cl)

st <- proc.time()
mlda_results3 <- foreach(i = 1:length(sequ), .packages=c('topicmodels','Rmpfr')) %dopar% {
  fitted <- LDA(ldadfm, k = sequ[i], method = "Gibbs",control = list(burnin = defBurnin, iter = defIter, keep = defKeep) )
  return(fitted)
  }
fin <- proc.time()
save(mlda_results3, file="split_mlda_foreach_results3.RData")

tot_time_hours <- (fin-st)/(60*60)
print(paste0('time in hours: ', tot_time_hours[3]))

tot_time_minutes <- (fin-st)/60
print(paste0('time in minutes: ', tot_time_minutes[3]))

closeCluster(cl)
