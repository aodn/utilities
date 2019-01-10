#!/usr/bin/env python

# Generates an Ansible YAML config file from a zone JSON file. The JSON may be extracted as follows:
# aws route53 list-resource-record-sets --hosted-zone-id [ZONE_ID] > zone.json

import argparse
import json
import re

import yaml


def is_managed_record(record):
    if record['Name'].startswith('ci-'):
        return True
    # matches stack deployed names which prepend the application name to the stack name
    # e.g. thredds-ci-eb-thredds-sandbox.aodn.org.au and  aodn-portal-ci-eb-aodn-portal-sandbox.aodn.org.au
    if re.match(r'^[\w\-]+\-ci\-eb\-[\w\-]+\..*$', record['Name']):
        return True
    return False


def alias2dict(record):
    output = {
        'record': record['Name'],
        'type': 'A',
        'value': record['AliasTarget']['DNSName'],
        'alias': True,
        'alias_hosted_zone_id': record['AliasTarget']['HostedZoneId'],
        'alias_evaluate_target_health': record['AliasTarget']['EvaluateTargetHealth']
    }
    return output


def simple2dict(record):
    output = {
        'record': record['Name'],
        'type': record['Type'],
        'ttl': record['TTL'],
        'value': [l['Value'] for l in record['ResourceRecords']]
    }
    return output


def get_simple_dicts(records):
    return [simple2dict(s) for s in records]


def get_alias_dist(records):
    return [alias2dict(a) for a in records]


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--zone-name', required=True)
    parser.add_argument('--zone-json', required=True)
    args = parser.parse_args()

    with open(args.zone_json) as f:
        all_records = json.load(f)

    all_unmanaged_records = [r for r in all_records['ResourceRecordSets'] if not is_managed_record(r)]
    alias_records = [r for r in all_unmanaged_records if r.get('AliasTarget') and r['Type'] == 'A']
    simple_records = [r for r in all_unmanaged_records if
                      r.get('ResourceRecords') and r['Type'] in ('A', 'CNAME', 'MX', 'TXT')]

    result = {'route53_records': []}
    result['route53_records'].extend(get_simple_dicts(simple_records))
    result['route53_records'].extend(get_alias_dist(alias_records))

    print(yaml.safe_dump(result, default_flow_style=False))
