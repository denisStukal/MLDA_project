#!/bin/bash
#PBS -l nodes=3:ppn=20
#PBS -l walltime=4:00:00
#PBS -l mem=60GB
#PBS -N mlda_exper_10
##PBS -m abe ds3918@nyu.edu
#PBS -e localhost:$PBS_O_WORKDIR/${PBS_JOBNAME}.e${PBS_JOBID}
#PBS -o localhost:$PBS_O_WORKDIR/${PBS_JOBNAME}.o${PBS_JOBID}
 
module load r/intel/3.2.0 
module load openmpi/intel/1.6.5
RUNDIR=$SCRATCH/ma_paper/experiment/code
cd $RUNDIR

mpirun -np 50 R --slave -f R_mlda_exper_10.R
exit 0;
