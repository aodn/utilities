# This will convert old Talend 7 upgrade configs to integration test configs.
# Currently only converts pipeline 2 pipelines.
# argo and auv require manual editing of config.yaml to set the manifest file to be the 'incoming' file
# Converted configs are moved into original_tests/converted/ directory when converted

import os
import yaml
import shutil

original_tests = "original_tests"

for filename in os.listdir(original_tests):
    if filename.endswith(".yaml"):
        # print(os.path.join(original_tests, filename))
        with open(os.path.join(original_tests, filename), 'r') as stream:
            try:
                # print(yaml.safe_load(stream))
                config = yaml.safe_load(stream)
                if config.get('type') == 'pipeline_version_2':   # converts pipeline version 2 only
                    name = config.get('name')
                    # make dirs
                    test_config_dir = os.path.join('test_configs',name)
                    new_input_files_dir = os.path.join(test_config_dir, 'input_files')
                    try:
                        os.mkdir(test_config_dir)
                        os.mkdir(new_input_files_dir)
                    except FileExistsError as exc:
                        # print(exc)
                        pass
                    # move input files
                    input_files_dir = os.path.join(original_tests,'input_files',name)
                    try:
                        for input_filename in os.listdir(input_files_dir):
                            source = os.path.join(input_files_dir, input_filename)
                            destination = os.path.join(new_input_files_dir, input_filename)
                            shutil.copy2(source, destination)
                    except FileNotFoundError as exc:
                        # print(exc)
                        pass
                    #set incoming
                    actions = config.get('actions')
                    updated_actions = []
                    for action in actions:
                        files = action.get('files')
                        if action.get('type') != 'DELETE' and files is not None and len(files) == 1:
                            action['incoming'] = action.pop('files')
                            action['incoming'][0]['dest'] = action['incoming'][0]['dest'].replace('/mnt/ebs/incoming/','')
                        elif action.get('type') != 'DELETE':
                            print("%s : %s has more than one file" % (name, action.get('type')))
                        updated_actions.append(action)
                    #create config.yaml
                    test_config = {'actions': updated_actions, 'process_report_template': 'processing_results',
                                       'test_report_template': 'test_results',
                                       'assertions': [
                                           {
                                                'name': 'diff',
                                                'expected': os.path.join('../test_configs/', name, 'expect'),
                                                'content': name
                                           }
                                       ]
                                   }
                    config.update(test_config)
                    # write the yaml
                    new_config_file = os.path.join(test_config_dir, 'config.yaml')
                    with open(new_config_file, 'w') as yaml_file:
                        yaml.dump(config, yaml_file, default_flow_style=False)
                    # move the original
                    os.rename(os.path.join(original_tests, filename), os.path.join(original_tests, 'converted', filename))
            except yaml.YAMLError as exc:
                print(exc)
    else:
        continue