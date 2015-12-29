# Name: 	README_code_application_qp
# Author: 	Denis Stukal
# Date: 	December 25, 2015
# Summary: 	describes the logic and the structure of the code for the PoliSci application 
#			of MLDA (5th Russian State Duma)

There are *.q and *.R files:
- .q files are used on cluster with qsub NAME.q to submit jobs and refer to some .R file
- .R files are files with R code (used for analysis on cluster via some .q file or with an interactive session)

These files belong to 2 groups:
- default: implement LDA with the default settings
- mlda: implement MLDA


DEFAULT:
- app_default.q
- R_default_app.R
Run on the cluster using 80 cores to estimate a range of LDA models with topic numbers from 20 to 99.
"reduced" in the name, since the code has the LDA part only (no model selection). Previos versions of the code included the post-processing parts -- hence, the "reduced" in the name.

- R_default_model_selection_and_output.R 
# takes the output (default_foreach_results.RData) from app_default_reduced.q, 
# performs model selection and saves an object default_app_output.RData which is a 2-component list with "optnumber" and "fitted" components
# Output: /scratch/ds3918/ma_paper/app_qp/results/default_app_output.RData


MLDA:
The code is split to allow for simultaneous runs. Since reps = 10, there are 10 splits:
- app_mlda_split1.q 
- app_mlda_split2.q     
- app_mlda_split3.q 
- app_mlda_split4.q 
- app_mlda_split5.q 
- app_mlda_split6.q   
- app_mlda_split7.q 
- app_mlda_split8.q
- app_mlda_split9.q     
- app_mlda_split10.q  
- R_app_mlda_split1.R    
- R_app_mlda_split2.R     
- R_app_mlda_split3.R    
- R_app_mlda_split4.R    
- R_app_mlda_split5.R     
- R_app_mlda_split6.R     
- R_app_mlda_split7.R    
- R_app_mlda_split8.R    
- R_app_mlda_split9.R     
- R_app_mlda_split10.R 
Output (split_mlda_foreach_results*.RData) goes to: /scratch/ds3918/ma_paper/app_qp/results

After all the output is produced, post-process it with:
- R_mlda_model_selection_and_output.R
# Output: /scratch/ds3918/ma_paper/app_qp/results/mlda_app_output.RData


POST_ANALYSIS:
- R_post-analysis.R
# This code makes use of the output from R_mlda_model_selection_and_output.R and R_default_model_selection_and_output.R to find the most probable words within topics and label them. 






