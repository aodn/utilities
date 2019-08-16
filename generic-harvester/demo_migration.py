from migration import run
from collections import OrderedDict

import json

from harvester import file_index
from harvester.metadata_harvester import NetcdfMetadataHarvester
from harvester.output.database_store import DatabaseStore
from harvester.stubs.aodncore import PipelineFile
from harvester.feature_harvester import NetcdfFeatureHarvester

run.do_downgrade("base")
run.do_upgrade("head")

with open("config/abos_sofs_fl.json") as f:
    config = json.load(f, object_pairs_hook=OrderedDict)

netcdf_file = PipelineFile(
    "IMOS_ABOS-ASFS_FMT_20190805T015900Z_SOFS_FV02.nc",
    "IMOS_ABOS-ASFS_FMT_20190805T015900Z_SOFS_FV02.nc"
)

persistent_store = DatabaseStore()

netcdf_metadata_harvester = NetcdfMetadataHarvester(persistent_store, netcdf_file, config, None)
netcdf_feature_harvester = NetcdfFeatureHarvester(persistent_store, netcdf_file, config, None)

file_index.add_or_update_file(persistent_store, netcdf_file)
netcdf_metadata_harvester.harvest()
netcdf_feature_harvester.harvest()

# file_index.delete_file(persistent_store, netcdf_file)
# netcdf_metadata_harvester.delete()
# netcdf_feature_harvester.delete()


