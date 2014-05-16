#!/bin/bash

# Written by Dan Fruehauf <dan.fruehauf@utas.edu.au>

#
# This script takes a squid log and helps inspect tiles that have been cached.
#

# extracts bbox name from request
# $1 - tile url
get_bbox() {
    local tile_url="$1"; shift
    echo $tile_url | sed -e 's#.*?##' | tr "&" "\n" | grep BBOX | cut -d= -f2
}

# extracts layer name from request
# $1 - tile url
get_layer_name() {
    local tile_url="$1"; shift
    echo $tile_url | sed -e 's#.*?##' | tr "&" "\n" | grep LAYERS | cut -d= -f2
}

# inspect a single tile
# $1 - output directory
# $2 - geoserver url
# $3 - tile url
inspect_tile() {
    local output_dir=$1; shift
    local geoserver="$1"; shift
    local url="$1"; shift
    local tile_address="$geoserver/$url"

    local bbox=`get_bbox $tile_address`
    local layer_name=`get_layer_name $tile_address`

    local tile_filename="$output_dir/${layer_name}---${bbox}.png"
    echo "Inspecting '$tile_address' -> $tile_filename"

    curl -o $tile_filename "$tile_address"
}

# tile inspector logic
# $1 - geoserver url
# $2 - apache/squid log file
# $3 - output directory
tile_inspector() {
    local geoserver="$1"; shift
    local log_file="$1"; shift
    local output_dir="$1"; shift

    local tmp_url_list=`mktemp`
    awk '{print $7}' $log_file | \
        sed -e 's#http://[[:alnum:]]\+:[[:digit:]]\+/##' | \
        sort | uniq > $tmp_url_list

    local url
    for url in `cat $tmp_url_list`; do
        inspect_tile $output_dir $geoserver "$url"
    done
    rm -f $tmp_url_list
}

# prints usage and exit
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Inspect tiles in given log file."
    echo "
Options:
  -g, --geoserver            Geoserver address.
  -l, --log-file             Squid/Apache log file.
  -o, --outptu-dir           Output directory for tiles."
    exit 3
}

# "$@" - parameters, see usage
main() {
    # parse options with getopt
    local tmp_getops=`getopt -o hg:l:o: --long help,geoserver:,url:,output-dir: -- "$@"`
    [ $? != 0 ] && usage

    eval set -- "$tmp_getops"
    local geoserver log_file output_dir

    # parse the options
    while true ; do
        case "$1" in
            -h|--help) usage;;
            -g|--geoserver) geoserver="$2"; shift 2;;
            -l|--log-file) log_file="$2"; shift 2;;
            -o|--output-dir) output_dir="$2"; shift 2;;
            --) shift; break;;
            *) usage;;
        esac
    done

    # if geoserver is empty, do not proceed
    [ x"$geoserver" = x ] && usage

    # if log_file is empty, do not proceed
    [ x"$log_file" = x ] && usage

    # if output_dir is empty, do not proceed
    [ x"$output_dir" = x ] && usage

    # make sure output dir does not exist as we're going to create it
    [ -f "$output_dir" ] && echo "Output directory '$output_dir' is a file"
    mkdir $output_dir

    tile_inspector "$geoserver" "$log_file" "$output_dir"
}

main "$@"
