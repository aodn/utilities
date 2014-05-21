## About

### tile_seeder

A simple utility which mimicks the behaviour os OpenLayers and request exactly
the same URLs OpenLayers does for squidclient. Should be used to seed/purge
layers in a squid cache.

### Dependencies

Something which can run Javascript from the command line. On Ubuntu you can
run:
```
# apt-get install rhino
```

### Simple Usage

Seed imos:argo_profile_layer_map zoom levels 0-3 with tile size 256px and
gutter 20px:
```
$ ./tile_seeder.js GET 0-3 http://localhost:8080/geoserver imos:argo_profile_layer_map 256 20
```

Purge the same layer and same parameters as above:
```
$ ./tile_seeder.js PURGE 0-3 http://localhost:8080/geoserver imos:argo_profile_layer_map 256 20
```

Seed a layer with a BBox defined (faster than seeding the whole globe):
```
$ ./tile_seeder.js GET 0-3 http://localhost:8080/geoserver imos:aatams_sattag_nrt_profile_map 256 20 104.0,-46.0,177.0,-15.0
```

