#!/bin/bash

#
# Copyright (C) 2013 Dan Fruehauf <malkodan@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#

######################
# CORE FUNCTIONALITY #
######################
# test logging via log::logfile
test_module_log_logfile() {
	# build a tmp model
	local backup_name="$RANDOM"
	local tmp_model=`mktemp`
	local tmp_log_file1=`mktemp -u`
	local tmp_log_file2=`mktemp -u`
	local tmp_log_file3=`mktemp -u`
	cat > $tmp_model <<EOF
log() {
	logfile $tmp_log_file1
	logfile $tmp_log_file2
	logfile $tmp_log_file3
}
EOF
	$BACKUP_EXEC -m $tmp_model >& /dev/null
	assertTrue 'exit status of backup' "[ $? -eq 0 ]"

	assertTrue 'log file created and used' "[ -f $tmp_log_file1 ]"
	assertTrue 'log file created and used' "[ -f $tmp_log_file2 ]"
	assertTrue 'log file created and used' "[ -f $tmp_log_file3 ]"
	rm -f $tmp_log_file1 $tmp_log_file2 $tmp_log_file3 $tmp_model
}

# test a bogus model file passed
test_invalid_model() {
	# build a tmp model
	local backup_name="$RANDOM"
	local tmp_model=`mktemp`
	cat > $tmp_model <<EOF
p[INCORRECT BASH SYNTAX((
EOF
	$BACKUP_EXEC -m $tmp_model >& /dev/null
	assertFalse 'exit status of backup' "[ $? -eq 0 ]"

	rm -f $tmp_model
}

###########
# MODULES #
###########

###########
# EXECUTE #
###########
# test backup::execute backup and restore
test_module_backup_execute() {
	# build a tmp model
	local backup_name="$RANDOM"
	local directory_to_backup=`ls -1 $BACKUP_SOURCE | head -1`
	local tmp_model=`mktemp`
	local tmp_file_to_touch=`mktemp -u`
	cat > $tmp_model <<EOF
backup() {
	tar $backup_name $BACKUP_SOURCE/$directory_to_backup
	execute "touch a temporary file" touch $tmp_file_to_touch
}
store() {
	cp $BACKUP_DEST
}
EOF
	$BACKUP_EXEC -m $tmp_model >& /dev/null
	assertTrue 'exit status of backup' "[ $? -eq 0 ]"

	assertTrue 'execute plugin failed' "test -f $tmp_file_to_touch"

	# remove tmp_file_to_touch before testing restore
	rm -f $tmp_file_to_touch

	# restore!
	$BACKUP_EXEC -r -m $tmp_model >& /dev/null
	assertTrue 'exit status of backup' "[ $? -eq 0 ]"

	# make sure file exists again
	assertTrue 'execute plugin failed' "test -f $tmp_file_to_touch"

	# cleanup
	rm -f $tmp_model $tmp_file_to_touch
}


#######
# TAR #
#######
# test backup::tar backup and restore
test_module_backup_tar() {
	# build a tmp model
	local backup_name="$RANDOM"
	local directory_to_backup=`ls -1 $BACKUP_SOURCE | head -1`
	local tmp_model=`mktemp`
	cat > $tmp_model <<EOF
backup() {
	tar $backup_name $BACKUP_SOURCE/$directory_to_backup
}

store() {
	cp $BACKUP_DEST
}
EOF
	$BACKUP_EXEC -m $tmp_model >& /dev/null
	assertTrue 'exit status of backup' "[ $? -eq 0 ]"

	assertTrue 'tar backup failed' "test -f ${BACKUP_DEST}/*/$backup_name.tar"

	# remove source directory (it'll come back from backup)
	mv $BACKUP_SOURCE/$directory_to_backup $BACKUP_SOURCE/$directory_to_backup.orig

	# restore!
	$BACKUP_EXEC -r -m $tmp_model >& /dev/null
	assertTrue 'exit status of backup' "[ $? -eq 0 ]"
	rm -f $tmp_model

	# take a diff between directories after restore, they should be identical
	local -i diff_lines=`diff -urN $BACKUP_SOURCE/$directory_to_backup.orig $BACKUP_SOURCE/$directory_to_backup | wc -l`

	assertTrue 'restore not identical to backup' "[ $diff_lines -eq 0 ]"
}

# test backup::tar backup and exclude
test_module_backup_tar_excludes() {
	# build a tmp model
	local backup_name="$RANDOM"
	local directory_to_backup=`ls -1 $BACKUP_SOURCE | head -1`
	local file_to_exclude=$BACKUP_SOURCE/$directory_to_backup/EXCLUDED
	echo "this file is excluded" > $file_to_exclude
	local tmp_model=`mktemp`
	cat > $tmp_model <<EOF
backup() {
	tar $backup_name $BACKUP_SOURCE/$directory_to_backup --exclude=EXCLUDED
}

store() {
	cp $BACKUP_DEST
}
EOF

	$BACKUP_EXEC -m $tmp_model >& /dev/null
	assertTrue 'exit status of backup' "[ $? -eq 0 ]"

	assertTrue 'tar backup failed' "test -f ${BACKUP_DEST}/*/$backup_name.tar"

	# remove source directory (it'll come back from backup)
	mv $BACKUP_SOURCE/$directory_to_backup $BACKUP_SOURCE/$directory_to_backup.orig

	# restore!
	$BACKUP_EXEC -r -m $tmp_model >& /dev/null
	assertTrue 'exit status of backup' "[ $? -eq 0 ]"
	rm -f $tmp_model

	assertFalse 'excluded file found after restore' "[ -f $file_to_exclude ]"
}

# test backup::tar backup and sudo
test_module_backup_tar_sudo() {
	# build a tmp model
	local backup_name="$RANDOM"
	local directory_to_backup=`ls -1 $BACKUP_SOURCE | head -1`
	local tmp_model=`mktemp`
	cat > $tmp_model <<EOF
backup() {
	tar $backup_name --sudo $BACKUP_SOURCE/$directory_to_backup
}

store() {
	cp $BACKUP_DEST
}
EOF
	$BACKUP_EXEC -m $tmp_model >& /dev/null
	assertTrue 'exit status of backup' "[ $? -eq 0 ]"

	assertTrue 'tar backup failed' "test -f ${BACKUP_DEST}/*/$backup_name.tar"

	# remove source directory (it'll come back from backup)
	mv $BACKUP_SOURCE/$directory_to_backup $BACKUP_SOURCE/$directory_to_backup.orig

	# restore!
	$BACKUP_EXEC -r -m $tmp_model >& /dev/null
	assertTrue 'exit status of backup' "[ $? -eq 0 ]"
	rm -f $tmp_model

	# take a diff between directories after restore, they should be identical
	local -i diff_lines=`diff -urN $BACKUP_SOURCE/$directory_to_backup.orig $BACKUP_SOURCE/$directory_to_backup | wc -l`

	assertTrue 'restore not identical to backup' "[ $diff_lines -eq 0 ]"
}

#########
# RSYNC #
#########
# test backup::rsync backup
test_module_backup_rsync() {
	# build a tmp model
	local backup_name="$RANDOM"
	local tmp_model=`mktemp`
	cat > $tmp_model <<EOF
backup() {
	rsync $backup_name $BACKUP_SOURCE/backup
}

store() {
	cp $BACKUP_DEST
}
EOF
	$BACKUP_EXEC -m $tmp_model >& /dev/null
	assertTrue 'exit status of backup' "[ $? -eq 0 ]"
	rm -f $tmp_model

	local backup_timestamp=`ls -1 $BACKUP_DEST`
	local -i diff_lines=`diff -urN $BACKUP_SOURCE $BACKUP_DEST/$backup_timestamp/$backup_name | wc -l`

	assertTrue 'rsync not identical to source' "[ $diff_lines -eq 0 ]"
}


########
# GZIP #
########
# test process::bzip backup and restore
test_module_process_gzip() {
	# build a tmp model
	local backup_name="$RANDOM"
	local directory_to_backup=`ls -1 $BACKUP_SOURCE | head -1`
	local tmp_model=`mktemp`
	cat > $tmp_model <<EOF
backup() {
	tar $backup_name $BACKUP_SOURCE/$directory_to_backup
}

process() {
	gzip '.*'
}

store() {
	cp $BACKUP_DEST
}
EOF
	$BACKUP_EXEC -m $tmp_model >& /dev/null
	assertTrue 'exit status of backup' "[ $? -eq 0 ]"

	assertTrue 'tar.gz backup failed' "test -f ${BACKUP_DEST}/*/$backup_name.tar.gz"

	# remove source directory (it'll come back from backup)
	mv $BACKUP_SOURCE/$directory_to_backup $BACKUP_SOURCE/$directory_to_backup.orig

	# restore!
	$BACKUP_EXEC -r -m $tmp_model >& /dev/null
	assertTrue 'exit status of backup' "[ $? -eq 0 ]"
	rm -f $tmp_model

	# take a diff between directories after restore, they should be identical
	local -i diff_lines=`diff -urN $BACKUP_SOURCE/$directory_to_backup.orig $BACKUP_SOURCE/$directory_to_backup | wc -l`

	assertTrue 'restore not identical to backup' "[ $diff_lines -eq 0 ]"
}

#########
# BZIP2 #
#########
# test process::bzip2 backup and restore
test_module_process_bzip2() {
	# build a tmp model
	local backup_name="$RANDOM"
	local directory_to_backup=`ls -1 $BACKUP_SOURCE | head -1`
	local tmp_model=`mktemp`
	cat > $tmp_model <<EOF
backup() {
	tar $backup_name $BACKUP_SOURCE/$directory_to_backup
}

process() {
	bzip2 '.*'
}

store() {
	cp $BACKUP_DEST
}
EOF
	$BACKUP_EXEC -m $tmp_model >& /dev/null
	assertTrue 'exit status of backup' "[ $? -eq 0 ]"

	assertTrue 'tar.bz2 backup failed' "test -f ${BACKUP_DEST}/*/$backup_name.tar.bz2"

	# remove source directory (it'll come back from backup)
	mv $BACKUP_SOURCE/$directory_to_backup $BACKUP_SOURCE/$directory_to_backup.orig

	# restore!
	$BACKUP_EXEC -r -m $tmp_model >& /dev/null
	assertTrue 'exit status of backup' "[ $? -eq 0 ]"
	rm -f $tmp_model

	# take a diff between directories after restore, they should be identical
	local -i diff_lines=`diff -urN $BACKUP_SOURCE/$directory_to_backup.orig $BACKUP_SOURCE/$directory_to_backup | wc -l`

	assertTrue 'restore not identical to backup' "[ $diff_lines -eq 0 ]"
}

######
# XZ #
######
# test process::xz backup and restore
test_module_process_xz() {
	# build a tmp model
	local backup_name="$RANDOM"
	local directory_to_backup=`ls -1 $BACKUP_SOURCE | head -1`
	local tmp_model=`mktemp`
	cat > $tmp_model <<EOF
backup() {
	tar $backup_name $BACKUP_SOURCE/$directory_to_backup
}

process() {
	xz '.*'
}

store() {
	cp $BACKUP_DEST
}
EOF
	$BACKUP_EXEC -m $tmp_model >& /dev/null
	assertTrue 'exit status of backup' "[ $? -eq 0 ]"

	assertTrue 'tar.xz backup failed' "test -f ${BACKUP_DEST}/*/$backup_name.tar.xz"

	# remove source directory (it'll come back from backup)
	mv $BACKUP_SOURCE/$directory_to_backup $BACKUP_SOURCE/$directory_to_backup.orig

	# restore!
	$BACKUP_EXEC -r -m $tmp_model >& /dev/null
	assertTrue 'exit status of backup' "[ $? -eq 0 ]"
	rm -f $tmp_model

	# take a diff between directories after restore, they should be identical
	local -i diff_lines=`diff -urN $BACKUP_SOURCE/$directory_to_backup.orig $BACKUP_SOURCE/$directory_to_backup | wc -l`

	assertTrue 'restore not identical to backup' "[ $diff_lines -eq 0 ]"
}

#########
# SPLIT #
#########
# test process::split backup and restore
test_module_process_split() {
	# build a tmp model
	# have at least 2 files here as we should test reconstruction of more than
	# one file in the backup directory when performing a restore
	local backup_name1="$RANDOM"
	local backup_name2="$RANDOM"
	local directory_to_backup=`ls -1 $BACKUP_SOURCE | head -1`
	local tmp_model=`mktemp`
	# max size in bytes to split files
	local -i split_max_size=30000
	cat > $tmp_model <<EOF
backup() {
	tar $backup_name1 $BACKUP_SOURCE/$directory_to_backup
	tar $backup_name2 $BACKUP_SOURCE/$directory_to_backup
}

process() {
	split '.*' $split_max_size
}

store() {
	cp $BACKUP_DEST
}
EOF
	$BACKUP_EXEC -m $tmp_model >& /dev/null
	assertTrue 'exit status of backup' "[ $? -eq 0 ]"

	local -i files_larger_than_max_size=`find ${BACKUP_DEST} -size +${split_max_size}c | wc -l`
	assertTrue "files larger than $split_max_size exist" "[ $files_larger_than_max_size -eq 0 ]"

	# remove source directory (it'll come back from backup)
	mv $BACKUP_SOURCE/$directory_to_backup $BACKUP_SOURCE/$directory_to_backup.orig

	# restore!
	$BACKUP_EXEC -r -m $tmp_model >& /dev/null
	assertTrue 'exit status of backup' "[ $? -eq 0 ]"
	rm -f $tmp_model

	# take a diff between directories after restore, they should be identical
	local -i diff_lines=`diff -urN $BACKUP_SOURCE/$directory_to_backup.orig $BACKUP_SOURCE/$directory_to_backup | wc -l`

	assertTrue 'restore not identical to backup' "[ $diff_lines -eq 0 ]"
}

#######
# GPG #
#######
# test process::gpg backup (no restore)
test_module_process_gpg() {
	local gpg_test_key=`mktemp`
	local gpg_test_key_default=gpg_test_key.asc
	if [ -f $gpg_test_key_default ]; then
		cp -a $gpg_test_key_default $gpg_test_key
	else
		# try to export key
		# skip test if key doesn't exist
		gpg --export  --armor > $gpg_test_key
		[ $? -ne 0 ] && echo "Skipping test 'test_module_process_gpg'" && return
	fi

	assertTrue "gpg key not found" "test -f $gpg_test_key"

	# build a tmp model
	local backup_name="$RANDOM"
	local directory_to_backup=`ls -1 $BACKUP_SOURCE | head -1`
	local tmp_model=`mktemp`
	cat > $tmp_model <<EOF
backup() {
	tar $backup_name $BACKUP_SOURCE/$directory_to_backup
}

process() {
	gpg '.*\.tar' $gpg_test_key
}

store() {
	cp $BACKUP_DEST
}
EOF
	$BACKUP_EXEC -m $tmp_model >& /dev/null
	assertTrue 'exit status of backup' "[ $? -eq 0 ]"

	# encryption succeded?
	assertTrue 'gpg encryption failed' "test -f ${BACKUP_DEST}/*/$backup_name.tar.gpg"

	# make sure all the files are just encrypted data and not tar
	local num_files_that_are_not_data=`find $BACKUP_DEST -type f -exec file {} \; | grep -v ': data$' | wc -l`
	assertTrue 'non encrypted files found' "[ $num_files_that_are_not_data -eq 0 ]"

	# cleanup
	rm -f $tmp_model $gpg_test_key
}


#########
# CYCLE #
#########
# test store::cycle backup
test_module_store_cycle() {
	# build a tmp model
	local -i cycle_backups=2
	local backup_name="$RANDOM"
	local tmp_model=`mktemp`
	cat > $tmp_model <<EOF
backup() {
	rsync $backup_name $BACKUP_SOURCE/backup
}

store() {
	cp $BACKUP_DEST
	cycle $BACKUP_DEST $cycle_backups
}
EOF

	# have at least $cycle_backups+3 in directory
	local -i backups_to_procude=`expr $cycle_backups + 3`
	for i in `seq 1 $backups_to_procude`; do
		$BACKUP_EXEC -m $tmp_model >& /dev/null
		assertTrue 'exit status of backup' "[ $? -eq 0 ]"
	done
	local -i backups_nr=`ls -1 $BACKUP_DEST | wc -l`
	assertTrue "cycling broken in directory, have $backups_nr, expected: $cycle_backups" \
		"[ $backups_nr -eq $cycle_backups ]"

	rm -f $tmp_model
}

#################
# NAGIOS_STATUS #
#################
# test notify::nagios_status backup
test_module_notify_nagios_status() {
	# build a tmp model
	local backup_name="$RANDOM"
	local directory_to_backup=`ls -1 $BACKUP_SOURCE | head -1`
	local tmp_model=`mktemp`
	local model_name=`basename $tmp_model`
	local tmp_status_dir=`mktemp -d`
	cat > $tmp_model <<EOF
backup() {
	tar $backup_name $BACKUP_SOURCE/$directory_to_backup
}
notify() {
	nagios_status $tmp_status_dir
}
EOF

	# backup!
	$BACKUP_EXEC -m $tmp_model >& /dev/null
	assertTrue 'exit status of backup' "[ $? -eq 0 ]"

	# compare success message
	local status_message=`cat $tmp_status_dir/$model_name`
	assertTrue 'nagios_status message' \
		"[ '$status_message' = 'OK: Backup successful' ]"

	# create a backup model that'll fail
	cat > $tmp_model <<EOF
backup() {
	tar $backup_name /non-existing-directory
}
notify() {
	nagios_status $tmp_status_dir
}
EOF

	# backup (should fail here!)
	$BACKUP_EXEC -m $tmp_model >& /dev/null
	assertFalse 'exit status of backup' "[ $? -eq 0 ]"

	local status_message=`cat $tmp_status_dir/$model_name`
	assertTrue 'nagios_status message' \
		"[ '$status_message' = 'Critical: Backup failed for: backup::tar' ]"

	# cleanup
	rm -f $tmp_model
	rm -f $tmp_status_dir/$model_name
	rmdir $tmp_status_dir
}

##################
# SETUP/TEARDOWN #
##################

oneTimeSetUp() {
	# load include to test
	BACKUP_EXEC=`dirname $0`/backup.sh
	BACKUP_SOURCE_SETUP=`mktemp -d`
	mkdir -p $BACKUP_SOURCE_SETUP
	# TODO
	#(cd $BACKUP_SOURCE_SETUP && git clone git@github.com:danfruehauf/backup.git)
	(mkdir -p $BACKUP_SOURCE_SETUP/backup && cp -a ./* $BACKUP_SOURCE_SETUP/backup/)

	# AWS settings (for S3)
	source aws-credentials.sh
}

oneTimeTearDown() {
	rm -rf --preserve-root $BACKUP_SOURCE_SETUP
}

setUp() {
	BACKUP_DEST=`mktemp -d`
	BACKUP_SOURCE=`mktemp -d`
	cp -a $BACKUP_SOURCE_SETUP/* $BACKUP_SOURCE/
}

tearDown() {
	rm -rf --preserve-root $BACKUP_DEST $BACKUP_SOURCE
}

# load and run shUnit2
. /usr/share/shunit2/shunit2
