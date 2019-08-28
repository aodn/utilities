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

```
sudo su - postgres
createdb test_harvest
psql -d test_harvest -c "create extension postgis;"
psql -c "CREATE USER file_index WITH PASSWORD 'file_index';"
psql -d test_harvest -c "CREATE SCHEMA AUTHORIZATION file_index;"
psql -d test_harvest -c "GRANT USAGE ON SCHEMA file_index TO public;"
psql -c "CREATE USER anmn_ts WITH PASSWORD 'anmn_ts';"
psql -d test_harvest -c "CREATE SCHEMA AUTHORIZATION anmn_ts;"
psql -c "CREATE USER abos_sofs_fl WITH PASSWORD 'abos_sofs_fl';"
psql -d test_harvest -c "CREATE SCHEMA AUTHORIZATION abos_sofs_fl;"
exit

```

#### Creating example tables/views using alembic

Alembic is currently being used to create tables/views in the target schemas (see issues below - may change).
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
  -c config/anmn_ts.json -i config/file_index.json \
  -s 'IMOS_ANMN-NSW_TZ_20141118T130000Z_BMP070_FV01_BMP070-1411-Aqualogger-520PT-16_END-20150504T063500Z_C-20160901T044727Z.nc' \
  -d 'IMOS/ANMN/NSW/BMP070/Temperature/IMOS_ANMN-NSW_TZ_20141118T130000Z_BMP070_FV01_BMP070-1411-Aqualogger-520PT-16_END-20150504T063500Z_C-20160901T044727Z.nc'
```

#### Issues:

 - alembic doesn't work with default privileges (they are not applied) meaning we would 
   have to rework all the current chef management of roles and groups - may have to find another solution

#### TODO:

 - logging
 - sensible exception handling
 - config validation
 - value_table expressions (add lambda support to expression parser)
 