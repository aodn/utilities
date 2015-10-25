#!/bin/bash

# prints usage and exit
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Parallelize s3cmd upload."
    echo "
Options:
  -b                         Bucket base (for instance s3://imos-data/IMOS/AUV).
  -d                         Directory to upload (for instance /mnt/public/AUV).
  -p                         Number of processes to spawn for operation.
  -f                         Parallelize by uploading individual files."
    exit 3
}

main() {
    # parse options with getopt
    local tmp_getops
    tmp_getops=`getopt hb:d:p:f $*`
    [ $? != 0 ] && usage

    set -- $tmp_getops
    local bucket_base dir
    local -i per_file=0
    local -i max_procs=1

    # parse the options
    while true ; do
        case "$1" in
            -h) usage;;
            -b) bucket_base=$2; shift 2;;
            -d) dir="$2"; shift 2;;
            -p) max_procs="$2"; shift 2;;
            -f) per_file=1; shift 1;;
            --) shift; break;;
            *) usage;;
        esac
    done

    [ x"$bucket_base" = x ] && usage
    [ x"$dir" = x ] && usage

    if [ $per_file -eq 1 ]; then
        (cd $dir && find . -type f | cut -c3- | \
            xargs -P $max_procs -L1 -I ___FILE___ /bin/sh -c "s3cmd --no-preserve sync '___FILE___' '$bucket_base/___FILE___'")
    else
        local tmp_commands=`mktemp`
        local dir_to_upload
        for dir_to_upload in $dir/*; do
            local dir_basename=`basename $dir_to_upload`
            echo "s3cmd --no-preserve sync $dir_to_upload $bucket_base > $dir_basename.log 2>&1" >> $tmp_commands
        done
        echo "Going to run the following commands:"
        echo "------------------------------------"
        cat $tmp_commands
        echo "------------------------------------"
        echo -n "Proceed with that? (yes/no) "

        local ans; read ans
        if [ x"$ans" != x ] && [ "$ans" = "yes" ]; then
            echo "Spwaning '$max_procs' parallel processes"
            xargs -a $tmp_commands -P $max_procs -I COMMAND sh -c COMMAND
            local -i retval=$?
            rm -f $tmp_commands
            return $retval
        else
            echo "Aborting..."
        fi
    fi
}

main "$@"
