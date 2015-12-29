#!/bin/bash
#PBS -l nodes=2:ppn=4
#PBS -l walltime=1:00:00
#PBS -l mem=60GB
#PBS -N exper_generate
##PBS -m abe ds3918@nyu.edu
#PBS -e localhost:$PBS_O_WORKDIR/${PBS_JOBNAME}_e${PBS_JOBID}.txt
#PBS -o localhost:$PBS_O_WORKDIR/${PBS_JOBNAME}_o${PBS_JOBID}.txt
 
module load r/intel/3.2.0 
module load openmpi/intel/1.6.5
RUNDIR=$SCRATCH/ma_paper/experiment/code
cd $RUNDIR

mpirun -np 8 R --slave -f R_cluster_exper_generate.R
exit 0;

