#!/bin/bash

declare -r -i TILE_SIZE=256
declare -r -i GUTTER_SIZE=20
declare -r -i THREADS=1
declare -r DEFAULT_GEOSERVER_ADDRESS=geoserver

# returns all urls for given layer and zoom level
# $1 - layer name
# $2 - zoom level
get_urls_for_layer() {
    local layer_name=$1; shift
    local zoom_level=$1; shift
    ./tile_seeder.js $zoom_level $layer_name $TILE_SIZE $GUTTER_SIZE
}

# seed a single layer
# $1 - threads
# $2 - layer name
# $3 - geoserver port
# $4 - geoserver url
# $5 - zoom level start
# $6 - zoom level end
# $7 - bounding box (optional)
seed_layer() {
    local -i threads=$1; shift
    local layer_name=$1; shift
    local -i geoserver_port=$1; shift
    local geoserver_url=$1; shift
    local -i zoom_level_start=$1; shift
    local -i zoom_level_end=$1; shift

    local -i zoom_level
    local tmp_url_list=`mktemp`

    for zoom_level in `seq $zoom_level_start $zoom_level_end`; do
        echo -n "Obtaining URL list for $layer_name:$zoom_level..."
        get_urls_for_layer $layer_name $zoom_level > $tmp_url_list
        echo "Done!"

        echo -n "Seeding $layer_name:$zoom_level..."

        # implant the http prefix and run with xargs, so we can run things in
        # parallel
        sed -e "s#^#http://localhost:$geoserver_port/$geoserver_url/wms?#" $tmp_url_list | \
            xargs -L1 --max-proc=$threads -- squidclient -s -m GET
        echo "Done!"
    done
    rm -f $tmp_url_list
}

# prints usage and exit
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Seeds a Geoserver layer."
    echo
    echo "Example: $0 -g geoserver -p 8080 -l imos:argo_profile_layer_map -s 2 -e 5"
    echo
    echo "
Options:
  -t, --threads              Number of concurrent threads.
  -g, --geoserver            Geoserver URL, default is '$DEFAULT_GEOSERVER_ADDRESS'.
  -p, --port                 Tomcat port on which Geoserver is running.
  -l, --layer                Layer to seed (including workspace name).
  -s, --start-zoom           Zoom level to start.
  -e, --end-zoom             Zoom level to end.
  -b, --bouding-box          Bounding box (optional).
"
    exit 3
}

# "$@" - parameters, see usage
main() {
    # parse options with getopt
    local tmp_getops
    tmp_getops=`getopt -o ht:g:p:l:s:e:b: --long help,threads:,geoserver:,port:,layer:,start-zoom:,end-zoom:,bounding-box: -- "$@"`
    [ $? != 0 ] && usage

    eval set -- "$tmp_getops"

    local geoserver=$DEFAULT_GEOSERVER_ADDRESS
    local layer bbox
    local -i threads=$THREADS
    local -i port=0
    local -i start_zoom=0
    local -i end_zoom=0

    # parse the options
    while true ; do
        case "$1" in
            -h|--help) usage;;
            -t|--threads) threads="$2"; shift 2;;
            -g|--geoserver) geoserver="$2"; shift 2;;
            -p|--port) port=$2; shift 2;;
            -l|--layer) layer="$2"; shift 2;;
            -s|--start-zoom) start_zoom="$2"; shift 2;;
            -e|--end-zoom) end_zoom=$2; shift 2;;
            -b|--bounding-box) bbox=$2; shift 2;;
            --) shift; break;;
            *) usage;;
        esac
    done

    # if geoserver is empty, do not proceed
    [ x"$geoserver" = x ] && usage

    # if port is 0, do not proceed
    [ $port -eq 0 ] && usage

    # if layer is empty, do not proceed
    [ x"$layer" = x ] && usage

    # if start_zoom is larger than end_zoom, just do start_zoom
    [ $start_zoom -gt $end_zoom ] && start_zoom=$end_zoom

    seed_layer $threads "$layer" $port $geoserver $start_zoom $end_zoom $bbox
}

main "$@"
