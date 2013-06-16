#!/bin/bash
#
# run.sh
#
# Iterates over all application folders and starts the startup.sh routine.

source $FLOWS_HOME/config.sh

for flow in $flows_home/src/main/*
do
    flow_folder=$(basename $flow)
    for run_folder in $flow/*
    do
        run_script=$run_folder/run.sh
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
                            event="$fileSet/$(basename $run_folder).txt"
                            if [ -f "$event" ] ; then
								$run_script "$fileSet"
                            fi
                        fi
                    done
                done
            done
        fi
    done
done