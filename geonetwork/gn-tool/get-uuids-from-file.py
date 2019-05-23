# Remove namespace from source xml

import xml.etree.ElementTree as ET
import sys

text_xml = ET.parse(sys.argv[1])
xml_tree = text_xml.getroot()
try:
    template = sys.argv[3] # template eg: "update sources set name = 'BlueNet' where uuid = '{}'"
except IndexError:
    template = None

uuids = {uuid.text for uuid in xml_tree.findall('.//' + sys.argv[2])}

for uuid in uuids:
    if template is not None:
        print(template.format(uuid))
    else:
        print(uuid)