"""

"""

import datetime

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
        dao = DatabaseStoreDao(self.url)
        dao.delete(table_name, {"file_id": file_id})

    def write(self, table_name, source):
        print("Writing records to {}...".format(table_name))

        dao = DatabaseStoreDao(self.url)
        print(datetime.datetime.now())
        dao.insert(table_name, source)
        print(datetime.datetime.now())

    def select_one(self, table_name, key):
        print("selecting {} from {}".format(key, table_name))
        dao = DatabaseStoreDao(self.url)
        return dao.select_one(table_name, key)

    def select_query(self, query):
        print("selecting query {}".format(query))
        dao = DatabaseStoreDao(self.url)
        return dao.select_query(query)

    def update(self, table_name, key, values):
        print("updating {} in {} with {}".format(key, table_name, values))
        dao = DatabaseStoreDao(self.url)
        dao.update(table_name, key, values)

    def aggregate(self, aggregation, key):
        dao = DatabaseStoreDao(self.url)
        query = " ".join(aggregation["query"])
        if "table" in aggregation:
            table = aggregation["table"]
            print("Removing previously aggregated data for {} from {}".format(key, table))
            dao.delete(table, key)
        print("Performing aggregation {} for {}".format(query, key))
        dao.execute_query(query, key)




