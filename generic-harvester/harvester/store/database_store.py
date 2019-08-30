"""

"""

import psycopg2
import sqlalchemy as sa


from harvester.store.common import format_dict, reduce_space


class PostgresStore(object):

    def __init__(self, db_params, logger):
        self.url = db_params["driver"]+"://"+db_params["user"]+":"+db_params["password"]+"@"+db_params["host"]\
            + ":"+db_params["port"]+"/"+db_params["database"]
        self.logger = logger
        self.engine = sa.create_engine(self.url)
        self.conn = self.engine.connect()

    def delete(self, table_name, key):
        self.logger.info("Deleting records from {} where {}...".format(table_name, format_dict(key)))
        where_clause = " ".join([field_name + " = :" + field_name for field_name in key])
        s = sa.text("DELETE FROM {} WHERE {}".format(table_name, where_clause))

    def write(self, table_name, source):
        self.logger.info("Writing records to {}...".format(table_name))
        self.dao.insert(table_name, source)

    def select_one(self, table_name, key):
        self.logger.info("Selecting from {} where {}".format(table_name, format_dict(key)))
        return self.dao.select_one(table_name, key)

    def select_query(self, query):
        self.logger.info("Selecting query {}".format(query))
        return self.dao.select_query(query)

    def update(self, table_name, key, values):
        self.logger.info("Updating {} setting {} where {}".format(table_name, format_dict(values), format_dict(key)))
        self.dao.update(table_name, key, values)

    def execute_query(self, query, key):
        self.logger.info("Executing query '{}...' with {}".format(reduce_space(query)[:70], format_dict(key)))
        self.dao.execute_query(query, key)




