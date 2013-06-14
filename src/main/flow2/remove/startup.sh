#!/bin/bash

source $FLOWS_HOME/config.sh
log="/var/log/flow2/remove.$datestamp.log"
net use $FLOW2_SHARE
cd $flow2_home/remove
$global_home/startup.sh "$flow2_hotfolders" "$log"
