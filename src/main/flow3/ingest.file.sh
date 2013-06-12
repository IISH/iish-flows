#!/bin/bash

# ingest.files.sh
#
# Collects all folders under the fileSet.
# For each folder creates a manifest and UDF image
#
# Example:
# /a/b/BULK23456/1/files and folders
# /a/b/BULK23456/2/files and folders
#
# Will produce:
# /a/b/BULK23456/1/manifest.csv
# /a/b/BULK23456/1/manifest.html
# /a/b/BULK23456/BULK23456.1.iso
# /a/b/BULK23456/2/manifest.csv
# /a/b/BULK23456/2/manifest.html
# /a/b/BULK23456/BULK23456.2.iso
#
# Usage:
# ingest.files.sh [na] [folder name] [log]

na=$1
fileSet=$2
log=$3
source $FLOWS_HOME/config.sh
fileSet_windows=$(cygpath --windows $fileSet)
folder=$(basename $fileSet)
ftp_script_base=$flows_log/flow3/ftp.$folder.$datestamp
GiB=$(echo "(2^30)" | bc)
BlockLimit=128

if [ ! -d "$fileSet" ] ; then
	echo "No fileSet found: $fileSet">>$log
	exit 0
fi

ok=true
for d in $fileSet/*
do
    size=$(du $(cygpath "C:\Windows") -s | cut -d '/' -f 1)
    blocks=$(echo "$size / $GiB" | bc)
    if [[ $blocks -gt $BlockLimit ]] ; then
        echo "The folder $d is larger then the allowed size of $GiB x $BlockLimit"
    fi
    ok=false
done
if [ ok == false ] ; then
    exit -1
fi

# Start a droid analysis
cd $(cygpath $DROID_HOME)
for d in $fileSet/*
do
    if [ -d $d ] ; then
        profile=$(cygpath --windows "$d/profile.droid")
        droid.bat -p "$profile" -a $(cygpath --windows "$d") -R >> $log
        droid.bat -p "$profile" -e $(cygpath --windows "$d/manifest.csv") >> $log
        droid.bat -p "$profile" -e $(cygpath --windows "$d/manifest.html") >> $log
        rm $(cygpath "$profile")
    fi
done

# Create the UDF 1.02 images
for d in $fileSet/*
do
    if [ -d $d ] ; then
        subfolder=$(basename $d)
        groovy -cp $(cygpath --windows "$HOMEPATH\.m2\repository\com\github\stephenc\java-iso-tools\sabre\2.0.1-SNAPSHOT\sabre-2.0.1-SNAPSHOT.jar") BuildUDFImage.groovy $d $fileSet/$folder.$subfolder.iso >> $log
        rc=$?
        if [[$rc != 0 ]] ; then
            echo "There were errors when creating the image for $d"
            exit -1
        fi
    fi
done

# Upload the files
ftp_script=$ftp_script_base.files.txt
fileSet_windows
$global_home/ftp.sh "$ftp_script" "synchronize remote -mirror $fileSet_windows $folder" "$log"
rc=$?
if [[ $rc != 0 ]] ; then
    exit -1
fi

# Produce instruction and upload the filee
groovy $(cygpath --windows "$global_home/instruction.groovy") -na $na -fileSet "$fileSet_windows" -autoIngestValidInstruction true -label "$folder $flow3_client" -notificationEMail $flow3_notificationEMail>>$log
ftp_script=$ftp_script_base.instruction.txt
$global_home/ftp.sh "$ftp_script" "put $fileSet_windows\instruction.xml $folder/instruction.xml" "$log"
rc=$?
if [[ $rc != 0 ]] ; then
    exit -1
fi

exit 0