#!/bin/bash

# retry.sh
#
# From errors in the log we will re-submit files when there are issues
#
# usage: ftp.sh [ftp log file] [fileSet]


# There are always one or more files that failed to transport properly.
# We will use the log to detect such events.

log_retry=$1
fileSet=$2
source $FLOW_HOME/config.sh
folder=$(basename $fileSet)

if [ ! -f "$log_retry" ] ; then
	echo "No log found to check the status of the ftp action: $log_retry"
	exit 0
fi


limit=5
x=1
while [ $x -le $limit ]
do
    ftp_script=$log_retry.ftpscript
    echo "option batch continue">$ftp_script
    echo "option confirm off">>$ftp_script
    echo "option transfer bina:ry">>$ftp_script
    echo "option reconnecttime 5">>$ftp_script
    echo "open $FTP_CONNECTION">>$ftp_script

    groovy $global_home/retry "$(cygwin --windows $log_retry) $(cygwin --windows $ftp_script)"

    if [ -f "$ftp_script" ] ; then
        rm "$log_retry"
	    WinSCP /console /script="$(cygwin --windows $ftp_script)" /parameter $folder /log:"$(cygwin --windows $log_retry)"
    else
        exit 0
    fi
    x=$(( $x + 1 ))
done

if [[ $x == $limit ]] ; then
    exit -1
fi