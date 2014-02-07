#!/bin/bash
#
# Test validation for metadata
#
# Usage: ./ead.sh IISH flow home folder

flows_home=$1
if [ ! -d "$flows_home" ] ; then
    echo "flows_home folder should point to the iish-flows home directory."
    exit -1
fi

global_home=$flows_home/src/main/global

na=12345
fileSet=$flows_home/src/test/flow2manual/$na
work=$fileSet/work
if [ ! -d $work ] ; then
    mkdir $work
fi
log=$work/log.txt

cd $flows_home/src/main/flow2manual/validate
source ./run.sh