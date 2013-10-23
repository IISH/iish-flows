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
	echo "The ingest was interrupted.">>$log
	exit -1
fi

archiveIDs=$work/archiveIDs.xml
if [ ! -f $archiveIDs ] ; then
    echo "Unable to find the archiveIDs file at $archiveIDs">>$log
	echo "The ingest was interrupted.">>$log
	exit -1
fi

groovy $global_home/ead.groovy "$archiveID" "$archiveIDs" $eadReport >> $log
if [ -f $eadReport ] ; then
    $log >> "See the EAD validation for inventarisnummer and unitid matches at"
    $log >> $eadReport
else
    $log >> "Unable to validate $eadFile"
fi