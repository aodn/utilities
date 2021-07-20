
# obtain groups xml by _logging into_ the catalogue-aodn console,
# browse to https://catalogue.aodn.org.au/geonetwork/srv/eng/xml.group.list
# and copying the xml

import os
import glob
import xmltodict, json

files = glob.glob('./users/*')
for f in files:
    os.remove(f)

users_xml = None

with open("users.xml", "r") as usersfile:
    users_xml = usersfile.read()

users_json = xmltodict.parse(users_xml)

for user in users_json['response']['record']:
    del user['id']
    del user['address']
    del user['city']
    del user['state']
    del user['zip']
    del user['country']

    if user['email']:
        user['emailAddresses'] = [user['email']]
    del user['email']

    with open('./users/ca_gn3_' + user['username'] + '.json', 'w') as writer:
        writer.writelines(json.dumps(user, indent=4))
