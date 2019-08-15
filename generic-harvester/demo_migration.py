from migration import run
from collections import OrderedDict

import json

from harvester.output.database_store import DatabaseStore
from harvester.stubs.aodncore import PipelineFile
from harvester.feature_harvester import NetcdfFeatureHarvester

run.do_downgrade("base")
run.do_upgrade("head")

with open("config/abos_sofs_fl.json") as f:
    config = json.load(f, object_pairs_hook=OrderedDict)

netcdf_file = PipelineFile(
    "IMOS_ABOS-ASFS_FMT_20190805T015900Z_SOFS_FV02.nc",
    "IMOS_ABOS-ASFS_FMT_20190805T015900Z_SOFS_FV02.nc",
    24
)

persistent_store = DatabaseStore(OrderedDict())

harvester = NetcdfFeatureHarvester(persistent_store, netcdf_file, config, None)
harvester.harvest()
#harvester.delete()

