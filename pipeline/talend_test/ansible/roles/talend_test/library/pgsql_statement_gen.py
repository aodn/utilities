import os

from ansible.module_utils.basic import AnsibleModule


def run_module():
    module_args = dict(
        schema_obj=dict(type='dict', required=True),
        pgsql_output_dir=dict(type='str', required=True),
        pgsql_queries_shell_script=dict(type='str', required=True)
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    p = type('Params', (), module.params)
    queries = []

    template = """
-- get export column list
with query1 as (
  select '"'||array_to_string(array(SELECT column_name::text FROM information_schema.columns WHERE table_schema = '{schema}' AND table_name   = '{table}' and column_name not in ({exclude_columns})),'","')||'"' as "column_list"
),
-- build export query
query2 as (
  select 'select '||(select column_list from query1)||' from {schema}.{table} order by '||(select column_list from query1) as "export_query"
),
-- build export to csv query
query3 as (
  select 'COPY ('||(select export_query from query2)||') to ''{csv_output}'' with csv' as "csv_export_query"
)
-- execute csv_export query
select exec((select csv_export_query from query3)::text);
    """

    for table in p.schema_obj['tables']:

        query = template.format(
            schema=p.schema_obj['name'],
            table=table['name'],
            exclude_columns="'" + "', '".join(table['exclude_columns']) + "'",
            csv_output=os.path.join(p.pgsql_output_dir, p.schema_obj['name'], table['name'] + '.csv'))
        queries.append(query)

    with open(p.pgsql_queries_shell_script, 'a') as _file:
        for query in queries:
            _file.write("%s\n" % query)

    module.exit_json(changed=True, queries=queries)


def main():
    run_module()


if __name__ == '__main__':
    main()
