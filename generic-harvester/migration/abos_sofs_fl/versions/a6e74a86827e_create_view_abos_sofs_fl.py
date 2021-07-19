"""create view abos_sofs_fl

Revision ID: a6e74a86827e
Revises: cac5d2f75f1c
Create Date: 2019-08-15 10:28:41.720302

"""
from alembic import op
from migration.replaceable_object import ReplaceableObject


# revision identifiers, used by Alembic.
revision = 'a6e74a86827e'
down_revision = 'dd40085d47ea'
branch_labels = None
depends_on = None


def upgrade():
    op.create_view(get_abos_sofs_surfaceflux_dm_data())
    op.create_view(get_abos_sofs_surfaceflux_dm_map())
    op.create_view(get_abos_sofs_surfaceflux_rt_data())
    op.create_view(get_abos_sofs_surfaceflux_rt_map())


def downgrade():
    op.drop_view(get_abos_sofs_surfaceflux_dm_data())
    op.drop_view(get_abos_sofs_surfaceflux_dm_map())
    op.drop_view(get_abos_sofs_surfaceflux_rt_data())
    op.drop_view(get_abos_sofs_surfaceflux_rt_map())


def get_abos_sofs_surfaceflux_dm_data():
    abos_sofs_surfaceflux_dm_data = ReplaceableObject(
        "abos_sofs_surfaceflux_dm_data",
        "SELECT fm.deployment_number, "
        "fm.delivery_mode, "
        "m.file_id, "
        "timezone('UTC'::text, m.\"TIME\") AS \"TIME\", "
        "m.\"LATITUDE\", "
        "m.\"LONGITUDE\", "
        "m.\"PL_CMP\", "
        "m.\"WDIR\", "
        "m.\"WSPD\", "
        "m.\"WIND_H\", "
        "m.\"WIND_FLAG\", "
        "m.\"ATMP\", "
        "m.\"ATMP_H\", "
        "m.\"ATMP_FLAG\", "
        "m.\"AIRT\", "
        "m.\"AIRT_H\", "
        "m.\"AIRT_FLAG\", "
        "m.\"RELH\", "
        "m.\"RELH_H\", "
        "m.\"RELH_FLAG\", "
        "m.\"TEMP\", "
        "m.\"TEMP_H\", "
        "m.\"TEMP_FLAG\", "
        "m.\"RAIN_AMOUNT\", "
        "m.\"RAIN_AMOUNT_H\", "
        "m.\"RAIN_AMOUNT_FLAG\", "
        "m.\"SW\", "
        "m.\"SW_H\", "
        "m.\"SW_FLAG\", "
        "m.\"LW\", "
        "m.\"LW_H\", "
        "m.\"LW_FLAG\", "
        "m.\"HS\", "
        "m.\"HL\", "
        "m.\"H_RAIN\", "
        "m.\"TAU\", "
        "m.\"SST\", "
        "m.\"HEAT_NET\", "
        "m.\"MASS_NET\", "
        "m.\"LW_NET\", "
        "m.\"SW_NET\", "
        "m.\"WSPD10M\", "
        "m.\"AIRT1_5M\", "
        "m.\"AIRT2_0M\", "
        "m.\"RELH1_5M\", "
        "m.\"RELH2_0M\", "
        "f.geom "
        "FROM measurement m "
        "JOIN file_metadata fm USING (file_id) "
        "JOIN feature_metadata f ON f.deployment_number = fm.deployment_number "
        "WHERE fm.delivery_mode::text = 'DM'::text "
        )
    return abos_sofs_surfaceflux_dm_data


def get_abos_sofs_surfaceflux_dm_map():
    abos_sofs_surfaceflux_dm_map = ReplaceableObject(
        "abos_sofs_surfaceflux_dm_map",
        "SELECT m.file_id, "
        "m.deployment_number, "
        "m.delivery_mode, "
        "timezone('UTC'::text, m.time_coverage_start) AS time_coverage_start, "
        "timezone('UTC'::text, m.time_coverage_end) AS time_coverage_end, "
        "timezone('UTC'::text, m.date_created) AS date_created, "
        "i.url, "
        "i.size, "
        "f.geom "
        "FROM feature_metadata f "
        "JOIN file_metadata m USING (deployment_number) "
        "JOIN file_index.indexed_file i ON m.file_id = i.id "
        "WHERE m.delivery_mode::text = 'DM'::text "
        "ORDER BY (timezone('UTC'::text, m.time_coverage_start));"
    )
    return abos_sofs_surfaceflux_dm_map


def get_abos_sofs_surfaceflux_rt_data():
    abos_sofs_surfaceflux_rt_data = ReplaceableObject(
        "abos_sofs_surfaceflux_rt_data",
        "SELECT fm.deployment_number, "
        "fm.delivery_mode, "
        "m.file_id, "
        "timezone('UTC'::text, m.\"TIME\") AS \"TIME\", "
        "m.\"LATITUDE\", "
        "m.\"LONGITUDE\", "
        "m.\"PL_CMP\", "
        "m.\"WDIR\", "
        "m.\"WSPD\", "
        "m.\"WIND_H\", "
        "m.\"WIND_FLAG\", "
        "m.\"ATMP\", "
        "m.\"ATMP_H\", "
        "m.\"ATMP_FLAG\", "
        "m.\"AIRT\", "
        "m.\"AIRT_H\", "
        "m.\"AIRT_FLAG\", "
        "m.\"RELH\", "
        "m.\"RELH_H\", "
        "m.\"RELH_FLAG\", "
        "m.\"TEMP\", "
        "m.\"TEMP_H\", "
        "m.\"TEMP_FLAG\", "
        "m.\"RAIN_AMOUNT\", "
        "m.\"RAIN_AMOUNT_H\", "
        "m.\"RAIN_AMOUNT_FLAG\", "
        "m.\"SW\", "
        "m.\"SW_H\", "
        "m.\"SW_FLAG\", "
        "m.\"LW\", "
        "m.\"LW_H\", "
        "m.\"LW_FLAG\", "
        "m.\"HS\", "
        "m.\"HL\", "
        "m.\"H_RAIN\", "
        "m.\"TAU\", "
        "m.\"SST\", "
        "m.\"HEAT_NET\", "
        "m.\"MASS_NET\", "
        "m.\"LW_NET\", "
        "m.\"SW_NET\", "
        "m.\"WSPD10M\", "
        "m.\"AIRT1_5M\", "
        "m.\"AIRT2_0M\", "
        "m.\"RELH1_5M\", "
        "m.\"RELH2_0M\", "
        "f.geom "
        "FROM measurement m "
        "JOIN file_metadata fm USING (file_id) "
        "JOIN feature_metadata f ON f.deployment_number = fm.deployment_number "
        "WHERE fm.delivery_mode::text = 'RT'::text "
        )
    return abos_sofs_surfaceflux_rt_data


def get_abos_sofs_surfaceflux_rt_map():
    abos_sofs_surfaceflux_rt_map = ReplaceableObject(
        "abos_sofs_surfaceflux_rt_map",
        "SELECT m.file_id, "
        "m.deployment_number, "
        "m.delivery_mode, "
        "timezone('UTC'::text, m.time_coverage_start) AS time_coverage_start, "
        "timezone('UTC'::text, m.time_coverage_end) AS time_coverage_end, "
        "timezone('UTC'::text, m.date_created) AS date_created, "
        "i.url, "
        "i.size, "
        "f.geom "
        "FROM feature_metadata f "
        "JOIN file_metadata m USING (deployment_number) "
        "JOIN file_index.indexed_file i ON m.file_id = i.id "
        "WHERE m.delivery_mode::text = 'RT'::text "
        "ORDER BY (timezone('UTC'::text, m.time_coverage_start));"
    )
    return abos_sofs_surfaceflux_rt_map

