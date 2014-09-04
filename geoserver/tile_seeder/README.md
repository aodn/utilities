# About

## tile_seeder.js

A simple utility which mimicks the behaviour of OpenLayers and outputs exactly
the same URLs OpenLayers does. Can be used to seed/purge layers in a squid
cache.


### Dependencies

Something which can run Javascript from the command line. On Ubuntu you can
run:
```
# apt-get install rhino
```

### Simple Usage

Generate URLs for imos:argo_profile_layer_map zoom levels 0 with tile size 256px
and gutter 20px:
```
$ ./tile_seeder.js 3 imos:argo_profile_layer_map 256 20
```

Generate URLs for a layer with a BBox defined (faster than seeding the whole
globe):
```
$ ./tile_seeder.js 3 imos:aatams_sattag_nrt_profile_map 256 20 104.0,-46.0,177.0,-15.0
```

## geoserver_seeder.rb

A script which can seed a cache by requesting tiles from a specified Geoserver
for specific layers and at a specified range of zoom levels. Utilises tile_seeder.js
to generate the URLs.

### Example usage

Seed Geoserver with all layers in catalogue-123.aodn.org.au, zoom level 2 to 5, 4 threads:

`$ ./geoserver_seeder.rb -u http://catalogue-123.aodn.org.au/geonetwork -g http://geoserver-123.aodn.org.au/geoserver/wms -s 2 -e 2 -t 2`

Seed the argo and aatams layers, zoom level 4 to 6, 8 threads:

`$ ./geoserver_seeder.rb -l imos:argo_profile_layer_map imos:aatams_sattag_nrt_profile_map -g http://geoserver-123.aodn.org.au/geoserver/wms -s 4 -e 6 -t 8`

## Improvements (to do)
*These noted improvments would be particularly useful for seeding base layers*
* Allow gutter to be specified as an argument to geoserver_seeder.rb 
* Allow chosing between openlayersQueryConstants in tile_seeder.js
* Refactoring to bring more logic into Ruby script and leave only floating-point maths to JS
