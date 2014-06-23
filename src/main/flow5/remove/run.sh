#!/bin/bash
#
# run.sh
# Verify if the access status was set accordingly.
#
# Usage:
# run.sh [na] [folder name]

source $FLOWS_HOME/src/main/global/setup.sh $0 "$@"

report=$work/report.txt
file_access_exist=$fileset/.ingest/access_exist.txt
if [ ! -f $file_access_exist ] ; then
    echo "Nothing to do." >> $report
fi

while read line
do
    if [[ "$line" == \#* ]] ; then
        echo $line
    else
        IFS=, read id access pid <<< $line
        currentStatus=$(groovy currentOrStatus.groovy "${or}/metadata/${pid}?accept=text/xml&format=xml")
        if [ "$currentStatus" == "$access" ] ; then
            echo "Success: ${line}" >> $report
        else
            echo "Failed: ${line}" >> $report
        fi
    fi
done < $file_access

groovy -cp "$(cygpath --windows "$HOMEPATH\.m2\repository\javax\mail\javax.mail-api\1.5.0\javax.mail-api-1.5.0.jar");$(cygpath --windows "$HOMEPATH\.m2\repository\javax\mail\mail\1.4.7\mail-1.4.7.jar")" $(cygpath --windows "$global_home/mail.groovy") $(cygpath --windows "$report") $flow_client "$flow_notificationEMail" "Dagelijkste Sor access status updates." $mailrelay >> $log

history="$(dirname $fileSet)/.history"
mkdir -p $history
mv $fileSet $history

