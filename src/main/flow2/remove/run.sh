#!/bin/bash

# Iterate over the fileSet and verify a corresponding master with identical pid and checksum over at the Sor.
# When we find a match, remove the file.
# And when all files are gone, remove the fileSet
#
# Usage: run.sh [na] [fileSet] [work directory]

source $FLOWS_HOME/setup.sh "$@"

file_instruction=$fileSet/instruction.xml
if [ ! -f "$file_instruction" ] ; then
	echo "Instruction not found: $file_instruction">>$log
	exit 0
fi

groovy remove.file.groovy "$file_instruction" >> $log
count=$(find $fileSet -type f | wc -l)
if [[ $count == 1 ]] ; then
	history="$(dirname $fileSet)/.history/$archiveID"
	mkdir -p $history
	mv $fileSet $history
fi

groovy -cp $(cygpath --windows "$HOMEPATH\.m2\repository\javax\mail\javax.mail-api\1.5.0\javax.mail-api-1.5.0.jar;$HOMEPATH\.m2\repository\javax\mail\mail\1.4.7\mail-1.4.7.jar") $global_home/mail.groovy $(cygpath --windows $report) $flow2_client "$flow2_notificationEMail" "flow2 Sor import" $mailrelay >>$log