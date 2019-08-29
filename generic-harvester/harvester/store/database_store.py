"""

"""

from harvester.database.database_store_dao import DatabaseStoreDao


class DatabaseStore(object):
    """
    TODO: rethink DatabaseStore/DatabaseStoreDAO interactions
    """

    def __init__(self, db_params, logger):
        self.url = db_params["driver"]+"://"+db_params["user"]+":"+db_params["password"]+"@"+db_params["host"]\
            + ":"+db_params["port"]+"/"+db_params["database"]
        self.logger = logger

    def delete_records_for_file(self, table_name, file_id):
        self.logger.info("Deleting records for file with id {} from {}...".format(file_id, table_name))
        dao = DatabaseStoreDao(self.url, self.logger)
        dao.delete(table_name, {"file_id": file_id})

    def write(self, table_name, source):
        self.logger.info("Writing records to {}...".format(table_name))

        dao = DatabaseStoreDao(self.url, self.logger)
        dao.insert(table_name, source)

    def select_one(self, table_name, key):
        self.logger.info("selecting {} from {}".format(key, table_name))
        dao = DatabaseStoreDao(self.url, self.logger)
        return dao.select_one(table_name, key)

    def select_query(self, query):
        self.logger.info("selecting query {}".format(query))
        dao = DatabaseStoreDao(self.url, self.logger)
        return dao.select_query(query)

    def update(self, table_name, key, values):
        self.logger.info("updating {} in {} with {}".format(key, table_name, values))
        dao = DatabaseStoreDao(self.url, self.logger)
        dao.update(table_name, key, values)

    def aggregate(self, aggregation, key):
        dao = DatabaseStoreDao(self.url, self.logger)
        query = " ".join(aggregation["query"])
        if "table" in aggregation:
            table = aggregation["table"]
            self.logger.info("Removing previously aggregated data for {} from {}".format(key, table))
            dao.delete(table, key)
        self.logger.info("Performing aggregation {} for {}".format(query, key))
        dao.execute_query(query, key)




