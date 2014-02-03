#!/bin/bash

# Written by Dan Fruehauf <dan.fruehauf@utas.edu.au>

#
# This script takes a httpd access log file and replays it on the given URL
# using siege. It can be used for load testing simulation
#

# downloads remote file with scp and returns it's local path
# $1 - remote file URL
get_remote_file() {
    local remote_file="$1"; shift
    local file=`basename $remote_file`

    # return if file exists
    test -f $file && echo $file && return 0

    # download file using scp or return
    scp $remote_file . >& /dev/null || return 1

    echo $file
}
# prepares the URLs in the given file
# $1 - file
# $2 - url
# $3 - strip term
prepare_urls() {
    local file="$1"; shift
    local url="$1"; shift
    local strip_term="$1"; shift
    local tmp_file=`mktemp`
    cat $file \
        | tr -s " " \
        | cut -d' ' -f7 \
        | grep "$strip_term" \
        | sed -e "s#${strip_term}#${url}#" \
        > $tmp_file
    echo $tmp_file
}

# display some statistics
# $1 - time_delta_scenario_real_life
# $2 - time_delta_scenario_stressed
# $3 - number of clients in stressed simulation
display_statistics() {
    local -i time_delta_scenario_real_life=$1; shift
    local -i time_delta_scenario_stressed=$1; shift
    local -i num_clients=$1; shift

    # multiply by number of clients - this is how much "harder" this scenario
    # was
    local -i times=`echo \
        "$time_delta_scenario_real_life / $time_delta_scenario_stressed * $num_clients" \
        | bc -l | cut -d. -f1`

    echo "-----------------------------------------------"
    echo "Real life: $time_delta_scenario_real_life seconds"
    echo "Stress test: $time_delta_scenario_stressed seconds (x$num_clients harder!)"
    echo "We can do x$times times better!"
    echo "-----------------------------------------------"
}

# parses ugly date time string as '17/Jan/2014:23:13:17' and returns seconds
# since epoch
# $1 - date time string to parse
parse_date() {
    local date_time="$1"; shift
    # 17/Jan/2014:23:13:17 -> 17-Jan-2014 23:13:17
    date_time=`echo $date_time | sed -e 's#/#-#g' -e 's/:/ /'`
    date --date="$date_time" "+%s"
}

# replay attack
# $1 - URL to attack
# $2 - query part to strip
# $3 - access.log file
replay_attack() {
    local url="$1"; shift
    local strip_term="$1"; shift
    local file="$1"; shift

    local -i num_clients=64

    # take second line as first line might be empty :(
    local date_time_start_scenario=`head -2 $file | tail -1 | cut -d' ' -f4 | cut -d[ -f2`
    local date_time_end_scenario=`tail -1 $file | cut -d' ' -f4 | cut -d[ -f2`
    local -i date_time_start_scenario_s=`parse_date $date_time_start_scenario`
    local -i date_time_end_scenario_s=`parse_date $date_time_end_scenario`
    local -i time_delta_scenario_real_life=`expr $date_time_end_scenario_s - $date_time_start_scenario_s`
    echo "Replayed scenario took '$time_delta_scenario_real_life' to complete in real life, lets see if we can do better!"

    # prepare scenario
    local tmp_replay_urls=`prepare_urls $file $url "$strip_term"`
    local -i time_start_scenario=`date +%s`
    siege -v -c$num_clients --reps=once -b -f $tmp_replay_urls
    local -i time_end_scenario=`date +%s`
    local -i time_delta_scenario_stressed=`expr $time_end_scenario - $time_start_scenario`

    display_statistics $time_delta_scenario_real_life $time_delta_scenario_stressed $num_clients

    rm -f $tmp_replay_urls
}

# prints usage and exit
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Replays urls found in given file."
    echo "
Options:
  -u, --url                  URL to attack.
  -s, --strip-term           HTTP query type to strip.
  -f, --file                 access.log file from apache or squid.
  -r, --remote-file          Specify remote access.log (username@server:/path)."
    exit 3
}


# "$@" - parameters, see usage
main() {
    # parse options with getopt
    local tmp_getops=`getopt -o hu:s:f:r: --long help,url:,strip-term:,file:,remote-file: -- "$@"`
    [ $? != 0 ] && usage

    eval set -- "$tmp_getops"
    local url file strip_term

    # parse the options
    while true ; do
        case "$1" in
            -h|--help) usage;;
            -u|--url) url="$2"; shift 2;;
            -s|--strip-term) strip_term="$2"; shift 2;;
            -f|--file) file="$2"; shift 2;;
            -r|--remote-file) remote_file="$2"; shift 2;;
            --) shift; break;;
            *) usage;;
        esac
    done

    # if url is empty, do not proceed
    [ x"$url" = x ] && usage

    # strip query term doesn't exist?
    [ x"$strip_term" = x ] && usage

    # no file? - do not proceed
    [ x"$file" = x ] && [ x"$remote_file" = x ] && usage

    # get remote file from server if specified
    if [ x"$remote_file" != x ]; then
        local file=`get_remote_file $remote_file`
        if [ ! -f $file ]; then
            echo "Could not download remote file '$remote_file'"
            return 0
        fi
    fi

    replay_attack "$url" "$strip_term" "$file"
}

main "$@"
