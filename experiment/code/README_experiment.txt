# Title: 	README_experiment.txt
# Name: 	Denis Stukal
# Date: 	December 25, 2015
# Summary: 	Describes how the experiment is performed on the cluster

Step 1: Generate topics and texts
Code: 	/scratch/ds3918/ma_paper/experiment/code/exper_generate.q
Input: 	-
Output:	/scratch/ds3918/ma_paper/experiment/results/myCorpusDTMList_*.RData


Step 2: LDA with DEFAULT settings
Code: 	/scratch/ds3918/ma_paper/experiment/code/default/* (1 file for all 12 experimental setups)
Input: 	/scratch/ds3918/ma_paper/experiment/results/myCorpusDTMList_*.RData
Output:	/scratch/ds3918/ma_paper/experiment/results/default_texts*.RData


Step 3: LDA with MANY iterations 
Code:	/scratch/ds3918/ma_paper/experiment/code/many/* (12 files for 12 experimental setups)
Input:	/scratch/ds3918/ma_paper/experiment/results/myCorpusDTMList_*.RData
Output:	/scratch/ds3918/ma_paper/experiment/results/many_texts*.RData 


Step 4: MLDA 
Code:	/scratch/ds3918/ma_paper/experiment/code/mlda/* (12 files for 12 experimental setups)
Input:	/scratch/ds3918/ma_paper/experiment/results/myCorpusDTMList_*.RData
Output:	/scratch/ds3918/ma_paper/experiment/results/mlda_texts*.RData  


STEP 5: Prepare topics_final/ folder in /scratch/ds3918/ma_paper/experiment/generated/
cd /scratch/ds3918/ma_paper/experiment/generated
mkdir topics_final
cp topics100_vocab10000/* topics_final/
cp topics100_vocab1e+05/* topics_final/
cp topics100_vocab5000/* topics_final/
cp topics100_vocab50000/* topics_final/
cp topics10_vocab10000/* topics_final/
cp topics10_vocab1e+05/* topics_final/
cp topics10_vocab5000/* topics_final/
cp topics10_vocab50000/* topics_final/
cp topics50_vocab10000/* topics_final/
cp topics50_vocab1e+05/* topics_final/
cp topics50_vocab5000/* topics_final/
cp topics50_vocab50000/* topics_final/


Step 6: Compare results from DEFAULT, MANY, and MLDA
Code:	/scratch/ds3918/ma_paper/experiment/code/R_compare_results.R  
# 		NB! In interactive session:
#			qsub -I -l nodes=1:ppn=1,mem=60GB,walltime=4:00:00
#			module load r/intel/3.2.0 	
Input:	different files from /scratch/ds3918/ma_paper/experiment/results/
Output:	/scratch/ds3918/ma_paper/experiment/results/comparison_results_full.RData  


