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

ead=$work/ead.with.daoloc.xml
groovy $global_home/ead.groovy "$eadFile" "$archiveIDs" $ead >> $log
if [ -f $ead ] ; then
    $log >> "See the EAD with added daoloc elements at"
    $log >> $ead
else
    $log >> "Unable to add daoloc elements to $ead"
fi