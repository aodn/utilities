from collections import OrderedDict

from harvester.source.netcdf import NetcdfFileSource
from harvester.source.netcdf import NetcdfMeasurementSource
from harvester.util.collections import subset


class NetcdfFeatureHarvester(object):

    def __init__(self, feature_store, netcdf_file, config, logger):
        self.feature_store = feature_store
        self.netcdf_file = netcdf_file
        self.config = config
        self.feature_key = self.config["feature_metadata"]["feature_key"]

    def harvest(self):
        self._delete_existing_data()

        # feature_metadata file
        file_mapping = self.config["file_metadata"]
        file_source = NetcdfFileSource(self.netcdf_file, file_mapping)
        self.feature_store.write("file_metadata", file_source)

        # measurements
        measurement_source = NetcdfMeasurementSource(self.netcdf_file, self.config["measurement"])
        self.feature_store.write("measurement", measurement_source)

        # determine feature_key
        feature_metadata_record = next(file_source.records())
        feature_key = subset(feature_metadata_record, self.feature_key)

        # feature_metadata
        self._aggregate_feature_metadata(feature_key)

    def delete(self):
        feature_metadata_record = self.feature_store.select_one("file_metadata", {"file_id": self.netcdf_file.id})
        if not feature_metadata_record:
            return
        feature_key = subset(feature_metadata_record, self.feature_key)
        self._delete_existing_data()
        self._aggregate_feature_metadata(feature_key)

    def _delete_existing_data(self):
        for table_name in ("measurement", "file_metadata"):
            self.feature_store.delete_records_for_file(table_name, self.netcdf_file.id)

    def _aggregate_feature_metadata(self, feature_key):
        self.feature_store.aggregate(
            "feature_metadata",
            self.config["feature_metadata"],
            feature_key
        )
