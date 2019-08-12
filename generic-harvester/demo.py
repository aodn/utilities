from collections import OrderedDict

import json

from harvester.netcdf_harvester import NetcdfTimeseriesHarvester
from harvester.stubs.aodncore import PipelineFile

input_file = {
    "src_path": "IMOS_ABOS-ASFS_FMT_20190805T015900Z_SOFS_FV02.nc"
}

json_config = """{
    "schema": "abos_sofs_fl",
    "user": "abos_sofs_fl",
    "password": "abos_sofs_fl",
    "measurement": {
        "dimensions": ["TIME"],
        "fields": {
            "file_id": {"value": "file.id"},
            "index": {"value": "indexes['TIME']"},
            "TIME": {},
            "LATITUDE": {},
            "LONGITUDE": {},
            "PL_CMP": {},
            "WDIR": {},
            "WSPD": {},
            "WIND_H": {},
            "WIND_FLAG": {},
            "ATMP": {},
            "ATMP_H": {},
            "ATMP_FLAG": {},
            "AIRT": {},
            "AIRT_H": {},
            "AIRT_FLAG": {},
            "RELH": {},
            "RELH_H": {},
            "RELH_FLAG": {},
            "TEMP": {},
            "TEMP_H": {},
            "TEMP_FLAG": {},
            "RAIN_AMOUNT": {},
            "RAIN_AMOUNT_H": {},
            "RAIN_AMOUNT_FLAG": {},
            "SW": {},
            "SW_H": {},
            "SW_FLAG": {},
            "LW": {},
            "LW_H": {},
            "LW_FLAG": {},
            "HS": {},
            "HL": {},
            "H_RAIN": {},
            "TAU": {},
            "SST": {},
            "HEAT_NET": {},
            "MASS_NET": {},
            "LW_NET": {},
            "SW_NET": {},
            "WSPD10M": {},
            "AIRT1_5M": {},
            "AIRT2_0M": {},
            "RELH1_5M": {},
            "RELH2_0M": {}
        }
    },
    "timeseries_file": {
        "fields": {
            "file_id": {"value": "file.id"},
            "deployment_number": {"value": "dataset.deployment_number"},
            "delivery_mode": {"value": "'RT' if re.match(r'.*Real-time.*', file.dest_path) else 'DM'"},
            "latitude": {"value": "dataset['LATITUDE'][(0)].item()"},
            "time_coverage_start": {"value": "parse_datetime(dataset.time_coverage_start)"},
            "time_coverage_end": {"value": "parse_datetime(dataset.time_coverage_start)"},
            "date_created": {"value": "parse_datetime(dataset.date_created)"}
        }
    },
    "timeseries_key": ["deployment_number"],
    "timeseries": {
        "fields": {
            "deployment_number": {"value": "deployment_number"},
            "mean_latitude": {"value": "avg(\\"LATITUDE\\")"},
            "mean_longitude": {"value": "avg(\\"LONGITUDE\\")"},
            "geom": {"value": "st_geomfromtext('POINT(' || avg(\\\"LONGITUDE\\") || ' ' || avg(\\"LATITUDE\\") || ')', 4326)"},
            "time_deployment_start": {"value": "min(\\"TIME\\")"},
            "time_deployment_end": {"value": "max(\\"TIME\\")"}
        },
        "where": "\\"LATITUDE\\" > -60 AND \\"LATITUDE\\" < -30 AND \\"LONGITUDE\\" > 130 AND \\"LONGITUDE\\" < 160"
    },
    "metadata_updates": [
        {
          "uuid": "09319023093810983098",
          "spatial_table": "timeseries",
          "spatial_column": "geom",
          "spatial_resolution": 3
        }
    ]
}
"""

config = json.loads(json_config, object_pairs_hook=OrderedDict)

netcdf_file = PipelineFile(24, "IMOS_ABOS-ASFS_FMT_20190805T015900Z_SOFS_FV02.nc",
                           "IMOS/ABOS/ASFS/SOFS/Surface_fluxes/Real-time/2018_daily/"
                           "IMOS_ABOS-ASFS_FMT_20190805T015900Z_SOFS_FV02.nc"
                           )

harvester = NetcdfTimeseriesHarvester(output_manager, netcdf_file, config)
harvester.run()
