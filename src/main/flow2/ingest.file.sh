#!/bin/bash

# ftp.sh
#
# Usage:
# ftp.sh [na] [folder name]

na=$1
fileSet=$2
log=$3
source $FLOWS_HOME/config.sh
fileSet_windows=$(cygpath --windows $fileSet)
folder=$(basename $fileSet)
ftp_script_base=$flows_log/flow2/ftp.$folder.$datestamp

if [ ! -d "$fileSet" ] ; then
	echo "No fileSet found: $fileSet">>$log
	exit 0
fi

file_instruction=$fileSet/instruction.xml
if [ -f "$file_instruction" ] ; then
	echo "Instruction already present: $file_instruction">>$log
	exit 0
fi


# Upload the files
ftp_script=$ftp_script_base.files.txt
$global_home/ftp.sh "$ftp_script" "synchronize remote -mirror $fileSet_windows $folder" "$log"
rc=$?
if [[ $rc != 0 ]] ; then
    exit -1
fi

# Produce instruction and upload the filee
groovy $(cygpath --windows "$flow2_home/instruction.groovy") -na $na -fileSet "$fileSet_windows" -autoIngestValidInstruction true -label "$folder $flow2_client" -notificationEMail $flow2_notificationEMail>>$log
ftp_script=$ftp_script_base.instruction.txt
$global_home/ftp.sh "$ftp_script" "put $fileSet_windows\instruction.xml $folder/instruction.xml" "$log"
rc=$?
if [[ $rc != 0 ]] ; then
    exit -1
fi

exit 0