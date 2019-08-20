"""

"""

import datetime

from harvester.util.collections import subset
from harvester.database.database_store_dao import DatabaseStoreDao


class DatabaseStore(object):
    """
    TODO: rethink DatabaseStore/DatabaseStoreDAO interactions
    """

    def __init__(self, db_params):
        self.url = db_params["driver"]+"://"+db_params["user"]+":"+db_params["password"]+"@"+db_params["host"]\
            + ":"+db_params["port"]+"/"+db_params["database"]

    def delete_records_for_file(self, table_name, file_id):
        print("Deleting records for file with id {} from {}...".format(file_id, table_name))
        dao = DatabaseStoreDao(table_name, self.url)
        dao.delete({"file_id": file_id})

    def write_dataframe(self, table_name, df):
        dao = DatabaseStoreDao(table_name, self.url)
        print(datetime.datetime.now())
        dao.insert_dataframe(df)
        print(datetime.datetime.now())

    def write(self, table_name, source):
        print("Writing records to {}...".format(table_name))

        dao = DatabaseStoreDao(table_name, self.url)
        print(datetime.datetime.now())
        records = list(source.records())
        print(datetime.datetime.now())
        dao.insert(records)
        print(datetime.datetime.now())

    def select_first_record_for_file(self, table_name, field_names, file_id):
        print("selecting {} from first record on {} for {}...".format(field_names, table_name, file_id))
        return subset(self.select_one(table_name, {"file_id": file_id}), field_names)

    def select_one(self, table_name, key):
        print("selecting {} from {}".format(key, table_name))
        dao = DatabaseStoreDao(table_name, self.url)
        return dao.select_one(key)

    def update(self, table_name, key, values):
        print("updating {} in {} with {}".format(key, table_name, values))
        dao = DatabaseStoreDao(table_name, self.url)
        dao.update(key, values)

    def aggregate(self, table_name, aggregation, key):
        aggregation_query = " ".join(aggregation["aggregation_query"])
        print("Aggregating records for {} to {} using {}".format(table_name, aggregation_query, key))
        dao = DatabaseStoreDao(table_name, self.url)
        dao.delete(key)
        dao.insert_query(aggregation_query, key)




