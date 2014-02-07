#!/bin/bash
#
# validate.sh
#
# See if the identifiers are declared in our metadata catalog.
#

source $FLOWS_HOME/src/main/global/setup.sh $0 "$@"

groovy $(cygpath --windows "$global_home/validate.sru.groovy") -work $(cygpath --windows "$work") -na $na -fileSet "$fileSet_windows" -sruServer "$sru" -recurse true>>$log
rc=$?
if [[ $rc != 0 ]] ; then
    echo "There were errors during the validation routine." >> $log
    exit -1
fi

# Stop if we find problems
validate_file="$work/validation.txt"
if [ -f $validate ] ; then
    count=$(grep -c mislukt $validate)
    if [[ $count != 0 ]] ; then
        echo "There where validation issues with ${count} files. Not ingesting." >> $log
        exit -1
    fi
fi