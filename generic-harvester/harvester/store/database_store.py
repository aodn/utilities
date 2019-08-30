"""

"""

import psycopg2
import sqlalchemy as sa


def format_dict(dictionary):
    return ", ".join(["{}='{}'".format(key, value) for key, value in dictionary.items()])


def reduce_space(value):
    return ' '.join(value.split())


# TODO: make this a context manager?

class PostgresStore(object):

    def __init__(self, db_params, logger):
        self.url = db_params["driver"]+"://"+db_params["user"]+":"+db_params["password"]+"@"+db_params["host"]\
            + ":"+db_params["port"]+"/"+db_params["database"]
        self.logger = logger
        self.engine = sa.create_engine(self.url)
        self.conn = self.engine.connect()
        self.trans = self.conn.begin()

    def delete(self, table_name, key):
        """
        Delete records from table name where they match the provided key

        :param table_name: name of table
        :param key: a dictionary of column name/value pairs to use as the key
        """

        self.logger.info("Deleting records from {} where {}...".format(table_name, format_dict(key)))

        condition = " ".join([field_name + " = :" + field_name for field_name in key])
        s = sa.text("DELETE FROM {} WHERE {}".format(table_name, condition))

        self.conn.execute(s, key)

    def write(self, table_name, source):
        """
        Insert records into table...

        :param table_name: name of the table
        :param source: source of records
        """

        self.logger.info("Writing records to {}...".format(table_name))

        # Need raw psycopg2 connection to insert in batches easily (most performant option)
        conn = self.conn.connection

        with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
            values_template = "(" + ", ".join(["%({})s".format(field_name) for field_name in source.field_names]) + ")"
            insert_stmt = 'INSERT INTO "{}" ("{}") VALUES %s'.format(table_name, '","'.join(source.field_names))

            psycopg2.extras.execute_values(
                cur,
                insert_stmt,
                source.records(),
                template=values_template
            )

    def select_one(self, table_name, key):
        """
        Select one record from table using key...

        :param table_name: name of the table
        :param key: dictionary of column/value pairs to use as the key
        :return:
        """

        self.logger.info("Selecting from {} where {}".format(table_name, format_dict(key)))

        where_clause = " and ".join([field_name + " = :" + field_name for field_name in key])
        s = sa.text("SELECT * FROM {} WHERE {}".format(table_name, where_clause))
        r = self.conn.execute(s, key)

        return r.fetchone()

    def select_query(self, query):
        """
        Select records from defined query...

        :param query: select query
        :return: query resultset
        """

        self.logger.info("Selecting query {}".format(query))

        r = self.conn.execute(query)

        return r.fetchall()

    def update(self, table_name, key, values):
        """
        Update record in table using key...

        :param table_name: name of the table
        :param key: dictionary of column/value pairs to use as the key
        :param values: dictionary of column/value pairs to set
        """

        self.logger.info("Updating {} setting {} where {}".format(table_name, format_dict(values), format_dict(key)))

        condition = " and ".join([field_name + " = :" + field_name for field_name in key])
        column_exprs = ", ".join([field_name + "= :" + field_name for field_name in values])
        s = sa.text("UPDATE {} SET {} WHERE {}".format(table_name, column_exprs, condition))

        self.conn.execute(s, {**key, **values})

    def execute_query(self, query, key):
        """
        Execute query

        :param query: query to execute
        :param parameters: dictionary of column/value pairs referenced in the query
        """

        self.logger.info("Executing query '{}...' with {}".format(reduce_space(query)[:70], format_dict(key)))

        s = sa.text(query)
        self.conn.execute(s, key)

    def commit(self):
        """
        Commit changes made so far
        """

        self.trans.commit()

    def rollback(self):
        """
        Rollback changes made since last commit
        """

        self.trans.rollback()
