from xml.etree.ElementTree import fromstring, ElementTree
import sys
from requests.auth import HTTPBasicAuth
import unicodedata

import requests

if len(sys.argv) > 2:
    auth = HTTPBasicAuth(sys.argv[2], sys.argv[3])
    if len(sys.argv) >= 5:
        headers = {"X-XSRF-TOKEN": sys.argv[4]}
    else:
        headers = None
else:
    auth = None

text_xml = requests.get(sys.argv[1], headers=headers, auth=auth).text
text_xml = text_xml.encode('ascii','ignore')
xml_tree = ElementTree(fromstring(text_xml))

uuids = {uuid.text for uuid in xml_tree.findall('.//uuid')}

for uuid in uuids:
    print(uuid)
