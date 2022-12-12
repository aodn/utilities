"""create table abos_sofs_fl

Revision ID: dd40085d47ea
Revises: 
Create Date: 2019-08-09 09:35:43.039230

"""
from alembic import op
import sqlalchemy as sa
import geoalchemy2 as geoal2


# revision identifiers, used by Alembic.
revision = 'dd40085d47ea'
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    op.create_table(
        'feature_metadata',
        sa.Column('deployment_number', sa.VARCHAR(3), nullable=False),
        sa.Column('mean_latitude', sa.dialects.postgresql.DOUBLE_PRECISION),
        sa.Column('mean_longitude', sa.dialects.postgresql.DOUBLE_PRECISION),
        sa.Column('geom', geoal2.Geometry(geometry_type='Geometry', srid=4326)),
        sa.Column('time_deployment_start', sa.TIMESTAMP(timezone=True)),
        sa.Column('time_deployment_end', sa.TIMESTAMP(timezone=True)),
        sa.PrimaryKeyConstraint('deployment_number', name='feature_metadata_pk'),
        sa.CheckConstraint(geoal2.functions.ST_IsValid(sa.text('geom')), name='feature_metadata_geom_check')
    )

    op.create_table(
        'file_metadata',
        sa.Column('file_id', sa.BIGINT, nullable=False),
        sa.Column('deployment_number', sa.VARCHAR(3), nullable=False),
        sa.Column('delivery_mode', sa.VARCHAR(3), nullable=False),
        sa.Column('latitude', sa.REAL),
        sa.Column('time_coverage_start', sa.TIMESTAMP(timezone=True)),
        sa.Column('time_coverage_end', sa.TIMESTAMP(timezone=True)),
        sa.Column('date_created', sa.TIMESTAMP(timezone=True)),
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
        sa.Column('RELH2_0M', sa.REAL)
    )
    op.create_primary_key(
        'measurement_pk', 'measurement',
        ['file_id', 'TIME']
    )
    op.create_foreign_key(
        'measurement_file_metadata_fk', 'measurement',
        'file_metadata', ['file_id'], ['file_id'],
        onupdate='CASCADE', ondelete='CASCADE', match='SIMPLE'
    )


def downgrade():
    op.drop_constraint(u'measurement_file_metadata_fk', 'measurement', type_='foreignkey')
    op.drop_constraint(u'measurement_pk', 'measurement', type_='primary')
    op.drop_table('measurement')

    op.drop_constraint(u'file_metadata_indexed_file_fk', 'file_metadata', type_='foreignkey')
    op.drop_table('file_metadata')

    op.drop_table('feature_metadata')
