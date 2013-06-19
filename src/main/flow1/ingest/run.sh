#!/bin/bash
#
# /ingest/run.sh
#
# Starts the ingest and objid pid bindings
#
# Usage: run.sh [na] [fileSet] [work directory]

source $FLOWS_HOME/src/main/global/setup.sh $0 "$@"

echo "Start preparing ingest...">>$log
cf=$fileSet/.validate/concordanceValidWithPID.csv
if [ ! -f $cf ] ; then
    echo "Error... did not find $cf">>$log
    echo "Is the dataset validated ?">>$log
    exit -1
fi

source ./file.sh
source ./pid.sh
