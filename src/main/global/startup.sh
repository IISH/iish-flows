#!/bin/bash
#
# startup.sh
#
# Iterates over all folders and looks for the queue to start the ingest
# File structure is:
# sharename\10622\project id

hotfolders=$1
if [ -z "$hotfolders" ] ; then
    echo "hotfolders cannot be empty"
	exit -1
fi
log=$2

for hotfolder in $hotfolders
do
	for na in $hotfolder/*
	do
		for fileSet in $na/*
		do
			if [ -d $fileSet ] ; then
			    if [ -f "$fileSet/ingest.txt" ] ; then
					rm -f "$fileSet/ingest.txt"
					./run.sh $(basename $na) "$fileSet" "$log"
				fi
			fi
		done
	done
done