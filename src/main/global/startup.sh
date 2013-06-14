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
        if [ -d $command_folder ] ; then
            run_script=$command_folder/run.sh
            if [ -f $run_script ] ; then
                hotfolders=""
                for hotfolder in $hotfolders
                do
                    for na in $hotfolder/*
                    do
                        for fileSet in $na/*
                        do
                            if [ -d $fileSet ] ; then
                                for command in "checksum validate ingest remove"
                                do
                                    if [ -f "$fileSet/$command.txt" ] ; then
                                        rm -f "$fileSet/$command.txt"
                                        cd $command_folder
                                        ./run.sh $(basename $na) "$fileSet" "$log"
                                    fi
                                done
                            fi
                        done
                    done
                done
            fi
        fi
    done
done