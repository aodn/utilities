Pipeline Integration Testing
============================

Provides a framework for running harvester pipeline integration tests to test any part of the pipeline with static sets 
of input data. Data is extracted from the resultant database which is then used to compare with expected results.  
Multiple harvesters can be tested against multiple integration tests.

## Requirements

The example tests have been configured to work with the [PO Box for Talend Open Studio 7](https://github.com/aodn/chef/blob/master/doc/README.po-box7.md)
so get this launched first.
They are written using Ansible.

## Setup
```shell script
pip install -r requirements.txt
```

Allow setting of permissions on temporary files that ansible needs to create when becoming an unprivileged user:

- add `allow_world_readable_tmpfiles=true` to `/etc/ansible/ansible.cfg` 
- edit `./test_configs/hosts` and update ansible_host to point to the pipeline host.
- edit `./test_configs/hosts` and update db_user to a user with database admin privileges on the pipeline host.

Create .pgpass entries
- refer to [this document](https://blog.sleeplessbeastie.eu/2014/03/23/how-to-non-interactively-provide-password-for-the-postgresql-interactive-terminal/) for how to create a .pgpass file
- add an entry like this:
  ```po7.aodn.org.au:5432:harvest:admin:admin```

Configure your AWS profile e.g:
```shell script
export AWS_PROFILE=production-developer
```

Obtain the location of the vagrant private ssh key (do this in the chef directory from which you launched the po7 box):

```shell script
vagrant ssh-config po7
```
Note the value of the `IdentityFile` entry in the output.

Activate the ansible environment:

```shell script
source ansible-virtualenv/bin/activate
```

## Configure a test

Configurations for tests are in `test_configs`. You need to create a directory for each test that contains a `config.yaml` 
file and an `input_files` directory. The `input_files` directory contains sample data to run the tests with and should
contain files that will be processed by the pipeline. The `expect` directory and contents will be generated later in
these instructions.

### Example `config.yaml`

```yaml
# Configuration for processing files through pipeline and capturing results locally
name: soop_xbt_nrt
type: pipeline_version_2
po: laurent
dirs:
- path: /mnt/ebs/wip/SOOP/SOOP_XBT_ASF_SST/data_sorted/XBT/sbddata/FASB_Astrolabe/2019
  owner: vagrant
  group: vagrant
actions:
- type: ADD
  files:
  - dest: /mnt/ebs/wip/SOOP/SOOP_XBT_ASF_SST/data_sorted/XBT/sbddata/FASB_Astrolabe/2019
    local_file: IMOS_SOOP-XBT_T_20190226T111900Z_FASB_000593_FV00.csv.updated
    remote_file: IMOS_SOOP-XBT_T_20190226T111900Z_FASB_000593_FV00.csv
  - dest: /var/incoming/SOOP/XBT/NRT
    local_file: IMOS_SOOP-XBT_T_20190226T111900Z_FASB_000593_FV00.manifest
    remote_file: IMOS_SOOP-XBT_NRT_fileList.manifest
- type: UPDATE
  files:
  - dest: /mnt/ebs/wip/SOOP/SOOP_XBT_ASF_SST/data_sorted/XBT/sbddata/FASB_Astrolabe/2019
    local_file: IMOS_SOOP-XBT_T_20190226T111900Z_FASB_000593_FV00.csv
  - dest: /var/incoming/SOOP/XBT/NRT
    local_file: IMOS_SOOP-XBT_T_20190226T111900Z_FASB_000593_FV00.manifest
    remote_file: IMOS_SOOP-XBT_NRT_fileList.manifest
- type: ADD
  files:
  - dest: /mnt/ebs/wip/SOOP/SOOP_XBT_ASF_SST/data_sorted/XBT/sbddata/FASB_Astrolabe/2019
    local_file: IMOS_SOOP-XBT_T_20190226T112400Z_FASB_000594_FV00.csv
  - dest: /var/incoming/SOOP/XBT/NRT
    local_file: IMOS_SOOP-XBT_T_20190226T112400Z_FASB_000594_FV00.manifest
    remote_file: IMOS_SOOP-XBT_NRT_fileList.manifest
- type: DELETE
  file: IMOS/SOOP/SOOP-XBT/REALTIME/FASB_Astrolabe/2019/IMOS_SOOP-XBT_T_20190226T112400Z_FASB_000594_FV00.csv
drop_schema_objects: true
run_talend_liqui: true
talend_log_file: /mnt/ebs/log/pipeline/process/tasks.SOOP_XBT_NRT.log
talend_jobs:
- soop_xbt_nrt-soop_xbt_nrt
database_schemas:
-
  name: soop_xbt_nrt
  tables:
  - name: soop_xbt_nrt_profiles_map
    exclude_columns: [colour]
  - name: soop_xbt_nrt_profiles_data
    exclude_columns: []

# Configuration for running integration tests
assertions:
  # Asserts harvested results are as expected
  - name: diff
    expected: ../test_configs/soop_xbt_nrt/expect
    content: ../harvest_results/po7.aodn.org.au/soop_xbt_nrt
```

## Obtaining expected test results data

Before integration test assertions can be made the results of processing the input files through the pipeline need to be
benchmarked by generating data for the `expect` directory.  This can be done by creating the files and directory structure
manually (or some other means) or by using the `playbook_process.yaml` ansible playbook against a known working and tested
harvester.

To use the `playbook_process.yaml` ansible playbook for this:

```shell script
(ansible-virtualenv) ansible-playbook ansible/playbook_process.yaml \
-i test_configs/hosts -u vagrant --key-file "/path/to/ssh/private/key/file" \
--extra-vars "test_config=../test_configs/soop_xbt_nrt/config.yaml create_expect=true"
```

Note the key-file path is the the IdentityFile value obtained earlier.  The extra-vars contain a path to the `config.yaml`
file and the flag to generate the expected data.

This command will also create a copy of the harvested data in the `harvest_results` directory.  Note the structure of 
the directories here and how they correlate with the configuration in `config.yaml`.  This same structure (excluding the
host name) is used for the expected data. For example:

```
harvest_results/
  po7.aodn.org.au/                          #<-- host harvest was run against
    soop_asf_mt                             #<-- the harvest config that was run
      action_0_ADD                          #<-- action the harvester ran
        soop_asf_mt/                        #<-- schema listed in the test config
          soop_asf_mt_trajectory_data.csv   #<-- tables listed in the schema
          soop_asf_mt_trajectory_map.csv
      action_1_ADD
      action_2_UPDATE
      action_3_DELETE
```
```
expect/
  soop_asf_mt                             #<-- the harvest config that was run
    action_0_ADD                          #<-- action the harvester ran
      soop_asf_mt/                        #<-- schema listed in the test config
        soop_asf_mt_trajectory_data.csv   #<-- tables listed in the schema
        soop_asf_mt_trajectory_map.csv
    action_1_ADD
    action_2_UPDATE
    action_3_DELETE
```

These harvested data results can be used to verify the validity of one or more integration tests by running the tests:

```shell script
(ansible-virtualenv) ansible-playbook ansible/playbook_tests.yaml -i test_configs/hosts \
--extra-vars "test_config=../test_configs/soop_xbt_nrt/config.yaml"
``` 

## Obtaining new harvest results

New harvest results are obtained simply by running the previous command without the `create_expect` var:

```shell script
(ansible-virtualenv) ansible-playbook ansible/playbook_process.yaml \
-i test_configs/hosts -u vagrant --key-file "/path/to/ssh/private/key/file" \
--extra-vars "test_config=../test_configs/soop_xbt_nrt/config.yaml"
```

## Executing the integration tests

All integration tests in a `config.yaml` file will be executed with:

```shell script
(ansible-virtualenv) ansible-playbook ansible/playbook_tests.yaml \
-i test_configs/hosts --extra-vars "test_config=../test_configs/soop_xbt_nrt/config.yaml"
``` 

An summary of the results will appear in the ansible PLAY RECAP.  Failed tests will be included in the `ignored` count.  
If this is greater than 0 then check the prior output for details on the test that failed.  The `failed` count should be
zero.  If it is not then something is wrong with the test configuration that should be fixed before proceeding.

## Create a new assertion

Assertions are Ansible tasks stored in `roles/execute_tests/tasks/assert_<name>.yaml` files.  Replace `<name>` with the 
name of the assertion.  Assertions consist of a `set_fact` task, a preamble set of tasks as required and a `block` section.
The `block` with it's associated `ignore_errors: yes` is required for all assertions.     

To use an assertion in a pipeline integration test specify it in the `assertions:` part of the `config.yaml` file providing
the `<name>` used in the `roles/execute_tests/tasks/assert_<name>.yaml` file name and any values needed for the `set_fact`
task in the assertion:

```yaml
assertions:
  # Asserts harvested results are as expected
  - name: diff
    expected: ../test_configs/soop_xbt_nrt/expect
    content: ../harvest_results/po7.aodn.org.au/soop_xbt_nrt
```

## Assertions

### diff

The diff assertion does a recursive diff on all of the files in a directory and asserts that there are no differences. To
use this assertion in the `config.yaml`:

```yaml
  - name: diff
    expected: <path to validated harvest content directory>
    content: <path to directory containing harvested content to test>
```

## Running multiple pipeline harvesters and their integration tests

All configured harvesters in the test_config can be tested with the following two commands (`test_config` is set to the 
directory containing the config files):

```shell script
(ansible-virtualenv) ansible-playbook ansible/playbook_process.yaml \
-i test_configs/hosts -u vagrant --key-file "/path/to/ssh/private/key/file" --extra-vars "test_config=../test_configs"
```

Depending on the files being processed and the harvesters being run this can be a very long running process.

```shell script
(ansible-virtualenv) ansible-playbook ansible/playbook_tests.yaml -i test_configs/hosts --extra-vars "test_config=../test_configs"
``` 
  
## Types of test

Note that there are several type of test: `pipeline_version_1`, `pipeline_version_2` and `harvester`. 

### pipeline_version_1, harvester

- Running a test first removes pipeline/harvest logs.

### pipeline_version_2

- Running a test does not removes.

## Database

- database table columns that are not relevant for testing - e.g. timestamp of data insertion - can be excluded using `exclude_columns`.
- If needed change the database user in `test_configs/hosts`
- Run only the db initialisation step for schemas in the test

```shell script
(ansible-virtualenv) ansible-playbook ansible/playbook_process.yaml \
-i test_configs/hosts -u vagrant --key-file "/path/to/ssh/private/key/file" \
--extra-vars "test_config=../test_configs/soop_xbt_nrt/config.yaml" \
--tags "init_db_only"
```

- Run only the fetching of database results 
It is possible to run the tool without invoking the harvester so that only the content of the schemas/tables for a given test is fetched using the `harvest_results_only` e.g.

```shell script
(ansible-virtualenv) ansible-playbook ansible/playbook_process.yaml \
-i test_configs/hosts -u vagrant --key-file "/path/to/ssh/private/key/file" \
--extra-vars "test_config=../test_configs/soop_xbt_nrt/config.yaml" \
--tags "harvest_results_only"
```

## Actions

- Run zero actions in a test

For debugging it may be useful to run a test with no actions. Edit a `test_config` file:
```yaml
...
actions:
  - type: NONE
# comment-out other actions
...
```

- Deleting files

The DELETE action can take either a `file` or a `path` as a parameter.
 
- `file` specifies a single file to delete. 
- `path` specifies a directory in which _all files will be deleted_
