import harvester.io.netcdf as netcdf
import petl
import netCDF4 as nc
import re
from collections import OrderedDict
from simpleeval import simple_eval

#TODO:
# - review table/view creation/management alembic
# - review expression parsers/select most appropriate
# - replace petl usage
# - output api/transaction management
# - pipeline integration

input_file = {
    "src_path": "IMOS_ABOS-ASFS_FMT_20190805T015900Z_SOFS_FV02.nc"
}

config = {
    "schema": "abos_sofs_fl",
    "user": "abos_sofs_fl",
    "password": "abos_sofs_fl",
    "outputs": {
        "measurement": {
            "source": "values",
            "mapping" : {
                "file_id": {"type": "int64", "value": "context.file_id"},
                "index": {"type": "int32", "value": "index('TIME')"},
                "TIME": {"type": "datetime"},
                "LATITUDE": {"type": "float32"},
                "LONGITUDE": {"type": "float32"},
                "PL_CMP": {"type": "float32"},
                "WDIR": {"type": "float32"},
                "WSPD": {"type": "float32"},
                "WIND_H": {"type": "float32"},
                "WIND_FLAG": {"type": "int32"},
                "ATMP": {"type": "float32"},
                "ATMP_H": {"type": "float32"},
                "ATMP_FLAG": {"type": "int32"},
                "AIRT": {"type": "float32"},
                "AIRT_H": {"type": "float32"},
                "AIRT_FLAG": {"type": "int32"},
                "RELH": {"type": "float32"},
                "RELH_H": {"type": "float32"},
                "RELH_FLAG": {"type": "int32"},
                "TEMP": {"type": "float32"},
                "TEMP_H": {"type": "float32"},
                "TEMP_FLAG": {"type": "int32"},
                "RAIN_AMOUNT": {"type": "float32"},
                "RAIN_AMOUNT_H": {"type": "float32"},
                "RAIN_AMOUNT_FLAG": {"type": "int32"},
                "SW": {"type": "float32"},
                "SW_H": {"type": "float32"},
                "SW_FLAG": {"type": "int32"},
                "LW": {"type": "float32"},
                "LW_H": {"type": "float32"},
                "LW_FLAG": {"type": "int32"},
                "HS": {"type": "float32"},
                "HL": {"type": "float32"},
                "H_RAIN": {"type": "float32"},
                "TAU": {"type": "float32"},
                "SST": {"type": "float32"},
                "HEAT_NET": {"type": "float32"},
                "MASS_NET": {"type": "float32"},
                "LW_NET": {"type": "float32"},
                "SW_NET": {"type": "float32"},
                "WSPD10M": {"type": "float32"},
                "AIRT1_5M": {"type": "float32"},
                "AIRT2_0M": {"type": "float32"},
                "RELH1_5M": {"type": "float32"},
                "RELH2_0M": {"type": "float32"}
            }
        },
        "timeseries_file": {
            "source": "metadata",
            "mappings": {
                "file_id": {"type": "int64", "value": "context['file_id']"},
                "deployment_number": {"type": "str", "value": "dataset.deployment_number"},
                "delivery_mode": {"type": "str", "value": "'RT' if re.match(r'Real-time', context.url) else 'DM'"},
                "latitude": {"value": "dataset['LATITUDE'][(0)]"},
                "time_coverage_start": {"type": "datetime", "value": "dataset.time_coverage_start"},
                "time_coverage_end": {"type": "datetime", "value": "dataset.time_coverage_start"},
                "date_created": {"type": "datetime", "value": "dataset.date_created"}
            }
        },
        "timeseries": {
            "source": "aggregation",
            "columns": {
                "deployment_number": {"type": "str", "value": "deployment_number"},
                "mean_latitude": {"type": "float64", "value": "avg(\"LATITUDE\")"},
                "mean_longitude": {"type": "float64", "value": "avg(\"LONGITUDE\")"},
                "geom": {
                    "type": "geometry",
                    "value": "st_geomfromtext('POINT(' || avg(\"LONGITUDE\") || ' ' || avg(\"LATITUDE\") || ')', 4326)"
                },
                "time_deployment_start": {"type": "datetime", "value": "min(\"TIME\")"},
                "time_deployment_end": {"type": "datetime", "value": "max(\"TIME\")"}
            },
            "group_by": ["deployment_number"],
            "where": "\"LATITUDE\" > -60 AND \"LATITUDE\" < -30 AND \"LONGITUDE\" > 130 AND \"LONGITUDE\" < 160"
        }
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


class NetcdfHarvester(object): 
    
    def __init__(self, src_path, config):
        
        self.src_path = src_path
        self.config = config
        
    def run(self):

        dataset = nc.Dataset(self.src_path)
        
        try:
            
            for output_name, output_defn in config["outputs"].items():
                if output_defn["source"] == "values":
                    requested_variables = OrderedDict((name, mapping) for (name, mapping) in output_defn["mapping"].items() if not "values" in mapping.keys())
                    # Replace with non-petl version
                    table_data = netcdf.fromnetcdf(self.src_path, requested_variables)
                    #print(table_data)
                elif output_defn["source"] == "metadata":
                    mappings = output_defn["mappings"]
                    variables = {
                        "dataset": dataset,
                        "context" : {
                            "file_id": 23,
                            "url": "IMOS/ABOS/ASFS/SOFS/Surface_fluxes/Real-time/2018_daily/IMOS_ABOS-ASFS_FMT_20190805T015900Z_SOFS_FV02.nc"
                        }
                    }
 
                    for column_name, defn in mappings.items():
                        print(column_name, simple_eval(defn["value"], names=variables, functions={"re": re}))
                                
                    
                    
                    
                    
                
        finally:
            dataset.close()
            
    
harvester = NetcdfHarvester(input_file["src_path"], config)
harvester.run()
