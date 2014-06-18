#!/bin/bash

# run.sh
#
# Usage:
# run.sh [na] [folder name]

source $FLOWS_HOME/src/main/global/setup.sh $0 "$@"
ftp_script_base=$work/ftp.$archiveID.$datestamp

file_instruction=$fileSet/instruction.xml
if [ -f "$file_instruction" ] ; then
	echo "Instruction already present: $file_instruction">>$log
	exit 0
fi

# Harvest and create a list of updates. We use the folder name as datestamp for the -from parameter.
from=$(basename $fileSet)
file_access=$work/access.txt
groovy oai2harvester.groovy -na $na -baseURL $oai -verb ListRecords -from $from -metadataPrefix marcxml > $file_access

# Filter out from access.txt a new file access_exist. It will conly contain references if the pid values exist in the
# object repository and the access status differs.
count=0
file_access_exist=$work/access_exist.txt
rm $file_access_exist
while read line
do
    if [[ "$line" == \#* ]] ; then
        echo $line
    else
        IFS=, read id access pid <<< $line
        currentStatus=$(groovy currentStatus.groovy "${or}/metadata/${pid}?accept=text/xml&format=xml")
        if [ "$currentStatus" == "$access" ] ; then
            echo "Not updating ${line} because the access values are identical: ${access}=${currentStatus}" >> $log
        else
            case "$currentStatus" in
                open)
                    echo $line >> $file_access_exist
                    count=$((count + 1))
                    ;;
                restricted)
                    echo $line >> $file_access_exist
                    count=$((count + 1))
                    ;;
                closed)
                    echo $line >> $file_access_exist
                    count=$((count + 1))
                    ;;
                minimal)
                    echo $line >> $file_access_exist
                    count=$((count + 1))
                    ;;
                *)
                    echo "Not updating ${line} because of an unknown status: ${currentStatus}" >> $log
                    ;;
            esac
        fi
    fi
done < $file_access

if [[ $count == 0 ]] ; then
    echo "Nothing to upload as the count was zero." >> $log
    exit 0
fi

# create instruction header:
echo "<instruction xmlns='http://objectrepository.org/instruction/1.0/' access='$flow_access' autoIngestValidInstruction='$flow_autoIngestValidInstruction' label='$archiveID $flow_client' action='upsert' notificationEMail='$flow_notificationEMail' plan='StagingfileIngestMaster'>" > $file_instruction
while read line
do
    IFS=, read id access pid <<< $line
    echo "<stagingfile><pid>${pid}</pid><access>${access}</access><embargo>-1</embargo><embargoAccess>-1</embargoAccess><contentType>-1</contentType><objid>-1</objid><seq>-1</seq><label>-1</label></stagingfile>" >> $file_instruction
done < $file_access_exist
echo "</instruction>" >> $file_instruction

ftp_script=$ftp_script_base.instruction.txt
$global_home/ftp.sh "$ftp_script" "put $fileSet_windows\instruction.xml $archiveID/instruction.xml" "$log"
rc=$?
if [[ $rc != 0 ]] ; then
    exit -1
fi

exit 0
