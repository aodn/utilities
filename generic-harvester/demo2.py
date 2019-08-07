import harvester.io.netcdf as netcdf
import petl
import netCDF4 as nc

input_file = {
    "src_path": "IMOS_ANMN-NSW_TZ_20141118T130000Z_BMP070_FV01_BMP070-1411-Aqualogger-520PT-16_END-20150504T063500Z_C-20160901T044727Z.nc"
}

config = {
    "schema": "abos_sofs_fl",
    "user": "abos_sofs_fl",
    "password": "abos_sofs_fl",
    "netcdf_inputs": {
        "measurements": {
            "TIME": {},
            "TEMP": {},
            "TEMP_quality_control": {},
            "PRES": {},
            "PRES_quality_control": {},
            "DEPTH": {},
            "DEPTH_quality_control": {}
        }
    },
    "netcdf_metadata": {
        "global_attributes": {
            "title": {}
        },
        "scalar_variables": {
            "LATITUDE": {},
            "LONGITUDE": {},
            "NOMINAL_DEPTH": {}
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
            global_attributes = self._read_attributes(dataset, config['netcdf_metadata']['global_attributes'])
            scalar_variables = self._read_scalar_variables(dataset, config['netcdf_metadata']['scalar_variables'])
            netcdf_metadata = {**global_attributes, **scalar_variables}
            
            self.file_start(netcdf_metadata)
            
            for input_name, variable_set in config['netcdf_inputs'].items():
                netcdf_input = netcdf.fromnetcdf(self.src_path, variable_set)
                mapped_rows = petl.rowmap(netcdf_input, self._map_row(input_name), self.map_header(input_name, variable_set.keys()))
                # Need
            
            self.file_end(netcdf_metadata)
        finally:
            dataset.close()
            
    def _read_attributes(self, dataset, global_attributes):
        
        return {global_attribute: getattr(dataset, global_attribute) for global_attribute in global_attributes.keys()}

    def _read_scalar_variables(self, dataset, scalar_variables):
        
        return {scalar_variable: dataset[scalar_variable][()].item() for scalar_variable in scalar_variables}
        
    def file_start(self, netcdf_metadata):
        
        pass

    def file_end(self, netcdf_metadata):
        
        pass
    
    def _map_row(self, input_name):
        
        return lambda row: self.map_row(input_name, row)
        
    def map_row(self, input_name, row):

        return row
    
    def map_header(self, input_name, input_header):
        
        return input_header
 
    
#class NetcdfTimeseriesHarvester(NetcdfHarvester):
    
harvester = NetcdfHarvester(input_file["src_path"], config)
harvester.run()
