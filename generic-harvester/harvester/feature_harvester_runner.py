"""

"""


class FeatureHarvesterRunner(object):

    def __init__(self, storage_broker, harvest_params, tmp_base_dir, config, logger, deletion=False):
        # TODO: super(GenericHarvesterRunner, self).__init__(config, logger)
        if harvest_params is None:
            harvest_params = {}

        self.deletion = deletion
        self.slice_size = harvest_params.get('slice_size', 2048)
        self.undo_previous_slices = harvest_params.get('undo_previous_slices', True)
        self.params = harvest_params
        self.tmp_base_dir = tmp_base_dir
        self.storage_broker = storage_broker

    def run(self, pipeline_files):
        # loop through pipeline files
        #   update file index for dest_path - get file_id
        #   lookup generic harvester config for file dest path
        #   instantiate instance of harvester based on file type
        #   call delete for deletions/harvest for additions
        #   update metadata spatial extent
        #   upload on success
        pass

