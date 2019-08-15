"""
Dummy persistent store for testing purposes
"""
import itertools

from harvester.util.collections import subset


class MemoryStore(object):
    """

    """

    def __init__(self, content):
        self.content = content

    def delete_records_for_file(self, table_name, file_id):
        print("Deleting records for file with id {} from {}...".format(file_id, table_name))
        self.content[table_name] = [row for row in self.content.get(table_name, []) if row['file_id'] != file_id]

    def write(self, table_name, source):
        print("Writing records to {}...".format(table_name))
        print(source.field_names())

        for record in itertools.islice(source.records(), 10):
            print(record)

        print("...")
        self.content[table_name] += list(source.records())

    def select_first_record_for_file(self, table_name, field_names, file_id):
        print("selecting {} from first record on {} for {}...".format(field_names, table_name, file_id))
        return [subset(row, field_names) for row in self.content.get(table_name, []) if row['file_id'] == file_id][0]

    def select_one(self, table_name, key):
        print("selecting record on {} for {}...".format(table_name, key))

    def aggregate(self, table_name, aggregation, key):
        print("Aggregating records for {} to {} using {}".format(table_name, aggregation, key))


