from migration.run import RunAlembic
from collections import OrderedDict

import json
import os
import click

from harvester import file_index
from harvester.metadata_harvester import NetcdfMetadataHarvester
from harvester.output.database_store import DatabaseStore
from harvester.stubs.aodncore import PipelineFile
from harvester.feature_harvester import NetcdfFeatureHarvester

# config_file = "config/abos_sofs_fl.json"
# src_path = "IMOS_ABOS-ASFS_FMT_20190805T015900Z_SOFS_FV02.nc"
# dest_path = "IMOS_ABOS-ASFS_FMT_20190805T015900Z_SOFS_FV02.nc"

# config_file = "config/anmn_ts.json"
# src_path = "IMOS_ANMN-QLD_TZ_20130204T000000Z_PIL100_FV01_PIL100-1301-SBE56-43_END-20130801T005134Z_C-20170621T070805Z.nc"
# dest_path = "IMOS_ANMN-QLD_TZ_20130204T000000Z_PIL100_FV01_PIL100-1301-SBE56-43_END-20130801T005134Z_C-20170621T070805Z.nc"


def init_config(config_file):
    with open(config_file) as f:
        return json.load(f, object_pairs_hook=OrderedDict)


def init_alembic(config_file):
    config = init_config(config_file)
    db_params = config["db_params"]
    script_location = os.path.join("migration", db_params["schema"])
    url = db_params["driver"] + "://" + db_params["user"] + ":" + db_params["password"] + "@" + db_params[
        "host"] + ":" + db_params["port"] + "/" + db_params["database"]
    run_alembic = RunAlembic(script_location, url)
    return run_alembic


def init_harvester(config_file, src_path, dest_path):
    config = init_config(config_file)
    db_params = config["db_params"]
    persistent_store = DatabaseStore(db_params)

    netcdf_file = PipelineFile(
        src_path,
        dest_path
    )

    netcdf_metadata_harvester = NetcdfMetadataHarvester(persistent_store, netcdf_file, config, None)
    netcdf_feature_harvester = NetcdfFeatureHarvester(persistent_store, netcdf_file, config, None)
    return persistent_store, netcdf_file, netcdf_metadata_harvester, netcdf_feature_harvester


@click.group()
def harvester():
    pass


@harvester.command()
@click.option('-c', '--config', prompt=True, type=click.Path(exists=True, file_okay=True, resolve_path=False),
              help='Configuration file of the harvester')
def db_create(config):
    run_alembic = init_alembic(config)
    run_alembic.do_upgrade("head")


@harvester.command()
@click.option('-c', '--config', prompt=True, type=click.Path(exists=True, file_okay=True, resolve_path=False),
              help='Configuration file of the harvester')
def db_drop(config):
    run_alembic = init_alembic(config)
    run_alembic.do_downgrade("base")


@harvester.command()
@click.option('-c', '--config', prompt=True, type=click.Path(exists=True, file_okay=True, resolve_path=False),
              help='Configuration file of the harvester')
@click.option('-s', '--source', prompt=True, type=click.Path(exists=True, file_okay=True, resolve_path=False),
              help='Source path for the NetCDF file')
@click.option('-d', '--destination', prompt=True, type=click.Path(exists=True, file_okay=True, resolve_path=False),
              help='Destination path for the NetCDF file')
def harvest(config, source, destination):
    persistent_store, netcdf_file, netcdf_metadata_harvester, netcdf_feature_harvester = init_harvester(config,
                                                                                                        source,
                                                                                                        destination)
    file_index.add_or_update_file(persistent_store, netcdf_file)
    netcdf_metadata_harvester.harvest()
    netcdf_feature_harvester.harvest()


@harvester.command()
@click.option('-c', '--config', prompt=True, type=click.Path(exists=True, file_okay=True, resolve_path=False),
              help='Configuration file of the harvester')
@click.option('-s', '--source', prompt=True, type=click.Path(exists=True, file_okay=True, resolve_path=False),
              help='Source path for the NetCDF file')
@click.option('-d', '--destination', prompt=True, type=click.Path(exists=True, file_okay=True, resolve_path=False),
              help='Destination path for the NetCDF file')
def delete(config, source, destination):
    persistent_store, netcdf_file, netcdf_metadata_harvester, netcdf_feature_harvester = init_harvester(config,
                                                                                                        source,
                                                                                                        destination)
    file_index.delete_file(persistent_store, netcdf_file)
    netcdf_metadata_harvester.delete()
    netcdf_feature_harvester.delete()


harvester.add_command(db_create)
harvester.add_command(db_drop)
harvester.add_command(harvest)
harvester.add_command(delete)

if __name__ == '__main__':
    harvester()
