#!/usr/bin/env bash

WORKING_DIR=$1
TRANSFORMED_EXTENSION=$2

echo "working directory: $WORKING_DIR"

find $WORKING_DIR -name metadata*.xml | while read -r metadata_file; do

    echo
    echo "Comparing $metadata_file  > $metadata_file$TRANSFORMED_EXTENSION"
    diff -w -b --suppress-common-lines --minimal $metadata_file $metadata_file$TRANSFORMED_EXTENSION
done
