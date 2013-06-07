#!/bin/bash

# ftp.sh
#
# Usage:
# ftp.sh [na] [folder name]

na=$1
fileSet=$2
source $FLOW_HOME/config.sh
fileSet_windows=$(cygpath --windows $fileSet)
folder=$(basename $fileSet)
log_files=/var/log/flow2/files.$folder.$datestamp.log
log_instruction=/var/log/flow2/instruction.$folder.$datestamp.log
log_retry=/var/log/flow2/ftp.retry.$folder.$datestamp.log
ftp_script_base=/var/log/flow2/ftp.$folder.$datestamp

if [ ! -d "$fileSet" ] ; then
	echo "No fileSet found: $fileSet"
	exit 0
fi

file_instruction=$fileSet/instruction.xml
if [ -f "$file_instruction" ] ; then
	echo "Instruction already present: $file_instruction"
	exit 0
fi


# Create the upload ftp_script and start it. Try it a couple of times:
limit=5
x=1
while [ $x -le $limit ]
do
    ftp_script="$ftp_script_base.files.script"
    echo "option batch continue">$ftp_script
    echo "option confirm off">>$ftp_script
    echo "option transfer binary">>$ftp_script
    echo "option reconnecttime 5">>$ftp_script
    echo "open $FTP_CONNECTION">>$ftp_script
    echo "synchronize remote -mirror $fileSet_windows $folder">>$ftp_script
    echo "close">>$ftp_script
    echo "exit">>$ftp_script
    WinSCP /console /script="$(cygpath --windows $ftp_script)" /parameter "$folder" /log:"$(cygpath --windows $log_files)"
    rc=$?
    if [[ $rc == 0 ]] ; then
        break
    else
        x=$(( $x + 1 ))
    fi
done

# Produce instruction
groovy $(cygpath --windows "$flow2_home/instruction.groovy") -na $na -fileSet "$fileSet_windows" -autoIngestValidInstruction false -label "$folder $flow2_client" -notificationEMail $flow2_notificationEMail
ftp_script="$ftp_script_base.instruction.script"
echo "option batch continue">$ftp_script
echo "option confirm off">>$ftp_script
echo "option transfer binary">>$ftp_script
echo "option reconnecttime 5">>$ftp_script
echo "open $FTP_CONNECTION">>$ftp_script
echo "put $fileSet_windows\instruction.xml $folder/instruction.xml">>$ftp_script
echo "close">>$ftp_script
echo "exit">>$ftp_script
WinSCP /console /script="$(cygpath --windows $ftp_script)" /parameter "$folder" /log:"$(cygpath --windows $log_instruction)"