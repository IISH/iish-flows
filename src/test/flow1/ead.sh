#!/bin/bash
#
# Test report EAD and concordance relationship
#
# Usage: ./ead.sh IISH flow home folder

flows_home=$1
if [ ! -d "$flows_home" ] ; then
    echo "flows_home folder should point to the iish-flows home directory."
    exit -1
fi
FLOWS_HOME=$flows_home

global_home=$flows_home/src/main/global

cd $flows_home/src/main/flow1/validate
fileSet=$flows_home/src/test/flow1
work=$fileSet/work
if [ ! -d $work ] ; then
    mkdir $work
fi
log=$work/log.txt
na=12345
cf=$fileSet/cf.txt

source ./ead.sh

cd $flows_home/src/main/flow1/ingest
source ./ead.sh