import itertools

from harvester.source.netcdf import (NetcdfMeasurementSource, NetcdfFileSource)


class NetcdfTimeseriesHarvester(object):

    def __init__(self, persistent_store, netcdf_file, config, logger):
        self.persistent_store = persistent_store
        self.netcdf_file = netcdf_file
        self.config = config

    def harvest(self):
        self._delete_existing_data()

        # measurements
        measurement_source = NetcdfMeasurementSource(self.netcdf_file, self.config["measurement"])
        self.persistent_store.write("measurement", measurement_source)

        # timeseries file
        file_mapping = self.config["timeseries_file"]
        file_source = NetcdfFileSource(self.netcdf_file, file_mapping)
        self.persistent_store.write("timeseries_file", file_source)

        # determine timeseries_key
        timeseries_record = next(file_source.records())
        # TODO: timeseries_key = timeseries_record.values(self.config["timeseries_key"])
        timeseries_key = self.config["timeseries_key"]

        # timeseries
        self._aggregate_timeseries(timeseries_key)

    def delete(self):
        timeseries_key = self.persistent_store.select("timeseries_file", self.netcdf_file.id, self.config["timeseries_key"])
        self._delete_existing_data()
        self._aggregate_timeseries(timeseries_key)

    def _delete_existing_data(self):
        for table_name in ("measurement", "timeseries_file"):
            self.persistent_store.delete_records_for_file(table_name, self.netcdf_file.id)

    def _aggregate_timeseries(self, timeseries_key):
        self.persistent_store.aggregate("timeseries", self.config["timeseries"], timeseries_key)
