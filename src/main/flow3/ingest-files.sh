#!/bin/bash
#
# ingest.files.sh
#
# Will iterate over the desired folder; take all sub folders; and for each kick start the creation of an instruction.

source $FLOWS_HOME/config.sh
log=$flows_log/flow3/ingest.files.$datestamp.log

# Enable share
net use $FLOW3_SHARE
if [ ! -d $flow3_share_path ] ; then
	echo "Cannot connect to share $FLOW3_HOME" >>$log
	exit -1
fi

for d in $flow3_share_path/*
do
    for fileSet in $d/*
    do
    	na=$(basename $d)
    	$FLOWS_HOME/src/main/flow3/ingest.file.sh $na $fileSet $log
    done
done


exit 0
