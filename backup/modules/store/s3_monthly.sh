#!/bin/bash

#
# Monthly backup to s3.
#
# Find the first backup file for the current month in the provided s3 path & copy it to the monthly
# backup location.
# $1 - s3 config file
# $2 - s3 backup path
# $3 - monthly backup s3 path
backup() {
    s3cfg=$@
    backup_s3_path=$1
    monthly_backup_s3_path=$2

    echo $s3cfg
    echo $backup_s3_path
    echo $monthly_backup_s3_path

    if [ x"backup_s3_path" = x ]; then
        echo "No S3 backup path is specified!!"
        return 1
    fi

    if [ x"monthly_backup_s3_path" = x ]; then
        echo "No S3 monthly backup path is specified!!"
        return 1
    fi

    #  List the files in the backup location - and if the latest file in the backup location is the first for the month
    #  then copy that file to the monthly backup location.
    IFS=$'\n' # split on newline
    set -o noglob
    # s3cmd ls output sorted into descending date order
    backup_location_contents=$(s3cmd --config=$s3cfg ls s3://$backup_s3_path | tr -s " " | sort -r -k 1,2)

    #  Current date
    date_now=$(date -I)
    now_month=$(cut -d'-' -f2 <<<$date_now)
    now_year=$(cut -d'-' -f1 <<<$date_now)
    echo Now month/year: $now_month/$now_year

    #  Determine if there is a single file from this month - ie: the first for this month
    files_this_month=0
    first_file_filename=""

    for line in $backup_location_contents
    do
      date_string=$(cut -d' ' -f1 <<<$line)
      month=$(cut -d'-' -f2 <<<$date_string)
      year=$(cut -d'-' -f1 <<<$date_string)
      if [ $year -eq $now_year ] && [ $month -eq $now_month ]
      then
        ((files_this_month++))
        if [ -z "$first_file_filename" ]
        then
            first_file_filename=$(cut -d' ' -f4 <<<$line)
        fi

        echo month/year: $month/$year : $line
        echo files_this_month=$files_this_month

        if [ $files_this_month -gt 1 ]
        then
            #  Found a second file from the month
            #  ie: this isn't this first file for this month
            break
        fi
      fi
    done

    #  If we found the first file for the month - move it to the monthly backup location
    if [ $files_this_month -eq 1 ]
    then
        echo Found the first file from this month.  Filename: $first_file_filename
        command_output=`s3cmd --config=$s3cfg cp $first_file_filename s3://$monthly_backup_s3_path`
        echo Ran command.  Output: $command_output
    fi
}


# not implemented for s3_monthly
restore() {
	return 1
}