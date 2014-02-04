#!/bin/bash

# Written by Jon Burgess <jonathan.burgess@utas.edu.au>
# Refactored by Dan Fruehauf <dan.fruehauf@utas.edu.au>

#
# This script takes a Geoserver URL and loads it by running a siege against all
# URLs it serves
#

declare -r CAT_GEOSERVER_LINKS_CMD=../../link_checker/lib/cat_geoserver_links.rb

# returns a list of WFS urls
# $1 - geoserver url
get_wfs_urls() {
    local geoserver_url=$1; shift
    ${CAT_GEOSERVER_LINKS_CMD} ${geoserver_url} --layers \
        | grep data \
        | sed "s@\(.*\)@${geoserver_url}/wfs?service=wfs\&version=2.0.0\&request=GetFeature\&typeNames=\1@g"
}

# returns a list of WMS urls
# $1 - geoserver url
get_wms_urls() {
    local geoserver_url=$1; shift
    ${CAT_GEOSERVER_LINKS_CMD} ${geoserver_url} --layers \
        | grep map \
        | sed "s@\(.*\)@${geoserver_url}/wms?LAYERS=\1\&TRANSPARENT=TRUE\&VERSION=1.1.1\&FORMAT=image%2Fpng\&QUERYABLE=true\&EXCEPTIONS=application%2Fvnd.ogc.se_xml\&SERVICE=WMS\&REQUEST=GetMap\&STYLES=\&SRS=EPSG%3A4326\&BBOX=-180,-90,180,90\&WIDTH=296\&HEIGHT=296@g"
}

# prepare siege scenario with all geoserver URLs
# $1 - geoserver url
# $2 - scenario file
prepare_scenario() {
    local geoserver_url=$1; shift
    local scenario_file=$1; shift
    local wfs_scenario_file=`mktemp`
    local wms_scenario_file=`mktemp`

    echo -n "Preparing WFS URLs..."
    get_wfs_urls $geoserver_url >> $wfs_scenario_file
    echo "Done!"

    echo -n "Preparing WMS URLs..."
    get_wms_urls $geoserver_url >> $wms_scenario_file
    echo "Done!"

    echo `wc -l ${wfs_scenario_file}` " WFS layers"
    echo `wc -l ${wms_scenario_file}` " WMS layers"

    cat $wfs_scenario_file $wms_scenario_file > $scenario_file
    rm -f $wfs_scenario_file $wms_scenario_file
}

# prints usage and exit
usage() {
    echo "Usage: $0 [OPTIONS] -- [SIEGE_PARAMETERS]"
    echo "Uses siege to load test geoserver"
    echo "
Options:
  -u, --url                  URL to siege"
    exit 3
}

# "$@" - parameters, see usage
main() {
    # parse options with getopt
    local tmp_getops=`getopt -o hu: --long help,url: -- "$@"`
    [ $? != 0 ] && usage

    eval set -- "$tmp_getops"
    local url

    # parse the options
    while true ; do
        case "$1" in
            -h|--help) usage;;
            -u|--url) url="$2"; shift 2;;
            --) shift; break;;
            *) usage;;
        esac
    done

    # if url is empty, do not proceed
    [ x"$url" = x ] && usage

    # prepare siege scenario
    local scenario_file=`mktemp`
    prepare_scenario $url $scenario_file

    echo "Running siege with '$@ -f $scenario_file'"
    siege "$@" -f $scenario_file
}

main "$@"
