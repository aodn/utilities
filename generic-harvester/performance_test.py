import json
from collections import OrderedDict

from datetime import datetime

from harvester.source.netcdf import NetcdfValueSource
from harvester.stubs.aodncore import PipelineFile

with open("config/anmn_ts.json") as f:
    config = json.load(f, object_pairs_hook=OrderedDict)

netcdf_file = PipelineFile(
    "IMOS_ANMN-QLD_TZ_20130204T000000Z_PIL100_FV01_PIL100-1301-SBE56-43_END-20130801T005134Z_C-20170621T070805Z.nc",
    "IMOS_ANMN-QLD_TZ_20130204T000000Z_PIL100_FV01_PIL100-1301-SBE56-43_END-20130801T005134Z_C-20170621T070805Z.nc",
    24
)

# with open("config/srs.json") as f:
#     config = json.load(f, object_pairs_hook=OrderedDict)
#
# netcdf_file = PipelineFile(
#     "20100101032000-ABOM-L3C_GHRSST-SSTskin-AVHRR16_D-1d_day.nc",
#     "20100101032000-ABOM-L3C_GHRSST-SSTskin-AVHRR16_D-1d_day.nc",
#     24
# )

source = NetcdfValueSource(netcdf_file, config["measurement"])

print(datetime.now())

for row in source.records():
    pass

print(datetime.now())
