#!/bin/bash
#
# Test validation for metadata
#
# Usage: ./run.sh [IISH flow home folder]

flows_home=$1
flow=flow5

if [ ! -d "$flows_home" ] ; then
    echo "flows_home folder should point to the iish-flows home directory."
    exit -1
fi
FLOWS_HOME=$flows_home

global_home=$flows_home/src/main/global
if [ ! -d "$global_home" ] ; then
    echo "global_home folder should point to: $global_home"
    exit -1
fi

test_folder=$flows_home/src/main/$flow/ingest
if [ ! -d "$test_folder" ] ; then
    echo "test_folder folder should point to: $test_folder"
    exit -1
fi

na=12345
runFrom=$flows_home/src/test/$flow
fileSet=$runFrom/$na
work=$fileSet/work
if [ ! -d $work ] ; then
    mkdir -p $work
fi
log=$work/log.txt

cd $flows_home/src/main/$flow/ingest
source ./run.sh $runFrom $fileSet $flow