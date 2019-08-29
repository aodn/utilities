"""
Dummy persistent store for testing purposes
"""
import logging

from harvester.util.collections import subset


class MemoryStore(object):
    """

    """

    def __init__(self, content, logger):
        self.content = content
        self.logger = logger

    def delete_records_for_file(self, table_name, file_id):
        logging.info("Deleting records for file with id {} from {}...".format(file_id, table_name))
        self.content[table_name] = [row for row in self.content.get(table_name, []) if row['file_id'] != file_id]

    def write(self, table_name, source):
        logging.info("Writing records to {}...".format(table_name))

        self.content[table_name] += list(source.records())

    def select_first_record_for_file(self, table_name, field_names, file_id):
        logging.info("selecting {} from first record on {} for {}...".format(field_names, table_name, file_id))
        return [subset(row, field_names) for row in self.content.get(table_name, []) if row['file_id'] == file_id][0]

    def select_one(self, table_name, key):
        logging.info("selecting record on {} for {}...".format(table_name, key))

    def aggregate(self, table_name, aggregation, key):
        logging.info("Aggregating records for {} to {} using {}".format(table_name, aggregation, key))


