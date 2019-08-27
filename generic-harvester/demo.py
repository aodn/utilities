import json
from collections import OrderedDict

from harvester import file_index
from harvester.metadata_harvester import NetcdfMetadataHarvester
from harvester.output.psycopg2_store import Psycopg2Store
from harvester.stubs.aodncore import PipelineFile
from harvester.feature_harvester import NetcdfFeatureHarvester

# with open("config/abos_sofs_fl.json") as f:
#     config = json.load(f)
#
# netcdf_file = PipelineFile(
#     "IMOS_ABOS-ASFS_FMT_20190805T015900Z_SOFS_FV02.nc",
#     "IMOS_ABOS-ASFS_FMT_20190805T015900Z_SOFS_FV02.nc"
# )

with open("config/anmn_ts.json") as f:
    config = json.load(f, object_pairs_hook=OrderedDict)

with open("config/file_index.json") as f:
    index_config = json.load(f, object_pairs_hook=OrderedDict)

# netcdf_file = PipelineFile(
#     "IMOS_ANMN-NSW_TZ_20141118T130000Z_BMP070_FV01_BMP070-1411-Aqualogger-520PT-16_END-20150504T063500Z_C-20160901T044727Z.nc",
#     "IMOS_ANMN-NSW_TZ_20141118T130000Z_BMP070_FV01_BMP070-1411-Aqualogger-520PT-16_END-20150504T063500Z_C-20160901T044727Z.nc"
# )

netcdf_file = PipelineFile(
    "IMOS_ANMN-QLD_TZ_20130204T000000Z_PIL100_FV01_PIL100-1301-SBE56-43_END-20130801T005134Z_C-20170621T070805Z.nc",
    "IMOS_ANMN-QLD_TZ_20130204T000000Z_PIL100_FV01_PIL100-1301-SBE56-43_END-20130801T005134Z_C-20170621T070805Z.nc"
)

index_store = Psycopg2Store(index_config["db_params"])
feature_store = Psycopg2Store(config["db_params"])

netcdf_metadata_harvester = NetcdfMetadataHarvester(index_store, netcdf_file, config, None)
netcdf_feature_harvester = NetcdfFeatureHarvester(feature_store, netcdf_file, config, None)

file_index.add_or_update_file(index_store, netcdf_file)
netcdf_metadata_harvester.harvest()
netcdf_feature_harvester.harvest()

