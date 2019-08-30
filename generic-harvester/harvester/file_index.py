"""
Routines for managing the file index
"""
import datetime
import os

from harvester.source.common import RecordSource


def add_or_update_file(index_store, pipeline_file):
    """
    Add the file to the index or update any existing entry with new metadata
    Updates the pipeline_file with the id allocated

    :param index_store: persistent store where index is stored
    :param pipeline_file: pipeline file metadata
    """

    key = {"url": pipeline_file.dest_path}

    record = {
        "url": pipeline_file.dest_path,
        "size": os.path.getsize(pipeline_file.src_path),
        "last_indexed": datetime.datetime.now(),
        "deleted": False
    }

    existing_record = index_store.select_one("indexed_file", key)

    if existing_record:
        # update existing record
        index_store.update("indexed_file", key, record)
    else:
        # insert
        index_store.write("indexed_file", RecordSource([record]))

    # get file id
    new_record = index_store.select_one("indexed_file", key)
    pipeline_file.id = new_record[0]


# TODO: make updating the id separate to marking the file as deleted.

def delete_file(index_store, pipeline_file):
    """
    Mark the file as being deleted in the index
    Updates the pipeline_file with the id of the file

    :param index_store: persistent store where index is stored
    :param pipeline_file: pipeline file metadata
    """

    result = index_store.select_one("indexed_file", {"url": pipeline_file.dest_path})

    if result is None:
        raise Exception("Should be raising a subclass of exception")  # TODO: fix

    pipeline_file.id = result[0]

    index_store.update(
        "indexed_file",
        {"url": pipeline_file.dest_path},
        {"deleted": True}
    )

