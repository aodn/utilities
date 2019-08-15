"""create table abos_sofs_fl

Revision ID: dd40085d47ea
Revises: 
Create Date: 2019-08-09 09:35:43.039230

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.schema import Sequence, CreateSequence, DropSequence
import geoalchemy2 as geoal2


# revision identifiers, used by Alembic.
revision = 'dd40085d47ea'
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    op.create_table(
        'timeseries',
        sa.Column('deployment_number', sa.VARCHAR(3), nullable=False),
        sa.Column('mean_latitude', sa.dialects.postgresql.DOUBLE_PRECISION),
        sa.Column('mean_longitude', sa.dialects.postgresql.DOUBLE_PRECISION),
        sa.Column('geom', geoal2.Geometry(geometry_type='Geometry', srid=4326)),
        sa.Column('time_deployment_start', sa.TIMESTAMP(timezone=True)),
        sa.Column('time_deployment_end', sa.TIMESTAMP(timezone=True)),
        sa.PrimaryKeyConstraint('deployment_number', name='timeseries_pk'),
        sa.CheckConstraint(geoal2.functions.ST_IsValid(sa.text('geom')), name='timeseries_geom_check')
    )

    op.execute(CreateSequence(Sequence('indexed_file_id_seq')))
    op.create_table(
        'indexed_file',
        sa.Column('id', sa.INTEGER, nullable=False, server_default=sa.text("nextval('indexed_file_id_seq'::regclass)")),
        sa.Column('url', sa.VARCHAR(512), nullable=False),
        sa.Column('created', sa.TIMESTAMP(timezone=True)),
        sa.Column('modified', sa.TIMESTAMP(timezone=True)),
        sa.Column('first_indexed', sa.TIMESTAMP(timezone=True), server_default=sa.text('now()')),
        sa.Column('last_indexed', sa.TIMESTAMP(timezone=True)),
        sa.Column('last_indexed_run', sa.INTEGER),
        sa.Column('size', sa.dialects.postgresql.DOUBLE_PRECISION),
        sa.Column('deleted', sa.BOOLEAN, server_default=sa.schema.DefaultClause("0")),
        sa.PrimaryKeyConstraint('id', name='indexed_file_pk')
    )
    op.create_index('indexed_file_deleted_idx', 'indexed_file', ['deleted'])

    op.create_table(
        'nc_global_attribute',
        sa.Column('file_id', sa.BIGINT, nullable=False),
        sa.Column('name', sa.dialects.postgresql.TEXT, nullable=False),
        sa.Column('type', sa.dialects.postgresql.TEXT, nullable=False),
        sa.Column('value', sa.dialects.postgresql.TEXT, nullable=False)
    )

    op.create_table(
        'nc_variable',
        sa.Column('file_id', sa.BIGINT, nullable=False),
        sa.Column('name', sa.dialects.postgresql.TEXT, nullable=False),
        sa.Column('type', sa.dialects.postgresql.TEXT, nullable=False),
        sa.Column('dimensions', sa.dialects.postgresql.TEXT, nullable=False),
        sa.Column('shape', sa.dialects.postgresql.TEXT, nullable=False)
    )

    op.create_table(
        'nc_variable_attribute',
        sa.Column('file_id', sa.BIGINT, nullable=False),
        sa.Column('var_name', sa.dialects.postgresql.TEXT, nullable=False),
        sa.Column('attr_name', sa.dialects.postgresql.TEXT, nullable=False),
        sa.Column('type', sa.dialects.postgresql.TEXT, nullable=False),
        sa.Column('value', sa.dialects.postgresql.TEXT, nullable=False)
    )

    op.create_table(
        'timeseries_file',
        sa.Column('file_id', sa.BIGINT, nullable=False),
        sa.Column('deployment_number', sa.VARCHAR(3), nullable=False),
        sa.Column('delivery_mode', sa.VARCHAR(3), nullable=False),
        sa.Column('latitude', sa.REAL),
        sa.Column('time_coverage_start', sa.TIMESTAMP(timezone=True)),
        sa.Column('time_coverage_end', sa.TIMESTAMP(timezone=True)),
        sa.Column('date_created', sa.TIMESTAMP(timezone=True)),
        sa.UniqueConstraint('file_id', name='timeseries_file_file_id_uc')
    )
    op.create_foreign_key(
        'timeseries_file_indexed_file_fk', 'timeseries_file',
        'indexed_file', ['file_id'], ['id'],
        onupdate='CASCADE', ondelete='CASCADE', match='SIMPLE'
    )

    op.create_table(
        'measurement',
        # sa.Column('deployment_number', sa.VARCHAR(3), nullable=False),
        # sa.Column('delivery_mode', sa.VARCHAR(3), nullable=False),
        sa.Column('file_id', sa.BIGINT, nullable=False),
        sa.Column('TIME', sa.TIMESTAMP(timezone=True), nullable=False),
        sa.Column('LATITUDE', sa.REAL),
        sa.Column('LONGITUDE', sa.REAL),
        sa.Column('PL_CMP', sa.REAL),
        sa.Column('WDIR', sa.REAL),
        sa.Column('WSPD', sa.REAL),
        sa.Column('WIND_H', sa.REAL),
        sa.Column('WIND_FLAG', sa.INTEGER),
        sa.Column('ATMP', sa.REAL),
        sa.Column('ATMP_H', sa.REAL),
        sa.Column('ATMP_FLAG', sa.INTEGER),
        sa.Column('AIRT', sa.REAL),
        sa.Column('AIRT_H', sa.REAL),
        sa.Column('AIRT_FLAG', sa.INTEGER),
        sa.Column('RELH', sa.REAL),
        sa.Column('RELH_H', sa.REAL),
        sa.Column('RELH_FLAG', sa.INTEGER),
        sa.Column('TEMP', sa.REAL),
        sa.Column('TEMP_H', sa.REAL),
        sa.Column('TEMP_FLAG', sa.INTEGER),
        sa.Column('RAIN_AMOUNT', sa.REAL),
        sa.Column('RAIN_AMOUNT_H', sa.REAL),
        sa.Column('RAIN_AMOUNT_FLAG', sa.INTEGER),
        sa.Column('SW', sa.REAL),
        sa.Column('SW_H', sa.REAL),
        sa.Column('SW_FLAG', sa.INTEGER),
        sa.Column('LW', sa.REAL),
        sa.Column('LW_H', sa.REAL),
        sa.Column('LW_FLAG', sa.INTEGER),
        sa.Column('HS', sa.REAL),
        sa.Column('HL', sa.REAL),
        sa.Column('H_RAIN', sa.REAL),
        sa.Column('TAU', sa.REAL),
        sa.Column('SST', sa.REAL),
        sa.Column('HEAT_NET', sa.REAL),
        sa.Column('MASS_NET', sa.REAL),
        sa.Column('LW_NET', sa.REAL),
        sa.Column('SW_NET', sa.REAL),
        sa.Column('WSPD10M', sa.REAL),
        sa.Column('AIRT1_5M', sa.REAL),
        sa.Column('AIRT2_0M', sa.REAL),
        sa.Column('RELH1_5M', sa.REAL),
        sa.Column('RELH2_0M', sa.REAL),
    )
    op.create_primary_key(
        'measurement_pk', 'measurement',
        ['file_id', 'TIME']
    )
    op.create_foreign_key(
        'measurement_timeseries_file_fk', 'measurement',
        'timeseries_file', ['file_id'], ['file_id'],
        onupdate='CASCADE', ondelete='CASCADE', match='SIMPLE'
    )


def downgrade():
    op.drop_constraint(u'measurement_timeseries_file_fk', 'measurement', type_='foreignkey')
    op.drop_constraint(u'measurement_pk', 'measurement', type_='primary')
    op.drop_table('measurement')

    op.drop_table('nc_global_attribute')
    op.drop_table('nc_variable')
    op.drop_table('nc_variable_attribute')

    op.drop_constraint(u'timeseries_file_indexed_file_fk', 'timeseries_file', type_='foreignkey')
    op.drop_table('timeseries_file')

    op.drop_index('indexed_file_deleted_idx')
    op.drop_table('indexed_file')
    op.execute(DropSequence(Sequence('indexed_file_id_seq')))

    op.drop_table('timeseries')
