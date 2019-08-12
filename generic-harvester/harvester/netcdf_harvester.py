import itertools

from harvester.source.netcdf import (NetcdfMeasurementSource, NetcdfFileSource)


class NetcdfTimeseriesHarvester(object):

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

        # measurements
        measurement_source = NetcdfMeasurementSource(self.netcdf_file, self.config["measurement"])
        self.persistent_store.write("measurement", measurement_source)

        # timeseries file
        file_mapping = self.config["timeseries_file"]
        file_source = NetcdfFileSource(self.netcdf_file, file_mapping)
        self.persistent_store.write("timeseries_file", file_source)

        # timeseries_key
        timeseries_file_metadata = itertools.islice(file_mapping.records(), 1)
        timeseries_key = {field_name: timeseries_file_metadata[field_name] for field_name in self.config["timeseries_key"]}

        # timeseries
        self._aggregate_timeseries(timeseries_key)

    def delete(self):
        timeseries_key = self.persistent_store.select("timeseries_file", self.netcdf_file.id, self.config["timeseries_key"])
        self._delete_existing_data()
        self._aggregate_timeseries(timeseries_key)

    def _delete_existing_data(self):
        for table_name in ("nc_global_attribute", "nc_variable", "nc_variable_attribute", "measurement",
                           "timeseries_file"):
            self.persistent_store.deleteFileData(table_name, self.netcdf_file.id)

    def _aggregate_timeseries(self, timeseries_key):
        self.persistent_store.aggregate("timeseries", self.config["timeseries"], timeseries_key)
