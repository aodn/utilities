import abc
from pathlib import Path
from db import DatabaseInteractions
from basestep import BaseStepRunner
from pprint import pprint


class BaseHarvesterRunner(BaseStepRunner, metaclass=abc.ABCMeta):
    """Base class for HarvesterRunner classes
    """

    @abc.abstractmethod
    def run(self, pipeline_files):
        pass


class GenericCsvHarvester(BaseHarvesterRunner):

    # preliminary order of steps for each harvest_params.db_object by ingest_type
    # may need a way of differentiating between DDL and DML sql
    # ie. execute_sql_file to create db object vs execute_sql_file for inserts and updates
    process = {
        "replace": [
            "drop_object",
            "create_table_from_yaml_file",
            "load_data_from_csv",
            "execute_sql_file",
        ],
        "truncate": [
            "truncate_table",
            "load_data_from_csv",
            "refresh_materialized_view",
        ],
        "append": [
            "load_data_from_csv",
            "refresh_materialized_view",
        ],

    }

    def __init__(self, storage_broker, harvest_params, tmp_base_dir, config, logger, deletion=False):
        super().__init__(config, logger)
        if harvest_params is None:
            harvest_params = {}

        self.deletion = deletion
        self.slice_size = harvest_params.get('slice_size', 2048)
        self.undo_previous_slices = harvest_params.get('undo_previous_slices', True)
        self.params = harvest_params
        self.tmp_base_dir = tmp_base_dir
        self.storage_broker = storage_broker
        # self.harvested_file_map = HarvesterMap()
        self.config = self._config
        self.logger = self._logger
        self.pipeline_files = None

    def build_runsheet(self, obj):
        pf = next((pf for pf in self.pipeline_files if Path(pf.local_path).stem.lower() == obj['name'].lower()
                   or Path(pf.local_path).stem.lower() in [i.lower() for i in obj.get('dependencies', [])]), None)
        if pf:
            if obj['name'].lower() == Path(pf.local_path).stem.lower():
                obj['local_path'] = pf.local_path
            return obj

    def run(self, pipeline_files):
        self.pipeline_files = pipeline_files
        runsheet = (x for x in map(self.build_runsheet, self.params['db_objects']) if x)
        conn_str = self.config['db']
        with DatabaseInteractions(config=conn_str, schema_base_path=self.config['schema_base_path']) as conn:
            # placeholder - compare schema versions
            # if no change to schemas, go with the defined ingest_type, otherwise use the replace (drop and recreate)
            if conn.compare_schemas:
                proc = self.process.get(self.params['ingest_type'])
            else:
                proc = self.process['replace']

            if proc:
                for step in runsheet:
                    print("Executing {} steps for {}".format(self.params['ingest_type'], step['name']))
                    for task in proc:
                        getattr(conn, task)(step)
                errors = conn.get_errors()
                if errors:
                    return {'status': 'errors', 'details': errors}
                else:
                    return {
                        'status': 'success',
                        'data': [{'local_path': pf.local_path, 'is_harvested': True} for pf in pipeline_files]
                    }
            else:
                return {
                    'status': 'errors',
                    'details': 'No implementation for ingest_type {}'.format(self.params['ingest_type'])}

