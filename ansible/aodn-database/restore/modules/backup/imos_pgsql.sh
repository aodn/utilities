#!/bin/bash

# never restore any of those schemas, even if they are being backed up!
declare -r IGNORED_SCHEMAS="chef admin postgis"

# returns true if schema should be ignored
# $1 - schema name
_ignore_schema() {
    local schema=$1; shift
    echo $IGNORED_SCHEMAS | grep -q "\b$schema\b"
}

# disconnects all users accessing the given database
# $1 - database name
# $2 - host
# $3 - port
_disconnect_all_users() {
    local database_name=$1; shift

    logger_warn "Disconnecting all users from database '$database_name'"
    psql -d $database_name -t -c \
        "select pg_terminate_backend(pg_stat_activity.pid) from pg_stat_activity where pg_stat_activity.datname = '$database_name' and pid <> pg_backend_pid();"
}

# returns a list of extensions for given schema
# $1 - database name
# $2 - host
# $3 - port
# $4 - schema
_get_extensions_on_schema() {
    local database_name=$1; shift
    local schema=$1; shift

    psql -d $database_name -t -c \
        "select e.extname as extension from pg_catalog.pg_extension e \
            left join pg_catalog.pg_namespace n \
            on n.oid = e.extnamespace where n.nspname = '$schema'" | xargs
}

# restore a pgsql database
# $1 - database_name
# $2 - host
# $3 - port
# $4 - username
# $5 - password
restore() {
    local database_name=$1; shift
    local host=$1; shift
    local -i port=$1; shift
    local username=$1; shift
    local password=$1; shift

    logger_info "Restoring database '$database_name'"

    export PGHOST="$host"
    export PGPORT="$port"
    export PGUSER="$username"
    export PGPASSWORD="$password"

    local -i retval=0

    local schema_file

    for schema_file in `ls -1 $_BACKUP_DEST/$database_name`; do
        local schema=`echo $schema_file | cut -d. -f1`

        if ! _ignore_schema $schema; then
            _disconnect_all_users $database_name 2> /dev/null

            # get all extensions
            extensions=`_get_extensions_on_schema $database_name $schema`
            logger_info "Probed extensions '$extensions' on database '$database_name'"

            # recreate the schema
            logger_info "Dropping and creating schema '$schema'"
            psql -d $database_name -c "drop schema $schema cascade; create schema $schema"

            # restore extensions after scehma drop
            local extension
            for extension in $extensions; do
                logger_info "Installing extension '$extension'"
                psql -d $database_name -c "create extension if not exists $extension schema $schema"
            done

            logger_info "Restoring schema '$schema'"

            # create a table of contents, which excludes the 'CREATE SCHEMA' directive
            local tmp_toc=`mktemp`
            chmod 644 $tmp_toc
            local absolute_schema_file=$_BACKUP_DEST/$database_name/$schema_file
            pg_restore --list $absolute_schema_file | grep -v SCHEMA > $tmp_toc

            # note that user postgres will not have permissions to read the schema dump file
            cat $absolute_schema_file | \
                pg_restore -d $database_name --use-list=$tmp_toc || \
                logger_fatal "Failed to restore schema '$schema' from database '$database_name'"

            rm -f $tmp_toc
            let retval+=$?
        else
            logger_info "Ignoring schema '$schema'"
        fi
    done

return $retval
}
