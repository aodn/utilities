"""

"""

from harvester.source.netcdf import (NetcdfGlobalAttributeSource, NetcdfVariableSource, NetcdfVariableAttributeSource)


class NetcdfMetadataHarvester(object):

    def __init__(self, persistent_store, netcdf_file, config, logger):
        self.persistent_store = persistent_store
        self.netcdf_file = netcdf_file
        self.config = config

    def harvest(self):
        self._delete_existing_data()

        # global attributes
        global_attribute_source = NetcdfGlobalAttributeSource(self.netcdf_file)
        self.persistent_store.write("nc_global_attribute", global_attribute_source)

        # variables
        variable_source = NetcdfVariableSource(self.netcdf_file)
        self.persistent_store.write("nc_variable", variable_source)

        # variable_attributes
        variable_attribute_source = NetcdfVariableAttributeSource(self.netcdf_file)
        self.persistent_store.write("nc_variable_attribute", variable_attribute_source)

    def delete(self):
        for table_name in ("nc_global_attribute", "nc_variable", "nc_variable_attribute"):
            self.persistent_store.deleteFileData(table_name, self.netcdf_file.id)
