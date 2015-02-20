#!/bin/bash

# get modified/added files in a git repository
# $1 - git directory
# $2 - from sha
# $3 - to sha
get_modified_new_files() {
    local dir=$1; shift
    local sha1=$1; shift
    local sha2=$1; shift
    (cd $dir && git diff --diff-filter=MAC --stat ${sha1}..${sha2} | head -n -1 | cut -d' ' -f2)
}

# get deleted files in a git repository
# $1 - git directory
# $2 - from sha
# $3 - to sha
get_deleted_files() {
    local dir=$1; shift
    local sha1=$1; shift
    local sha2=$1; shift
    (cd $dir && git diff -M --diff-filter=D --stat ${sha1}..${sha2} | head -n -1 | cut -d' ' -f2)
}

# return all available record uuids in geonetwork
# $1 - geonetwork address
# $2 - geonetwork user
# $3 - geonetwork password
get_all_records() {
    local gn_addr=$1; shift
    local gn_user=$1; shift
    local gn_password=$1; shift

    curl -s "$gn_addr/srv/eng/xml.search.imos?fast=index" | \
        grep "<uuid>.*</uuid>" | tr -s " " | cut -c8-43
}

# delete a single record
# $1 - record uuid
# $2 - geonetwork address
# $3 - geonetwork user
# $4 - geonetwork password
delete_record() {
    local record_uuid=$1; shift
    local gn_addr=$1; shift
    local gn_user=$1; shift
    local gn_password=$1; shift

    echo "Deleting record '$record_uuid'"
    curl -s \
        -u $gn_user:$gn_password \
        -d "uuid=$record_uuid" \
        "$gn_addr/srv/eng/xml.metadata.delete"
}

# export a single geonetwork record
# $1 - record uuid
# $2 - file to export record to
# $2 - geonetwork address
# $3 - geonetwork user
# $4 - geonetwork password
export_record() {
    local record_uuid=$1; shift
    local record_file=$1; shift
    local gn_addr=$1; shift
    local gn_user=$1; shift
    local gn_password=$1; shift

    curl -s "$gn_addr/srv/eng/xml_iso19139.mcp?styleSheet=xml_iso19139.mcp.xsl&uuid=$record_uuid" -o $record_file
}

# export geonetwork records
# $1 - record uuid
# $2 - file to export record to
# $2 - geonetwork address
# $3 - geonetwork user
# $4 - geonetwork password
export_records() {
    local record_uuid=$1; shift
    local record_file=$1; shift
    local gn_addr=$1; shift
    local gn_user=$1; shift
    local gn_password=$1; shift

    local -i retval=0
    if [ x"$record_uuid" = x"ALL" ]; then
        mkdir -p $record_file
        for record_uuid in `get_all_records $gn_addr $gn_user $gn_password`; do
            export_record $record_uuid $record_file/${record_uuid}.xml $gn_addr $gn_user $gn_password
            let retval=$retval+$?
        done
    else
        export_record $record_uuid $record_file $gn_addr $gn_user $gn_password
        let retval=$retval+$?
    fi

    return $retval
}

# imports a single geonetwork record
# $1 - file to import from
# $2 - geonetwork address
# $3 - geonetwork user
# $4 - geonetwork password
import_record() {
    local record_file=$1; shift
    local gn_addr=$1; shift
    local gn_user=$1; shift
    local gn_password=$1; shift

    local uuid=`basename $record_file | cut -d. -f1`

    echo "Importing record '$uuid' from '$record_file'"

    curl -s -X POST \
        -u $gn_user:$gn_password \
        -F "insert_mode=1" \
        -F "file_type=single" \
        -F "category=_none_" \
        -F "group=2" \
        -F "styleSheet=_none_" \
        -F "uuidAction=overwrite" \
        -F mefFile=@$record_file \
        $gn_addr/srv/eng/mef.import && \
    curl -s \
        -u $gn_user:$gn_password \
        -d "_1_0=on&_1_1=on&_1_5=on&_1_6=on" \
        -d "uuid=$uuid" \
        $gn_addr/srv/eng/metadata.admin
}

# imports geonetwork records
# $1 - file/directory to import
# $2 - geonetwork address
# $3 - geonetwork user
# $4 - geonetwork password
import_records() {
    local record_location=$1; shift
    local gn_addr=$1; shift
    local gn_user=$1; shift
    local gn_password=$1; shift

    local record_file
    local -i retval=0
    if [ -d $record_location ]; then
        for record_file in $record_location/*.xml; do
            import_record $record_file $gn_addr $gn_user $gn_password
            let retval=$retval+$?
        done
    else
        import_record $record_location $gn_addr $gn_user $gn_password
        let retval=$retval+$?
    fi
    return $retval
}

# imports geonetwork records, assume git directory
# $1 - git directory to import
# $2 - geonetwork address
# $3 - geonetwork user
# $4 - geonetwork password
import_records_git() {
    local record_location=$1; shift
    local gn_addr=$1; shift
    local gn_user=$1; shift
    local gn_password=$1; shift

    if [ ! -d "$record_location" ] || [ ! -d "$record_location/.git" ]; then
        echo "'$record_location' is not a git directory"
        return 1
    fi

    local -i retval=0
    echo "Performing intelligent import from git directory '$record_location'"

    # either start from the begining, or take sha from last_update file
    local from_sha=`(cat $record_location/last_update) || (cd $record_location && git log --oneline | tail -1 | cut -d' ' -f1)`
    local to_sha=`(cd $record_location && git log --oneline | head -1 | cut -d' ' -f1)`

    if [ "$from_sha" = "$to_sha" ]; then
        echo "No new changes detected"
        return 0
    fi

    echo "Applying changes from '$from_sha' to '$to_sha'"
    local record_file
    for record_file in `get_modified_new_files $record_location $from_sha HEAD`; do
        import_record $record_location/$record_file $gn_addr $gn_user $gn_password
        let retval=$retval+$?
    done

    for record_file in `get_deleted_files $record_location $from_sha HEAD`; do
        local uuid=`basename $record_file | cut -d. -f1`
        delete_record $uuid $gn_addr $gn_user $gn_password
        let retval=$retval+$?
    done

    local last_commit=`cd $record_location && git log --oneline | head -1 | cut -d' ' -f1`
    if [ $retval -eq 0 ]; then
        echo $last_commit > $record_location/last_update
    else
        echo "Could not apply changes from '$from_sha' to '$last_commit'"
    fi

    return $retval
}

# prints usage and exit
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Import/export Geonetwork records."
    echo "
Options:
  -G, --git                  Intelligent import using git.
  -o, --operation            import or export.
  -l, --location             Location to read/write records from/to.
  -g, --geonetwork           Geonetwork address like http://a.b.c.d/geonetwork
  -u, --user                 Username to login with.
  -p, --password             Password to login with."
    exit 3
}

main() {
    # parse options with getopt
    local tmp_getops
    tmp_getops=`getopt -o hGo:l:g:u:p: --long help,git,operation:,location:,geonetwork:,user:,password: -- "$@"`
    [ $? != 0 ] && usage

    eval set -- "$tmp_getops"
    local gn_addr gn_user gn_password
    local location operation
    local record_uuid="ALL"
    local git=no

    # parse the options
    while true ; do
        case "$1" in
            -h|--help) usage;;
            -G|--git) git=yes; shift 1;;
            -o|--operation) operation=$2; shift 2;;
            -l|--location) location="$2"; shift 2;;
            -r|--record) record_uuid="$2"; shift 2;;
            -g|--geonetwork) gn_addr="$2"; shift 2;;
            -u|--user) gn_user="$2"; shift 2;;
            -p|--password) gn_password="$2"; shift 2;;
            --) shift; break;;
            *) usage;;
        esac
    done

    [ x"$operation" = x ] && usage
    [ x"$location" = x ] && usage
    [ x"$gn_addr" = x ] && usage

    if [ "$operation" = "import" ]; then
        # must authenticate to run import
        if [ x"$gn_user" = x ] || [ x"$gn_password" = x ]; then
            usage
        fi

        if [ "$git" = "yes" ]; then
            import_records_git $location $gn_addr $gn_user $gn_password
        else
            import_records $location $gn_addr $gn_user $gn_password
        fi
    elif [ "$operation" = "export" ]; then
        export_records $record_uuid $location $gn_addr $gn_user $gn_password
    else
        usage
    fi
}

main "$@"
