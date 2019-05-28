#!/usr/bin/env bash

# runs xsltproc tool on each metadata xml file in a mef export directory (the type exported by gn-tool.sh)
# usage: ./transform-downloads.sh /path/to/mef/dir https://my-geonetwork.dev.aodn.org.au _transformed

WORKING_DIR=$1
XSL_file=$2
TRANSFORMED_EXTENSION=$3

echo "working directory: $WORKING_DIR"

find $WORKING_DIR -name metadata*.xml | while read -r metadata_file; do
    echo $metadata_file$TRANSFORMED_EXTENSION
    xsltproc  --output $metadata_file$TRANSFORMED_EXTENSION  ../transforms/$XSL_file $metadata_file
done
