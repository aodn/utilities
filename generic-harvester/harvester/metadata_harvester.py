"""
This module contains the NetcdfMetadataHarvester and supporting code
"""

from harvester.source.netcdf import (NetcdfGlobalAttributeSource, NetcdfVariableSource, NetcdfVariableAttributeSource)


class NetcdfMetadataHarvester(object):
    """
    A netcdf metadata harvester

    A NetcdfMetadataHarvester is used to harvest or delete netCDF metadata from a netCDF file

    netCDF metadata is harvested to or deleted from the provided metadata store
    """

    def __init__(self, metadata_store, config, logger):
        """
        Create a new NetcdfFeatureHarvester

        :param metadata_store: metadata store to write harvested information to or delete from
        :param config: metadata harvesting config
        :param logger: logger for messages
        """

        self.metadata_store = metadata_store
        self.config = config
        self.logger = logger

    def harvest(self, netcdf_file):
        """
        Harvest netCDF metadata from a netCDF file

        :param netcdf_file: netCDF file to harvest
        """

        # delete any previously harvested metadata for a file
        self.delete(netcdf_file)

        # harvest global attributes
        global_attribute_source = NetcdfGlobalAttributeSource(netcdf_file)
        self.metadata_store.write("nc_global_attribute", global_attribute_source)

        # harvest variables
        variable_source = NetcdfVariableSource(netcdf_file)
        self.metadata_store.write("nc_variable", variable_source)

        # harvest variable attributes
        variable_attribute_source = NetcdfVariableAttributeSource(netcdf_file)
        self.metadata_store.write("nc_variable_attribute", variable_attribute_source)

    def delete(self, netcdf_file):
        """
        Delete previously harvested metadata for a netCDF file

        :param netcdf_file: netCDF file for which harvested metadata should be deleted
        """

        for table_name in ("nc_global_attribute", "nc_variable", "nc_variable_attribute"):
            self.metadata_store.delete_records_for_file(table_name, netcdf_file.id)
