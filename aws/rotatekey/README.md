## rotatekey

This utility is used to rotate a user's default AWS key pair in a single command.

### Installation

1. Clone this repo
    ``` bash
    git clone https://github.com/aodn/utilities.git
    ```
1. Ensure that you have boto3 installed
    ``` bash
    pip install --upgrade boto3
    ```    

**OPTIONAL:** do a sparse-checkout of this bloated repository so you only grab this utility:
1. Clone this repo
    ``` bash
    git clone --depth 1 --filter=blob:none --no-checkout git@github.com:aodn/utilities.git
    ```
2. Next, cd into the repo, enable sparse-checkout and configure sparse-checkout to only include the folder we care about
    ``` bash
    cd utilities
    git sparse-checkout init
    git sparse-checkout set aws/rotatekey
    ```

### Usage
```bash
usage: rotatekey.py [-h] [-c CREDENTIALS_FILE] [-r]

Utility to rotate the default AWS IAM access key for a user

optional arguments:
  -h, --help            show this help message and exit
  -c CREDENTIALS_FILE, --credentials-file CREDENTIALS_FILE
                        path to a valid AWS credentials file
  -r, --dry-run         load and create a session with the current key, but
                        don't make any changes
```

The simplest use case is to run with no parameters, which will cause the script to:
1. authenticate to AWS using your current "default" credentials
1. create a second key
1. validate the new key
1. update your AWS credentials file (usually ~/.aws/credentials) with the new key pair
1. remove your old key

```bash
$ cd aws/rotatekey/
$ ./rotatekey.py
```

```
2018-11-26 15:39:58,680 INFO [rotatekey] loaded current credentials from: /home/joebloggs/.aws/credentials
2018-11-26 15:39:58,682 INFO [rotatekey] created AWS session with key: MY_OLD_ACCESS_KEY
2018-11-26 15:40:00,452 INFO [rotatekey] retrieved current user from session: joebloggs
2018-11-26 15:40:00,753 INFO [rotatekey] authenticated with current key: MY_OLD_ACCESS_KEY
2018-11-26 15:40:01,338 INFO [rotatekey] created new key pair: MY_NEW_ACCESS_KEY
2018-11-26 15:40:01,356 INFO [rotatekey] created AWS session with key: MY_NEW_ACCESS_KEY
2018-11-26 15:40:12,973 INFO [rotatekey] retrieved current user from session: joebloggs
2018-11-26 15:40:12,977 INFO [rotatekey] updated credentials file '/home/joebloggs/.aws/credentials' with new key: MY_NEW_ACCESS_KEY
2018-11-26 15:40:12,978 INFO [rotatekey] successfully validated new key, deleting old key: MY_OLD_ACCESS_KEY
```

### Important notes
- If you store your key in multiple places for some reason, you will need to manually retrieve your key pair from the credentials file for use elsewhere. Don't try to run this utility multiple times, because it will clobber your key each time!
- If your IAM user has multiple access keys - e.g. you have created an additional key yourself at some point - then a key will need to be removed by navigating to your user in IAM and deleting one of the keys listed in 'Security credentials'. Only remove the key that _is not_ going to be used to run `rotatekey.py`.
