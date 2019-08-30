### Feature Harvester Prototype

Prototype netCDF feature harvester for harvesting timeseries information from netCDF files

#### Installing

```
git clone git@github.com:aodn/utilities.git
cd utilities/
git checkout generic-harvester-prototype
cd generic-harvester/
virtualenv --python=/usr/bin/python3.5 venv
source venv/bin/activate
pip install -r requirements.txt
```

#### Creating test database and example schemas

Schemas, roles and permissions are normally managed using chef/ansible.  Here we will create them 
manually to simplify setup work we need to perform for the prototype. 

Run the following sql statements as the postgres user or a user with the required access

```
CREATE DATABASE test_harvest;
CREATE USER file_index WITH PASSWORD 'file_index';
CREATE USER anmn_ts WITH PASSWORD 'anmn_ts';
CREATE USER abos_sofs_fl WITH PASSWORD 'abos_sofs_fl';
```

Then connect to the test_harvest database and run

```
CREATE EXTENSION postgis;
CREATE SCHEMA AUTHORIZATION file_index;
GRANT USAGE ON SCHEMA file_index TO public;
CREATE SCHEMA AUTHORIZATION anmn_ts;
CREATE SCHEMA AUTHORIZATION abos_sofs_fl;
```

#### Creating example tables/views using alembic

Alembic is currently being used to create tables/views in the target schemas (see issues below).
Alembic performs a similar function to liquibase which most PO's are currently familiar with.

Database migrations (revisions in Alembic terms) for the file_index, anmn_ts and abos_sofs_fl 
tables and views can be found in migration/abos_sofs_fl, migration/anmn_ts and migration/abos_sofs_fl
directories.

To run these migrations to create the required tables for the example config files:

```
python run_harvester.py db-create  -c config/file_index.json
python run_harvester.py db-create  -c config/anmn_ts.json
python run_harvester.py db-create  -c config/abos_sofs_fl.json
```

### Running feature harvester with example configs 

To run the feature harvester for bundled anmn_ts and abos_sofs_fl files:

```
python run_harvester.py harvest \
  -c config/abos_sofs_fl.json \
  -i config/file_index.json \
  -s IMOS_ABOS-ASFS_FMT_20190805T015900Z_SOFS_FV02.nc \
  -d IMOS/ABOS/ASFS/SOFS/Surface_fluxes/Real-time/2019_daily/IMOS_ABOS-ASFS_FMT_20190805T015900Z_SOFS_FV02.nc

python run_harvester.py harvest \
  -c config/anmn_ts.json \
  -i config/file_index.json \
  -s 'IMOS_ANMN-NSW_TZ_20141118T130000Z_BMP070_FV01_BMP070-1411-Aqualogger-520PT-16_END-20150504T063500Z_C-20160901T044727Z.nc' \
  -d 'IMOS/ANMN/NSW/BMP070/Temperature/IMOS_ANMN-NSW_TZ_20141118T130000Z_BMP070_FV01_BMP070-1411-Aqualogger-520PT-16_END-20150504T063500Z_C-20160901T044727Z.nc'
```

### Configuring the feature harvester

Best read while looking at an example config file in the config directory

#### db_params

Specifies database connection details to use. Authentication is required to update metadata records. 

| key | value |
| --- | --- |
| driver | sql alchemy driver |
| host | host to connect to |
| port | port to connect to |
| database | database to connect to |
| user | user to connect as |
| password | password to use |
| schema | schema directory to use (alembic) |

#### value_mappings

An array of value mappings. Value mappings map netCDF variable values to fields in target tables.

#### value_mapping

A value mapping maps values from variables with the specified dimensions in the source netcdf file to 
fields in the target output table.

| key | value |
| --- | --- |
| table | table into which values should be inserted/deleted |
| dimensions | values from variables with these dimensions will be available for inclusion in mapped values |
| fields | dictionary of variable value to field mappings |

#### field_mapping (value_mapping)

Mapping of variable values to field in target output table

Only one mapping (the default mapping {}) is supported at the moment which is, map the value of the variable 
with the name of the field value of the field.  This could be expanded on in future to allow
simple expressions to be used to map variable values to field values as described below for file_metadata
if required.

#### file_metadata

Mapping of file level metadata in the source netCDF file to the target output table.

| key | value |
| --- | --- |
| table | name of output table (defaults to "file_metadata" if not specified) |
| fields | dictionary of file metadata to field mappimgs |

#### field mapping (file_metadata)

Mapping of file metadata to field in the output table

Currently supports three types of mappings:

* the default mapping {} - map the value of the global attribute with the name of the field to the field value
* datetime mapping {"type": "datetime"} - parse the value of the global attribute with the name of the field
  as a datetime.  If a time zone isn't specified set the time zone to UTC
* simple expression {"value": "simple python expression"} - evaluate the "simple python expression" to 
  calculate the field's value.   The netCDF4 dataset will be available for use ("dataset") as well as details 
  about the file being processed ("file").   A restricted set of functions will also be available for use 
  which are currently:
  
  * re - for performing regular expression matching
  * parse_datetime - for performing your own datetime parsing
  * average - numpy.average
  * mean - numpy.mean
  * amin - numpy.amin
  * amax - numpy.amax
  * getattr - for getting attribute values with a default
  * point(x, y) - for creating a postgres EWKT point string for ingestion into postgres
  
  This list can be easily extended as required (requires minor code changes)
  
  See config files in the config directory for examples.
  
#### aggregations

An array of aggregations/updates/db actions to be performed after harvesting variable values/file metadata

#### aggregation

An aggregation/update/db action to be performed after harvesting variable values/file metadata

| key | value |
| --- | --- |
| table | if specified, previously aggregated details in this table for the key specified below are deleted before performing the aggregation |
| key | fields from the file_metadata table that define the key of the aggregation details to be updated |
| query | an array of strings joined together to form the templated query used to perform the aggregation/update/db action. |

The templated query string can use key place holders to aggregate details for the specified key only.
When used with the table key this allows only aggregated details associated with the source file 
to be updated rather than updating all aggregated details for all files.  This is 
far less resource intensive/time consuming and should be used wherever possible. 

### Running metadata updater with example configs 

To run the metadata updater for bundled anmn_ts and abos_sofs_fl files:

```
python run_harvester.py update-metadata -c config/abos_sofs_fl.json

python run_harvester.py update-metadata -c config/anmn_ts.json
```

### Configuring the metadata updater

#### geonetwork_params

Specifies necessary geonetwork server connection details. 

| key | value |
| --- | --- |
|url| url of the geonetwork server|
|username| username to connect to the geonetwork server|
|password|password to connect to the geonetwork server|

#### metadata_updates

Metadata updates includes updates of following extent elements (spatial, temporal and vertical) of the metadata records.

| key | value |
| --- | --- |
| uuid | uuid of the metadata record |
| spatial | spatial extent (bounding polygons) |
| temporal | temporal extent (begin and end time) |
| vertical | vertical extent (min and max depth) |

#### spatial

| key | value |
| --- | --- |
| table | feature metadata table |
| column | geometry column of the feature metadata table |
| resolution | spatial resolution |

#### temporal

| key | value |
| --- | --- |
| table | name of the measurement table |
| column | name of temporal column of the measurement table |

#### vertical

| key | value |
| --- | --- |
| relation | name of the measurement table |
| min_column | name of the depth column to calculate min value |
| max_column | name of the depth column to calculate max value |

For vertical extent, if DEPTH column does not exists in measurement table, then we retrieve it from 
global attribute table as shown below:

| key | value |
| --- | --- |
| relation | (SELECT vertical_mins.value::real as vertical_min, vertical_maxs.value::real as vertical_max FROM file_metadata fm  JOIN file_index.nc_global_attribute vertical_mins ON (fm.file_id = vertical_mins.file_id AND vertical_mins.name = 'geospatial_vertical_min') JOIN file_index.nc_global_attribute vertical_maxs ON (fm.file_id = vertical_maxs.file_id AND vertical_maxs.name = 'geospatial_vertical_max'))|
| min_column | vertical_min |
| max_column | vertical_max |

Note: verticalCRS element mandatory for schema validation is set as missing.  `<gmd:verticalCRS gco:nilReason=\"missing\"/>` 

#### Issues:

 - alembic doesn't work with default privileges (they are not applied) meaning we would 
   have to rework all the current chef management of roles and groups - may have to find another solution

#### TODO:

 - index_manager?
 - revisit database classes - transaction around all file updates - connection pooling
 - more testing/integration tests
 - sensible exception handling
 - config validation (when config settles down)
 - value_table expressions (add lambda support to expression parser)
 
