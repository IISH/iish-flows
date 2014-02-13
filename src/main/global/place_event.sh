#!/bin/bash
#
# place_event.sh
#
# useage: place_event [event]
#
# Iterates over all application folders and starts the startup.sh routine.

source $FLOWS_HOME/config.sh
flow=$1
event=$2

if [ -z "$flow" ] ; then
	echo "No flow given"
	exit -1
fi
if [ -z "$event" ] ; then
	echo "No event given"
	exit -1
fi

key=$flow"_hotfolders"
hotfolders=$(eval "echo \$$key")

for hotfolder in $hotfolders
do
	if [ ! -d "$hotfolder" ] ; then
		key=$flow"_share"
		share=$(eval "echo \$$key")
		net use $share
	fi

    for na in $hotfolder/*
    do
        for fileSet in $na/*
        do
			if [ -d $fileSet ] ; then
				echo $(date)>$fileSet/$event
			fi
		done
	done
done

exit 0