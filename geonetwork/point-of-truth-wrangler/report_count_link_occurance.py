
import os
import sys
import csv

dir = sys.argv[1]
pot_data = sys.argv[2]

metadata_record_files = [ os.path.join(dir, filename) for filename in os.listdir(dir)]

data = [line for line in csv.DictReader(open(pot_data, 'rb'))]

all_collections_ok = True

for item in data:
    with open(os.path.join(dir, item['uuid'] + '.xml')) as fp:
        xml_str = fp.read()

        num_occurrences = xml_str.count(item['link'])

        if num_occurrences > 1:
            print('{} has {} occurrences of {}'.format(item['uuid'], num_occurrences, item['link']))
            all_collections_ok = False
        else:
            pass

if all_collections_ok:
    print('okay to continue')
else:
    print('one or more collections has multiple occurrences of the point of truth link')
