#!/bin/bash
#
# flow5/create.sh
#
#
# Create a folder with the given datestamp and an ingest command.

# We must be in a system folder

source $FLOWS_HOME/src/main/global/setup.sh $0 "$@"

if [ -z "$datestamp" ] ; then
    echo "No datestamp was set." >> $log
    exit -1
fi

# We will not make fileSets whilst others are still running.
# That is, there should only be:
# one folder and a slot is available
# two folders and the slot is in use. We skip the procedure.
count=$(ls $fs_parent | wc -l)
if [[ $count == 0 ]] ; then
	echo "There is no System folder." >> $log
	mkdir $fs_parent/DO_NOT_REMOVE_THIS_FOLDER
	touch $fs_parent/DO_NOT_REMOVE_THIS_FOLDER/system
fi

if [[ $count == 1 ]] ; then
	# Remember we are in a fileset: .../create_flow5_commands/
	# We need to step back to the parent and set /datestamp/
	fileSet=$fs_parent/$datestamp
	instruction=$fileSet/instruction.xml
	if [ -f $instruction ] ; then
		echo "Instruction already created: ${instruction}" >> $log
		exit -1
	fi

	echo "Creating ${fileSet}" >> $log
	mkdir $fileSet
	touch $fileSet/ingest.txt

	exit 0
fi

echo "Slot in use." >> $log
exit 1