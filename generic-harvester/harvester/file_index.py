"""
Routines for managing the file index
"""
from harvester.source.common import RecordSource


def add_or_update_file(persistent_store, pipeline_file):
    """
    Add the file to the index or update any existing entry with new metadata
    Updates the pipeline_file with the id allocated

    :param persistent_store: persistent store where index is stored
    :param pipeline_file: pipeline file metadata
    """

    result = persistent_store.select_one("indexed_file", {"url": pipeline_file.dest_path})

    if result is None:
        record = RecordSource([{"url": pipeline_file.dest_path}], field_names=("url",))
        persistent_store.write("indexed_file", record)
        result = persistent_store.select_one("indexed_file", {"url": pipeline_file.dest_path})

    pipeline_file.id = result[0]


# TODO: make updating the id separate to marking the file as deleted.

def delete_file(persistent_store, pipeline_file):
    """
    Mark the file as being deleted in the index
    Updates the pipeline_file with the id of the file

    :param persistent_store: persistent store where index is stored
    :param pipeline_file: pipeline file metadata
    """

    result = persistent_store.select_one("indexed_file", {"url": pipeline_file.dest_path})

    if result is None:
        raise Exception("Should be raising a subclass of exception")  # TODO: fix

    pipeline_file.id = result[0]

    persistent_store.update(
        "indexed_file",
        {"url": pipeline_file.dest_path},
        {"deleted": True}
    )

