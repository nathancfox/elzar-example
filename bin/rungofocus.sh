#!/bin/bash 
#   Usage: rungofocus.sh <setup> <basefile> <inputdir> <outputdir> 
# job name
#$ -N gofocus
# processes per job
#$ -pe threads 8
#$ -wd $HOME/project/$JOB_NAME
# Per-thread memory request. 
#$ -l m_mem_free=5G
#$ -l gpu=1 
#$ -o  $HOME/project/$JOB_NAME/logs/$JOB_NAME.o$TASK_ID
#$ -e  $HOME/project/$JOB_NAME/logs/$JOB_NAME.e$TASK_ID

COMMON=~/git/elzar-example/lib/common.sh 
CMD=~/git/gofocus/gofocus/pytorch_goterm_pred.py 
NUMARGS=4

# Check for arg count...
if [ $# -ne $NUMARGS ]; then
    echo "Incorrect number of arguments."
    echo "Usage: rungofocus.sh  <setup> <basefile> <indir> <outdir>"
    exit 1
fi

# Source common functions. 
. $COMMON

# Normalize args.
setup=$1       
basefile=$2
inputdir=$3
outputdir=$4

echo "Running setup from $1"
. $setup

# $SGE_TASK_ID
taskid=gettaskid
filebase=`head -$SGE_TASK_ID $taskid | tail -1 `
echo "filebase is $filebase"

infile="$inputdir/${filebase}_hiprio.tfa "
outfile="$outputdir/${filebase}_hiprio.predout"
echo "$infile -> $outfile"

nodeinfo
prelude

time $CMD -v $infile $outfile
RET=$?

if [ $RET -ne 0 ] ; then
    exit $RET
fi
echo "Job command Return code was $RET"

postlude

exit $RET