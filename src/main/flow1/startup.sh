#!/bin/bash
#
# start.sh
#
# Iterates over all folders and looks for a csv file to validate, create an instruction; and produce mets

for project in $FLOW1_SHARE/*
do
    for d in $project/*
    do
        if [ -d $d ] ; then
            na=$(basename $d)
            for fileSet in $d/*
            do
                if [ -d $fileSet ] ; then
                    if [ -f $fileSet/validate.txt ] || [ -f $fileSet/valideer.txt ] ; then
                        rm -f $fileSet/vali*
                        $flow2_home/validate.sh -na $na -fileSet $fileSet
                    fi
                    if [ -f $fileSet/ingest.txt ] ; then
                        rm -f $fileSet/ingest.txt
                        $flow2_home/ingest.sh -na $na -fileSet $fileSet
                    fi
                    if [ -f $fileSet/checksum.txt ] ; then
                        rm -f $fileSet/checksum.txt
                        $flow2_home/checksum.sh -na $na -fileSet $fileSet
                    fi
                fi
            done
        fi
    done
done