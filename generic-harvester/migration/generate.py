from sqlalchemy import create_engine
from sqlalchemy import MetaData, Table
from alembic import autogenerate
from alembic.operations import ops

e = create_engine("postgresql+psycopg2://abos_sofs_fl:abos_sofs_fl@localhost/abos_sofs_fl")

with e.connect() as conn:
    m = MetaData()
    # timeseries_table = Table('timeseries', m, autoload_with=conn)
    # measurement_table = Table('measurement', m, autoload_with=conn)
    # file_metadata_table = Table('file_metadata', m, autoload_with=conn)
    indexed_file_table = Table('indexed_file', m, autoload_with=conn)


print(autogenerate.render_python_code(
    ops.UpgradeOps(
        ops=[
            ops.CreateTableOp.from_table(table) for table in m.tables.values()
        ] + [
            ops.CreateIndexOp.from_index(idx) for table in m.tables.values()
            for idx in table.indexes
        ]
    ))
)
