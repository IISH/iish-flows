#!/bin/bash
#
# startup.sh
#
# Iterates over all folders and looks for a csv file to validate, create an instruction; and produce mets

source $FLOWS_HOME/config.sh

net use $FLOW1_SHARE

for flow_share in $flow1_sharenames
do
	for project in $FLOW1_SHARE/$flow_share
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
							$flow1_home/validate.sh -na $na -fileSet $fileSet
						fi
						if [ -f $fileSet/ingest.txt ] ; then
							rm -f $fileSet/ingest.txt
							$flow1_home/ingest.sh -na $na -fileSet $fileSet
						fi
						if [ -f $fileSet/checksum.txt ] ; then
							rm -f $fileSet/checksum.txt
							$flow1_home/checksum.sh -na $na -fileSet $fileSet
						fi
					fi
				done
			fi
		done
	done
done