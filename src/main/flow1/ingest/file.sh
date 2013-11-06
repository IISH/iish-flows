#!/bin/bash
#
# /ingest/file.sh
#
# Upload files
# Add Instruction
#

find $fileSet -type f -name "Thumbs.db" -exec rm -f {} \;
find $fileSet -type f -name "Thumbs.db.md5" -exec rm -f {} \;

echo "Upload files...">>$log

if [[ ! -d $fileSet/Tiff ]] ; then
	echo "Expecting the folder $fileSet/Tiff"
	echo "Stopping procedure."
	exit -1
fi 

# Upload the files
ftp_script=$work/$archiveID.txt
$global_home/ftp.sh "$ftp_script" "synchronize remote -mirror -criteria=size $fileSet_windows\Tiff $archiveID/Tiff" "$log"
rc=$?
if [[ $rc != 0 ]] ; then
    exit -1
fi

# Upload the derivatives
$global_home/ftp.sh "$ftp_script" "synchronize remote -mirror -criteria=size $fileSet_windows\jpeg $archiveID/.level1" "$log"
$global_home/ftp.sh "$ftp_script" "synchronize remote -mirror -criteria=size $fileSet_windows\.level2 $archiveID/.level2" "$log"
$global_home/ftp.sh "$ftp_script" "synchronize remote -mirror -criteria=size $fileSet_windows\.level3 $archiveID/.level3" "$log"
$global_home/ftp.sh "$ftp_script" "synchronize remote -mirror -criteria=size $fileSet_windows\.level4 $archiveID/.level4" "$log"
rc=$?
if [[ $rc != 0 ]] ; then
    exit -1
fi

echo "Create instruction for our files">>$log
groovy $(cygpath --windows "$global_home/instruction.csv.groovy") -fileSet $(cygpath --windows "$fileSet") -csv $(cygpath --windows "$cf") -label "$archiveID $flow1_client" -access restricted -contentType image/tiff -autoIngestValidInstruction false -notificationEMail $flow1_notificationEMail  -plan "StagingfileIngestLevel3,StagingfileIngestLevel2,StagingfileIngestLevel1,StagingfileBindPIDs,StagingfileIngestMaster">>$log
rc=$?
if [[ $rc != 0 ]] ; then
	echo "Problem when creating the instruction.">>$log
    exit -1
fi
if [ ! -f $fileSet/instruction.xml ] ; then
    echo "Instruction not found.">>$log
    exit -1
fi

echo "Upload remaining instruction...">>$log
$global_home/ftp.sh "$ftp_script" "put $fileSet_windows\instruction.xml $archiveID/instruction.xml" "$log"
rc=$?
mv $fileSet/.level1 $fileSet/Jpeg
rm $ftp_script
if [[ $rc != 0 ]] ; then
    exit -1
fi

echo $(date)>>$log
echo "Done files update.">>$log