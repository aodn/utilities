#!/bin/bash
set -e

GEOSERVER_URL=$1
shift


TMP_WFS_URLS_FILE=${TMP_WFS_URLS_FILE:=`mktemp /tmp/wfs_urls.txt.XXXXX`}
TMP_WMS_URLS_FILE=${TMP_WMS_URLS_FILE:=`mktemp /tmp/wms_urls.txt.XXXXX`}
TMP_URLS_FILE=${TMP_URLS_FILE:=`mktemp /tmp/urls.txt.XXXXX`}

CAT_GEOSERVER_LINKS_CMD=../../link_checker/lib/cat_geoserver_links.rb

write_get_feature_urls_to_file() {
    echo "Writing WFS (GetFeature) request URLs to temporary file at ${TMP_WFS_URLS_FILE}..."

    ${CAT_GEOSERVER_LINKS_CMD} ${GEOSERVER_URL} --layers \
        | grep data \
        | sed "s@\(.*\)@${GEOSERVER_URL}/wfs?service=wfs\&version=2.0.0\&request=GetFeature\&typeNames=\1@g" \
        > ${TMP_WFS_URLS_FILE}

    echo "`wc -l ${TMP_WFS_URLS_FILE}` requests written to ${TMP_WFS_URLS_FILE}."
}

write_get_map_urls_to_file() {
    echo "Writing WMS (GetMap) request URLs to temporary file at ${TMP_WMS_URLS_FILE:=/tmp/urls.txt}..."

    ${CAT_GEOSERVER_LINKS_CMD} ${GEOSERVER_URL} --layers \
        | grep map \
        | sed "s@\(.*\)@${GEOSERVER_URL}/wms?LAYERS=\1\&TRANSPARENT=TRUE\&VERSION=1.1.1\&FORMAT=image%2Fpng\&QUERYABLE=true\&EXCEPTIONS=application%2Fvnd.ogc.se_xml\&SERVICE=WMS\&REQUEST=GetMap\&STYLES=\&SRS=EPSG%3A4326\&BBOX=-180,-90,180,90\&WIDTH=296\&HEIGHT=296@g" \
        > ${TMP_WMS_URLS_FILE}

    echo "`wc -l ${TMP_WMS_URLS_FILE}` requests written to ${TMP_WMS_URLS_FILE}."
}

run_siege() {
    echo "Running siege..."
    cat ${TMP_WMS_URLS_FILE} ${TMP_WFS_URLS_FILE} > ${TMP_URLS_FILE}
    siege $@ -f ${TMP_URLS_FILE}
}

main() {
    write_get_feature_urls_to_file
    write_get_map_urls_to_file
    run_siege "$@"
}

main "$@"
