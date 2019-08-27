import json
from collections import OrderedDict

from datetime import datetime

from harvester.source.netcdf import NetcdfMeasurementSource
from harvester.stubs.aodncore import PipelineFile

with open("config/anmn_ts.json") as f:
    config = json.load(f, object_pairs_hook=OrderedDict)

netcdf_file = PipelineFile(
    "IMOS_ANMN-QLD_TZ_20130204T000000Z_PIL100_FV01_PIL100-1301-SBE56-43_END-20130801T005134Z_C-20170621T070805Z.nc",
    "IMOS_ANMN-QLD_TZ_20130204T000000Z_PIL100_FV01_PIL100-1301-SBE56-43_END-20130801T005134Z_C-20170621T070805Z.nc",
    24
)

source = NetcdfMeasurementSource(netcdf_file, config["measurement"])

print(datetime.now())

for row in source.records():
    pass

print(datetime.now())
