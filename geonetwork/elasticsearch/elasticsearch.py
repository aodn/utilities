#!/usr/bin/env python3

# Read the following from MEF and create OpenSearch documents

# - uuid
# - title
# - point of truth
# - temporal extent begin
# - temporal extent end
# - organisation(s) (sequence)
# - polygons (sequence)

import json
import sys
from pathlib import Path, PurePath
import xml.etree.ElementTree as ET
import requests
import opensearchpy


def index_id(info):
    # uuid from info.xml
    text_xml = ET.parse(info)
    xml_tree = text_xml.getroot()
    return xml_tree.find('.//uuid').text


def document(path):
    # document from metadata.xml
    metadata = PurePath(path).parent / "metadata" / "metadata.xml"
    text_xml = ET.parse(metadata)
    xml_tree = text_xml.getroot()
    return {key: get_field(xml_tree, value) for key, value in schema.items()}


def process_xpath(xml, xpath, empty):
    elements = xml.findall(xpath, ns)
    if elements is None:
        return empty
    else:
        if len(elements) == 1:
            return elements[0].text
        elif len(elements) == 0:
            return empty
        else:
            return [element.text for element in elements]


def get_field(xml, field):
    # apply the xpath expressions returning the value and correct data type
    if type(field["xpath"]) == list:
        value = []
        for xpath in field["xpath"]:
            value.append(process_xpath(xml, xpath, field["empty"]))
    else:
        value = process_xpath(xml, field["xpath"], field["empty"])
    return value


def index(action):
    # add an index action
    metadata = json.dumps({action["_type"]: {key: action[key] for key in action if key not in ["_source", "_type"]}})
    data = json.dumps(action["_source"])
    return metadata + "\n" + data + "\n"


def actions_to_string(actions_list):
    # accumulate all the actions
    action_string = ""
    for action in actions_list:
        if action["_type"] == "index":
            action_string += index(action)
    return action_string


def bulk(bulk_actions):
    # execute the bulk actions
    return requests.post(
        "{}/_bulk".format(opensearch_url),
        data=actions_to_string(bulk_actions),
        headers={'Content-Type': 'application/x-ndjson'}
    )


def client_bulk(client, bulk_actions):
    # TODO: currently not working
    # execute bulk actions using opensearchpy.client
    return opensearchpy.bulk(client, bulk_actions)

def count_results(items):
    count = {
        "updated": 0,
        "error": 0
    }
    for item in items:
        if item["index"]["status"] == 200:
            if item["index"]["result"] == "updated":
                count["updated"] += 1
        if item["index"]["status"] == 400:
            print(item)
            count["error"] += 1
    return count


# Schema: Declare XPath expressions
schema = {
    "uuid": {"xpath": ".//mdb:metadataIdentifier/mcc:MD_Identifier/mcc:code/gco:CharacterString", "empty": ""},
    "title": {
        "xpath": ".//mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:title/gco:CharacterString", "empty": ""},
    "point-of-truth": {"xpath": ".//mdb:metadataLinkage/cit:CI_OnlineResource/cit:linkage/gco:CharacterString", "empty": ""},
    "temporal-extent-begin": {
        "xpath": ".//mri:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent/gex:extent/gml:TimePeriod/gml:begin/gml:TimeInstant/gml:timePosition", "empty": None},
    "temporal-extent-end": {
        "xpath": ".//mri:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent/gex:extent/gml:TimePeriod/gml:end/gml:TimeInstant/gml:timePosition", "empty": None},
    "organisations": {"xpath": [
        ".//mri:MD_DataIdentification/mri:citation//cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name/gco:CharacterString",
        ".//mri:MD_DataIdentification/mri:pointOfContact//cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name/gco:CharacterString"
    ], "empty": []},
    "polygons": {
        "xpath": ".//mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent/gex:geographicElement/gex:EX_BoundingPolygon/gex:polygon/gml:MultiSurface/gml:surfaceMember/gml:Polygon/gml:exterior/gml:LinearRing/gml:posList", "empty": ""}
}

# namespaces used by the schema
ns = {
    'mdb': 'http://standards.iso.org/iso/19115/-3/mdb/2.0',
    'mcc': "http://standards.iso.org/iso/19115/-3/mcc/1.0",
    'gco': "http://standards.iso.org/iso/19115/-3/gco/1.0",
    'cit': "http://standards.iso.org/iso/19115/-3/cit/2.0",
    'mri': "http://standards.iso.org/iso/19115/-3/mri/1.0",
    'gex': "http://standards.iso.org/iso/19115/-3/gex/1.0",
    'gml': "http://www.opengis.net/gml/3.2"
}

source = sys.argv[1]
opensearch_url = sys.argv[2]

# All the actions for a _bulk index of the source data
actions = [
    {
        "_index": "catalogue-imos",
        "_id": index_id(path),
        "_type": "index",
        "_source": document(path)
    }
    for path in Path(source).rglob('info.xml')
]

# USING REQUESTS
response = bulk(actions)

# USING THE OPENSEARCH CLIENT
# client = OpenSearch(hosts={'host': opensearch_url})
# response = client_bulk( client, actions  )

# print(response.content)
# print(response.status_code)
print(f'Actions attempted: {len(actions)}')
if response.status_code == 200:
    items = json.loads(response.content.decode("utf-8"))["items"]
    counted = count_results(items)
    print(f'Actions updated: {counted["updated"]}')
    print(f'Actions with errors: {counted["error"]}')
else:
    print(f'Error: {json.loads(response.content.decode("utf-8"))["Message"]}')
