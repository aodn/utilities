from xml.etree.ElementTree import fromstring, ElementTree
import argparse
import sys
from requests.auth import HTTPBasicAuth
import xml
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

try:
    xml_tree = ElementTree(fromstring(text_xml))
except xml.etree.ElementTree.ParseError as e:
    print("Couldn't parse XML response: " + str(text_xml))
    sys.exit(1)

if not xml_tree.find('./summary'):
    print("Not valid search result: " + str(text_xml))
    sys.exit(1)

uuids = {uuid.text for uuid in xml_tree.findall('.//uuid')}

for uuid in uuids:
    print(uuid)
