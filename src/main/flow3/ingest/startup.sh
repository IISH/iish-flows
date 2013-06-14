#!/bin/bash

source $FLOWS_HOME/config.sh
log="/var/log/flow3/images.$datestamp.log"
net use $FLOW3_SHARE
cd $flow3_home/ingest
$global_home/startup.sh "$flow3_hotfolders" "$log"
