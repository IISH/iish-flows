#!/bin/bash
#
# flow5/create.sh
#
#
# Create a folder with the given datestamp and an ingest command.

# We must be in a system folder

source $FLOWS_HOME/src/main/global/setup.sh $0

if [ -z "$datestamp" ] ; then
    echo "No datestamp was set." >> $log
    exit -1
fi

# Remember we are in a fileset: .../create_flow5_commands/
# We need to step back to the parent and set /datestamp/
fileSet=$fs_parent/$datestamp
instruction=$fileSet/instruction.xml
if [ -f $instruction ] ; then
    echo "Instruction already created: ${instruction}" >> $log
    exit -1
fi

mkdir $fileSet
touch $fileSet/ingest.txt

exit 0