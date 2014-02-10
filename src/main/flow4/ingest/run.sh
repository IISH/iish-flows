#!/bin/bash

# run.sh
#
# Usage:
# validate.sh [na] [folder name]

source $FLOWS_HOME/src/main/global/setup.sh $0 "$@"

cd $FLOWS_HOME/src/main/flow4/validate
source ./run.sh

cd $FLOWS_HOME/src/main/flow2/ingest
source ./run.sh

exit 0