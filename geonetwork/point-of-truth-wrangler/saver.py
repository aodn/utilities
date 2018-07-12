from xml.etree.ElementTree import fromstring, ElementTree
import sys
import os

import requests


SEARCH = '/srv/eng/xml.search?fast=index'
METADATA_GET = '/srv/eng/xml.metadata.get?uuid='

geonetwork_endpoint = sys.argv[1]
dir_ = sys.argv[2]

text_xml = requests.get(geonetwork_endpoint + SEARCH).text
xml_tree = ElementTree(fromstring(text_xml))

uuids = {uuid.text for uuid in xml_tree.findall('.//uuid')}

print('number of uuids: {}'.format(len(uuids)))

count = 0

for uuid in uuids:
    metadata_url = geonetwork_endpoint + METADATA_GET + uuid
    result = requests.get(metadata_url)
    filename = os.path.join(dir_, uuid + '.xml').replace('{', '').replace('}', '')
    with open(os.path.join(dir_, uuid + '.xml'), 'w') as fp:
        try:
            fp.write(result.content)
            print('saved: {}'.format(filename))
            count += 1
        except UnicodeEncodeError, e:
            print('bailing out. could not save: {}'.format(filename))
            print(e.message)
            sys.exit()

print('saved {} records'.format(count))

