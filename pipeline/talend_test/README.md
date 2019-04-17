talend_test
===========

Runs harvester tests with static sets of input data, and extracts data from database to be used as a comparison.

## Setup
```
pip install -r requirements.txt
```

Allow setting of permissions on temporary files that ansible needs to create when becoming an unprivileged user

- add `allow_world_readable_tmpfiles=true` to `/etc/ansible/ansible.cfg` 
- edit `./global_vars.yaml` and update the path in `input_files_dir`

## run tests

Configurations for tests are in `test_configs`. E.g. To run the `anfog_dm` harvester on `6-nec-hob` use:
```
ansible-playbook ansible/playbook.yaml \
  -e @test_configs/anfog_dm.yaml \
  --ask-pass --user <your_ssh_user> \
  --extra-vars "hosts=6-nec-hob.emii.org.au"
```

After the playbook is finished, results will be available in the `query_results` dir.


## Compare results

If for example the same test config has been run against both `6-nec-hob` and `9-nec-hob`, then the `query_results` dir would looks something like this: 

```
query_results/
  6-nec-hob.emii.org.au/   #<-- host test was run against
    abos_asfs              #<-- the test config that was run
      anmn_metadata/       #<-- schema listed in the test config
        abos_all_map.csv   #<-- table listed in the schema        #<-- run diff
  9-nec-hob.emii.org.au/   #<-- host test was run against
    abos_asfs              #<-- the test config that was run
      anmn_metadata/       #<-- schema listed in the test config
        abos_all_map.csv   #<-- table listed in the schema        #<-- run diff
```

To check the difference between the output of the pipelines across both nodes:
```
diff -r query_results/6-nec-hob.emii.org.au query_results/9-nec-hob.emii.org.au
```

## Create a new test

- Add a new `<test>.yaml` file to the `./test_configs` dir.
- Note that there are several type of test: `pipeline_version_1`, `pipeline_version_2` and `harvester`
- Copy config from an appropiate existing test and change the values.
- database table columns that are not relevant for testing - e.g. timestamp of data insertion - can be excluded using `exclude_columns`.

## Notes

- Running a test first truncates any database schemas that are relevant to the test so that the database result is easily comparable to results from other pipeline nodes
- Running a test first removes pipeline/harvest logs. This is needed so that the playbook can perform a `wait` action and detect when processing has completed.
- All connections are via ansible-ssh to remote nodes. Postgresql queries could have be made directly from the ansible host to postgresql but then this would not work in scenarios where the database is not publicly accessible.

