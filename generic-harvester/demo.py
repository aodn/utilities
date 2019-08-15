from collections import OrderedDict

import json

from harvester import file_index
from harvester.metadata_harvester import NetcdfMetadataHarvester
from harvester.output.database_store import DatabaseStore
from harvester.output.memory_store import MemoryStore
from harvester.stubs.aodncore import PipelineFile
from harvester.timeseries_harvester import NetcdfTimeseriesHarvester

with open("config/abos_sofs_fl.json") as f:
    config = json.load(f, object_pairs_hook=OrderedDict)

netcdf_file = PipelineFile(
    "IMOS_ABOS-ASFS_FMT_20190805T015900Z_SOFS_FV02.nc",
    "IMOS_ABOS-ASFS_FMT_20190805T015900Z_SOFS_FV02.nc"
)

persistent_store = DatabaseStore(OrderedDict())

file_index.add_or_update_file(persistent_store, netcdf_file)

# TODO: add table creation to alembic for netcdf metadata
metadata_harvester = NetcdfMetadataHarvester(persistent_store, netcdf_file, config, None)
metadata_harvester.harvest()
timeseries_harvester = NetcdfTimeseriesHarvester(persistent_store, netcdf_file, config, None)
timeseries_harvester.harvest()

# file_index.delete_file(persistent_store, netcdf_file)
# metadata_harvester.delete()
# harvester.delete()
