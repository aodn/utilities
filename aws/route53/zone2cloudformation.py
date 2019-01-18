#!/usr/bin/env python

# Generates a CloudFormation template from a zone JSON file. The JSON may be extracted as follows:
# aws route53 list-resource-record-sets --hosted-zone-id [ZONE_ID] > zone.json

import argparse
import json
import re

import troposphere
import troposphere.route53 as route53

INCLUDED_TYPES = ('A', 'CNAME', 'MX', 'TXT')


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


def exclude_record(record, exclusions=None):
    # manual exclusions
    if exclusions is None:
        exclusions = []

    if strip_trailing_dot(record['Name']) in exclusions:
        return True

    if record['Type'] not in INCLUDED_TYPES:
        return True

    if record['Name'].startswith('ci-'):
        return True
    # matches stack deployed names which prepend the application name to the stack name
    # e.g. thredds-ci-eb-thredds-sandbox.aodn.org.au and  aodn-portal-ci-eb-aodn-portal-sandbox.aodn.org.au
    if re.match(r'^[\w\-]+\-ci\-eb\-[\w\-]+\..*$', record['Name']):
        return True

    return False


def add_trailing_dot(value):
    return value if value[-1] == '.' else value + '.'


def strip_trailing_dot(value):
    return value[:-1] if value[-1] == '.' else value


def is_mail_record(record):
    if record['Type'] == "MX":
        return True
    if record['Type'] == "TXT" and "v=spf1" in record["ResourceRecords"][0]["Value"]:
        return True
    if record['Name'].startswith('_amazonses.'):
        return True
    for value in ["dkim", "domainkey", "sendgrid.net"]:
        if value in record["ResourceRecords"][0]["Value"]:
            return True


def is_serverless_website(record):
    if 's3-website' in record["ResourceRecords"][0]["Value"]:
        return True
    if strip_trailing_dot(record["ResourceRecords"][0]["Value"]).endswith('cloudfront.net'):
        return True


def is_miscellaneous(record):
    for value in ['.acm-validations.aws', '.dv.googlehosted.com']:
        stripped = strip_trailing_dot(record["ResourceRecords"][0]["Value"])
        if stripped.endswith(value):
            return True

    if record['Type'] == "TXT" and not is_mail_record(record):
        return True


def create_template_yaml(zone_name, list_of_resources):
    template = troposphere.Template()
    template.add_parameter(zone_name)
    template.add_resource(list_of_resources)
    output = troposphere.Output('Endpoint',
                                Description='dummy endpoint required by aodnstack playbook',
                                Value='NO_ENDPOINT')
    template.add_output(output)
    return template.to_yaml(long_form=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--zone-name', required=True)
    parser.add_argument('--zone-json', required=True)
    parser.add_argument('--exclude', action='append')
    args = parser.parse_args()

    zone_name_with_dot = add_trailing_dot(args.zone_name)
    zone_name_without_dot = strip_trailing_dot(args.zone_name)

    with open(args.zone_json) as f:
        all_records = json.load(f)

    exclusions = [strip_trailing_dot(e) for e in args.exclude] if args.exclude else []
    all_unmanaged_records = [r for r in all_records['ResourceRecordSets'] if not exclude_record(r, exclusions=exclusions)]
    alias_records = [r for r in all_unmanaged_records if r.get('AliasTarget') and r['Type'] == 'A']
    simple_records = [r for r in all_unmanaged_records if
                      r.get('ResourceRecords') and r['Type'] in INCLUDED_TYPES]

    records_remaining = simple_records[:]
    mail_records = []
    serverless_website_records = []
    miscellaneous_records = []
    standard_records = []

    while records_remaining:
        record = records_remaining.pop()
        if is_mail_record(record):
            mail_records.append(record)
        elif is_serverless_website(record):
            serverless_website_records.append(record)
        elif is_miscellaneous(record):
            miscellaneous_records.append(record)
        else:
            standard_records.append(record)

    template_name = "".format(zone_name_without_dot)
    deletion_change_record_set_name = "{}-deletions-change-record-set.json".format(zone_name_without_dot)
    creations_change_record_set_name = "{}-creations-change-record-set.json".format(zone_name_without_dot)

    zone_name = troposphere.Parameter('HostedZoneName')
    zone_name.Type = 'String'
    zone_name.Default = zone_name_with_dot

    with open("{}-{}-template.yaml".format(zone_name_without_dot, "mail"), 'w') as f:
        f.write(create_template_yaml(zone_name, get_simple_resources(mail_records, zone_name)))

    with open("{}-{}-template.yaml".format(zone_name_without_dot, "serverless-website"), 'w') as f:
        f.write(create_template_yaml(zone_name, get_simple_resources(serverless_website_records, zone_name) + get_alias_resources(alias_records, zone_name)))

    with open("{}-{}-template.yaml".format(zone_name_without_dot, "misc"), 'w') as f:
        f.write(create_template_yaml(zone_name, get_simple_resources(miscellaneous_records, zone_name)))

    with open("{}-{}-template.yaml".format(zone_name_without_dot, "standard"), 'w') as f:
        f.write(create_template_yaml(zone_name, get_simple_resources(standard_records, zone_name)))

    deletions = {
        'Comment': 'aws route53 change-resource-record-sets --change-batch deletions-change-log.json --hosted-zone-id <value>',
        'Changes': [{'Action': 'DELETE', 'ResourceRecordSet': r} for r in all_unmanaged_records]}
    with open(deletion_change_record_set_name, 'w') as f:
        json.dump(deletions, f, indent=2)

    creations = {
        'Comment': 'aws route53 change-resource-record-sets --change-batch create-change-log.json --hosted-zone-id <value>',
        'Changes': [{'Action': 'UPSERT', 'ResourceRecordSet': r} for r in all_unmanaged_records]}
    with open(creations_change_record_set_name, 'w') as f:
        json.dump(creations, f, indent=2)
