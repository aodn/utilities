#!/bin/bash

BACKUP_DIR=restore_cache

# clears given model from backups, before we start fetching
# $1 - model
clear_backups() {
    local model=$1; shift
    test -d $BACKUP_DIR/$model && rm -rf --preserve-root $BACKUP_DIR/$model
}

# fetches a given model from a given host
# $1 - host to restore from
# $2 - model to restore from
# $3 - model to restore to
fetch_backup() {
    local from_host=$1; shift
    local from_model=$1; shift
    local to_model=$1; shift
    test -d $BACKUP_DIR/$from_model || mkdir -p $BACKUP_DIR/$from_model
    bin/fetch_backup.sh -H $from_host -m $from_model -d $BACKUP_DIR/$to_model -- "$@"
}

# if user wishes to run in unattended mode (-u), close stdin and then
# everything running from here will think we don't have a terminal
[[ "$1" = "-u" ]] && exec 0>&-

clear_backups pgsql

fetch_backup 2-aws-syd.emii.org.au pgsql pgsql \
    harvest/aatams_biologging_penguin.dump \
    harvest/acorn_hourly_avg_qc.dump


bin/backup.sh -r -m ./models/pgsql.sh

