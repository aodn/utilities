#!/usr/bin/python
import psycopg2
from config import config


def connect(schema=None):
    """ Connect to the PostgreSQL database server """
    schema = schema or "dbo,public"
    params = config()
    params['options'] = "-c search_path={}".format(schema)
    return psycopg2.connect(**params)
