#!/bin/bash
#
# ingest.sh
#
# Add Instruction
#

na=$1
fileSet=$2

archiveID=$(basename $fileSet)
ftp_script=$fileSet/$archiveID.lftp
log=$fileSet/$archiveID.log
echo $(date)>$log
echo "Start preparing ingest...">>$log

cf=$fileSet/$archiveID.concordanceValidWithPID.csv
if [ ! -f $cf ] ; then
    echo "Error... did not find $cf">>$log
    echo "Is the dataset validated ?">>$log
    exit -1
fi

source $flow2_home/ingest.files.sh
source $flow2_home/ingest.pids.sh