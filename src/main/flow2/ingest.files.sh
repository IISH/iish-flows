#!/bin/bash
#
# ingest.files.sh
#
# Will iterate over the desired folder; take all subfolders; and for each kickstart the creation of an instruction.

net use %SHARE_FLOW2%

for d in $SHARE_FLOW2/*
do
    for fileSet in $d/*
    do
        if [ -d $fileSet ] ; then
            if [ ! -f $fileSet/instruction.xml ] ; then
                na=$(basename $d)
                $SORIMPORT_HOME/src/main/flow2/ftp.sh $na $fileSet
            fi
        fi
    done
done