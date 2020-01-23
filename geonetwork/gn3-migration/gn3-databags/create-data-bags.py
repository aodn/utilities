#!/usr/bin/env python

import errno
import os
import sys

import requests
import xmltodict
from argparse_prompt import PromptParser
from jinja2 import Environment, FileSystemLoader
from urllib.parse import urlparse


def log_error(message):
    if type(message) == str:
        message = [message]

    for msg in message:
        sys.stderr.write("{0}\n".format(msg))

    sys.exit(1)


def log_info(message):
    if type(message) == str:
        message = [message]

    for msg in message:
        sys.stdout.write("{0}\n".format(msg))


def mkdir_p(*args):
    for path in args:
        try:
            os.makedirs(path)
        except OSError as exc:  # Python >2.5
            if exc.errno == errno.EEXIST and os.path.isdir(path):
                pass
            else:
                raise


def parse_args():
    parser = PromptParser(description='Create gn3 databags')
    parser.add_argument('-i',
                        '--instance',
                        dest='geonetwork_instance',
                        help='geonetwork 2 instance '
                             'e.g. https://catalogue-imos.aodn.org.au')
    parser.add_argument('-u',
                        '--username',
                        dest='username',
                        help='username for basic auth')
    parser.add_argument('-p',
                        '--password',
                        dest='password',
                        help='password for basic auth. '
                             'If a username is given but not a password, the '
                             'password will be prompted for.',
                        secure=True)
    parser.add_argument('-o',
                        '--output-directory',
                        default='.',
                        dest='output_directory',
                        help='directory at which to backup the repositories')
    return parser.parse_args()


def parse_response(geonetwork_instance, service, username, password):
    url = '{}/geonetwork/srv/eng/{}'.format(geonetwork_instance, service)
    resp = requests.get(url, auth=(username, password))
    return xmltodict.parse(resp.content)


def get_name(groups):
    def get_group_name(id):
        for group in groups:
            if group['id'] == id:
                return group['name']

        # System groups aren't returned by api - just hardcode translation
        # for ones used here - they always have the same id
        if id == '-1':
            return 'Guest'

        return None

    return get_group_name


def sanitise(name):
    return name.lower().replace(' ', '_').replace('@','_')


def main():
    args = parse_args()

    # Create output directories if required

    output_directory = os.path.realpath(args.output_directory)
    groups_directory = os.path.join(output_directory, 'imos_webapps_geonetwork_groups')
    users_directory = os.path.join(output_directory, 'imos_webapps_geonetwork_users')

    if not os.path.isdir(groups_directory):
        log_info('Create groups directory {0}'.format(groups_directory))
        mkdir_p(groups_directory)

    if not os.path.isdir(users_directory):
        log_info('Create users directory {0}'.format(users_directory))
        mkdir_p(users_directory)

    # Use start of source instance host name as the prefix for the databags created

    host_name = urlparse(args.geonetwork_instance).hostname
    prefix = host_name.split('.')[0]

    # Configure jinja2 templating

    env = Environment(
        loader=FileSystemLoader('templates'),
        keep_trailing_newline=True,
        trim_blocks=True,
        lstrip_blocks=True
    )

    # Create group data bags from source instance groups

    group_template = env.get_template('group.json.j2')

    log_info("Retrieving groups...")
    response = parse_response(args.geonetwork_instance, 'xml.group.list', args.username, args.password)
    groups = response['response']['record']

    log_info("Creating group databags...")
    for group in groups:
        log_info("Creating group databag for {}...".format(group['name']))
        output_file = os.path.join(groups_directory, "{}-{}.json".format(prefix, sanitise(group['name'])))
        content = group_template.render(group=group)
        with open(output_file, "w") as fh:
            fh.write(content)

    # Create user data bags from source instance users

    env.filters['toname'] = get_name(groups) # translates group id's to group names
    user_template = env.get_template('user.json.j2')

    log_info("Retrieving users...")
    response = parse_response(args.geonetwork_instance, 'xml.user.list', args.username, args.password)
    users = response['response']['record']

    log_info("Creating user databags...")
    for user in users:
        log_info("Creating user databag for {}...".format(user['username']))
        if user['profile'] == 'Administrator':
            # groups don't need to be specified for administrators
            user_groups = None
        else:
            # retrieve groups user belongs to using information used by the user edit page (! tells geonetwork to return
            # this information instead of the edit page itself)
            log_info("Retrieving groups for {}...".format(user['username']))
            response = parse_response(args.geonetwork_instance, 'user.edit!?id={}'.format(user['id']),
                                      args.username, args.password)
            groups_response = response['root']['response']['groups']

            # the jinja template expects a list of user groups
            if groups_response:
                if isinstance(groups_response['id'], list):
                    user_groups = groups_response['id']
                else:
                    user_groups = [groups_response['id']]
            else:
                user_groups = []

        output_file = os.path.join(users_directory, "{}-{}.json".format(prefix, sanitise(user['username'])))
        content = user_template.render(user=user, user_groups=user_groups)
        with open(output_file, "w") as fh:
            fh.write(content)


if __name__ == '__main__':
    main()
