from xml.etree.ElementTree import fromstring, ElementTree
import sys

import requests

text_xml = requests.get(sys.argv[1]).text
xml_tree = ElementTree(fromstring(text_xml))

uuids = {uuid.text for uuid in xml_tree.findall('.//uuid')}

for uuid in uuids:
    print(uuid)
