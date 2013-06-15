#!/bin/bash
#
# run.sh
#
# Iterates over all application folders and starts the startup.sh routine.

source $FLOWS_HOME/config.sh

for flow in $FLOWS_HOME/src/main/*
do
    flow_folder=$(basename $flow)
    for command_folder in $flow/*
    do
        run_script=$command_folder/run.sh
        if [ -f $run_script ] ; then
            key=$flow_folder"_hotfolders"
            hotfolders=$(eval "echo \$$key")
            for hotfolder in "$hotfolders"
            do
                for na in $hotfolder/*
                do
                    for fileSet in $na/*
                    do
                        if [ -d $fileSet ] ; then
                            command=$(basename $command_folder)
                            if [ -f "$fileSet/$command.txt" ] ; then
                                rm -f "$fileSet/$command.txt"
                                cd $command_folder
                                $run_script "$command_folder" $(basename $na) "$fileSet" "$fileSet/$(basename $fileSet).$command.$datestamp.log" &
                            fi
                        fi
                    done
                done
            done
        fi
    done
done