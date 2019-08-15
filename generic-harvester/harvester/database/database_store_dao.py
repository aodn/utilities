import sqlalchemy as sa


class DatabaseStoreDao:
    """

    """

    def __init__(self, table_name):
        """
            Constructor
        """
        self.engine = sa.create_engine('postgresql+psycopg2://abos_sofs_fl:abos_sofs_fl@localhost/test_abos_sofs_fl',
                                       echo=True)
        self.conn = self.engine.connect()
        self.meta = sa.MetaData(self.conn)
        self.table = self.get_table(table_name)

    def get_table(self, table_name):
        """

        :return: table
        """
        return sa.Table(table_name, self.meta, autoload=True)

    def insert(self, values_data):
        """
            Insert records into table...

        :return:
        """

        ins = self.table.insert()
        # start transaction
        t = self.conn.begin()

        try:
            r = self.conn.execute(ins, values_data)
            t.commit()
            print("Transaction completed.")

        except sa.exc.SQLAlchemyError as e:
            print(e)
            t.rollback()
            r = None
            print("Transaction failed.")
        return r

    def select(self):
        """
            Select all records from table...

        :return:
        """

        s = sa.select([self.table])
        str(s)
        r = self.conn.execute(s)
        return r.fetchall()

    def select_one(self, key):
        """
            Select one record from table using key...

        :return:
        """

        table_name = self.table.name
        where_clause = " ".join([field_name + " = :" + field_name for field_name in key])
        s = sa.text("SELECT * FROM {} WHERE {}".format(table_name, where_clause))
        str(s)
        r = self.conn.execute(s, key)
        return r.fetchone()

    def update(self, key, values):
        """
            update record from table using key...

        :return:
        """

        table_name = self.table.name
        where_clause = " ".join([field_name + " = :" + field_name for field_name in key])
        set_clause = " ".join([field_name + "= :" + field_name for field_name in values])
        s = sa.text("UPDATE {} SET {} WHERE {}".format(table_name, set_clause, where_clause))
        str(s)
        self.conn.execute(s, {**key, **values})

    def delete(self):
        """
            Delete all records from table...

        :return:
        """
        s = sa.delete(self.table)
        print(s)

        # start transaction
        t = self.conn.begin()
        try:
            r = self.conn.execute(s)
            t.commit()
            print("Transaction completed.")

        except sa.exc.SQLAlchemyError as e:
            print(e)
            t.rollback()
            r = None
            print("Transaction failed.")
        return r
