"""create view anmn_ts

Revision ID: 23ba54540692
Revises: abdd2c23e5c7
Create Date: 2019-08-19 11:38:02.569636

"""
from alembic import op
from migration.replaceable_object import ReplaceableObject


# revision identifiers, used by Alembic.
revision = '23ba54540692'
down_revision = 'abdd2c23e5c7'
branch_labels = None
depends_on = None


def upgrade():
    op.create_view(get_anmn_ts_timeseries_data())
    op.create_view(get_anmn_ts_timeseries_map())


def downgrade():
    op.drop_view(get_anmn_ts_timeseries_data())
    op.drop_view(get_anmn_ts_timeseries_map())

def get_anmn_ts_timeseries_data():
    anmn_ts_timeseries_data = ReplaceableObject(
        "anmn_ts_timeseries_data",
        "SELECT m.file_id AS timeseries_id, "
        "fm.site_code, "
        "fm.platform_code, "
        "fm.deployment_code, "
        "fm.instrument_nominal_depth, "
        "timezone('UTC'::text, m.\"TIME\") AS \"TIME\", "
        "m.\"TIME_quality_control\", "
        "fm.\"LATITUDE\", "
        "fm.\"LATITUDE_quality_control\", "
        "fm.\"LONGITUDE\", "
        "fm.\"LONGITUDE_quality_control\", "
        "m.\"DEPTH\", "
        "m.\"DEPTH_quality_control\", "
        "m.\"TEMP\", "
        "m.\"TEMP_quality_control\", "
        "m.\"CNDC\", "
        "m.\"CNDC_quality_control\", "
        "m.\"PSAL\", "
        "m.\"PSAL_quality_control\", "
        "m.\"PRES\", "
        "m.\"PRES_quality_control\", "
        "m.\"PRES_REL\", "
        "m.\"PRES_REL_quality_control\", "
        "fm.geom, "
        "fm.depth_b, "
        "fm.sea_water_temperature_b, "
        "fm.sea_water_electrical_conductivity_b, "
        "fm.sea_water_salinity_b, "
        "fm.sea_water_pressure_b, "
        "fm.sea_water_pressure_due_to_sea_water_b "
        "FROM feature_metadata fm "
        "JOIN measurement m ON fm.file_id = m.file_id;"
        )
    return anmn_ts_timeseries_data


def get_anmn_ts_timeseries_map():
    anmn_ts_timeseries_map = ReplaceableObject(
        "anmn_ts_timeseries_map",
        "SELECT fm.file_id AS timeseries_id, "
        "fm.site_code, "
        "fm.platform_code, "
        "fm.deployment_code, "
        "fm.geom, "
        "fm.\"LATITUDE\", "
        "fm.\"LONGITUDE\", "
        "fm.instrument_nominal_depth, "
        "timezone('UTC'::text, fm.time_coverage_start) AS time_coverage_start, "
        "timezone('UTC'::text, fm.time_coverage_end) AS time_coverage_end, "
        "fm.instrument, "
        "fm.instrument_serial_number, "
        "f.url AS file_url, "
        "f.size, "
        "fm.depth_b, "
        "fm.sea_water_temperature_b, "
        "fm.sea_water_electrical_conductivity_b, "
        "fm.sea_water_salinity_b, "
        "fm.sea_water_pressure_b, "
        "fm.sea_water_pressure_due_to_sea_water_b "
        "FROM feature_metadata fm "
        "JOIN indexed_file f ON fm.file_id = f.id;"
    )
    return anmn_ts_timeseries_map
