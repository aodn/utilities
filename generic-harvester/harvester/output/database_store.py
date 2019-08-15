"""

"""
import itertools
from harvester.util.collections import subset
from harvester.database.database_store_dao import DatabaseStoreDao


class DatabaseStore(object):
    """

    """

    def __init__(self, content):
        self.content = content

    def delete_records_for_file(self, table_name, file_id):
        print("Deleting records for file with id {} from {}...".format(file_id, table_name))
        self.content[table_name] = [row for row in self.content.get(table_name, []) if row['file_id'] != file_id]
        dao = DatabaseStoreDao(table_name)
        dao.delete()

    def write(self, table_name, source):
        print("Writing records to {}...".format(table_name))
        print(source.field_names())

        dao = DatabaseStoreDao(table_name)
        dao.insert(list(source.records()))
        rs = dao.select()
        for row in rs:
            print(row)
        print("...")

        for record in itertools.islice(source.records(), 10):
            print(record)

        print("...")

    def select_first_record_for_file(self, table_name, field_names, file_id):
        print("selecting {} from first record on {} for {}...".format(field_names, table_name, file_id))
        return [subset(row, field_names) for row in self.content.get(table_name, []) if row['file_id'] == file_id][0]

    def select_one(self, table_name, key):
        print("selecting {} from {}".format(key, table_name))
        dao = DatabaseStoreDao(table_name)
        return dao.select_one(key)

    def update(self, table_name, key, values):
        print("updating {} in {} with {}".format(key, table_name, values))
        dao = DatabaseStoreDao(table_name)
        dao.update(key, values)

    def aggregate(self, table_name, aggregation, key):
        print("Aggregating records for {} to {} using {}".format(table_name, aggregation, key))
