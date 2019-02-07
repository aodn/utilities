#!/usr/bin/env python

import boto3
from botocore.exceptions import ClientError

s3 = boto3.client('s3')

for bucket in s3.list_buckets()['Buckets']:
    try:
        tagging = s3.get_bucket_tagging(Bucket=bucket['Name'])
        bucket_tag = next((t for t in tagging.get('TagSet') if t['Key'] == 'Bucket'), None)
    except ClientError:
        bucket_tag = None

    if not bucket_tag:
        print("UNTAGGED BUCKET '{}'".format(bucket['Name']))
    elif bucket_tag['Value'] != bucket['Name']:
        print("INCORRECTLY TAGGED BUCKET '{}' (tag value='{}')".format(bucket['Name'], bucket_tag['Value']))
