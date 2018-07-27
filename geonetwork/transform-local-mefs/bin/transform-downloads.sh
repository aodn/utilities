#!/usr/bin/env bash

# runs xsltproc tool on each metadata xml file in a mef export directory (the type exported by gn-tool.sh)
# usage: ./transform-downloads.sh /path/to/mef/dir https://my-geonetwork.dev.aodn.org.au

WORKING_DIR=$1
SITE_URL=$2

echo "working directory: $WORKING_DIR"
echo "siteURL: $SITE_URL"

find $WORKING_DIR -name metadata*.xml | while read -r metadata_file; do
    echo $metadata_file
    xsltproc --stringparam siteURL $SITE_URL --output $metadata_file ./bin/UpdateCatalogueReferences.xsl  $metadata_file
done
