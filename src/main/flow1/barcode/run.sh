#!/bin/bash
#
# /barcode/run.sh
#
# Fixes missing masters
#
# Usage: run.sh [na] [fileSet] [work directory]

source $FLOWS_HOME/src/main/global/setup.sh $0 "$@"

echo "Check concordance for missing masters" >> $log
python concordance_missing_masters.py --fileset "${fileSet}" --concordance "${fileSet}/$archiveID.bad.csv" --new "${fileSet}/$archiveID.good.csv"
rc=$?
if [[ $rc != 0 ]] ; then
	echo "Problem with creating new masters." >> $log
    exit -1
fi

echo $(date) >> $log
echo "Fixed missing masters." >> $log