"""create table anmn_ts

Revision ID: abdd2c23e5c7
Revises: 
Create Date: 2019-08-19 08:02:36.109635

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.schema import Sequence, CreateSequence, DropSequence
import geoalchemy2 as geoal2


# revision identifiers, used by Alembic.
revision = 'abdd2c23e5c7'
down_revision = None
branch_labels = None
depends_on = None


def upgrade():

    op.create_table(
        'feature_metadata',
        sa.Column('file_id', sa.BIGINT, nullable=False),
        sa.Column('site_code', sa.TEXT, nullable=False),
        sa.Column('platform_code', sa.TEXT, nullable=False),
        sa.Column('deployment_code', sa.TEXT, nullable=False),
        sa.Column('LATITUDE', sa.dialects.postgresql.DOUBLE_PRECISION),
        sa.Column('LATITUDE_quality_control', sa.TEXT),
        sa.Column('LONGITUDE', sa.dialects.postgresql.DOUBLE_PRECISION),
        sa.Column('LONGITUDE_quality_control', sa.TEXT),
        sa.Column('geom', geoal2.Geometry(geometry_type='Geometry', srid=4326)),
        sa.Column('instrument_nominal_depth', sa.REAL),
        sa.Column('site_nominal_depth', sa.REAL),
        sa.Column('site_depth_at_deployment', sa.REAL),
        sa.Column('instrument', sa.TEXT),
        sa.Column('instrument_serial_number', sa.TEXT),
        sa.Column('time_coverage_start', sa.TIMESTAMP(timezone=True)),
        sa.Column('time_coverage_end', sa.TIMESTAMP(timezone=True)),
        sa.Column('time_deployment_start', sa.TIMESTAMP(timezone=True)),
        sa.Column('time_deployment_end', sa.TIMESTAMP(timezone=True)),
        sa.Column('comment', sa.TEXT),
        sa.Column('history', sa.TEXT),
        sa.Column('toolbox_version', sa.TEXT),
        sa.Column('depth_b', sa.BOOLEAN),
        sa.Column('sea_water_temperature_b', sa.BOOLEAN),
        sa.Column('sea_water_electrical_conductivity_b', sa.BOOLEAN),
        sa.Column('sea_water_salinity_b', sa.BOOLEAN),
        sa.Column('sea_water_pressure_b', sa.BOOLEAN),
        sa.Column('sea_water_pressure_due_to_sea_water_b', sa.BOOLEAN),
        sa.PrimaryKeyConstraint('file_id', name='feature_metadata_pk'),
        sa.CheckConstraint(geoal2.functions.ST_IsValid(sa.text('geom')), name='feature_metadata_geom_check')
    )
    op.create_foreign_key(
        'feature_metadata_fk', 'feature_metadata',
        'indexed_file', ['file_id'], ['id'],
        referent_schema='file_index',
        onupdate='CASCADE', ondelete='CASCADE', match='SIMPLE'
    )

    op.create_table(
        'file_metadata',
        sa.Column('file_id', sa.BIGINT, nullable=False),
        sa.Column('site_code', sa.TEXT, nullable=False),
        sa.Column('platform_code', sa.TEXT, nullable=False),
        sa.Column('deployment_code', sa.TEXT, nullable=False),
        sa.Column('LATITUDE', sa.dialects.postgresql.DOUBLE_PRECISION),
        sa.Column('LATITUDE_quality_control', sa.TEXT),
        sa.Column('LONGITUDE', sa.dialects.postgresql.DOUBLE_PRECISION),
        sa.Column('LONGITUDE_quality_control', sa.TEXT),
        sa.Column('geom', geoal2.Geometry(geometry_type='Geometry', srid=4326)),
        sa.Column('instrument_nominal_depth', sa.REAL),
        sa.Column('site_nominal_depth', sa.REAL),
        sa.Column('site_depth_at_deployment', sa.REAL),
        sa.Column('instrument', sa.TEXT),
        sa.Column('instrument_serial_number', sa.TEXT),
        sa.Column('time_coverage_start', sa.TIMESTAMP(timezone=True)),
        sa.Column('time_coverage_end', sa.TIMESTAMP(timezone=True)),
        sa.Column('time_deployment_start', sa.TIMESTAMP(timezone=True)),
        sa.Column('time_deployment_end', sa.TIMESTAMP(timezone=True)),
        sa.Column('comment', sa.TEXT),
        sa.Column('history', sa.TEXT),
        sa.Column('toolbox_version', sa.TEXT),
        sa.UniqueConstraint('file_id', name='file_metadata_id_uc')
    )
    op.create_foreign_key(
        'file_metadata_indexed_file_fk', 'file_metadata',
        'indexed_file', ['file_id'], ['id'],
        referent_schema='file_index',
        onupdate='CASCADE', ondelete='CASCADE', match='SIMPLE'
    )

    op.create_table(
        'measurement',
        sa.Column('file_id', sa.BIGINT, nullable=False),
        sa.Column('TIME', sa.TIMESTAMP(timezone=True), nullable=False),
        sa.Column('TIME_quality_control', sa.TEXT),
        sa.Column('DEPTH', sa.REAL),
        sa.Column('DEPTH_quality_control', sa.TEXT),
        sa.Column('TEMP', sa.REAL),
        sa.Column('TEMP_quality_control', sa.TEXT),
        sa.Column('CNDC', sa.REAL),
        sa.Column('CNDC_quality_control', sa.TEXT),
        sa.Column('PSAL', sa.REAL),
        sa.Column('PSAL_quality_control', sa.TEXT),
        sa.Column('PRES', sa.REAL),
        sa.Column('PRES_quality_control', sa.TEXT),
        sa.Column('PRES_REL', sa.REAL),
        sa.Column('PRES_REL_quality_control', sa.TEXT)
    )
    op.create_primary_key(
        'measurement_pk', 'measurement',
        ['file_id', 'TIME']
    )
    op.create_foreign_key(
        'measurement_ts_fk', 'measurement',
        'file_metadata', ['file_id'], ['file_id'],
        onupdate='CASCADE', ondelete='CASCADE', match='SIMPLE'
    )


def downgrade():
    op.drop_constraint(u'measurement_ts_fk', 'measurement', type_='foreignkey')
    op.drop_constraint(u'measurement_pk', 'measurement', type_='primary')
    op.drop_table('measurement')

    op.drop_constraint(u'file_metadata_indexed_file_fk', 'file_metadata', type_='foreignkey')
    op.drop_table('file_metadata')

    op.drop_constraint(u'feature_metadata_fk', 'feature_metadata', type_='foreignkey')
    op.drop_table('feature_metadata')


