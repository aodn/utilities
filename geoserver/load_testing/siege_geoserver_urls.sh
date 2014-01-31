#!/bin/bash
set -e

GEOSERVER_URL=${GEOSERVER_URL:=http://10.11.12.13/geoserver}
TMP_URLS_FILE=${TMP_URLS_FILE:=/tmp/urls.txt}

write_get_feature_urls_to_file() {
    echo "Writing WFS (GetFeature) request URLs to temporary file at ${TMP_URLS_FILE}..."

    ../../link_checker/lib/cat_geoserver_links.rb ${GEOSERVER_URL} --layers \
        | grep data \
        | sed "s@\(.*\)@${GEOSERVER_URL}/wfs?service=wfs\&version=2.0.0\&request=GetFeature\&typeNames=\1@g" \
        > ${TMP_URLS_FILE}
}

write_get_map_urls_to_file() {
    echo "Appending WMS (GetMap) request URLs to temporary file at ${TMP_URLS_FILE:=/tmp/urls.txt}..."

    ../../link_checker/lib/cat_geoserver_links.rb ${GEOSERVER_URL} --layers \
        | grep map \
        | sed "s@\(.*\)@${GEOSERVER_URL}/wms?LAYERS=\1\&TRANSPARENT=TRUE\&VERSION=1.1.1\&FORMAT=image%2Fpng\&QUERYABLE=true\&EXCEPTIONS=application%2Fvnd.ogc.se_xml\&SERVICE=WMS\&REQUEST=GetMap\&STYLES=\&SRS=EPSG%3A4326\&BBOX=-180,-90,180,90\&WIDTH=296\&HEIGHT=296@g" \
        >> ${TMP_URLS_FILE}
}

run_siege() {
    echo "Running siege..."
    siege $* -f ${TMP_URLS_FILE}
}

main() {
    write_get_feature_urls_to_file
    write_get_map_urls_to_file
    run_siege $*
}

main $*
