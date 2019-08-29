"""

"""

from harvester.database.database_store_dao import DatabaseStoreDao


def _format(dictionary):
    return ", ".join(["{}='{}'".format(key, value) for key, value in dictionary.items()])


def _reduce_space(value):
    return ' '.join(value.split())


class DatabaseStore(object):
    """
    TODO: rethink DatabaseStore/DatabaseStoreDAO interactions
    """

    def __init__(self, db_params, logger):
        self.url = db_params["driver"]+"://"+db_params["user"]+":"+db_params["password"]+"@"+db_params["host"]\
            + ":"+db_params["port"]+"/"+db_params["database"]
        self.logger = logger

    def delete(self, table_name, key):
        self.logger.info("Deleting records from {} where {}...".format(table_name, _format(key)))
        dao = DatabaseStoreDao(self.url, self.logger)
        dao.delete(table_name, key)

    def write(self, table_name, source):
        self.logger.info("Writing records to {}...".format(table_name))
        dao = DatabaseStoreDao(self.url, self.logger)
        dao.insert(table_name, source)

    def select_one(self, table_name, key):
        self.logger.info("Selecting from {} where {}".format(table_name, _format(key)))
        dao = DatabaseStoreDao(self.url, self.logger)
        return dao.select_one(table_name, key)

    def select_query(self, query):
        self.logger.info("Selecting query {}".format(query))
        dao = DatabaseStoreDao(self.url, self.logger)
        return dao.select_query(query)

    def update(self, table_name, key, values):
        self.logger.info("Updating {} setting {} where {}".format(table_name, _format(values), _format(key)))
        dao = DatabaseStoreDao(self.url, self.logger)
        dao.update(table_name, key, values)

    def execute_query(self, query, key):
        self.logger.info("Executing query '{}...' with {}".format(_reduce_space(query)[:70], _format(key)))
        dao = DatabaseStoreDao(self.url, self.logger)
        dao.execute_query(query, key)




