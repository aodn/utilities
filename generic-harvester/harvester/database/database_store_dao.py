import sqlalchemy as sa
import logging

logging.basicConfig()
logging.getLogger('sqlalchemy').setLevel(logging.WARN)


class DatabaseStoreDao:
    """
    Database Store - Data Access Object
    """

    def __init__(self, url):
        """
            Constructor
        """
        self.url = url
        self.engine = sa.create_engine(self.url)
        self.conn = self.engine.connect()
        self.meta = sa.MetaData(self.conn)

    def get_table(self, table_name):
        """

        :param table_name: name of the table
        :return: SQLAlchemy table
        """
        return sa.Table(table_name, self.meta, autoload=True)

    def insert(self, table_name, values_data):
        """
        Insert records into table...
        :param table_name: name of the table
        :param values_data: insert data
        :return: insert execution result
        """

        ins = self.get_table(table_name).insert()
        # start transaction
        t = self.conn.begin()

        try:
            r = self.conn.execute(ins, values_data)
            t.commit()
            logging.info("Transaction completed.")

        except sa.exc.SQLAlchemyError as e:
            logging.error(e)
            t.rollback()
            r = None
            logging.info("Transaction failed.")
        return r

    def insert_query(self, query, parameters):
        """
        Insert records into table using defined query...
        :param query: insert query
        :param parameters: insert query parameters
        :return: insert execution result
        """

        s = sa.text(query)
        str(s)
        # start transaction
        t = self.conn.begin()
        try:
            self.conn.execute(s, parameters)
            t.commit()
            logging.info("Transaction completed.")

        except sa.exc.SQLAlchemyError as e:
            logging.error(e)
            t.rollback()
            logging.info("Transaction failed.")

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
            logging.info("Transaction completed.")

        except sa.exc.SQLAlchemyError as e:
            logging.error(e)
            t.rollback()
            r = None
            logging.info("Transaction failed.")
        return r

    def insert_dataframe(self, table_name, df):
        """

        :param table_name: name of the table
        :param df: dataframe
        :return:
        """
        # start transaction
        t = self.conn.begin()
        try:
            df.to_sql(table_name, con=self.engine, if_exists='append')
            t.commit()
            logging.info("Transaction completed.")

        except sa.exc.SQLAlchemyError as e:
            logging.error(e)
            t.rollback()
            logging.info("Transaction failed.")
