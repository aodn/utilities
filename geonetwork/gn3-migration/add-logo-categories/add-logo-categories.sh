#!/bin/bash

# return name when id is provided from the list (e.g. id1:name1;id2:name2)
# $1 - list containing name value pair
# $2 - name value
get_category_from_uuid() {
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

# Create uuid and category mapping for each geonetwork record
# $gn_addr     - geonetwork address
# $gn_user     - geonetwork user
# $gn_password - geonetwork password
create_uuid_category_mapping() {
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

    # Create mapping between source_id and category
    [ -e mappings.xml ] && rm mappings.xml
    xsltproc -o mappings.xml catalogue-portal-source-logos.xsl harvesters.xml

    # Retrieve metadata records
    [ -e harvested.xml ] && rm harvested.xml
    curl -s \
        -u $gn_user:$gn_password \
        -H "X-XSRF-TOKEN:$XSRFTOKEN" \
        -b "/tmp/cookie.txt" \
        $gn_addr/srv/eng/xml.search.imos?fast=index >> harvested.xml

    # Create mapping between records uuid and category
    [ -e uuid-category.csv ] && rm uuid-category.csv
    xsltproc -o uuid-category.csv catalogue-portal-logos.xsl harvested.xml

    retval=""
    while IFS=',' read -r first second; do
        retval+="$first::$second;"
    done < uuid-category.csv

    [ -e harvesters.xml ] && rm -f harvesters.xml
    [ -e mappings.xml ] && rm -f mappings.xml
    [ -e harvested.xml ] && rm -f harvested.xml
    [ -e uuid-category.csv ] && rm -f uuid-category.csv
    [ -e /tmp/cookie.txt ] && rm -f /tmp/cookie.txt ;

    echo "$retval"
}

# adds categories into geonetwork records
# $record_dir  - directory of geonetwork records
# $gn_addr     - geonetwork address
# $gn_user     - geonetwork user
# $gn_password - geonetwork password
add_logo_categories_records() {
    local record_location=$1; shift
    local gn_addr=$1; shift
    local gn_user=$1; shift
    local gn_password=$1; shift

    eCollection=$(create_uuid_category_mapping $gn_addr $gn_user $gn_password)

    if [ -d $record_location ]; then
        for record_dir_path in $record_location/*; do
            local uuid=`basename $record_dir_path`
            logo_category=$(get_category_from_uuid "$eCollection" "$uuid")
            # check if logo-category is empty
            if [[ ${logo_category} != "" ]]; then
              # check if logo-category already exists
              isInFile=$(cat $record_dir_path/info.xml | grep -c "<category name=\"$logo_category\" />")

              if [ $isInFile -eq 0 ]; then
                  echo "Adding category '$logo_category' in GeoNetwork record '$uuid'"
                  # adding logo based categories in info.xml
                  sed -i'.categories' -e 's~<categories>~<categories>\'$'\n    <category name=\"'$logo_category'\" />~' $record_dir_path/info.xml
                  sed -i'.categories' -e 's~<categories />~<categories>\'$'\n    <category name=\"'$logo_category'\" />\'$'\n  </categories>~' $record_dir_path/info.xml
              else
                  echo "Category '$logo_category' already exists in GeoNetwork record '$uuid'"
              fi
            fi
        done
    fi
}


# prints usage and exit
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Add categories in GeoNetwork records for logo assignment."
    echo "
Options:
  -l                         Location to read/write records from/to.
  -g                         Geonetwork address of catalogue portal (e.g. http://a.b.c.d/geonetwork)
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
    # Add logo categories
    add_logo_categories_records $location $gn_addr $gn_user $gn_password
}

main "$@"
