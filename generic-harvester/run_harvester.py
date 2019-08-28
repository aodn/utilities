"""
Run Harvester Commandline Stand alone application

python run_harvester.py db-drop -c config/file_index.json
python run_harvester.py db-create  -c config/file_index.json

python run_harvester.py db-drop -c config/abos_sofs_fl.json
python run_harvester.py db-create  -c config/abos_sofs_fl.json

python run_harvester.py harvest -c config/abos_sofs_fl.json -i config/file_index.json -s IMOS_ABOS-ASFS_FMT_20190805T015900Z_SOFS_FV02.nc -d IMOS_ABOS-ASFS_FMT_20190805T015900Z_SOFS_FV02.nc
python run_harvester.py delete -c config/abos_sofs_fl.json -i config/file_index.json -s IMOS_ABOS-ASFS_FMT_20190805T015900Z_SOFS_FV02.nc -d IMOS_ABOS-ASFS_FMT_20190805T015900Z_SOFS_FV02.nc
python run_harvester.py update-metadata -c config/abos_sofs_fl.json

python run_harvester.py db-drop -c config/anmn_ts.json
python run_harvester.py db-create  -c config/anmn_ts.json

python run_harvester.py harvest -c config/anmn_ts.json -i config/file_index.json -s IMOS_ANMN-NSW_TZ_20141118T130000Z_BMP070_FV01_BMP070-1411-Aqualogger-520PT-16_END-20150504T063500Z_C-20160901T044727Z.nc -d IMOS_ANMN-NSW_TZ_20141118T130000Z_BMP070_FV01_BMP070-1411-Aqualogger-520PT-16_END-20150504T063500Z_C-20160901T044727Z.nc
python run_harvester.py delete -c config/anmn_ts.json -i config/file_index.json -s IMOS_ANMN-NSW_TZ_20141118T130000Z_BMP070_FV01_BMP070-1411-Aqualogger-520PT-16_END-20150504T063500Z_C-20160901T044727Z.nc -d IMOS_ANMN-NSW_TZ_20141118T130000Z_BMP070_FV01_BMP070-1411-Aqualogger-520PT-16_END-20150504T063500Z_C-20160901T044727Z.nc
python run_harvester.py update-metadata -c config/anmn_ts.json

"""

from migration.run_alembic import RunAlembic
from collections import OrderedDict

import json
import os
import click

from harvester import file_index
from harvester.metadata_harvester import NetcdfMetadataHarvester
from harvester.store.database_store import DatabaseStore
from harvester.stubs.aodncore import PipelineFile
from harvester.feature_harvester import NetcdfFeatureHarvester
from harvester.metadata.update_metadata import MetadataUpdater


def init_config(config_file):
    """
    Read configuration file
    :param config_file: path to configuration file
    :return: configuration json object
    """
    with open(config_file) as f:
        return json.load(f, object_pairs_hook=OrderedDict)


def init_alembic(config_file):
    """
    Initialise alembic
    :param config_file: path to configuration file
    :return: returns (RunAlembic) instance
    """
    config = init_config(config_file)
    db_params = config["db_params"]
    script_location = os.path.join("migration", db_params["schema"])
    url = db_params["driver"] + "://" + db_params["user"] + ":" + db_params["password"] + "@" + db_params[
        "host"] + ":" + db_params["port"] + "/" + db_params["database"]
    run_alembic = RunAlembic(script_location, url)
    return run_alembic


def init_harvester(config_file, index_config_file, src_path, dest_path):
    """
    Create Harvesters classes
    :param config_file: path to harvester configuration file
    :param index_config_file: path to indexer configuration file
    :param src_path: source path for the NetCDF file
    :param dest_path: destination path for the NetCDF file
    :return: returns (DatabaseStore, PipelineFile, NetcdfMetadataHarvester, NetcdfFeatureHarvester) instances
    """
    config = init_config(config_file)
    index_config = init_config(index_config_file)

    index_store = DatabaseStore(index_config["db_params"])
    feature_store = DatabaseStore(config["db_params"])

    netcdf_file = PipelineFile(
        src_path,
        dest_path
    )

    netcdf_metadata_harvester = NetcdfMetadataHarvester(index_store, index_config, None)
    netcdf_feature_harvester = NetcdfFeatureHarvester(feature_store, config, None)
    return index_store, netcdf_file, netcdf_metadata_harvester, netcdf_feature_harvester


def init_metadata_updater(config_file):
    """
    Create MetadataUpdater class
    :param config_file: path to configuration file
    :return: returns (MetadataUpdater) instance
    """
    config = init_config(config_file)
    # Create MetadataUpdater instance
    return MetadataUpdater(config)


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
@click.option('-i', '--config_index', prompt=True, type=click.Path(exists=True, file_okay=True, resolve_path=False),
              help='Configuration file of the indexer')
@click.option('-s', '--source', prompt=True, type=click.Path(exists=True, file_okay=True, resolve_path=False),
              help='Source path for the NetCDF file')
@click.option('-d', '--destination', prompt=True, type=click.Path(exists=True, file_okay=True, resolve_path=False),
              help='Destination path for the NetCDF file')
def harvest(config, config_index, source, destination):
    index_store, netcdf_file, netcdf_metadata_harvester, netcdf_feature_harvester = init_harvester(config,
                                                                                                   config_index,
                                                                                                   source,
                                                                                                   destination)
    file_index.add_or_update_file(index_store, netcdf_file)
    netcdf_metadata_harvester.harvest(netcdf_file)
    netcdf_feature_harvester.harvest(netcdf_file)


@harvester.command()
@click.option('-c', '--config', prompt=True, type=click.Path(exists=True, file_okay=True, resolve_path=False),
              help='Configuration file of the harvester')
@click.option('-i', '--config_index', prompt=True, type=click.Path(exists=True, file_okay=True, resolve_path=False),
              help='Configuration file of the indexer')
@click.option('-s', '--source', prompt=True, type=click.Path(exists=True, file_okay=True, resolve_path=False),
              help='Source path for the NetCDF file')
@click.option('-d', '--destination', prompt=True, type=click.Path(exists=True, file_okay=True, resolve_path=False),
              help='Destination path for the NetCDF file')
def delete(config, config_index, source, destination):
    index_store, netcdf_file, netcdf_metadata_harvester, netcdf_feature_harvester = init_harvester(config,
                                                                                                   config_index,
                                                                                                   source,
                                                                                                   destination)
    file_index.delete_file(index_store, netcdf_file)
    netcdf_metadata_harvester.delete(netcdf_file)
    netcdf_feature_harvester.delete(netcdf_file)


@harvester.command()
@click.option('-c', '--config', prompt=True, type=click.Path(exists=True, file_okay=True, resolve_path=False),
              help='Configuration file of the harvester')
def update_metadata(config):
    # Create MetadataUpdater instance
    updater = init_metadata_updater(config)

    # Update metadata information
    updater.update_metadata()


harvester.add_command(db_create)
harvester.add_command(db_drop)
harvester.add_command(harvest)
harvester.add_command(delete)
harvester.add_command(update_metadata)

if __name__ == '__main__':
    harvester()
