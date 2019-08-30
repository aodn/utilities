import sqlalchemy as sa

import psycopg2


class DatabaseStoreDao:
    """
    Database Store - Data Access Object
    """

    def __init__(self, url, logger):
        """
            Constructor
        """
        self.url = url
        self.logger = logger
        self.engine = sa.create_engine(self.url)
        self.conn = self.engine.connect()
        self.meta = sa.MetaData(self.conn)

    def get_table(self, table_name):
        """

        :param table_name: name of the table
        :return: SQLAlchemy table
        """
        return sa.Table(table_name, self.meta, autoload=True)

    def insert(self, table_name, source):
        """
        Insert records into table...
        :param table_name: name of the table
        :param values_data: insert data
        :return: insert execution result
        """

        conn = self.engine.raw_connection()

        try:
            cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
            values_template = "(" + ", ".join(["%({})s".format(field_name) for field_name in source.field_names]) + ")"
            insert_stmt = 'INSERT INTO "{}" ("{}") VALUES %s'.format(table_name, '","'.join(source.field_names))

            psycopg2.extras.execute_values(
                cur,
                insert_stmt,
                source.records(),
                template=values_template
            )

            rows_inserted = cur.rowcount

            conn.commit()
            cur.close()
        except sa.exc.SQLAlchemyError as e:
            self.logger.exception(e)
            self.logger.error("Transaction failed.")
        return rows_inserted

    def execute_query(self, query, parameters):
        """
        Execute query
        :param query: query to execute
        :param parameters: query parameters
        :return: execution result
        """

        s = sa.text(query)
        str(s)
        # start transaction
        t = self.conn.begin()
        try:
            self.conn.execute(s, parameters)
            t.commit()

        except sa.exc.SQLAlchemyError as e:
            self.logger.exception(e)
            t.rollback()
            self.logger.error("Transaction failed.")

    def select(self, table_name):
        """
        Select all records from table...
        :param table_name: name of the table
        :return: query resultset
        """

        s = sa.select([self.get_table(table_name)])
        str(s)
        r = self.conn.execute(s)
        return r.fetchall()

    def select_query(self, query):
        """
        Select records from defined query...
        :param query: select query
        :return: query resultset
        """

        r = self.conn.execute(query)
        return r.fetchall()

    def select_one(self, table_name, key):
        """
        Select one record from table using key...
        :param table_name: name of the table
        :param key: key parameters
        :return:
        """

        where_clause = " ".join([field_name + " = :" + field_name for field_name in key])
        s = sa.text("SELECT * FROM {} WHERE {}".format(table_name, where_clause))
        str(s)
        r = self.conn.execute(s, key)
        return r.fetchone()

    def update(self, table_name, key, values):
        """
        Update record from table using key...
        :param table_name: name of the table
        :param key: update key parameters
        :param values: update values
        :return:
        """

        where_clause = " ".join([field_name + " = :" + field_name for field_name in key])
        set_clause = " ".join([field_name + "= :" + field_name for field_name in values])
        s = sa.text("UPDATE {} SET {} WHERE {}".format(table_name, set_clause, where_clause))
        str(s)
        self.conn.execute(s, {**key, **values})

    def delete(self, table_name, key):
        """
        Delete all records for key...
        :param table_name: name of the table
        :param key: delete key parameters
        :return:
        """

        where_clause = " ".join([field_name + " = :" + field_name for field_name in key])
        s = sa.text("DELETE FROM {} WHERE {}".format(table_name, where_clause))
        str(s)

        # start transaction
        t = self.conn.begin()
        try:
            r = self.conn.execute(s, key)
            t.commit()

        except sa.exc.SQLAlchemyError as e:
            self.logger.exception(e)
            t.rollback()
            r = None
            self.logger.error("Transaction failed.")
        return r
