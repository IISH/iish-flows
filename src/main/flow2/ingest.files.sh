#!/bin/bash
#
# ingest.files.sh
#
# Will iterate over the desired folder; take all sub folders; and for each kick start the creation of an instruction.

flow_home=$(cygpath "$FLOW2_HOME")
flow2_share=$(cygpath "$FLOW2_SHARE")

# Enable share
net use $FLOW2_SHARE

for d in $flow2_share/*
do
    for fileSet in $d/*
    do
        if [ -d $fileSet ] ; then
            if [ ! -f $fileSet/instruction.xml ] ; then
                na=$(basename $d)
                $flow_home/src/main/flow2/ftp.sh $na $fileSet
            fi
        fi
    done
done