"""

"""

import datetime
import psycopg2
from psycopg2.extras import execute_values

from harvester.store.common import format_dict
from harvester.util.collections import subset


class Psycopg2Store(object):
    """

    """

    def __init__(self, params, logger):
        self.params = subset(params, ("database", "host", "port", "user", "password"))
        self.logger = logger
        self.conn = psycopg2.connect(**self.params)

    def delete(self, conn, table_name, key):
        self.logger.info("Deleting records from {} where {}...".format(table_name, format_dict(key)))
        with self.conn.cursor() as cur:
            condition = " ".join(["{} = %({})".format(field_name, field_name) for field_name in key])
            cur.execute('DELETE FROM "{}" WHERE {}'.format(table_name, condition))
            return cur.rowcount

    def write(self, conn, table_name, source):
        self.logger.info("Writing records to {}...".format(table_name))

        conn = None
        rows_inserted = 0
        try:
            conn = psycopg2.connect(**self.params)
            cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
            values_template = "(" + ", ".join(["%({})s".format(field_name) for field_name in source.field_names]) + ")"
            insert_stmt = 'INSERT INTO "{}" ("{}") VALUES %s'.format(table_name, '","'.join(source.field_names))
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
            self.logger.exception(error)
        finally:
            if conn is not None:
                conn.close()

        self.logger.info(datetime.datetime.now())
        return rows_inserted

    def select_one(self, table_name, key):
        self.logger.info("selecting {} from {}".format(key, table_name))
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
            self.logger.info(error)
        finally:
            if conn is not None:
                conn.close()

