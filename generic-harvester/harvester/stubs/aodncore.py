class PipelineFile(object):
    """
    Mock real PipelineFile for prototyping
    """

    # TODO: revisit id handling - more likely to be set by this step than initialised with it
    def __init__(self, src_path, dest_path=None, file_id=None):
        self.id = file_id
        self.src_path = src_path
        self.dest_path = dest_path

