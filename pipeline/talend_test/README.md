talend_test
===========

Runs harvester tests with static sets of input data, and extracts data from database to be used as a comparison.

## Setup
```
pip install -r requirements.txt
```

Allow setting of permissions on temporary files that ansible needs to create when becoming an unprivileged user

- add `allow_world_readable_tmpfiles=true` to `/etc/ansible/ansible.cfg` 
- edit `./global_vars.yaml` and update any placeholders `<that_look_like_this>`

Create .pgpass entries
- refer to [this document](https://blog.sleeplessbeastie.eu/2014/03/23/how-to-non-interactively-provide-password-for-the-postgresql-interactive-terminal/) for how to create a .pgpass file
- e.g. add an entry like this:
  ```6-nec-hob.emii.org.au:5432:harvest:<your_db_username>:<your_db_password>```

Configure your AWS profile e.g:
```
export AWS_PROFILE=production-developer
```

## run tests

Configurations for tests are in `test_configs`. E.g. To run the `anfog_dm` harvester on `6-nec-hob` use:
```
ansible-playbook ansible/playbook.yaml \
  -e @test_configs/anfog_dm.yaml \
  --ask-pass --user <your_ssh_user> \
  --extra-vars "hosts=6-nec-hob.emii.org.au"
```

After the playbook is finished, results will be available in the `harvest_results` dir.


## Compare results

If for example the same test config has been run against both `6-nec-hob` and `9-nec-hob`, then the `harvest_results` dir would looks something like this: 

```
harvest_results/
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
diff -r harvest_results/6-nec-hob.emii.org.au harvest_results/9-nec-hob.emii.org.au
```

## Create a new test

- Add a new `<test>.yaml` file to the `./test_configs` dir.
- Note that there are several type of test: `pipeline_version_1`, `pipeline_version_2` and `harvester`
- Copy config from an appropiate existing test and change the values.
- database table columns that are not relevant for testing - e.g. timestamp of data insertion - can be excluded using `exclude_columns`.

##Options

### Database user parameter
In case your harvest database user differs from your remote ssh user, add `db_user=<your_harvest_username>` to the list of `--extra-vars` e.g.

```
ansible-playbook ansible/playbook.yaml \
  -e @test_configs/anfog_dm.yaml \
  --ask-pass --user <your_ssh_user> \
  --extra-vars "hosts=6-nec-hob.emii.org.au db_user=<your_harvest_username>" \
  --tags "init_db_only"
```

### Run only the db initialisation step for schemas in the test


```
ansible-playbook ansible/playbook.yaml \
  -e @test_configs/anfog_dm.yaml \
  --ask-pass --user <your_ssh_user> \
  --extra-vars "hosts=6-nec-hob.emii.org.au" \
  --tags "init_db_only"
```

## Run only the fetching of database results 
It is possible to run the tool without invoking the harvester so that only the content of the schemas/tables for a given test is fetched using the `harvest_results_only` e.g.
```
ansible-playbook ansible/playbook.yaml \
  -e @test_configs/anfog_dm.yaml \
  --ask-pass --user <your_ssh_user> \
  --extra-vars "hosts=6-nec-hob.emii.org.au" \
  --tags "harvest_results_only"
```

## Run zero actions in a test

For debugging it may be useful to run a test with no actions. Edit a `test_config` file:
```
...
actions:
  - type: NONE
# comment-out other actions
...
```

## Deleting files

The DELETE action can take either a `file` or a `path` as a parameter.
 
- `file` specifies a single file to delete. 
- `path` specifies a directory in which _all files will be deleted_

## Notes

- Running a test first removes pipeline/harvest logs. This is needed so that the playbook can perform a `wait` action and detect when processing has completed.
