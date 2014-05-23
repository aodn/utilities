#!/bin/bash

LAYERS_TO_SEED="imos:argo_profile_layer_map \
imos:aatams_biologging_shearwater_map
imos:aatams_sattag_dm_profile_map
imos:aatams_biologging_penguin_map
imos:aatams_sattag_nrt_profile_map
imos:soop_co2_trajectory_map
imos:soop_ba_trajectory_map
imos:soop_asf_mt_trajectory_map
imos:srs_oc_soop_rad_trajectory_map
imos:soop_tmv_nrt_trajectory_map
imos:soop_sst_dm_trajectory_map
imos:soop_sst_nrt_trajectory_map
imos:soop_tmv_trajectory_map
imos:soop_trv_trajectory_map
imos:soop_xbt_nrt_profiles_map
imos:soop_asf_mft_trajectory_map
imos:soop_xbt_dm_profile_map"

declare -r -i ZOOM_LEVEL_START=2
declare -r -i ZOOM_LEVEL_END=5
declare -r -i TILE_SIZE=256
declare -r -i GUTTER_SIZE=20
declare -r -i GEOSERVER_PORT=8081
declare -r GEOSERVER_NAME=geoserver

get_layers() {
    echo "$LAYERS_TO_SEED"
}

# returns all urls for given layer and zoom level
# $1 - layer name
# $2 - zoom level
get_urls_for_layer() {
    local layer_name=$1; shift
    local zoom_level=$1; shift
    ./tile_seeder.js $zoom_level http://localhost:$GEOSERVER_PORT/$GEOSERVER_NAME $layer_name $TILE_SIZE $GUTTER_SIZE
}

# main
main() {
    local -i zoom_level
    local layer_name
    local tmp_url_list=`mktemp`
    for zoom_level in `seq $ZOOM_LEVEL_START $ZOOM_LEVEL_END`; do
        for layer_name in $LAYERS_TO_SEED; do
            echo -n "Obtaining URL list for $layer_name:$zoom_level..."
            get_urls_for_layer $layer_name $zoom_level > $tmp_url_list
            echo "Done!"

            echo -n "Seeding $layer_name:$zoom_level..."
            for url in `cat $tmp_url_list`; do
                squidclient -s -m GET "$url"
            done
            echo "Done!"
        done
    done
    rm -f $tmp_url_list
}

main "$@"
