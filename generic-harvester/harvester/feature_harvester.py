"""
This module contains the NetcdfFeatureHarvester and supporting code
"""

from harvester.source.netcdf import NetcdfFileSource
from harvester.source.netcdf import NetcdfValueSource
from harvester.util.collections import subset


class NetcdfFeatureHarvester(object):
    """
    A netcdf feature harvester

    A NetcdfFeatureHarvester is used to harvest or delete requested file metadata and measurements for a
    netCDF file and update aggregated feature metadata.

    The measurements and feature related metadata to harvest or delete and the feature metadata to be aggregated/updated
    is specified in a configuration file passed to the harvester

    Measurements, feature related metadata and aggregated feature metadata are written to, updated or deleted from
    the provided feature store
    """

    def __init__(self, feature_store, config, logger):
        """
        Create a new NetcdfFeatureHarvester

        :param feature_store: feature_store to write harvested information to or delete from
        :param config: feature harvesting config defining tables to update and mappings to use
        :param logger: logger for messages
        """
        self.feature_store = feature_store
        self.config = config
        self.logger = logger

    def harvest(self, netcdf_file):
        """
        Harvest required feature information from a netCDF file

        :param netcdf_file: netCDF file to harvest
        """
        # delete any existing data for file
        self._delete_existing_data(netcdf_file)

        # harvest requested file metadata
        requested_metadata = self.config["file_metadata"]
        file_source = NetcdfFileSource(netcdf_file, requested_metadata)
        self.feature_store.write("file_metadata", file_source)

        # loop through each table sourced from variable values,
        # source requested values for them and write them to the feature store
        for value_mapping in self.config["value_mappings"]:
            value_source = NetcdfValueSource(netcdf_file, value_mapping)
            self.feature_store.write(value_mapping["table"], value_source)

        # get file metadata for use in sourcing aggregation keys
        # and perform aggregations using it
        file_metadata = next(file_source.records())
        self._aggregate(file_metadata)

    def delete(self, netcdf_file):
        """
        Delete previously harvested information for file and update aggregated information

        :param netcdf_file: netCDF file for which harvested information should be deleted and aggregations updated
        """
        metadata_key = {"file_id": netcdf_file.id}
        file_metadata = self.feature_store.select_one("file_metadata", metadata_key)
        self._delete_existing_data(netcdf_file)

        # if there was any file_metadata found, update aggregations using it to source
        # aggregation keys
        if file_metadata:
            self._aggregate(file_metadata)

    def _delete_existing_data(self, netcdf_file):
        # get all value tables from which previously harvested file values needs to be deleted
        value_tables = [value_mapping["table"] for value_mapping in self.config["value_mappings"]]

        # delete all file metadata and previously harvested values for file
        for table_name in value_tables + ["file_metadata"]:
            delete_key = {"file_id": netcdf_file.id}
            self.feature_store.delete(table_name, delete_key)

    def _aggregate(self, file_metadata):
        # perform all requested aggregations
        for aggregation in self.config["aggregations"]:
            # get aggregation key
            key = subset(file_metadata, aggregation["key"])
            # delete any existing aggregation details for key if table name is specified
            if "table" in aggregation:
                table = aggregation["table"]
                self.feature_store.delete(table, key)
            # perform the aggregation
            query = " ".join(aggregation["query"])
            self.feature_store.execute_query(query, key)
