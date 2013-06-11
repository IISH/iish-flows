#!/bin/bash
#
# remove.files.sh
#
# Will iterate over the desired folder; take all sub folders; and for each kick start the remove file procedure.

source $FLOWS_HOME/config.sh
log=$flows_log/flow2/remove.files.$datestamp.log

# Enable share
net use $FLOW2_SHARE
if [ ! -d $flow2_share_path ] ; then
	echo "Cannot connect to share $FLOW2_HOME">>$log
	exit -1
fi

for d in $flow2_share_path/*
do
    for fileSet in $d/*
    do
    	na=$(basename $d)
    	$FLOWS_HOME/src/main/flow2/remove.file.sh $na $fileSet $log
    done
done


exit 0
