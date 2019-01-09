#!/usr/bin/env python

# Generates a CloudFormation template from a zone JSON file. The JSON may be extracted as follows:
# aws route53 list-resource-record-sets --hosted-zone-id [ZONE_ID] > zone.json

import argparse
import json
import re

import troposphere
import troposphere.route53 as route53


def get_resource_name(resource, suffix=None):
    if suffix is None:
        suffix = resource['Type']
    return resource['Name'].replace('-', '').replace('_', '').replace('.', ' ').title().replace(' ', '') + suffix


def alias2resource(record, zone_name):
    name = get_resource_name(record, suffix='ALIAS')
    resource = route53.RecordSetType(name)
    resource.HostedZoneName = zone_name.ref()
    resource.Name = record['Name']
    resource.Type = record['Type']
    alias_target = route53.AliasTarget()
    alias_target.HostedZoneId = record['AliasTarget']['HostedZoneId']
    alias_target.DNSName = record['AliasTarget']['DNSName']
    alias_target.EvaluateTargetHealth = record['AliasTarget']['EvaluateTargetHealth']
    resource.AliasTarget = alias_target
    return resource


def simple2resource(record, zone_name):
    name = get_resource_name(record)
    resource = route53.RecordSetType(name)
    resource.HostedZoneName = zone_name.ref()
    resource.Name = record['Name']
    resource.TTL = record['TTL']
    resource.ResourceRecords = [l['Value'] for l in record['ResourceRecords']]
    resource.Type = record['Type']
    return resource


def get_simple_resources(records, zone_name):
    return [simple2resource(s, zone_name) for s in records]


def get_alias_resources(records, zone_name):
    return [alias2resource(a, zone_name) for a in records]


def is_managed_record(record):
    if record['Name'].startswith('ci-'):
        return True
    # matches stack deployed names which prepend the application name to the stack name
    # e.g. thredds-ci-eb-thredds-sandbox.aodn.org.au and  aodn-portal-ci-eb-aodn-portal-sandbox.aodn.org.au
    if re.match(r'^[\w\-]+\-ci\-eb\-[\w\-]+\..*$', record['Name']):
        return True
    return False


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

    template = troposphere.Template()
    zone_name = troposphere.Parameter('HostedZoneName')
    zone_name.Type = 'String'
    zone_name.Default = args.zone_name
    template.add_parameter(zone_name)
    template.add_resource(get_simple_resources(simple_records, zone_name=zone_name))
    template.add_resource(get_alias_resources(alias_records, zone_name=zone_name))

    print(template.to_yaml())
