from collections import OrderedDict

import json

from harvester.output.memory_store import MemoryStore
from harvester.stubs.aodncore import PipelineFile
from harvester.timeseries_harvester import NetcdfTimeseriesHarvester

with open("config/anmn_ts.json") as f:
    config = json.load(f, object_pairs_hook=OrderedDict)

netcdf_file = PipelineFile(
    24,
    "IMOS_ANMN-QLD_TZ_20130204T000000Z_PIL100_FV01_PIL100-1301-SBE56-43_END-20130801T005134Z_C-20170621T070805Z.nc",
    "IMOS_ANMN-QLD_TZ_20130204T000000Z_PIL100_FV01_PIL100-1301-SBE56-43_END-20130801T005134Z_C-20170621T070805Z.nc"
)

persistent_store = MemoryStore(OrderedDict())

harvester = NetcdfTimeseriesHarvester(persistent_store, netcdf_file, config, None)
harvester.harvest()
harvester.delete()
