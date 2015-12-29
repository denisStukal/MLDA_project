# Author:   Denis Stukal
# Date:     December 29, 2015
# Summary:  collects the code for all tables and graphs in the paper

rm(list = ls())
library(quanteda)
library(ggplot2)
library(dplyr)
library(grid)
library(gridExtra)
library(scales)


##########################################################################################
######################################## Figure 1 ########################################
##########################################################################################
# Original code: ~/experiment/code/R_compare_results.R

load("~/experiment/results/comparison_results_full.RData")
grid.arrange(comparison_results[[1]]$boxplot, comparison_results[[2]]$boxplot, comparison_results[[3]]$boxplot,
             comparison_results[[4]]$boxplot, comparison_results[[5]]$boxplot, comparison_results[[6]]$boxplot,
             comparison_results[[7]]$boxplot, comparison_results[[8]]$boxplot, comparison_results[[9]]$boxplot,
              comparison_results[[10]]$boxplot, comparison_results[[11]]$boxplot, comparison_results[[12]]$boxplot,
              nrow = 3, ncol = 4, top = "Figure 1. Distances between True and Recovered Topics across Methods")


##########################################################################################
######################################### Table 1 ########################################
##########################################################################################
setwd("~/application_qp/input/")
load("mycorpus.RData")

UR_speech <- subset(mycorpus, party == "UR")
LDPR_speech <- subset(mycorpus, party == "LDPR")
KPRF_speech <- subset(mycorpus, party == "KPRF")
JR_speech <- subset(mycorpus, party == "JR")

JR_fb <- subset(mycorpus, party == "FB_JR")
KPRF_vk <- subset(mycorpus, party == "VK_KPRF")
LDPR_vk <- subset(mycorpus, party == "VK_LDPR")

### DFMs # 30sec
dfm_UR_speech <- dfm(UR_speech, verbose = T) # 4,869 documents x 66,105 features
dfm_JR_speech <- dfm(JR_speech, verbose = T) # 1,499 documents x 53,437 features
dfm_LDPR_speech <- dfm(LDPR_speech, verbose = T) # 1,181 documents x 56,419 features
dfm_KPRF_speech <- dfm(KPRF_speech, verbose = T) # 3,063 documents x 77,284 features

dfm_JR_fb <- dfm(JR_fb, verbose = T) # 35 docs x 14,616 types 
dfm_LDPR_vk <- dfm(LDPR_vk, verbose = T) # 111 docs x 3,193 types
dfm_KPRF_vk <- dfm(KPRF_vk, verbose = T) # 155 docs x 61,542 types 

########## Row1: number of obs (deputy-days)
DTcorpus[, .(num_obs = length(name)), by = party]

########## Row2: number of deputies
ur_total_dep_data <- read.table("UR_list_members_cleaned.txt", header = F, stringsAsFactors = F)
colnames(ur_total_dep_data) <- "dep"
jr_total_dep_data <- read.table("JR_list_members_cleaned.txt", header = F, stringsAsFactors = F)
colnames(jr_total_dep_data) <- "dep"
ldpr_total_dep_data <- read.table("LDPR_list_members_cleaned.txt", header = F, stringsAsFactors = F)
colnames(ldpr_total_dep_data) <- "dep"
kprf_total_dep_data <- read.table("KPRF_list_members_cleaned.txt", header = F, stringsAsFactors = F)
colnames(kprf_total_dep_data) <- "dep"

length(ur_total_dep_data$dep) #UR: 322
length(jr_total_dep_data$dep) #JR: 38
length(ldpr_total_dep_data$dep) #LDPR: 43
length(kprf_total_dep_data$dep) #KPRF: 61

# UR  322 [315]
# JR: 38 [38]
# LDPR: 43 [40]
# KPRF: 61 [57]
# Square brackets from https://ru.wikipedia.org/wiki/%D0%93%D0%BE%D1%81%D1%83%D0%B4%D0%B0%D1%80%D1%81%D1%82%D0%B2%D0%B5%D0%BD%D0%BD%D0%B0%D1%8F_%D0%B4%D1%83%D0%BC%D0%B0_%D0%A4%D0%B5%D0%B4%D0%B5%D1%80%D0%B0%D0%BB%D1%8C%D0%BD%D0%BE%D0%B3%D0%BE_%D1%81%D0%BE%D0%B1%D1%80%D0%B0%D0%BD%D0%B8%D1%8F_%D0%A0%D0%BE%D1%81%D1%81%D0%B8%D0%B9%D1%81%D0%BA%D0%BE%D0%B9_%D0%A4%D0%B5%D0%B4%D0%B5%D1%80%D0%B0%D1%86%D0%B8%D0%B8_V_%D1%81%D0%BE%D0%B7%D1%8B%D0%B2%D0%B0
# Square brackets show the number of parties' seats

########## Row3: number of NOT speaking deputies
# UR: 45 out of 322  (14%)
# JR: 2 out of 38 (5%)
# LDPR: 9 out of 43 (21%)
# KPRF: 6 out of 61
round(45/322*100)
round(2/38*100)
round(9/43*100)
round(6/61*100)
# reveal what names to change
unique(UR_speech$documents$name)[!unique(UR_speech$documents$name)%in%ur_total_dep_data$dep]
unique(JR_speech$documents$name)[!unique(JR_speech$documents$name)%in%jr_total_dep_data$dep]
unique(LDPR_speech$documents$name)[!unique(LDPR_speech$documents$name)%in%ldpr_total_dep_data$dep]
unique(KPRF_speech$documents$name)[!unique(KPRF_speech$documents$name)%in%kprf_total_dep_data$dep]

# correct names in the dataset
UR_speech$documents$name[grepl("Усач", UR_speech$documents$name)] <- as.character(ur_total_dep_data$dep[grepl("Усач", ur_total_dep_data$dep)])
UR_speech$documents$name[grepl("Греб", UR_speech$documents$name)] <- as.character(ur_total_dep_data$dep[grepl("Греб", ur_total_dep_data$dep)])
UR_speech$documents$name[grepl("Ваха", UR_speech$documents$name)] <- as.character(ur_total_dep_data$dep[grepl("Ваха", ur_total_dep_data$dep)])
UR_speech$documents$name[grepl("КоломейцевН.В.", UR_speech$documents$name)] <- as.character(ur_total_dep_data$dep[grepl("КоломейцевН.В.", ur_total_dep_data$dep)])
UR_speech$documents$name[grepl("Кузьмич", UR_speech$documents$name)] <- as.character(ur_total_dep_data$dep[grepl("Кузьмич", ur_total_dep_data$dep)])
UR_speech$documents$name[grepl("Воробь", UR_speech$documents$name)] <- as.character(ur_total_dep_data$dep[grepl("Воробь", ur_total_dep_data$dep)])

JR_speech$documents$name[grepl("Пономар", JR_speech$documents$name)] <- as.character(jr_total_dep_data$dep[grepl("Пономар", jr_total_dep_data$dep)])
JR_speech$documents$name[grepl("Бесч", JR_speech$documents$name)] <- as.character(jr_total_dep_data$dep[grepl("Бесч", jr_total_dep_data$dep)])

LDPR_speech$documents$name[grepl("Селезн", LDPR_speech$documents$name)] <- as.character(ldpr_total_dep_data$dep[grepl("Селезн", ldpr_total_dep_data$dep)])

KPRF_speech$documents$name[grepl("Плетн", KPRF_speech$documents$name)] <- as.character(kprf_total_dep_data$dep[grepl("Плетн", kprf_total_dep_data$dep)])
KPRF_speech$documents$name[grepl("Запол", KPRF_speech$documents$name)] <- as.character(kprf_total_dep_data$dep[grepl("Запол", kprf_total_dep_data$dep)])
KPRF_speech$documents$name[grepl("Соловь", KPRF_speech$documents$name)] <- as.character(kprf_total_dep_data$dep[grepl("Соловь", kprf_total_dep_data$dep)])

# No speaking ghosts
unique(UR_speech$documents$name)[!unique(UR_speech$documents$name)%in%ur_total_dep_data$dep]
unique(JR_speech$documents$name)[!unique(JR_speech$documents$name)%in%jr_total_dep_data$dep]
unique(LDPR_speech$documents$name)[!unique(LDPR_speech$documents$name)%in%ldpr_total_dep_data$dep]
unique(KPRF_speech$documents$name)[!unique(KPRF_speech$documents$name)%in%kprf_total_dep_data$dep]


# who did not speak: UR
counter = 0
for (i in 1:length(ur_total_dep_data$dep)) {
  what <- unlist(strsplit(ur_total_dep_data$dep[i], split=""))
  st <- paste0(what[c(1,2)], collapse="")
  en <- paste0(what[c(length(what)-3,length(what)-2,length(what)-1,length(what))], collapse="")
  did <- any(grepl(paste0(st, ".+", en), unique(UR_speech$documents$name)))
  if (!did) {
    counter <- counter + 1
    print(ur_total_dep_data$dep[i])
  }
}
print(counter) # 45 did not speak

# who did not speak: JR
counter = 0
for (i in 1:length(jr_total_dep_data$dep)) {
  what <- unlist(strsplit(jr_total_dep_data$dep[i], split=""))
  st <- paste0(what[c(1,2)], collapse="")
  en <- paste0(what[c(length(what)-3,length(what)-2,length(what)-1,length(what))], collapse="")
  did <- any(grepl(paste0(st, ".+", en), unique(JR_speech$documents$name)))
  if (!did) {
    counter <- counter + 1
    print(jr_total_dep_data$dep[i])
  }
}
print(counter) # 2 did not speak

# who did not speak: LDPR
counter = 0
for (i in 1:length(ldpr_total_dep_data$dep)) {
  what <- unlist(strsplit(ldpr_total_dep_data$dep[i], split=""))
  st <- paste0(what[c(1,2)], collapse="")
  en <- paste0(what[c(length(what)-3,length(what)-2,length(what)-1,length(what))], collapse="")
  did <- any(grepl(paste0(st, ".+", en), unique(LDPR_speech$documents$name)))
  if (!did) {
    counter <- counter + 1
    print(ldpr_total_dep_data$dep[i])
  }
}
print(counter) # 9 did not speak

# who did not speak: KPRF
counter = 0
for (i in 1:length(kprf_total_dep_data$dep)) {
  what <- unlist(strsplit(kprf_total_dep_data$dep[i], split=""))
  st <- paste0(what[c(1,2)], collapse="")
  en <- paste0(what[c(length(what)-3,length(what)-2,length(what)-1,length(what))], collapse="")
  did <- any(grepl(paste0(st, ".+", en), unique(KPRF_speech$documents$name)))
  if (!did) {
    counter <- counter + 1
    print(kprf_total_dep_data$dep[i])
  }
}
print(counter) # 6 did not speak


# Row4: 238 days
# length(unique(mycorpus$documents$date)) # 393
# party_condition <- mycorpus$documents$party=="UR"|mycorpus$documents$party=="JR"|mycorpus$documents$party=="LDPR"|mycorpus$documents$party=="KPRF"
# days_in_set <- unique(mycorpus$documents[party_condition,]$date)
length(days_in_set)
DTcorpus[, .(num_days = length(unique(date)), percent = round(length(unique(date))/238*100)), by = party]
# length(unique(mycorpus$documents$date[mycorpus$documents$party == "UR"])) # 238
# length(unique(mycorpus$documents$date[mycorpus$documents$party == "JR"])) # 228
# length(unique(mycorpus$documents$date[mycorpus$documents$party == "LDPR"])) # 236
# length(unique(mycorpus$documents$date[mycorpus$documents$party == "KPRF"])) # 238

# row5: av.number of party representatives speaking per day
DTcorpus <- data.table(mycorpus$documents)
party_day <- DTcorpus[, .(num_dep = length(name)), by = .(party, date)]
party_day[, .(av_num_dep = round(mean(num_dep),2), sd_num_dep = round(sd(num_dep),2)), by = party]
# UR: 20.46
# JR: 6.57
# LDPR: 5.00
# KPRF: 12.87




##########################################################################################
################################### Table 1 - Appendix ###################################
##########################################################################################
load("~/experiment/results/comparison_results_full.RData")

# Column 1 (main entries)
for (i in 1:length(comparison_results)) {
  print(round(comparison_results[[i]]$t_def_mlda, 2))
}

# Column 1 (entries in parentheses)
for (i in 1:length(comparison_results)) {
  print(round(comparison_results[[i]]$t_def_mlda_pval, 3))
}


# Column 2 (main entries)
for (i in 1:length(comparison_results)) {
  print(round(comparison_results[[i]]$t_many_mlda, 2))
}

# Column 2 (entries in parentheses)
for (i in 1:length(comparison_results)) {
  print(round(comparison_results[[i]]$t_many_mlda_pval, 3))
}













