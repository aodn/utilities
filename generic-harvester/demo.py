from collections import OrderedDict

import json

from harvester.source.netcdf import (NetcdfVariableSource, NetcdfFileSource)

input_file = {
    "src_path": "IMOS_ABOS-ASFS_FMT_20190805T015900Z_SOFS_FV02.nc"
}

json_config = """{
    "schema": "abos_sofs_fl",
    "user": "abos_sofs_fl",
    "password": "abos_sofs_fl",
    "mappings": {
        "variables": [
            {
                "name": "measurement",
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
            }
        ],
        "dataset": [
            {
                "name": "timeseries_file",
                "fields": {
                    "file_id": {"value": "file.id"},
                    "deployment_number": {"value": "dataset.deployment_number"},
                    "delivery_mode": {"value": "'RT' if re.match(r'.*Real-time.*', file.dest_path) else 'DM'"},
                    "latitude": {"value": "dataset['LATITUDE'][(0)]"},
                    "time_coverage_start": {"value": "parse_datetime(dataset.time_coverage_start)"},
                    "time_coverage_end": {"value": "parse_datetime(dataset.time_coverage_start)"},
                    "date_created": {"value": "parse_datetime(dataset.date_created)"}
                }
            }
        ]
    },
    "aggregations": [
        {
            "name": "timeseries",
            "fields": {
                "deployment_number": {"value": "deployment_number"},
                "mean_latitude": {"value": "avg(\\"LATITUDE\\")"},
                "mean_longitude": {"value": "avg(\\"LONGITUDE\\")"},
                "geom": {"value": "st_geomfromtext('POINT(' || avg(\\\"LONGITUDE\\") || ' ' || avg(\\"LATITUDE\\") || ')', 4326)"},
                "time_deployment_start": {"value": "min(\\"TIME\\")"},
                "time_deployment_end": {"value": "max(\\"TIME\\")"}
            },
            "group_by": ["deployment_number"],
            "where": "\\"LATITUDE\\" > -60 AND \\"LATITUDE\\" < -30 AND \\"LONGITUDE\\" > 130 AND \\"LONGITUDE\\" < 160"
        }
    ],
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


class PipelineFile(object):
    """
    Mock real PipelineFile for prototyping
    """

    # TODO: revisit id handling - more likely to be set by this step than initialised with it
    def __init__(self, id, src_path, dest_path):
        self.id = id
        self.src_path = src_path
        self.dest_path = dest_path


class NetcdfHarvester(object):
    
    def __init__(self, netcdf_file, config):
        self.netcdf_file = netcdf_file
        self.config = config
        
    def run(self):
        # TODO: look at using a factory function to create sources so don't have to replicate code below
        # TODO: and make it easier to test?
        for mapping in config["mappings"]["variables"]:
            variable_source = NetcdfVariableSource(self.netcdf_file, mapping)
            dump(variable_source)

        for mapping in config["mappings"]["dataset"]:
            file_source = NetcdfFileSource(self.netcdf_file, mapping)
            dump(file_source)


def dump(variable_source):
    # TODO: Add an output for this
    print(variable_source.field_names())
    output = [record for record in variable_source.records()]
    print(output)


netcdf_file = PipelineFile(24, "IMOS_ABOS-ASFS_FMT_20190805T015900Z_SOFS_FV02.nc",
                           "IMOS/ABOS/ASFS/SOFS/Surface_fluxes/Real-time/2018_daily/"
                           "IMOS_ABOS-ASFS_FMT_20190805T015900Z_SOFS_FV02.nc"
                           )

harvester = NetcdfHarvester(netcdf_file, config)
harvester.run()
