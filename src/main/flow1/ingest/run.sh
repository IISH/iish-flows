#!/bin/bash
#
# run.sh
#
# Add Instruction
#

na=$1
fileSet=$2
log=$3
source $FLOWS_HOME/config.sh
fileSet_windows=$(cygpath --windows $fileSet)

net use $FLOW1_SHARE
if [ ! -d $flow1_share_path ] ; then
	echo "Cannot connect to share $FLOW1_HOME">>$log
	exit -1
fi

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

source file.sh
source pid.sh