#!/bin/bash

# ftp.sh
#
# Usage:
# ftp.sh [na] [folder name]

na=$1
fileSet=$2
source $FLOWS_HOME/config.sh
fileSet_windows=$(cygpath --windows $fileSet)
folder=$(basename $fileSet)
log_files=$flows_log/flow2/files.$folder.$datestamp.log
log_instruction=$flows_log/flow2/instruction.$folder.$datestamp.log
log_retry=$flows_log/flow2/ftp.retry.$folder.$datestamp.log
ftp_script_base=$flows_log/flow2/ftp.$folder.$datestamp

if [ ! -d "$fileSet" ] ; then
	echo "No fileSet found: $fileSet"
	exit 0
fi

file_instruction=$fileSet/instruction.xml
if [ -f "$file_instruction" ] ; then
	echo "Instruction already present: $file_instruction"
	exit 0
fi


# Upload the files
$global_home/ftp.sh "$ftp_script" "synchronize remote -mirror $fileSet_windows $folder" "$log_files"
rc=$?
if [[ $rc != 0 ]] ; then
    break
fi

# Produce instruction and upload the filee
groovy $(cygpath --windows "$flow2_home/instruction.groovy") -na $na -fileSet "$fileSet_windows" -autoIngestValidInstruction false -label "$folder $flow2_client" -notificationEMail $flow2_notificationEMail
$global_home/ftp.sh "$ftp_script" "put $fileSet_windows\instruction.xml $folder/instruction.xml" "$log_files"
rc=$?
if [[ $rc != 0 ]] ; then
    break
fi