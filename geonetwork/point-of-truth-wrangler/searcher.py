import os
import sys

dir = sys.argv[1]
term = sys.argv[2]
pos_or_neg = sys.argv[3]


metadata_records = [ os.path.join(dir, filename) for filename in os.listdir(dir)]

positive_files = []
negative_files = []

for record in metadata_records:

    with open(record, 'r') as fp:
        xml_str = fp.read()

        if term in xml_str:
            positive_files.append(record)
        else:
            negative_files.append(record)

if pos_or_neg == 'positive':
    result = positive_files
elif pos_or_neg == 'negative':
    result = negative_files

uuids = [item.replace('.xml', '').replace(dir + '/', '') for item in result]


print('\n'.join(uuids))
print('found term "{}" in the following {} files:'.format(term, len(result)))


