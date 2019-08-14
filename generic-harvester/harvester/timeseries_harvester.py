from harvester.source.netcdf import (NetcdfMeasurementSource, NetcdfFileSource)
from harvester.util.collections import subset


class NetcdfTimeseriesHarvester(object):

    def __init__(self, persistent_store, netcdf_file, config, logger):
        self.persistent_store = persistent_store
        self.netcdf_file = netcdf_file
        self.config = config

    def harvest(self):
        self._delete_existing_data()

        # timeseries file
        file_mapping = self.config["timeseries_file"]
        file_source = NetcdfFileSource(self.netcdf_file, file_mapping)
        self.persistent_store.write("timeseries_file", file_source)

        # measurements
        measurement_source = NetcdfMeasurementSource(self.netcdf_file, self.config["measurement"])
        self.persistent_store.write("measurement", measurement_source)

        # determine timeseries_key
        timeseries_record = next(file_source.records())
        timeseries_key = subset(timeseries_record, self.config["timeseries_key"])

        # timeseries
        self._aggregate_timeseries(timeseries_key)

    def delete(self):
        timeseries_key = self.persistent_store.select_first_record_for_file("timeseries_file", self.config["timeseries_key"],
                                                      self.netcdf_file.id)
        self._delete_existing_data()
        self._aggregate_timeseries(timeseries_key)

    def _delete_existing_data(self):
        for table_name in ("measurement", "timeseries_file"):
            self.persistent_store.delete_records_for_file(table_name, self.netcdf_file.id)

    def _aggregate_timeseries(self, timeseries_key):
        self.persistent_store.aggregate("timeseries", self.config["timeseries"], timeseries_key)
