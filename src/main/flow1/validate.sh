#!/bin/bash
#
# validate.sh
#
# Produce validation
# Add Instruction
# Prepare a mets document

na=$1
fileSet=$2
source $FLOWS_HOME/config.sh
archiveID=$(basename $fileSet)
report=$fileSet/$archiveID.report.txt
log=$fileSet/$archiveID.log
cf=$fileSet/$archiveID.concordanceValidWithPID.csv

echo $(date)>$log
echo "Start validation">>$log

echo "Validation for $archiveID\nStarted on $(date)\n\n" > $report
java -Xms512m -Xmx512m -cp $(cygpath --windows "$HOMEPATH\.m2\repository\org\objectrepository\validation\1.0\validation-1.0.jar") org.objectrepository.validation.ConcordanceMain -fileSet ${fileSet%/*} -archiveID $archiveID -na $na >> $report
mv $fileSet/concordanceValidWithPID.csv $cf
if [ ! -f $cf ] ; then
    echo "Unable to find $cf">>$log
    exit -1
fi

echo "You can savely ignore warnings about Thumbs.db" >> $report
echo $(date)>>$log
echo "Done validate.">>$log

exit $?
