"""

"""

import datetime
import psycopg2
from psycopg2.extras import execute_values

from harvester.util.collections import subset
from harvester.database.database_store_dao import DatabaseStoreDao


class Psycopg2Store(object):
    """

    """

    def __init__(self, params):
        self.params = subset(params, ("database", "host", "port", "user", "password"))

    def delete_records_for_file(self, table_name, file_id):
        print("Deleting records for file with id {} from {}...".format(file_id, table_name))

        conn = None
        rows_deleted = 0
        try:
            conn = psycopg2.connect(**self.params)
            cur = conn.cursor()
            cur.execute('DELETE FROM "{}" WHERE file_id = %s'.format(table_name), (file_id,))
            rows_deleted = cur.rowcount
            conn.commit()
            cur.close()
        except (Exception, psycopg2.DatabaseError) as error:
            print(error)
        finally:
            if conn is not None:
                conn.close()

        return rows_deleted

    def write(self, table_name, source):
        print("Writing records to {}...".format(table_name))
        print(datetime.datetime.now())

        conn = None
        rows_inserted = 0
        try:
            conn = psycopg2.connect(**self.params)
            cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
            values_template = "(" + ", ".join(["%({})s".format(field_name) for field_name in source.field_names]) + ")"
            insert_stmt = 'INSERT INTO "{}" ("{}") VALUES %s'.format(table_name, '","'.join(source.field_names))
            print(insert_stmt)
            execute_values(
                cur,
                insert_stmt,
                source.records(),
                template=values_template
            )
            rows_inserted = cur.rowcount
            conn.commit()
            cur.close()
        except (Exception, psycopg2.DatabaseError) as error:
            print(error)
        finally:
            if conn is not None:
                conn.close()

        print(datetime.datetime.now())
        return rows_inserted

    def select_first_record_for_file(self, table_name, field_names, file_id):
        print("selecting {} from first record on {} for {}...".format(field_names, table_name, file_id))
        return subset(self.select_one(table_name, {"file_id": file_id}), field_names)

    def select_one(self, table_name, key):
        print("selecting {} from {}".format(key, table_name))
        conn = None
        try:
            conn = psycopg2.connect(**self.params)
            cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
            where_clause = " ".join(["{} = %({})s".format(field_name, field_name) for field_name in key])
            cur.execute("SELECT * FROM {} WHERE {}".format(table_name, where_clause), key)
            result = cur.fetchone()
            cur = conn.cursor()
            cur.close()
            return result
        except (Exception, psycopg2.DatabaseError) as error:
            print(error)
        finally:
            if conn is not None:
                conn.close()

    def aggregate(self, aggregation, key):
        print("Performing aggregation {} using {}".format(aggregation, key))
