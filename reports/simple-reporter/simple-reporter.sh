#!/bin/bash

# example usage:
# * stuff all your sql reports in /tmp/sql for instance
# * execute: ./simple-reporter.sh DB_NAME /tmp/sql your.email@address

declare -r FROM="Mr. Report"
declare -r FROM_EMAIL="reports@emii.org.au"

# run sql
# $1 - database to run query against
# $2 - sql file to run
# $3 - result file
run_sql() {
    local db=$1; shift
    local sql_file=$1; shift
    local result_file=$1; shift

    local tmp_sql_file=`mktemp`
    echo "COPY ("                       > $tmp_sql_file
    cat $sql_file                      >> $tmp_sql_file
    echo ") TO STDOUT WITH CSV HEADER" >> $tmp_sql_file
    chown postgres $tmp_sql_file

    su - postgres -c "cat $tmp_sql_file | psql $db" > $result_file
    local -i retval=$?

    rm -f $tmp_sql_file
    return $retval
}

# emails a file
# $1 - email recipient
# $2 - email subject
# $3 - attachment
mail_file() {
    local recipient="$1"; shift
    local subject="$1"; shift
    local attachment=$1; shift

    mutt -n -e "set realname='$FROM' from='$FROM_EMAIL' use_envelope_from=yes" \
        -a $attachment -s "$subject" -- $recipient < /dev/null
}

# run a single report
# $1 - db to run report against
# $2 - sql file for report
# $3 - subject of report
# $4 - email recipient
run_report() {
    local db=$1; shift
    local sql_file=$1; shift
    local mail_subject="$1"; shift
    local mail_to="$1"; shift

    local tmp_dir=`mktemp -d`
    local tmp_result="$tmp_dir/$mail_subject.csv"

    run_sql $db $sql_file $tmp_result && \
        mail_file "$mail_to" "$mail_subject" $tmp_result
    local -i retval=$?

    rm -f $tmp_result; rmdir $tmp_dir
    return $retval
}

# main
# $1 - db to run report against
# $2 - sql directory containing sql for reports
# $3 - email recipient
main() {
    local db=$1; shift
    local reports_dir=$1; shift
    local mail_to="$1"; shift

    local sql_file
    for sql_file in $reports_dir/*; do
        local mail_subject=`basename $sql_file | cut -d. -f1`
        run_report $db $sql_file $mail_subject $mail_to
    done
}

main "$@"
