#!/bin/bash
#PBS -q mpi_7
#PBS -l select=7:ncpus=28:mpiprocs=29:mem=65G
#PBS -l walltime=06:00:00
#PBS -N NEMO420
#PBS -eo 


cd $PBS_O_WORKDIR
qstat -f $PBS_JOBID
ls $TMPDIR
echo $SCRATCH
echo $DATAWORK
echo $HOST
pbsnodes $HOST
source /usr/share/Modules/3.2.10/init/bash
module load DCM/4.2.0

module list
which wo
pwd 

set -x
ulimit -s 
ulimit -s unlimited

CONFIG=CREG025.L75
CASE=NEMO420

CONFCASE=${CONFIG}-${CASE}
CTL_DIR=$HOME/RUNS/RUN_${CONFIG}/${CONFCASE}/CTL

# Following numbers must be consistant with the header of this job
export NB_NPROC=195     # number of cores used for NEMO
export NB_NPROC_IOS=7  # number of cores used for xios (number of xios_server.exe)
export NB_NCORE_DP=0    # activate depopulated core computation for XIOS. If not 0, RUN_DP is
                        # the number of cores used by XIOS on each exclusive node.
# Rebuild process 
export MERGE=0          # 0 = on the fly rebuild, 1 = dedicated job
export NB_NPROC_MER=28 # number of cores used for rebuild on the fly  (1/node is a good choice)
export NB_NNODE_MER=1  # number of nodes used for rebuild in dedicated job (MERGE=0). One instance of rebuild per node will be used.
export WALL_CLK_MER=3:00:00   # wall clock time for batch rebuild

date
#
echo " Read corresponding include file on the HOMEWORK "
.  ${CTL_DIR}/includefile.sh

. $RUNTOOLS/lib/function_4_all.sh
. $RUNTOOLS/lib/function_4.sh
#  you can eventually include function redefinitions here (for testing purpose, for instance).
. $RUNTOOLS/lib/nemo4.sh
