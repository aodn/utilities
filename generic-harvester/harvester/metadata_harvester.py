"""

"""

from harvester.source.netcdf import (NetcdfGlobalAttributeSource, NetcdfVariableSource, NetcdfVariableAttributeSource)


class NetcdfMetadataHarvester(object):

    def __init__(self, metadata_store, netcdf_file, config, logger):
        self.metadata_store = metadata_store
        self.netcdf_file = netcdf_file
        self.config = config

    def harvest(self):
        self.delete()

        # global attributes
        global_attribute_source = NetcdfGlobalAttributeSource(self.netcdf_file)
        self.metadata_store.write("nc_global_attribute", global_attribute_source)

        # variables
        variable_source = NetcdfVariableSource(self.netcdf_file)
        self.metadata_store.write("nc_variable", variable_source)

        # variable_attributes
        variable_attribute_source = NetcdfVariableAttributeSource(self.netcdf_file)
        self.metadata_store.write("nc_variable_attribute", variable_attribute_source)

    def delete(self):
        for table_name in ("nc_global_attribute", "nc_variable", "nc_variable_attribute"):
            self.metadata_store.delete_records_for_file(table_name, self.netcdf_file.id)
