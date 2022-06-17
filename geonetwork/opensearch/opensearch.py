#!/usr/bin/env python3

# Read the following from MEF and create search documents

# - uuid
# - title
# - point of truth
# - temporal extent begin
# - temporal extent end
# - organisation(s) (sequence)
# - polygons (sequence)
# - source document url

import json
import sys
from pathlib import Path, PurePath
import xml.etree.ElementTree as ET
import requests


def index_id(info):
    # uuid from info.xml
    text_xml = ET.parse(info)
    xml_tree = text_xml.getroot()
    return xml_tree.find('.//uuid').text


def get_document_path(info_path):
    # the path to metadata.xml
    return PurePath(info_path).parent / "metadata" / "metadata.xml"


def document(path):
    # document from metadata.xml
    metadata = get_document_path(path)
    text_xml = ET.parse(metadata)
    xml_tree = text_xml.getroot()
    doc = {key: get_field(xml_tree, value) for key, value in schema.items()}
    doc["_path"] = metadata.as_uri()
    return doc


def geojson_polygon_coordinate_array(gml_vertices_text):
    # a geojson polygon from gml vertices list
    # does not support holes
    gml_vertices_list = [float(x) for x in gml_vertices_text.split(" ")]
    vertices = [[gml_vertices_list[i], gml_vertices_list[i + 1]] for i in range(0, len(gml_vertices_list), 2)]
    return [vertices]


def geojson_multipolygon(elements):
    # a geojson multipolygon from xml elements
    multipolygon = {
        "type": "MultiPolygon",
        "coordinates": [
            geojson_polygon_coordinate_array(element.text) for element in elements
        ]
    }
    return multipolygon

def text(elements):
    if len(elements) == 1:
        return elements[0].text
    elif len(elements) == 0:
        return None
    else:
        return [element.text for element in elements]


def process_xpath(xml, xpath, type):
    # process an xpath expression
    elements = xml.findall(xpath, ns)
    if elements is None or len(elements) == 0:
        return None
    else:
        if type == "multipolygon":
            return geojson_multipolygon(elements)
        else:
            return text(elements)


def get_field(xml, field):
    # apply the xpath expressions returning the value and correct data type
    if "type" in field:
        field_type = field["type"]
    else:
        field_type = None
    if type(field["xpath"]) == list:
        # more than one xpath for the field - process them all
        value = []
        for xpath in field["xpath"]:
            value.append(process_xpath(xml, xpath, field_type))
    else:
        value = process_xpath(xml, field["xpath"], field_type)
    return value


def index(action):
    # add an index action
    metadata = json.dumps({action["_type"]: {key: action[key] for key in action if key not in ["_source", "_type"]}})
    data = json.dumps(action["_source"])
    return metadata + "\n" + data + "\n"


def actions_to_string(actions_list):
    # accumulate all the actions in a string for the payload
    # Implement another version of this for other index/search services
    action_string = ""
    for action in actions_list:
        if action["_type"] == "index":
            action_string += index(action)
    return action_string


def bulk(bulk_actions):
    # execute the bulk actions
    # Implement another version of this for other index/search services
    return requests.post(
        "{}/_bulk".format(searchservice_url),
        data=actions_to_string(bulk_actions),
        headers={'Content-Type': 'application/x-ndjson'}
    )


def count_results(items):
    # Statistics about the indexed documents and output of errors
    # Implement another version of this for other index/search services
    count = {
        "created": 0,
        "updated": 0,
        "error": 0
    }
    for item in items:
        if item["index"]["status"] in [200, 201]:
            if item["index"]["result"] == "updated":
                count["updated"] += 1
            if item["index"]["result"] == "created":
                count["created"] += 1
        if item["index"]["status"] == 400:
            print(item)
            count["error"] += 1
    return count


# Schema: Declare XPath expressions
# Can have more than one expression for a field eg. organisations
# Can specify the search services data type eg. spatial_extent
schema = {
    "uuid": {"xpath": ".//mdb:metadataIdentifier/mcc:MD_Identifier/mcc:code/gco:CharacterString"},
    "title": {
        "xpath": ".//mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:title/gco:CharacterString"},
    "point_of_truth": {"xpath": ".//mdb:metadataLinkage/cit:CI_OnlineResource/cit:linkage/gco:CharacterString"},
    "temporal_extent_begin": {
        "xpath": ".//mri:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent/gex:extent/gml:TimePeriod/gml:begin/gml:TimeInstant/gml:timePosition"},
    "temporal_extent_end": {
        "xpath": ".//mri:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent/gex:extent/gml:TimePeriod/gml:end/gml:TimeInstant/gml:timePosition"},
    "organisations": {"xpath": [
        ".//mri:MD_DataIdentification/mri:citation//cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name/gco:CharacterString",
        ".//mri:MD_DataIdentification/mri:pointOfContact//cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name/gco:CharacterString"
    ]},
    "spatial_extent": {
        "xpath": ".//mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent/gex:geographicElement"
                 "/gex:EX_BoundingPolygon/gex:polygon/gml:MultiSurface/gml:surfaceMember/gml:Polygon/gml:exterior/gml"
                 ":LinearRing/gml:posList",
        "type": "multipolygon"
    }
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
searchservice_url = sys.argv[2]

# All the actions for a _bulk index of the source data
actions = [
    {
        "_index": "catalogue-imos",  # identifier for the index
        "_id": index_id(path),  # identifier for the indexed document
        "_type": "index",  # the action type
        "_source": document(path)  # POST payload for the action
    }
    for path in Path(source).rglob('info.xml')
]

response = bulk(actions)

print(f'Actions attempted: {len(actions)}')
if response.status_code == 200:
    items = json.loads(response.content.decode("utf-8"))["items"]
    counted = count_results(items)
    print(f'Updated: {counted["updated"]}')
    print(f'Created: {counted["created"]}')
    print(f'Actions with errors: {counted["error"]}')
else:
    print(f'Error: {json.loads(response.content.decode("utf-8"))["Message"]}')
