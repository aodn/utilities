# Read element/attribute values from info.xml file

import xml.etree.ElementTree as ET
import sys

tag_name = sys.argv[2]
text_xml = ET.parse(sys.argv[1])
xml_tree = text_xml.getroot()

if tag_name == "uuid":
    element_value = xml_tree.find('.//uuid')
    if not (element_value is None):
        print(element_value.text)
elif tag_name == "userOwner":
    element_value = xml_tree.find('.//owner')
    if not (element_value is None):
        print(element_value.attrib['name'])
elif tag_name == "isTemplate":
    element_value = xml_tree.find('.//isTemplate')
    if not (element_value is None):
        print(element_value.text)
    else:
        print('n')
elif tag_name == "groupOwner":
    groupOwner = 'all'
    groupOwner_element = xml_tree.find('.//privileges/group[@groupOwner="true"]')
    if not (groupOwner_element is None):
        groupOwner = groupOwner_element.attrib['name']
    print(groupOwner)
elif tag_name == "groups":
    groups = {uuid for uuid in xml_tree.findall('.//privileges/group')}
    for group in groups:
        print(group.attrib['name'])
