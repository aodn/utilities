#!/usr/bin/env python3

import argparse
import logging
import os

import boto3
import botocore.exceptions
from retry import retry

# Python 2/3
try:
    import ConfigParser as configparser
except ImportError:
    import configparser

logging.basicConfig(level=logging.INFO, format='%(asctime)s %(levelname)s [%(name)s] %(message)s')
logging.getLogger('botocore').setLevel(logging.ERROR)
logging.getLogger('boto3.resources').setLevel(logging.ERROR)
logging.getLogger('retry').setLevel(logging.ERROR)
LOGGER = logging.getLogger('rotatekey')

DEFAULT_CREDENTIALS_FILE = os.path.expanduser('~/.aws/credentials')


def load_credentials_config(credentials_file):
    config_parser = configparser.SafeConfigParser()
    if not config_parser.read(credentials_file):
        raise RuntimeError('could not load credentials file')

    try:
        _ = config_parser.get('default', 'aws_access_key_id')
        _ = config_parser.get('default', 'aws_secret_access_key')
    except (configparser.NoSectionError, configparser.NoOptionError) as e:
        raise RuntimeError("invalid credentials file: {}".format(e))

    LOGGER.info('loaded current credentials from: {}'.format(credentials_file))

    return config_parser


def update_credentials_file(aws_access_key_id,
                            aws_secret_access_key,
                            config_parser,
                            credentials_file):
    config_parser.set('default', 'aws_access_key_id', aws_access_key_id)
    config_parser.set('default', 'aws_secret_access_key', aws_secret_access_key)
    with open(credentials_file, 'w') as f:
        config_parser.write(f)

    LOGGER.info("updated credentials file '{}' with new key: {}".format(credentials_file, aws_access_key_id))


def get_session_from_key_pair(aws_access_key_id,
                              aws_secret_access_key):
    session = boto3.Session(aws_access_key_id=aws_access_key_id, aws_secret_access_key=aws_secret_access_key)
    LOGGER.info("created AWS session with key: {}".format(aws_access_key_id))
    return session


@retry(exceptions=botocore.exceptions.ClientError, tries=5, delay=1, backoff=2)
def get_current_user_from_session(session, expected_access_key_count=1):
    # add retries to account for IAM 'eventual consistency'
    iam = session.resource('iam')
    user = iam.CurrentUser().user
    access_keys = tuple(user.access_keys.all())
    if len(access_keys) != expected_access_key_count:
        raise RuntimeError('rotate.key expects {} access key to exist (your user has {}).' \
                           'Remove any additional keys and re-run rotate.key'
                           .format(expected_access_key_count, len(access_keys)))
    LOGGER.info("retrieved current user from session: {}".format(user.user_name))
    return user


def get_access_key_from_user(user):
    result = tuple(user.access_keys.limit(count=1))[0]
    return result


def rotate_key(user, credentials_config, credentials_file):
    current_access_key = get_access_key_from_user(user)

    # create and test new key
    new_access_key_pair = user.create_access_key_pair()
    LOGGER.info('created new key pair: {}'.format(new_access_key_pair.id))

    try:
        new_key_pair_session = get_session_from_key_pair(aws_access_key_id=new_access_key_pair.id,
                                                         aws_secret_access_key=new_access_key_pair.secret)
        _ = get_current_user_from_session(session=new_key_pair_session,
                                          expected_access_key_count=2)

        update_credentials_file(aws_access_key_id=new_access_key_pair.id,
                                aws_secret_access_key=new_access_key_pair.secret,
                                config_parser=credentials_config,
                                credentials_file=credentials_file)
    except botocore.exceptions.ClientError:
        # delete the newly created key from IAM
        LOGGER.warn("error occurred, deleting new key: {}".format(new_access_key_pair.id))
        new_access_key_pair.delete()
        raise
    else:
        # delete the previous key from IAM
        LOGGER.info("successfully validated new key, deleting old key: {}".format(current_access_key.id))
        current_access_key.delete()


def main():
    parser = argparse.ArgumentParser(description='Utility to rotate the default AWS IAM access key for a user')
    parser.add_argument('-c', '--credentials-file', default=DEFAULT_CREDENTIALS_FILE,
                        help='path to a valid AWS credentials file')
    parser.add_argument('-r', '--dry-run', action='store_true',
                        help="load and create a session with the current key, but don't make any changes")
    args = parser.parse_args()

    # load current config from file
    current_credentials_config = load_credentials_config(credentials_file=args.credentials_file)
    current_aws_access_key_id = current_credentials_config.get('default', 'aws_access_key_id')
    current_aws_secret_access_key = current_credentials_config.get('default', 'aws_secret_access_key')

    # validate current IAM state
    current_key_pair_session = get_session_from_key_pair(
        aws_access_key_id=current_aws_access_key_id,
        aws_secret_access_key=current_aws_secret_access_key)
    current_user = get_current_user_from_session(current_key_pair_session)
    current_user_access_key = get_access_key_from_user(current_user)
    LOGGER.info('authenticated with current key: {}'.format(current_user_access_key.id))

    if current_user_access_key.id != current_aws_access_key_id:
        raise ValueError('expected IAM key to match config, aborting. {} != {}'.format(current_user_access_key.id,
                                                                                       current_aws_access_key_id))
    if args.dry_run:
        LOGGER.info('--dry-run mode, not rotating key')
    else:
        rotate_key(user=current_user,
                   credentials_config=current_credentials_config,
                   credentials_file=args.credentials_file)


if __name__ == '__main__':
    main()
