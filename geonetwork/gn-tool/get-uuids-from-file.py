# Remove namespace from source xml

import xml.etree.ElementTree as ET
import sys

text_xml = ET.parse(sys.argv[1])
xml_tree = text_xml.getroot()

uuids = {uuid.text for uuid in xml_tree.findall('.//' + sys.argv[2])}

for uuid in uuids:
    print(uuid)