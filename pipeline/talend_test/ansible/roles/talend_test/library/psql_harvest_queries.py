
import os

import psycopg2
from ansible.module_utils.basic import AnsibleModule

select_template = """
        with query1 as (   select
          '"'||array_to_string(array(SELECT
            column_name::text 
          FROM
            information_schema.columns 
          WHERE
            table_schema = '{schema}' 
            AND table_name   = '{table}' 
            and column_name not in ({exclude_columns})),
        '","')||'"' as "column_list" )
        select
        'select '||(select
            column_list 
        from
            query1)||' from {schema}.{table} order by '||(select
            column_list 
        from
            query1) as "export_column";""".replace('\n', '')


def exec_query(conn_string, query):
    conn = psycopg2.connect(conn_string)
    cur = conn.cursor()
    cur.execute(query)
    rows = cur.fetchall()
    cur.close()
    conn.close()
    return rows


def generate_select_statement(conn_string, schema, table, exclude_columns):
    query = select_template.format(
        schema=schema,
        table=table,
        exclude_columns="'" + "', '".join(exclude_columns) + "'")

    return exec_query(conn_string, query)[0][0]


def table_query_to_disk(conn_string, select_statement, csv_file_path):

    conn = psycopg2.connect(conn_string)
    cur = conn.cursor()
    outputquery = "COPY ({0}) TO STDOUT WITH CSV HEADER".format(select_statement)

    with open(csv_file_path, 'w+') as f:
        cur.copy_expert(outputquery, f)

    conn.close()


def run_module():
    module_args = dict(
        schema_obj=dict(type='dict', required=True),
        tmp_dir=dict(type='str', required=True),
        db_user=dict(type='str', required=True),
        db_host=dict(type='str', required=True),
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    p = type('Params', (), module.params)

    conn_string = "dbname='harvest' user='{db_user}' host='{db_host}'".format(
        db_user=p.db_user,
        db_host=p.db_host)

    for table in p.schema_obj['tables']:
        select_statement = generate_select_statement(conn_string, p.schema_obj['name'], table['name'], table['exclude_columns'])
        table_query_to_disk(conn_string, select_statement, os.path.join(p.tmp_dir, table['name'] + '.csv'))

    module.exit_json(changed=True)


def main():
    run_module()


if __name__ == '__main__':
    main()
