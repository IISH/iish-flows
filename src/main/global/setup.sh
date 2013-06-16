#!/bin/bash

fileSet=$2
na=$(basename $fileSet)
event=$(basename $1)
work=$fileSet/.$event
mkdir -p $work
rm -f "$fileSet/$event"

$FLOWS_HOME/config.sh

archiveID=$(basename $fileSet)
fileSet_windows=$(cygpath --windows $fileSet)
log=$work/$datestamp.log
echo $(date)>$log

if [[ ! -d "$fileSet" ]] ; then
    echo "Cannot find fileSet $fileSet">$log
    echo "Does the folder or share exist ?"
    exit -1
fi