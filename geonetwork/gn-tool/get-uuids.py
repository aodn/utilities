from xml.etree.ElementTree import fromstring, ElementTree
import argparse
import sys
from requests.auth import HTTPBasicAuth
import unicodedata

import requests

parser = argparse.ArgumentParser()
parser.add_argument('url')
parser.add_argument('--username', default=None)
parser.add_argument('--password', default=None)
parser.add_argument('--xsrftoken', default=None)
args = parser.parse_args()

headers = {}
if args.username and args.password:
    auth = HTTPBasicAuth(args.username, args.password)
    if args.xsrftoken:
        headers["X-XSRF-TOKEN"] = args.xsrftoken
else:
    auth = None

text_xml = requests.get(args.url, headers=headers, auth=auth).text
text_xml = text_xml.encode('ascii', 'ignore')
xml_tree = ElementTree(fromstring(text_xml))

uuids = {uuid.text for uuid in xml_tree.findall('.//uuid')}

for uuid in uuids:
    print(uuid)
