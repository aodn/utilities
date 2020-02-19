#!/bin/bash

# return name when id is provided from the list (e.g. id1:name1;id2:name2)
# $1 - list containing name value pair
# $2 - name value
get_category_from_uuid() {
  local objs=$1; shift
  local obj=$1; shift

  name=''
#  arr=($(echo "$objs" | tr ";" "\n"))
  IFS=';' read -ra arr <<< "$objs"
  for i in "${arr[@]}";
  do
    key="${i%%::*}"
    value="${i##*::}"
    if [[ $key == $obj ]]; then
      name=$value
    fi
  done
  echo ${name}
}

# adds categories in geonetwork records
# $1 - file/directory of geonetwork records
# $2 - mapping files
add_logo_categories_records() {
    local record_location=$1; shift
    local ecollection_file=$1; shift
    local record_file
    local -i retval=0

    eCollection=""
    while IFS=',' read -r first second; do
        eCollection+="$first::$second;"
    done < $ecollection_file

    if [ -d $record_location ]; then
        for record_dir_path in $record_location/*; do
            local uuid=`basename $record_dir_path`
            logo_category=$(get_category_from_uuid "$eCollection" "$uuid")
            if [[ ${logo_category} != "" ]]; then
              # check if logo-category already exists
              isInFile=$(cat $record_dir_path/info.xml | grep -c "<category name=\"$logo_category\" />")

              if [ $isInFile -eq 0 ]; then
                  echo "Adding Logo-category: '$logo_category' in GeoNetwork record '$uuid' from '$record_dir_path'"
                  # adding logo based categories in info.xml
                  sed -i'.categories' -e 's~<categories>~<categories>\'$'\n    <category name=\"'$logo_category'\" />~' $record_dir_path/info.xml
                  sed -i'.categories' -e 's~<categories />~<categories>\'$'\n    <category name=\"'$logo_category'\" />\'$'\n  </categories>~' $record_dir_path/info.xml
              else
                  echo "Logo-category: $logo_category already exists in GeoNetwork record '$uuid' from '$record_dir_path'"
              fi
            fi
            let retval=$retval+$?
        done
    fi

    return $retval
}


# prints usage and exit
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Add logo categories in GeoNetwork records."
    echo "
Options:
  -o                         Operation, must be 'add-logo-categories'.
  -l                         Location to read/write records from/to.
  -m                         uuid-category mapping file."
    exit 3
}

main() {
    # parse options with getopt
    local tmp_getops
    tmp_getops=`getopt ho:l:m: $*`
    [ $? != 0 ] && usage

    set -- $tmp_getops
    local location operation mapping_file

    # parse the options
    while true ; do
        case "$1" in
            -h) usage;;
            -o) operation=$2; shift 2;;
            -l) location="$2"; shift 2;;
            -m) mapping_file="$2"; shift 2;;
            --) shift; break;;
            *) usage;;
        esac
    done

    [ x"$operation" = x ] && usage
    [ x"$location" = x ] && usage
    [ x"$mapping_file" = x ] && usage

    if [ "$operation" = "add-logo-categories" ]; then
        add_logo_categories_records $location $mapping_file
    else
        usage
    fi
}

main "$@"
