#!/bin/bash
#
# remove.files.sh
#
# Will iterate over the desired folder; take all sub folders; and for each kick start the remove file procedure.

source $FLOWS_HOME/config.sh

# Enable share
net use $FLOW2_SHARE

for d in $flow2_share_path/*
do
    for fileSet in $d/*
    do
    	na=$(basename $d)
    	$FLOWS_HOME/src/main/flow2/remove.file.sh $na $fileSet
    done
done


exit 0
