#!/bin/bash

source $FLOWS_HOME/config.sh
log="/var/log/flow1/checksum.$datestamp.log"
net use $FLOW1_SHARE
cd $flow1_home/validate
$global_home/startup.sh "$flow1_hotfolders" "$log"
