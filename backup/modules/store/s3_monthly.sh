#!/bin/bash

#
# Monthly backup to s3.
#
# Find the first backup file for the current month in the provided s3 path & copy it to the monthly
# backup location.
# $@ - s3 config file location
# $1 - s3 backup path
# $2 - monthly backup s3 path
backup() {
    backup_s3_path=$1; shift
    monthly_backup_s3_path=$1; shift
    s3cmd_options=$@

    if [[ x"${backup_s3_path}" = "x" ]]; then
        echo "No S3 backup path is specified!!"
        return 1
    fi

    if [[ x"${monthly_backup_s3_path}" = "x" ]]; then
        echo "No S3 monthly backup path is specified!!"
        return 1
    fi

    # ensure trailing slashes on S3 paths
    [[ "${backup_s3_path}" != */ ]] && backup_s3_path="${backup_s3_path}/"
    [[ "${monthly_backup_s3_path}" != */ ]] && monthly_backup_s3_path="${monthly_backup_s3_path}/"

    # calculate monthly backup path, with the format: monthly_backup_root/year/month
    this_monthly_backup_s3_path="${monthly_backup_s3_path}$(date +%Y)/$(date +%m)/"

    # check whether there is already a monthly backup for this month
    monthly_backups=$(s3cmd ${s3cmd_options} ls s3://${this_monthly_backup_s3_path} | awk '{print $2}' | sort -r -k 1,2)
    if [[ -n ${monthly_backups} ]]; then
        echo Existing monthly backups found, exiting...
        return 0
    fi

    # determine the latest backup to be copied and retained as the monthly backup
    latest_backup=$(s3cmd ${s3cmd_options} ls s3://${backup_s3_path} | awk '{print $2}' | sort -r -k 1,2 | head -1)

    # execute the copy command to sync the latest backup to the monthly path
    command_string="s3cmd ${s3cmd_options} cp --recursive ${latest_backup} s3://${this_monthly_backup_s3_path}"
    command_output=$(eval ${command_string})
    retval=$?
    echo Ran command.  Output: ${command_output}

    return ${retval}
}


# not implemented for s3_monthly
restore() {
	return 1
}
