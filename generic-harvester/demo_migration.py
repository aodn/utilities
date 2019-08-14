from migration import run
from collections import OrderedDict

import json

from harvester.output.database_store import DatabaseStore
from harvester.stubs.aodncore import PipelineFile
from harvester.timeseries_harvester import NetcdfTimeseriesHarvester

run.do_downgrade("base")
run.do_upgrade("dd40085d47ea")
run.do_upgrade("1bf1628fe336")
# run.do_downgrade("dd40085d47ea")

with open("config/abos_sofs_fl.json") as f:
    config = json.load(f, object_pairs_hook=OrderedDict)

netcdf_file = PipelineFile(
    24,
    "IMOS_ABOS-ASFS_FMT_20190805T015900Z_SOFS_FV02.nc",
    "IMOS_ABOS-ASFS_FMT_20190805T015900Z_SOFS_FV02.nc"
)

persistent_store = DatabaseStore(OrderedDict())

harvester = NetcdfTimeseriesHarvester(persistent_store, netcdf_file, config, None)
harvester.harvest()
#harvester.delete()

