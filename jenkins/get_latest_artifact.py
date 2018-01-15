#!/usr/bin/env python
import argparse
import re

import boto3
from botocore import UNSIGNED
from botocore.config import Config

ARTIFACT_PATTERN = re.compile(r"^jobs/(?P<job_name>[^/]+)/(?P<build_number>[^/]+)/(?P<basename>.*)$")
BUCKET = 'imos-binary'


def main():
    parser = argparse.ArgumentParser(description='download the latest artifact for a given Jenkins job from S3')
    parser.add_argument('--job', required=True)
    parser.add_argument('--extension', required=True)
    args = parser.parse_args()

    s3 = boto3.client('s3', config=Config(signature_version=UNSIGNED))

    latest = sorted([ARTIFACT_PATTERN.match(a['Key']).groupdict() for
                     a in s3.list_objects_v2(Bucket=BUCKET, Prefix="jobs/{}".format(args.job))['Contents'] if
                     a['Key'].endswith(args.extension)],
                    key=lambda p: int(p['build_number']))[-1]

    s3.download_file(Bucket=BUCKET,
                     Key="jobs/{job_name}/{build_number}/{basename}".format(**latest),
                     Filename=latest['basename'])


if __name__ == '__main__':
    main()
