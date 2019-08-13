"""

"""
import itertools


class ConsoleStore(object):
    """

    """

    def delete_records_for_file(self, table_name, file_id):
        print("Deleting records for file with id {} from {}...".format(file_id, table_name))

    def write(self, table_name, source):
        print("Writing records to {}...".format(table_name))
        print(source.field_names())

        for record in itertools.islice(source.records(), 10):
            print(record)

        print("...")

    def aggregate(self, table_name, aggregation, key):
        print("Aggregating records for {} to {} using {}".format(table_name, aggregation, key))


