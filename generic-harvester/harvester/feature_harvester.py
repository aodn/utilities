from harvester.source.netcdf import (NetcdfMeasurementSource, NetcdfFileSource)
from harvester.util.collections import subset


class NetcdfFeatureHarvester(object):

    def __init__(self, persistent_store, netcdf_file, config, logger):
        self.persistent_store = persistent_store
        self.netcdf_file = netcdf_file
        self.config = config

    def harvest(self):
        self._delete_existing_data()

        # feature_metadata file
        file_mapping = self.config["file_metadata"]
        file_source = NetcdfFileSource(self.netcdf_file, file_mapping)
        self.persistent_store.write("file_metadata", file_source)

        # measurements
        measurement_source = NetcdfMeasurementSource(self.netcdf_file, self.config["measurement"])
        self.persistent_store.write("measurement", measurement_source)

        # determine feature_key
        feature_metadata_record = next(file_source.records())
        feature_key = subset(feature_metadata_record, self.config["feature_metadata"]["feature_key"])

        # feature_metadata
        self._aggregate_feature_metadata(feature_key)

    def delete(self):
        feature_metadata_record = self.persistent_store.select_one("file_metadata", {"file_id": self.netcdf_file.id})
        if not feature_metadata_record:
            return
        feature_key = subset(feature_metadata_record, self.config["feature_metadata"]["feature_key"])
        self._delete_existing_data()
        self._aggregate_feature_metadata(feature_key)

    def _delete_existing_data(self):
        for table_name in ("measurement", "file_metadata"):
            self.persistent_store.delete_records_for_file(table_name, self.netcdf_file.id)

    def _aggregate_feature_metadata(self, feature_key):
        self.persistent_store.aggregate(
            "feature_metadata",
            self.config["feature_metadata"],
            feature_key
        )
