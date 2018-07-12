## point-of-truth-wranger

### The Problem
You need to migrate collections from one geonetwork instance to another using the `MEF` format. With this type of harvesting method, any `Point of truth` entries on the remote site are harvested in and cannot easily be changed (and since you're migrating the record instead of simple harvesting it; this is not ideal).

### The Solution

Harvest the collections from the source cataloue into a staging geonetwork instance where you can safely edit metadata (in the database) and verify it is correct before harvesting into the target catalogue.

Editing the `Point of truth` is possible by executing sql statements on a database. For this reason, the staging geoserver instance needs to be configured using `postgresql` instead of the default `h2`


### NOTES
- this solution doesn't _add_ point of truth entries to records; it only updates existing

### Setup staging instance

1. Deploy a staging geonetwork instance e.g. using cloud-deploy
2. configure staging geonetwork instance to use postgresql

3. System Configuration
    - go to 'Adminstration'
    - click 'System configuration'
    - preferred protocol: *<desired point of truth schema>*
    - host: *<set to the desired point of truth>*
    - port: 80
    - secure port: 443
    - save

4. Configure new harvester
    - type: GeoNetwork v2.1 remote node
    - name: some useful name
    - url: https://some.remote.catalogue/geonetwork
    - Use full MEF format (check)
    - Use Account: (uncheck)
    - One run only: (check)
    - click Retrieve Groups and set 'all' to 'Copy'
    - Save

5. Run the harvester
6. make sure harvester is definitely set to 'inactive'

### Update Points of Truth procedure
```
# set some environment variables
METADATA_DOWNLOAD_DIR=/tmp/metadata_records

# your target geonetwork host (including '/geonetwork' endpoint)
GEONETWORK=https://your-geonetwork.aodn.org.au/geonetwork

# the host (must inlcude schema) that will replace any existing point of truth url
REPLACEMENT_HOST=https://some.catalogue.com


mkdir $METADATA_DOWNLOAD_DIR
```

download all metadata records to disk
```
python saver.py $GEONETWORK $METADATA_DOWNLOAD_DIR
```

generate csv containing *uuid,link* of each record that has a `Point of truth` entry
```
python get_point_of_truth.py $METADATA_DOWNLOAD_DIR > $METADATA_DOWNLOAD_DIR/points-of-truth.csv
```

take a look at the contents e.g.
```
cat $METADATA_DOWNLOAD_DIR/points-of-truth.csv

4df98f39-425a-4752-b6d8-aaf8cb741e61,https://example.com/geonetwork/srv/en/metadata.show?uuid=4df98f39-425a-4752-b6d8-aaf8cb741e61
9226b9ea-2de9-4f6b-a724-421802001438,https://example.com/geonetwork/srv/en/metadata.show?uuid=9226b9ea-2de9-4f6b-a724-421802001438
46b86471-7ad0-41db-825b-baff2daacb1d,https://example.com/geonetwork/srv/en/metadata.show?uuid=46b86471-7ad0-41db-825b-baff2daacb1d
4dae96c7-5be0-4b1d-9a01-160812886a91,https://example.com/geonetwork/srv/en/metadata.show?uuid=4dae96c7-5be0-4b1d-9a01-160812886a91
...
```
Ensure that for each record, the point of truth link only occurs once in the metadata. The result of this report will let you know if you can continue.
```
python report_count_link_occurance.py $METADATA_DOWNLOAD_DIR $METADATA_DOWNLOAD_DIR/points-of-truth.csv
```
generate sql _update_ statements
```
python generate_sql.py /tmp/metadata_records/points-of-truth.csv $REPLACEMENT_HOST > $METADATA_DOWNLOAD_DIR/update_points_of_truth.sql
```

The `update_points_of_truth.sql` script can now be executed on the `geonetwork` db
```
cat $METADATA_DOWNLOAD_DIR/update_points_of_truth.sql
```

### Verify

Once the sql script has been run, use these steps to verify what the updated points of truth are

VERIFY_DIR=/tmp/metadata_verify
mkdir $VERIFY_DIR

```
python saver.py $GEONETWORK $VERIFY_DIR
```

output all points of truth
```
python get_point_of_truth.py $VERIFY_DIR
```

from this output you can verify the urls for any record that has a `Point of truth`