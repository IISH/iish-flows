#!/bin/bash

# run.sh
#
# Collects all folders under the fileSet.
# For each folder creates a manifest and UDF image
#
# Example:
# /a/b/BULK23456/1/files and folders
# /a/b/BULK23456/2/files and folders
#
# Will produce:
# /a/b/BULK23456/.level1/BULK23456.1.csv
# /a/b/BULK23456/BULK23456.1.iso
# /a/b/BULK23456/.level1/BULK23456.2.csv
# /a/b/BULK23456/BULK23456.2.iso
# /a/b/BULK23456/instruction.xml
#
# Usage:
# file.sh [na] [folder name] [log]

source $FLOWS_HOME/setup.sh "$@"

GiB=$(echo "(2^30)" | bc)
BlockLimit=128
ftp_script_base=$work/ftp.$archiveID.$datestamp

ok=true
for d in $fileSet/*
do
    size=$(du $d -s | cut -d '/' -f 1)
    blocks=$(echo "$size / $GiB" | bc)
    if [[ $blocks -gt $BlockLimit ]] ; then
        echo "The folder $d with size $size is larger then the allowed size of $GiB x $BlockLimit">>$log
    fi
    ok=false
done
if [ $ok == false ] ; then
    exit -1
fi

# Start a droid analysis
p=$(pwd)
cd $(cygpath $DROID_HOME)
for d in $fileSet/*
do
    if [ -d $d ] ; then
		mkdir -p "$fileSet/.level1"
		subfolder=$(basename $d)
        profile=$(cygpath --windows "$d/profile.droid")
        manifest="$fileSet/.level1/$archiveID.$subfolder.csv"
        droid.bat -q -p "$profile" -a $(cygpath --windows "$d") -R>>$log
        droid.bat -q -p "$profile" -e "$(cygpath --windows "$manifest")">>$log
        cd "$pwd"
		groovy removePath.groovy "$manifest" $(cygpath --windows "$d")
		cp $manifest $d/
		rm "$d/profile.droid"
    fi
done

# Create the UDF 1.02 images
for d in $fileSet/*
do
    if [ -d $d ] ; then
        subfolder=$(basename $d)
		source=$(cygpath --windows "$d")
		target=$(cygpath --windows "$fileSet/$archiveID.$subfolder.iso")
        # See Oscdimg Command-Line Options at technet.microsoft.com/en-us/library/cc749036(v=ws.10).aspx
		oscdimg.exe -udfver102 -u2 -uf -l$archiveID.$subfolder -h -w4 $source $target>>$log
        rc=$?
        if [[ $rc != 0 ]] ; then
            echo "There were errors when creating the image for $d">>$log
            exit -1
        fi
    fi
done

# Upload the files
ftp_script=$ftp_script_base.files.txt
$global_home/ftp.sh "$ftp_script" "synchronize remote -mirror -filemask=\"|*/\;archiveID.*\" $fileSet_windows $archiveID" "$log"
$global_home/ftp.sh "$ftp_script" "synchronize remote -mirror -filemask=\"|*/\" $fileSet_windows\\.level1 $archiveID/.level1" "$log"
$global_home/ftp.sh "$ftp_script" "synchronize remote -mirror -filemask=\"|*/\" $fileSet_windows\\.level2 $archiveID/.level2" "$log"
$global_home/ftp.sh "$ftp_script" "synchronize remote -mirror -filemask=\"|*/\" $fileSet_windows\\.level3 $archiveID/.level3" "$log"
rc=$?
if [[ $rc != 0 ]] ; then
    exit -1
fi

# Produce instruction and upload it
groovy $(cygpath --windows "$global_home/instruction.groovy") -na $na -fileSet "$fileSet_windows" -autoIngestValidInstruction false -label "$datestamp UDF image $archiveID.$subfolder $flow3_client" -notificationEMail $flow3_notificationEMail>>$log
ftp_script=$ftp_script_base.instruction.txt
$global_home/ftp.sh "$ftp_script" "put $fileSet_windows\instruction.xml $archiveID/instruction.xml" "$log"
rc=$?
if [[ $rc != 0 ]] ; then
    exit -1
fi

exit 0