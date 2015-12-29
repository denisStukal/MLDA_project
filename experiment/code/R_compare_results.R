
rm(list = ls())

library(ggplot2)
library(gridExtra)


########################################################################################################
########################################################################################################

comb <- c(
  "10topics_with_5000vocsize", "10topics_with_10000vocsize", "10topics_with_50000vocsize",
  "10topics_with_100000vocsize", "50topics_with_5000vocsize", "50topics_with_10000vocsize",
  "50topics_with_50000vocsize", "50topics_with_100000vocsize", "100topics_with_5000vocsize",
  "100topics_with_10000vocsize", "100topics_with_50000vocsize", "100topics_with_100000vocsize")

# name_part = comb[2]
analysis_function <- function(name_part) {
  require(ggplot2)
  current_results_files <- list.files(path = "/scratch/ds3918/ma_paper/experiment/results/", pattern = name_part)
  load(paste0("/scratch/ds3918/ma_paper/experiment/results/", current_results_files[1]))
  load(paste0("/scratch/ds3918/ma_paper/experiment/results/", current_results_files[2]))
  load(paste0("/scratch/ds3918/ma_paper/experiment/results/", current_results_files[3]))
  
  for_top_name <- unlist(strsplit(name_part, split = "_with_"))
  to_replace <- unlist(strsplit(for_top_name[2], split = "vocsize"))
  pattern_top_name <- paste0(for_top_name[1], "_", to_replace, "words")
  ifelse( length(list.files(path = "/scratch/ds3918/ma_paper/experiment/generated/topics_final/", pattern = pattern_top_name)) != 0, 
        current_final_topic_file <- list.files(path = "/scratch/ds3918/ma_paper/experiment/generated/topics_final/", pattern = pattern_top_name),
        current_final_topic_file <- list.files(path = "/scratch/ds3918/ma_paper/experiment/generated/topics_final/", pattern = paste0(for_top_name[1], "_1e+05words")))
  load(paste0("/scratch/ds3918/ma_paper/experiment/generated/topics_final/", current_final_topic_file))
  load("/scratch/ds3918/ma_paper/experiment/code/topicsDistance.R")
  
  # Reassing names to loaded object (for function operation purposes)
  results_default <- get(ls()[grep("default", ls())])
  results_many <- get(ls()[grep("many", ls())])
  results_mlda <- get(ls()[grep("mlda", ls())])
  
  # Extract numbers of topics
  num_topics_found_default <- sapply(results_default, function(x) x[[1]])
  num_topics_found_many <- sapply(results_many, function(x) x[[1]])
  num_topics_raw_mlda <- sapply(results_mlda, function(x) x[[1]])
  num_topics_found_mlda <- sapply(results_mlda, function(x) x[[2]])
  
  # Extract LDA objects into a list
  list_default <- lapply(results_default, function(x) x[[2]])
  list_many <- lapply(results_many, function(x) x[[2]])
  list_mlda <- lapply(results_mlda, function(x) x[[3]])
  
  # Compute distances between recovered and true topics topics
  distance_default <- unlist(topicsDistance(topicsFinal, list_default))
  distance_many <- unlist(topicsDistance(topicsFinal, list_many))
  distance_mlda <- unlist(topicsDistance(topicsFinal, list_mlda))
  
  # Student's t test for paired obs
  t_def_many <- t.test(distance_default, distance_many, paired = F)
  t_def_mlda <- t.test(distance_default, distance_mlda, paired = F)
  t_many_mlda <- t.test(distance_many, distance_mlda, paired=F)
  
  # Wilcoxon rank sum tests
  w_def_many <- wilcox.test(distance_default, distance_many, paired = F, alternative = "two")
  w_def_mlda <- wilcox.test(distance_default, distance_mlda, paired = F, alternative = "two")
  w_many_mlda <- wilcox.test(distance_many, distance_mlda, paired = F, alternative = "two")
  

  # ggplot (boxplot for average distances obtained for every of the 50 simulations)
  gdat <- data.frame("type" = rep(c("default", "many", "mlda"), each = length(distance_default)), 
                     "values" = c(distance_default, distance_many, distance_mlda))
  
  parts <- unlist(strsplit(x = name_part, split = "_with_"))
  num_top <- as.numeric(unlist(strsplit(x = parts[1], split = "topics"))[1])
  vocsize <- unlist(strsplit(x = parts[2], split = "vocsize"))[1]
  
  g_box <- ggplot(data = gdat, aes(y = values, x = type)) + geom_boxplot() + 
    theme(panel.background = element_rect(fill = "white")) + 
    theme(axis.text=element_text(colour = "black")) + 
    xlab("Type of analysis") + 
    ylab("Distance values") + 
    ggtitle(paste0(num_top, " topics with ", vocsize, " words"))
  
  g_box_scaled <- ggplot(data = gdat, aes(y = values, x = type)) + geom_boxplot() + 
    theme(panel.background = element_rect(fill = "white")) + 
    theme(axis.text=element_text(colour = "black")) + 
    xlab("Type of analysis") + 
    ylab("Distance values") + 
    ggtitle(paste0(num_top, " topics with ", vocsize, " words")) + 
    scale_y_continuous(limits = c(0.005, 0.1))
  
  # Difference in retrieved and true numbers of topics
  dif_num_topics_default <- num_topics_found_default - num_top
  dif_num_topics_many <- num_topics_found_many - num_top
  dif_num_topics_mlda <- num_topics_found_mlda - num_top
  dif_num_topics_raw_mlda <- num_topics_raw_mlda - num_top


  return(list("distance_default" = distance_default, "distance_many" = distance_many, "distance_mlda" = distance_mlda,
              "t_def_many" = t_def_many$stat, "t_def_many_pval" = t_def_many$p.val, 
              "t_def_mlda" = t_def_mlda$stat, "t_def_mlda_pval" = t_def_mlda$p.val, 
              "t_many_mlda" = t_many_mlda$stat, "t_many_mlda_pval" = t_many_mlda$p.val, 
              "w_def_many" = w_def_many$stat, "w_def_many_pval" = w_def_many$p.val, 
              "w_def_mlda" = w_def_mlda$stat, "w_def_mlda_pval" = w_def_mlda$p.val, 
              "w_many_mlda" = w_many_mlda$stat, "w_many_mlda_pval" = w_many_mlda$p.val,
              "boxplot" = g_box, "boxplot_scaled" = g_box_scaled,
              "dif_num_topics_default" = dif_num_topics_default, "dif_num_topics_many" = dif_num_topics_many, "dif_num_topics_mlda" = dif_num_topics_mlda, "dif_num_topics_raw_mlda" = dif_num_topics_raw_mlda,
              "true_num_topics" = num_top))
}

st <- proc.time()
comparison_results <- list()
for (i in 1:length(comb)) {
  print(i)
  comparison_results[[i]] <- analysis_function(comb[i])
}
fin <- proc.time()
tot_time_minutes <- (fin - st)/60
tot_time_hours <- (fin - st)/(60*60)
print(paste0("total time in minutes: ", tot_time_minutes[3]))
print(paste0("total time in hours: ", tot_time_hours[3]))

names(comparison_results) <- comb
save(comparison_results, file = "/scratch/ds3918/ma_paper/experiment/results/comparison_results_full.RData")



# load("/scratch/ds3918/ma_paper/experiment/results/comparison_results_full.RData")
# grid.arrange(comparison_results[[1]]$boxplot, comparison_results[[2]]$boxplot, comparison_results[[3]]$boxplot,
#              comparison_results[[4]]$boxplot, comparison_results[[5]]$boxplot, comparison_results[[6]]$boxplot,
#              comparison_results[[7]]$boxplot, comparison_results[[8]]$boxplot, comparison_results[[9]]$boxplot,
#              comparison_results[[10]]$boxplot, comparison_results[[11]]$boxplot, comparison_results[[12]]$boxplot,
#              nrow = 3, ncol = 4, top = "Figure 1. Distances between True and Recovered Topics across Methods")
# 9x16

