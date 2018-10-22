#!/usr/bin/env python
#  -*- coding: utf8 -*-

# derived from https://stackoverflow.com/questions/5663787/upload-folders-from-local-system-to-ftp-using-python-script


import configparser
import os
import getpass
import sys
import time
import paramiko

SLEEP_SECONDS = 10
REMOTE_INCOMING_DIR = "staging"
FILE_KEY = 'path'


def _get_local_files(local_dir, walkdir=False):

    '''Retrieve local files list
        result_list == a list of dictionaries with path and mtime keys. ex: {'path':<filepath>,'mtime':<file last modified time>}
        ignore_dirs == a list of directories to ignore, should not include the base_dir.
        ignore_files == a list of files to ignore.
        ignore_file_ext == a list of extentions to ignore.
    '''

    result_list = []
    ignore_dirs = ['CVS', '.svn', '.git']
    ignore_files = ['.project', '.pydevproject', '.gitignore', '.DS_Store']
    ignore_file_ext = ['.pyc']

    base_dir = os.path.abspath(local_dir)

    for current_dir, dirs, files in os.walk(base_dir):
        for this_dir in ignore_dirs:
            if this_dir in dirs:
                dirs.remove(this_dir)

        sub_dir = current_dir.replace(base_dir, '')
        if not walkdir and sub_dir:
            break

        for this_file in files:
            if this_file not in ignore_files and os.path.splitext(this_file)[-1].lower() not in ignore_file_ext:
                filepath = os.path.join(current_dir, this_file)
                file_monitor_dict = {
                                     FILE_KEY: filepath,
                                     'mtime': os.path.getmtime(filepath)
                                     }
                result_list.append(file_monitor_dict)
    return result_list


def monitor_and_ftp(server,
                      username,
                      password,
                      local_dir,
                    walkdir=False):

    last_files_list = _get_local_files(local_dir, walkdir)

    '''Monitor local files and when an update is found connect and upload'''
    print(f'\nMonitoring changes in ({os.path.abspath(local_dir)}).')
    print('(Use ctrl-c to exit)')

    while True:
        try:

            latest_files_list = _get_local_files(local_dir, walkdir)

            files_to_update = []

            for idx in range(len(latest_files_list)):

                latest_file = latest_files_list[idx]
                latest_filename = latest_file[FILE_KEY]

                # get the matching entry from last_files_list
                item = find_dict_in_list(last_files_list, latest_filename, FILE_KEY)

                if item:

                    # compare last modified times
                    if latest_file['mtime'] > item['mtime']:
                        files_to_update.append(latest_file)

                else:
                    # add the file to the list (new file)
                    files_to_update.append(latest_file)

            if files_to_update:
                print()
                print('Detected NEW or CHANGED file(s), attempting to send ...')
                print()
                is_success = upload_all(server,
                                        username,
                                        password,
                                        local_dir,
                                        files_to_update,
                                        walkdir)
                if not is_success:
                    break

            else:
                print('.')

            last_files_list = latest_files_list[:]  # copy the list to hold
            time.sleep(SLEEP_SECONDS)

        except(KeyboardInterrupt):
            print()
            print('Exiting.')
            break


def find_dict_in_list(list_of_dicts, key, key_match):
    for p in list_of_dicts:
        if p[key_match] == key:
            return p

def upload_all(server,
               username,
               password,
               local_dir,
               files_to_update=None,
               walkdir=False
               ):
    print(f'\nUploading files in ({os.path.abspath(local_dir)})')
    continue_on = False
    server_connect_ok = False

    local_dir = os.path.abspath(local_dir)

    if files_to_update:
        local_files = files_to_update
    else:
        local_files = _get_local_files(local_dir, walkdir)

    if local_files:
        try:
            connection = paramiko.Transport(server,22)
            # todo Authenication method ?
            connection.connect(username=username, password=password)
            sftp = paramiko.SFTPClient.from_transport(connection)

            print(f"Logged in successfully ({server}) as ({username})")

            server_connect_ok = True

        except paramiko.ssh_exception.SSHException as e:
            print(e)
        except paramiko.ssh_exception.NoValidConnectionsError as e:
            print(f"SSH transport is not ready. {str(e.args)}")

        if server_connect_ok:

            try:
                sftp.chdir(REMOTE_INCOMING_DIR)
            except:
                print(f'ERROR: Cannot change CWD to "{REMOTE_INCOMING_DIR}" - so exiting...')
                sys.exit()

            for file_info in local_files:

                source = file_info['path']
                path, filename = os.path.split(source)
                remote_path = source.replace(local_dir, '')
                remote_path = remote_path.replace('\\', '/') # Convert to unix style and strip
                relative_remote_path = remote_path.strip("/")

                if os.path.exists(path):
                    try:

                        # todo compare mtimes with server
                        mkdir_p(sftp, remote_path.replace(filename, ''))
                        response = sftp.put(source, relative_remote_path, callback=None, confirm=True)
                        # todo response contains atime and mtime. Store this ?
                        print(f"Uploaded or checked {relative_remote_path}")
                        continue_on = True
                    except Exception as e:
                        print('ERROR!')
                        print(str(e.args))
                        print()
                else:
                    print(f"WARNING -- File no longer exists, ({source})!")

            connection.close()
            print('Closing Connection')
    else:
        print(f'ERROR -- No files found in ({local_dir}) walkdir={walkdir}')

    return continue_on


def mkdir_p(sftp, remote_directory):

    dir_path = str()
    new_dir = False

    for dir_folder in remote_directory.split("/"):
        if dir_folder == "":
            continue
        dir_path += r"/{0}".format(dir_folder)
        curr_path = dir_path.strip("/")
        try:
            sftp.listdir(curr_path)
        except IOError:
            sftp.mkdir(curr_path)
            new_dir = True

    if new_dir:
            print(f"Created {remote_directory}")


if __name__ == '__main__':
    import argparse

    default_config_file = 'ftp.conf'

    # Create parser, and configure command line options to parse

    parser = argparse.ArgumentParser()
    parser.add_argument("-l", "--local_dir",
                      dest="local_dir",
                      help="[REQUIRED] Local Directory",
                      default=None)
    parser.add_argument("-u", "--username",
                      dest="username",
                      help="[REQUIRED] username",
                      default=None)
    parser.add_argument("-s","--server",
                      dest="server",
                      help="[REQUIRED] Server Address",
                      default=None)
    parser.add_argument("-m",
                      action="store_true",
                      dest="monitor",
                      help="Monitor directory changes",
                      default=None)
    parser.add_argument("-w",
                      action="store_true",
                      dest="walkdir",
                      help="Walk sub directories of the given directory to find files to send.",
                      default=None)

    options = parser.parse_args()

    if (options.username and options.server) or os.path.exists(default_config_file):

        if os.path.exists(default_config_file):
            sys.path.append('.')

            config = configparser.ConfigParser()
            config.read(default_config_file)

            try:
                server = config['ftp_conf']['server'] if options.server is None else options.server
                username = config['ftp_conf']['username'] if options.username is None else options.username
                local_dir = config['ftp_conf']['local_dir'] if options.local_dir is None else options.local_dir
                monitor = config.getboolean('ftp_conf', 'monitor') if options.monitor is None else options.monitor
                walkdir = config.getboolean('ftp_conf', 'walkdir') if options.walkdir is None else options.walkdir

                print(f'\n** Using local config file {default_config_file} (and cmd overrides {options}) **\n')

            except KeyError as e:
                print("ERROR --", str(e.args))
                print()
                print(f'Value(s) missing in %s file!  The following values MUST be included:{default_config_file}')
                print('================================')
                print('server = <server to ftp to>')
                print('username = <Username for access to given server>')
                print('local_dir = <local directory>')
                print('monitor = True/False')
                print('walkdir == True/False')
                print('================================')
                sys.exit()
        else:
            server = options.server
            username = options.username
            local_dir = options.local_dir
            monitor = options.monitor
            walkdir = options.walkdir

            print(f'\n** Using: {options} **\n')

        # get the user password
        prompt = f'Password for ({username}@{server}) ?: '

        if os.isatty(sys.stdin.fileno()):
            p = getpass.getpass(prompt)
        else:
            p = sys.stdin.readline().rstrip()
            #p = raw_input(prompt).rstrip()

        if monitor:
            try:
                upload_all(server, username, p, local_dir, [], walkdir)
                monitor_and_ftp(server, username, p,local_dir, walkdir)
            except KeyboardInterrupt:
                print('Exiting...')
        else:
            try:
                upload_all(server, username, p, local_dir, [], walkdir)
            except KeyboardInterrupt:
                print('Exiting...')

    else:
        print('ERROR -- Required option not given!')
        print(__doc__)
        print()
        parser.print_help()
