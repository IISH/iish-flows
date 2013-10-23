#!/bin/bash
#
# /ingest/ead.sh
#
# Sees if all items in the concordance table are present in the EAD document.
#
# Usage: eadValidate.sh

eadFile=$fileSet/$na.xml
if [ ! -f $eadFile ] ; then
    echo "Unable to find the EAD document at $eadFile">>$log
	echo "The validation was interrupted.">>$log
	exit -1
fi

archiveIDs=$work/archiveIDs.xml
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?><list>" > $archiveIDs

while read line
do
    while IFS=, read objnr ID master jpeg volgnr PID; do
        if [[ $volgnr == 1 ]] ; then
            echo "<item>$ID</item>" >> $archiveIDs
        fi
    done
done < $cf

echo "</list>" >> $archiveIDs

eadReport=$work/ead.report.html
groovy $global_home/ead.groovy "$eadFile" "$archiveIDs" $eadReport >> $log
if [ -f $eadReport ] ; then
    $log >> "See the EAD validation for inventarisnummer and unitid matches at"
    $log >> $eadReport
else
    $log >> "Unable to validate $eadFile"
fi