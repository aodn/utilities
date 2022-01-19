import unittest
from db.db import connect
import os

import psycopg2


class TestDatabaseConnection(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        os.chdir("../")
        # abspath = os.path.abspath(__file__)
        # print(abspath, os.path.dirname(abspath))

    def test_connect(self):
        """ Connect to database"""
        conn = connect()
        # create a cursor
        with conn.cursor() as cur:
            cur.execute('SELECT current_schema()')
            self.assertIsNotNone(cur.fetchone())

    def test_connect_schema(self):
        """ Connect to database using schema name"""
        schema = "barebones"
        conn = connect(schema)
        # create a cursor
        with conn.cursor() as cur:
            cur.execute('SELECT current_schema()')
            curr_schema = cur.fetchone()[0]
            self.assertEqual(schema, curr_schema)


if __name__ == '__main__':
    unittest.main()
