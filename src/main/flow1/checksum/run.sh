#!/bin/bash

na=$1
fileSet=$2
work=$3
source $FLOWS_HOME/config.sh
archiveID=$(basename $fileSet)
fileSet_windows=$(cygpath --windows $fileSet)
log=$work/$datestamp.log
report=$fileSet/$archiveID.report.checksum.txt

# Remove DOS \r
file=$fileSet/checksum.md5
if [ ! -f $file ] ; then
    echo "File not found: $file">$report
    echo "No checksum file found at $file">$log
    exit -1
fi

backup=$fileSet/.checksum.md5
if [ ! -f $backup ] ; then
    cp $file $backup
fi
tr -d '\r' < $file > /tmp/$archiveID
mv /tmp/$archiveID $file
md5sum --check $file > $report