# This will add file_exists assertions for all 'incoming' files
# Does not consider that the file name on the file store may not be the same as the remote_file name in the action.
# Currently only converts pipeline 2 pipelines.

import os
import yaml
import shutil

original_tests = "test_configs_9nechob"

for pipeline_name in os.listdir(original_tests):
    if pipeline_name != 'hosts':
        config_file = os.path.join(pipeline_name, 'config.yaml')
        with open(os.path.join(original_tests, config_file), 'r+') as stream:
            try:
                config = yaml.safe_load(stream)
                if config.get('type') == 'pipeline_version_2':   # converts pipeline version 2 only
                    old_assertions = config.get('assertions')
                    # Remove old file_exists assertions
                    updated_assertions = old_assertions
                    for assertion in old_assertions:
                        if assertion.get('invert') is not None:
                            for i in range(len(new_assertions)):
                                if updated_assertions[i]['name'] != 'diff':
                                    del updated_assertions[i]
                                    break

                    # For each ADD and DELETE action create a file_exists assertion
                    actions = config.get('actions')
                    add_count = 0
                    for action in actions:
                        action_type = action.get('type')
                        if action.get('incoming') is not None and action_type == 'ADD':
                            incoming = action.get('incoming')
                            for incoming_file in incoming:
                                add_count += 1
                                if incoming_file.get('remote_file') is not None:
                                    remote_file = os.path.join('IMOS', incoming_file.get('dest'), incoming_file.get('remote_file'))
                                else:
                                    remote_file = os.path.join('IMOS', incoming_file.get('dest'), incoming_file.get('local_file'))
                                new_assertion = {
                                    'name': 'file_exists:' + str(add_count),
                                    'remote_file': remote_file
                                }
                                updated_assertions.append(new_assertion)
                        if action_type == 'DELETE':
                            if action.get('path') is not None:
                                remote_file = action.get('path')
                            else:
                                remote_file = action.get('file')
                            new_assertion = {
                                'name': 'file_exists:not:' + str(add_count),
                                'remote_file': remote_file,
                                'invert': True
                            }
                            updated_assertions.append(new_assertion)

                    # Check for ADDed files that are DELETEd
                    # When removing the assertion for the ADDed file this does not consider that the file name in the
                    # file store may not be the same as the remote_file name in the DELETE action.  Hence some file_exists
                    # assertions may be redundant.  These will need to be manually removed.
                    new_assertions = updated_assertions
                    for assertion in updated_assertions:
                        if assertion.get('invert') is not None:
                            for i in range(len(new_assertions)):
                                if new_assertions[i]['name'] != 'diff' and new_assertions[i]['remote_file'] == assertion.get('remote_file') and new_assertions[i]['invert'] is None:
                                    del new_assertions[i]
                                    break

                    config.update(assertions = new_assertions)

                    stream.seek(0)
                    stream.truncate()
                    yaml.dump(config, stream, default_flow_style=False)

            except yaml.YAMLError as exc:
                print(exc)
