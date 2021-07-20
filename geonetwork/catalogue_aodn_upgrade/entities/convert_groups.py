
# obtain groups xml by _logging into_ the catalogue-aodn console,
# browse to https://catalogue.aodn.org.au/geonetwork/srv/eng/xml.group.list
# and copying the xml

import os
import glob
import xmltodict, json

files = glob.glob('./groups/*')
for f in files:
    os.remove(f)

groups_xml = None

with open("groups.xml", "r") as groupsfile:
    groups_xml = groupsfile.read()

groups_json = xmltodict.parse(groups_xml)

#print(json.dumps(groups_json))


for group in groups_json['response']['record']:

    # clean up <> characters
    label = group['label']
    for key in label:
        if '<' in label[key] or '>' in label[key]:
            label[key] = label[key].replace('>', '').replace('<', '')

    del group['id']

    with open('./groups/ca_gn3_' + group['name'].replace(' ', '') + '.json', 'w') as writer:
        writer.writelines(json.dumps(group, indent=4))
