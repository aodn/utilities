import logging

import click

from seeder import Seeder, GeoWebCache, GeoNetworkConnector

# Main function
TRUNCATE = 'truncate'
SEED = 'seed'
PURGE = 'purge'


@click.command(context_settings=dict(help_option_names=['-h', '--help']))
@click.option('-n', '--geonetwork', type=click.STRING, envvar='geonetwork', required=True,
              help='Geonetwork URL')
@click.option('-g', '--geoserver', type=click.STRING, envvar='geoserver', help='Geoserver URL')
@click.option('-w', '--geowebcache', type=click.STRING, envvar='geowebcache', required=True, help='Geowebcache URL')
@click.option('-u', '--geowebcache-user', type=click.STRING, envvar='geowebcache_user', required=True,
              help='Geowebcache username')
@click.option('-p', '--geowebcache-password', type=click.STRING, envvar='geowebcache_password', required=True,
              help='Geowebcache password')
@click.option('-t', '--req-type', type=click.Choice([TRUNCATE, PURGE, SEED]), envvar='req_type', default=SEED,
              help='truncate, purge or seed (default: seed). Truncate deletes cache (i.e. S3) files. Purge kills all '
                   'running tasks on geowebcache')
@click.option('-s', '--start-zoom', type=click.INT, envvar='start_zoom', default=0,
              help='Zoom level to start with (default: 0)')
@click.option('-e', '--end-zoom', type=click.INT, envvar='end_zoom', default=5,
              help='Zoom level to end with (default: 5)')
@click.option('-l', '--layers', type=click.STRING, envvar='layers', multiple=True, help='Layers to seed')
@click.option('-i', '--grid-set-id', type=click.STRING, envvar='grid_set_id', default='EPSG:4326',
              help='Grid Set (default:EPSG:4326)')
@click.option('-f', '--req-format', type=click.STRING, envvar='req_format', default='image/png',
              help='Format (default:image/png)')
@click.option('-c', '--thread-count', type=click.INT, envvar='thread_count', default=2,
              help='Thread count (default: 2)')
def main(geonetwork, geoserver, geowebcache, geowebcache_user, geowebcache_password,
         req_type, start_zoom, end_zoom, layers, grid_set_id, req_format, thread_count):
    geowebcache = GeoWebCache(geowebcache, geowebcache_user, geowebcache_password)
    seeder = Seeder(geowebcache)

    geonetwork_connector = GeoNetworkConnector(geonetwork)
    wms_layers = geonetwork_connector.get_wms_layers()

    geoserver_layers = []
    final_layers = []

    # Calculating geoserver layers
    if geoserver:
        for wms_layer in wms_layers:
            if wms_layer['server'] == geoserver:
                geoserver_layers.append(wms_layer['layer'])

    if geoserver and layers:
        for layer in layers:
            if layer in geoserver_layers:
                final_layers.append(layer)
    elif geoserver:
        final_layers = geoserver_layers
    elif layers:
        final_layers = layers
    else:
        final_layers = wms_layers

    if req_type == TRUNCATE:
        for layer in final_layers:
            seeder.truncate_layer(layer)
    elif req_type == PURGE:
        for layer in final_layers:
            seeder.purge_layer(layer)
    elif req_type == SEED:
        for layer in final_layers:
            seeder.seed_layer(layer, grid_set_id, start_zoom, end_zoom, req_format, req_type, thread_count)


def exit_error(msg, err=1):
    logger = logging.getLogger(__name__)
    logger.error(msg)
    click.get_current_context().exit(err)


# AWS Lambda Handler
def handler(event, context):
    main()


if __name__ == '__main__':
    main()
