#!/bin/bash

# return all the groups info (groupid and group name) from geonetwork 3
# $1 - geonetwork address
# $2 - geonetwork user
# $3 - geonetwork password
get_groups() {
  local gn_addr=$1; shift
  local gn_user=$1; shift
  local gn_password=$1; shift

  rm -f /tmp/cookie.txt ;
  curl -s -c /tmp/cookie.txt -X POST -u $gn_user:$gn_password $gn_addr/srv/api/0.1 | grep -o 'XSRF-TOKEN.*'
  gn_xsrftoken=$(grep -o 'XSRF-TOKEN.*' /tmp/cookie.txt  | sed -E 's/[[:space:]]+/ /g' | cut -d  ' ' -f 2)

    if [[ $gn_user != "" ]]; then
      gn_user_arg="--username $gn_user"
    fi
    if [[ $gn_password != "" ]]; then
      gn_password_arg="--password $gn_password"
    fi
    if [[ $gn_xsrftoken != "" ]]; then
      $gn_xsrftoken_arg="--xsrftoken $gn_xsrftoken"
    fi

  python ./get-groups-from-xml.py "$gn_addr/srv/eng/xml.info?type=groups" $gn_user_arg $gn_password_arg $gn_xsrftoken_args

}

# return name when id is provided from the list (e.g. id1:name1;id2:name2)
# $1 - list containing name value pair
# $2 - name value
get_name_from_id() {
  local objs=$1; shift
  local obj=$1; shift

  name=''
#  arr=($(echo "$objs" | tr ";" "\n"))
  IFS=';' read -ra arr <<< "$objs"
  for i in "${arr[@]}";
  do
    key="${i%%:*}"
    value="${i##*:}"
    if [[ $key == $obj ]]; then
      name=$value
    fi
  done
  echo ${name}
}

# return name when id is provided from the list (e.g. id1:name1;id2:name2)
# $1 - list containing name value pair
# $2 - name value
get_group_from_uuid() {
  local objs=$1; shift
  local obj=$1; shift

  name=''
  IFS=';' read -ra arr <<< "$objs"
  for i in "${arr[@]}";
  do
    key="${i%%::*}"
    value="${i##*::}"
    if [[ $key == $obj ]]; then
      name=$value
    fi
  done
  echo "${name}"
}

# Create uuid and group mapping for each geonetwork record
# $gn_addr     - geonetwork address
# $gn_user     - geonetwork user
# $gn_password - geonetwork password
create_uuid_group_mapping() {
    local gn_addr=$1; shift
    local gn_user=$1; shift
    local gn_password=$1; shift

    local retval=""

    # create XSRFTOKEN
    rm -f /tmp/cookie.txt ;
    curl -s -c /tmp/cookie.txt -X POST -u $gn_user:$gn_password $gn_addr/srv/api/0.1 | grep -o 'XSRF-TOKEN.*'
    XSRFTOKEN=$(grep -o 'XSRF-TOKEN.*' /tmp/cookie.txt  | sed -E 's/[[:space:]]+/ /g' | cut -d  ' ' -f 2)

    # Retrieve harvesters
    [ -e harvesters.xml ] && rm harvesters.xml
    curl -s \
        -u $gn_user:$gn_password \
        -H "X-XSRF-TOKEN:$XSRFTOKEN" \
        -b "/tmp/cookie.txt" \
        $gn_addr/srv/eng/xml.harvesting.get >> harvesters.xml

    # Create mapping between source_id and group
    [ -e mappings.xml ] && rm mappings.xml
    xsltproc -o mappings.xml catalogue-imos-source-groupowners.xsl harvesters.xml

    # Retrieve metadata records
    [ -e harvested.xml ] && rm harvested.xml
    curl -s \
        -u $gn_user:$gn_password \
        -H "X-XSRF-TOKEN:$XSRFTOKEN" \
        -b "/tmp/cookie.txt" \
        "$gn_addr/srv/eng/xml.search.imos?fast=index&from=1&to=10000" >> harvested.xml

    # Create mapping between records uuid and group
    [ -e uuid-group.csv ] && rm uuid-group.csv
    xsltproc -o uuid-group.csv catalogue-imos-groupowners.xsl harvested.xml

    retval=""
    while IFS=',' read -r first second; do
        retval+="$first::$second;"
    done < uuid-group.csv

#    [ -e harvesters.xml ] && rm -f harvesters.xml
#    [ -e mappings.xml ] && rm -f mappings.xml
#    [ -e harvested.xml ] && rm -f harvested.xml
#    [ -e uuid-group.csv ] && rm -f uuid-group.csv
#    [ -e /tmp/cookie.txt ] && rm -f /tmp/cookie.txt ;

    echo "$retval"
}

# adds group owner privileges into geonetwork records
# $record_dir  - directory of geonetwork records
# $gn_addr     - geonetwork address
# $gn_user     - geonetwork user
# $gn_password - geonetwork password
add_group_owner_privileges_records() {
    local record_location=$1; shift
    local gn_addr=$1; shift
    local gn_user=$1; shift
    local gn_password=$1; shift

    eCollection=$(create_uuid_group_mapping $gn_addr $gn_user $gn_password)
    groups=$(get_groups $gn_addr $gn_user $gn_password)

    if [ -d $record_location ]; then
        for record_dir_path in $record_location/*; do
            local uuid=`basename $record_dir_path`
            owner_group=""
            owner_group_id=$(get_group_from_uuid "$eCollection" "$uuid")
            if [[ !  -z  $owner_group_id ]]
            then
              if [[ $owner_group_id == '1' ]]
              then
                owner_group='all'
              else
                owner_group=$(get_name_from_id "$groups" "$owner_group_id")
              fi
            fi

            # check if owner-group is empty
            if [[ ${owner_group} != "" ]]; then
              # check if owner-group already exists
              isInFile=$(cat $record_dir_path/info.xml | grep -c "<group name=\"$owner_group\" groupOwner=\"true\"")
              if [ $isInFile -eq 0 ]; then
                  echo "Adding group '$owner_group' in GeoNetwork record '$uuid'"
                  # adding owner based groups in info.xml
                  sed -i'.privileges' -e 's~<privileges>~<privileges>\'$'\n    <group name=\"'$owner_group'\" groupOwner=\"true\" />~' $record_dir_path/info.xml
                  sed -i'.privileges' -e 's~<privileges />~<privileges>\'$'\n    <group name=\"'$owner_group'\"  groupOwner=\"true\" />\'$'\n  </privileges>~' $record_dir_path/info.xml
              else
                  echo "Group '$owner_group' already exists in GeoNetwork record '$uuid'"
              fi
            fi
        done
    fi
}


# prints usage and exit
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Add groupowner privileges in GeoNetwork records."
    echo "
Options:
  -l                         Location to read/write records from/to.
  -g                         Geonetwork address of catalogue imos (e.g. http://a.b.c.d/geonetwork)
  -u                         Username to login with.
  -p                         Password to login with."
    exit 3
}

main() {
    # parse options with getopt
    local tmp_getops
    tmp_getops=`getopt h:l:g:u:p: $*`
    [ $? != 0 ] && usage

    set -- $tmp_getops
    local location gn_addr gn_user gn_password

    # parse the options
    while true ; do
        case "$1" in
            -h) usage;;
            -l) location="$2"; shift 2;;
            -g) gn_addr="$2"; shift 2;;
            -u) gn_user="$2"; shift 2;;
            -p) gn_password="$2"; shift 2;;
            --) shift; break;;
            *) usage;;
        esac
    done

    [ x"$location" = x ] && usage
    [ x"$gn_addr" = x ] && usage

    # Check if user name exists check password or viceversa
    if [ -n "$gn_user" ] && ! [[ -n "$gn_password" ]]; then
      usage
    fi
    if [ -n "$gn_password" ] && ! [[ -n "$gn_user" ]]; then
      usage
    fi
    # Add owner privileges
    add_group_owner_privileges_records $location $gn_addr $gn_user $gn_password
}

main "$@"
