#!/bin/bash
#PBS -l nodes=3:ppn=20
#PBS -l walltime=10:00:00
#PBS -l mem=60GB
#PBS -N default_exper_all
##PBS -m abe ds3918@nyu.edu
#PBS -e localhost:$PBS_O_WORKDIR/${PBS_JOBNAME}_e${PBS_JOBID}.txt
#PBS -o localhost:$PBS_O_WORKDIR/${PBS_JOBNAME}_o${PBS_JOBID}.txt
 
module load r/intel/3.2.0 
module load openmpi/intel/1.6.5
RUNDIR=$SCRATCH/ma_paper/experiment/code
cd $RUNDIR

mpirun -np 50 R --slave -f R_default_exper.R
exit 0;

