
import os
import sys
import xmltodict
import json

dir = sys.argv[1]


metadata_records = [ os.path.join(dir, filename) for filename in os.listdir(dir)]

positive_files = []
negative_files = []

total_count = 0
found = 0
contains_point_of_truth = 0

SEARCH = 'Point of truth'

results = []

for record in metadata_records:

    found_line = ''

    with open(record, 'r') as fp:
        xml_str = fp.read()

        should_process = False

        for line in xml_str.splitlines():
            if SEARCH in line:
                contains_point_of_truth += 1
                should_process = True
                break

        if should_process:

            result = {'uuid': None, 'link': None}

            target_found = False
            metadata = xmltodict.parse(xml_str)

            try:
                md_metadata = metadata['gmd:MD_Metadata']
            except:
                md_metadata = metadata['mcp:MD_Metadata']

            character_string = md_metadata['gmd:fileIdentifier']['gco:CharacterString']

            if isinstance(character_string, unicode):
                uuid = character_string
            else:
                uuid = character_string['#text']

            result['uuid'] = uuid

            distribution_info = md_metadata['gmd:distributionInfo']
            transfer_options = distribution_info['gmd:MD_Distribution']['gmd:transferOptions']

            digital_transfer_options = []

            if isinstance(transfer_options, list):
                for item in transfer_options:
                    digital_transfer_options.append(item['gmd:MD_DigitalTransferOptions'])
            else:
                if 'gmd:MD_DigitalTransferOptions' in transfer_options:
                    digital_transfer_options.append(transfer_options['gmd:MD_DigitalTransferOptions'])

            for item in digital_transfer_options:
                if item is not None and 'gmd:onLine' in item:
                    on_line = item['gmd:onLine']
                    ci_online_resource = []

                    if isinstance(on_line, list):
                        for item in on_line:
                            ci_online_resource.append(item['gmd:CI_OnlineResource'])
                    else:
                        if 'gmd:CI_OnlineResource' in on_line:
                            ci_online_resource.append(on_line['gmd:CI_OnlineResource'])

                    for item in ci_online_resource:

                        online_resource_json = json.dumps(item)

                        if SEARCH in online_resource_json:
                            found += 1
                            target_found = True
                            result['link'] = item['gmd:linkage']['gmd:URL']
                            break

            if not target_found:
                print('something went wrong')
                sys.exit(1)
            else:
                results.append(result)

        else:
            pass

        total_count += 1

#output csv statements
print('uuid,link')
for item in results:
    print item['uuid'] + ',' + item['link']
