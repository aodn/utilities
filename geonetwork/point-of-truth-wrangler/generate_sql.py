import sys
import csv
import urlparse

pots_data = [line for line in csv.DictReader(open(sys.argv[1], 'rb'))]
new_pot = sys.argv[2]

for item in pots_data:
    uuid = item['uuid']
    old_pot = item['link']

    parsed_old_pot = urlparse.urlparse(old_pot)
    parsed_new_pot = urlparse.urlparse(new_pot)

    parsed_updated_pot = parsed_old_pot._replace(netloc=parsed_new_pot.netloc)._replace(scheme=parsed_new_pot.scheme)
    updated_pot = urlparse.urlunparse(parsed_updated_pot)

    print("UPDATE metadata SET data = replace(data, '{}', '{}') WHERE uuid = '{}';".format(old_pot, updated_pot, uuid))
