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
