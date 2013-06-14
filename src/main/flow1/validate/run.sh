#!/bin/bash
#
# startup.sh
#
# Produce validation
# Add Instruction
# Prepare a mets document

na=$1
fileSet=$2
log=$3
source $FLOWS_HOME/config.sh
archiveID=$(basename $fileSet)
report=$fileSet/$archiveID.report.txt
cf=$fileSet/$archiveID.concordanceValidWithPID.csv

net use $FLOW1_SHARE
if [ ! -d $flow1_share_path ] ; then
	echo "Cannot connect to share $FLOW1_HOME">>$log
	exit -1
fi

echo $(date)>$log
echo "Start validation">>$log

echo "Validation for $archiveID\nStarted on $(date)\n\n" > $report
java -Xms512m -Xmx512m -cp $(cygpath --windows "$HOMEPATH\.m2\repository\org\objectrepository\validation\1.0\validation-1.0.jar") org.objectrepository.validation.ConcordanceMain -fileSet ${fileSet%/*} -archiveID $archiveID -na $na >> $report
mv $fileSet/concordanceValidWithPID.csv $cf
if [ ! -f $cf ] ; then
    echo "Unable to find $cf">>$log
	echo "The validation was interrupted."
fi

echo "You can savely ignore warnings about Thumbs.db" >> $report
echo $(date)>>$log
echo "Done validate.">>$log

body="/tmp/report.txt"
echo "Rapportage op $report">$body
groovy -cp $(cygpath --windows "$HOMEPATH\.m2\repository\javax\mail\javax.mail-api\1.5.0\javax.mail-api-1.5.0.jar;$HOMEPATH\.m2\repository\javax\mail\mail\1.4.7\mail-1.4.7.jar") $global_home/mail.groovy $(cygpath --windows $body) $flow1_client "$flow1_notificationEMail" "flow1 validation" $mailrelay >>$log
rm $body

exit $?