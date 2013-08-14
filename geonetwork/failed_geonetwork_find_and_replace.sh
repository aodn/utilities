#!/bin/bash

# $1 the search string
# $2 the replace string
# $3 the database username
update() {
    local find=$1; shift
    local replace=$1; shift
    local stmt="UPDATE metadata SET data = replace(data, '$find', '$replace');"
    local cmd="psql -h $host -d $database"
    if [ -n "$username" ]; then
        cmd="$cmd -U $username -W"
    fi
    echo "$cmd -c $stmt"
    #$cmd -c "$stmt"
}

usage() {
    echo "Usage: $0 [OPTIONS]... search_value replace_value"
    echo "Replaces string values in ALL Geonetwork metadata records."
    echo "
Options:
  -d             Name of the Geonetwork database, e.g. mest, optional, defaults to imosmest
  -h             Database hostname, optional defaults to localhost
  -U             The postgres username to use, if specified the password will be prompted for, i.e. psql -W"
    exit 2
}

main() {
    database="imosmest"
    host="localhost"

    while getopts "d:h:U:" opt; do
        case $opt in
            d)  database=$OPTARG
                ;;
            h)  host=$OPTARG
                ;;
            U)  username=$OPTARG
                ;;
            \?)
                usage
                ;;
        esac
    done

    shift $(($OPTIND -1))

    update $1 $2
}

main "$@"
