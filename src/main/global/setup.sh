#!/bin/bash

source $FLOWS_HOME/config.sh

fileSet=$2
na=$(dirname $fileSet)		# Gets the parent folder
na=$(basename $na)			# Now proceeds to the naming authority
event=$(dirname $1)			# Gets the parent folder of the application script
cd "$event"					# Make it the current directory
event=$(basename $event)	# Now proceeds to the actual command
work=$fileSet/.$event		# The Working directory for logging and reports
mkdir -p $work
rm -f "$fileSet/$event.txt"

archiveID=$(basename $fileSet)
fileSet_windows=$(cygpath --windows $fileSet)
log=$work/$datestamp.log
echo "date: $(date)">$log
echo "na: $na">>$log
echo "fileSet: $fileSet">>$log
echo "event: $event">>$log
echo "work: $work">>$log


if [[ ! -d "$fileSet" ]] ; then
    echo "Cannot find fileSet $fileSet">>$log
    echo "Does the folder or share exist ?">>$log
    exit -1
fi