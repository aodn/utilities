import os
import yaml
import psycopg2
from psycopg2 import sql
from db.db import connect
import csv
from pathlib import Path

db_field_translate = {
    'integer': 'int',
    'string': 'varchar',
    'any': 'varchar',
    'number': 'numeric',
    'datetime': 'timestamp',
    'date': 'date'
}


class DatabaseInteractions(object):

    # private methods

    def __init__(self, config, logger):
        self._errors = False
        self._conn = None
        self._cur = None
        self.config = config
        self.logger = logger

    def __enter__(self):
        self._conn = connect(self.config['db_schema'] or None)
        self._cur = self._conn.cursor()

        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        if self._errors:
            self._conn.rollback()
        else:
            self._conn.commit()
        self._cur.close()
        self._conn.close()

    def __exec(self, statement, params=None):
        try:
            self._cur.execute(sql.SQL(statement), params)
        except (Exception, psycopg2.DatabaseError) as error:
            self.logger.error(error)
            self._errors = True

    def __get_headers(self, file):
        """ Open a CSV file and read the first line into a list

        :param file: an open() file
        :return: header row as a list
        """
        headers = next(csv.reader(file))
        return headers

    # low-level methods

    def current_schema(self):
        self.__exec("SELECT current_schema()")
        return self._cur.fetchone()[0]

    def change_schema(self, new_schema):
        self.config['db_schema'] = new_schema
        self.__exec("SET SEARCH_PATH={}".format(self.config['db_schema']))
        self.logger.info("  new schema is: {}".format(self.current_schema()))


    def check_schema_table(self):
        self.__exec("SELECT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema=current_schema() and table_name ='schema_version')")
        return self._cur.fetchone()[0]

    def check_version(self):
        self.__exec("SELECT version FROM schema_version")
        return self._cur.fetchone()[0]

    def create_table_from_resource(self, path):
        with open(path) as stream:
            try:
                schema = yaml.safe_load(stream)

                # need to add details for primary key (and other constraints?)
                columns = ",".join(('{}  {}'.format(col['name'], db_field_translate[col['type']] or col['type'])
                                    for col in schema['schema']['fields']))
                self.__exec('CREATE TABLE {} ({})'.format(schema['name'], columns))
            except yaml.YAMLError as exc:
                self.logger.error(exc)

    def execute_sql_script(self, path):
        with open(path) as stream:
            self.__exec(stream.read())

    def truncate_table(self, table):
        self.logger.info("  truncating table {}".format(table))
        self.__exec("TRUNCATE TABLE {}".format(table))

    def execute_copy_from(self, table, headers, file):
        self.logger.info("  copying {} table {}".format(file.name, table))
        # trans = "COPY {}({}) FROM STDIN WITH HEADER CSV".format(table, ",".join(headers))
        # print(trans)
        self._cur.copy_expert("COPY {}({}) FROM STDIN WITH HEADER CSV".format(table, ",".join(headers)), file)

    def refresh_materialized_view(self, name):
        self.logger.info("  refreshing materialized view: {}".format(name))
        self.__exec("REFRESH MATERIALIZED VIEW {}".format(name))

    # high-level methods - these are a bit more opinionated

    def refresh_materialized_view_bulk(self, names=None):
        names = names or self.config['mv_refresh']
        for name in names:
            self.refresh_materialized_view(name)

    def copy_from_csv(self, path, truncate=False):
        table = Path(path).stem
        self.logger.info('  attempting to load {}'.format(table))
        with open(path) as f:
            headers = self.__get_headers(f)
            if truncate:
                self.truncate_table(table)
            self.execute_copy_from(table, headers, f)

    def copy_from_csv_bulk(self, path=None, truncate=False):
        path = path or self.config['data_path']
        entries = os.scandir(path)
        for entry in entries:
            if entry.name.endswith('csv'):
                self.copy_from_csv(entry.path, truncate)

    def schema_to_ddl(self, path):
        entries = os.scandir(path)
        for entry in entries:
            if 'resource.yaml' in entry.name:
                self.logger.info('  generating table from {} tableschema resource'.format(entry.name))
                self.create_table_from_resource(entry)
            elif entry.name.endswith('sql'):
                self.logger.info('  executing ddl script {}'.format(entry.name))
                self.execute_sql_script(entry)

    def drop_and_create_schema_objects(self):
        # drop schema objects
        self.logger.info('  dropping all schema objects')
        self.__exec("SELECT public.drop_objects_in_schema('{}')".format(self.config['db_schema']))
        # create and populate version table
        self.logger.info('  creating schema version table')
        self.__exec("CREATE TABLE schema_version AS (SELECT {} AS version)".format(self.config['schema_version']))
        # create resources, then ddl
        self.schema_to_ddl(self.config['yaml_path'])
        self.schema_to_ddl(self.config['ddl_path'])

    def run_ddl(self):
        # check schema version and recreate db objects if different
        if not self.check_schema_table() or (self.check_version() != self.config['schema_version']):
            self.logger.info('  something has changed - rebuilding schema {}'.format(self.config['db_schema']))
            self.drop_and_create_schema_objects()
        else:
            self.logger.info('  database version up to date - moving on')

    def run_dml(self, path=None):
        path = path or self.config['dml_path']
        entries = os.scandir(path)
        size = 0
        for entry in entries:
            if entry.name.endswith('sql'):
                size += 1
                self.execute_sql_script(entry.name)
        if size == 0:
            self.logger.info('  no dml found - moving on')
        else:
            self.logger.info('  {} scripts processed'.format(size))
