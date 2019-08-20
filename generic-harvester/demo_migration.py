from migration.run import RunAlembic

import json
import os

from harvester import file_index
from harvester.metadata_harvester import NetcdfMetadataHarvester
from harvester.output.database_store import DatabaseStore
from harvester.stubs.aodncore import PipelineFile
from harvester.feature_harvester import NetcdfFeatureHarvester

# config_file = "config/abos_sofs_fl.json"
# src_path = "IMOS_ABOS-ASFS_FMT_20190805T015900Z_SOFS_FV02.nc"
# dest_path = "IMOS_ABOS-ASFS_FMT_20190805T015900Z_SOFS_FV02.nc"

config_file = "config/anmn_ts.json"
src_path = "IMOS_ANMN-QLD_TZ_20130204T000000Z_PIL100_FV01_PIL100-1301-SBE56-43_END-20130801T005134Z_C-20170621T070805Z.nc"
dest_path = "IMOS_ANMN-QLD_TZ_20130204T000000Z_PIL100_FV01_PIL100-1301-SBE56-43_END-20130801T005134Z_C-20170621T070805Z.nc"

with open(config_file) as f:
    config = json.load(f)

db_params = config["db_params"]
script_location = os.path.join("migration", db_params["schema"])
url = db_params["driver"]+"://"+db_params["user"]+":"+db_params["password"]+"@"+db_params["host"]+":"+db_params["port"]+"/"+db_params["database"]

run = RunAlembic(script_location, url)


persistent_store = DatabaseStore(db_params)

netcdf_file = PipelineFile(
    src_path,
    dest_path
)

netcdf_metadata_harvester = NetcdfMetadataHarvester(persistent_store, netcdf_file, config, None)
netcdf_feature_harvester = NetcdfFeatureHarvester(persistent_store, netcdf_file, config, None)

run.do_upgrade("head")
# file_index.add_or_update_file(persistent_store, netcdf_file)
# netcdf_metadata_harvester.harvest()
# netcdf_feature_harvester.harvest()


# file_index.delete_file(persistent_store, netcdf_file)
# netcdf_metadata_harvester.delete()
# netcdf_feature_harvester.delete()
# run.do_downgrade("base")


