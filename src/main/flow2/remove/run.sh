#!/bin/bash

# Iterate over the fileSet and verify a corresponding master with identical pid and checksum over at the Sor.
# When we find a match, remove the file.
# And when all files are gone, remove the fileSet
#
# Usage: run.sh [na] [fileSet] [work directory]

source $FLOWS_HOME/src/main/global/setup.sh $0 "$@"

file_instruction=$fileSet/instruction.xml
if [ ! -f "$file_instruction" ] ; then
	echo "Instruction not found: $file_instruction">>$log
	exit 0
fi

report="$log.report"
groovy remove.file.groovy "$file_instruction" > $report
if [ -z "$notificationEMail" ] ; then
	notificationEMail=$flow2_notificationEMail
fi
groovy -cp "$(cygpath --windows "$HOMEPATH\.m2\repository\javax\mail\javax.mail-api\1.5.0\javax.mail-api-1.5.0.jar");$(cygpath --windows "$HOMEPATH\.m2\repository\javax\mail\mail\1.4.7\mail-1.4.7.jar")" $(cygpath --windows "$global_home/mail.groovy") $(cygpath --windows "$report") $flow2_client "$notificationEMail" "Dagelijkste Sor import van de scans" $mailrelay >> $log

count=$(find $fileSet -type f \( ! -regex ".*/\..*/..*" \) | wc -l)
if [[ $count == 1 ]] ; then
	history="$(dirname $fileSet)/.history"
	mkdir -p $history
	mv $fileSet $history
fi