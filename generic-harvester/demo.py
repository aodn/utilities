import json

from harvester import file_index
from harvester.metadata_harvester import NetcdfMetadataHarvester
from harvester.output.database_store import DatabaseStore
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
    config = json.load(f)

with open("config/file_index.json") as f:
    index_config = json.load(f)

netcdf_file = PipelineFile(
    "IMOS_ANMN-NSW_TZ_20141118T130000Z_BMP070_FV01_BMP070-1411-Aqualogger-520PT-16_END-20150504T063500Z_C-20160901T044727Z.nc",
    "IMOS_ANMN-NSW_TZ_20141118T130000Z_BMP070_FV01_BMP070-1411-Aqualogger-520PT-16_END-20150504T063500Z_C-20160901T044727Z.nc"
)

index_store = DatabaseStore(index_config["db_params"])
feature_store = DatabaseStore(config["db_params"])

netcdf_metadata_harvester = NetcdfMetadataHarvester(index_store, netcdf_file, config, None)
netcdf_feature_harvester = NetcdfFeatureHarvester(feature_store, netcdf_file, config, None)

file_index.add_or_update_file(index_store, netcdf_file)
netcdf_metadata_harvester.harvest()
netcdf_feature_harvester.harvest()

# file_index.delete_file(persistent_store, netcdf_file)
# netcdf_metadata_harvester.delete()
# netcdf_feature_harvester.delete()
