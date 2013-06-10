#!/bin/bash

# Iterate over the fileSet and verify a corresponding master with identical pid and checksum over at the Sor.
# When we find a match, remove the file.
# And when all files are gone, remove the fileSet
#
# Usage: remove.file.sh [fileSet]

na=$1
fileSet=$2
source $FLOWS_HOME/config.sh
fileSet_windows=$(cygpath --windows $fileSet)
folder=$(basename $fileSet)
log_removes=$flows_log/flow2/removes.$folder.$datestamp.log

if [ ! -d "$fileSet" ] ; then
	echo "No fileSet found: $fileSet">$log_removes
	exit 0
fi

file_instruction=$fileSet/instruction.xml
if [ ! -f "$file_instruction" ] ; then
	echo "Instruction not found: $file_instruction">$log_removes
	exit 0
fi

report=$flows_log/flow2/remove.file.$folder.$datestamp.log
groovy $flow2_home/remove.file.groovy "$file_instruction" > $report
count=$(find $fileSet -type c | wc -l)
if [[ $count == 1 ]] ; then
	history=$flow2_share_path/.history/$fileSet
	mkdir -p $history
	mv $fileSet $history
fi

groovy -cp $(cygpath --windows "$HOMEPATH\.m2\repository\javax\mail\javax.mail-api\1.5.0\javax.mail-api-1.5.0.jar;$HOMEPATH\.m2\repository\javax\mail\mail\1.4.7\mail-1.4.7.jar") $global_home/mail.groovy $(cygpath --windows $report) $flow2_client "$flow2_notificationEMail" "flow2 Sor import" $mailrelay