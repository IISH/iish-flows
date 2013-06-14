#!/bin/bash
#
# StagingFileIngestConcordance/file.sh
#
# Produce validation
# Add Instruction
#

find $fileSet -type f -name "Thumbs.db" -exec rm -f {} \;
find $fileSet -type f -name "Thumbs.db.md5" -exec rm -f {} \;

echo "Upload files...">>$log
mv $fileSet/Jpeg $fileSet/.level1
mv $fileSet/jpeg $fileSet/.level1
mv $fileSet/tiff $fileSet/Tiff

# Upload the files
$global_home/ftp.sh "$ftp_script" "synchronize remote -mirror $fileSet_windows $archiveID" "$log_files"
rc=$?
mv $fileSet/.level1 $fileSet/Jpeg
if [[ $rc != 0 ]] ; then
    break
fi

echo "Create instruction for our files">>$log
php csv.php -f $(cygpath --windows $cf) -n $na -h "access='restricted' contentType='image/tiff' autoIngestValidInstruction='false'"
if [ ! -f $fileSet/instruction.xml ] ; then
    echo "Instruction not found.">>$log
    exit -1
fi

echo "Upload remaining instruction...">>$log
$global_home/ftp.sh "$ftp_script" "put $fileSet_windows\instruction.xml $archiveID/instruction.xml" "$log_files"
rc=$?
mv $fileSet/.level1 $fileSet/Jpeg
rm $ftp_script
if [[ $rc != 0 ]] ; then
    break
fi

echo $(date)>>$log
echo "Done files update.">>$log

rm $fileSet/instruction.xml