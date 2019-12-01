#!/usr/bin/env python3

import base64
import hashlib
import hmac
import os
import sys

KEY_ENV_VARIABLE = 'AWS_SECRET_ACCESS_KEY'
MESSAGE = 'SendRawEmail'
VERSION = '\x02'


def main():
    try:
        print(base64.b64encode("{v}{s}".format(v=VERSION, s=hmac.new(sys.argv[1], MESSAGE, hashlib.sha256).digest())))
    except IndexError:
        sys.exit("Usage: {script} AWS_SECRET_ACCESS_KEY".format(script=os.path.basename(__file__)))


if __name__ == '__main__':
    main()

