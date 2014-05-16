## About

### tile_inspector

A simple stupid utility to look at a squid/apache log and download tiles into a
directory for later inspection. This utility helped me identify bogus
bathymetry layer tiles

### Simple Usage

Running on the bathymetry layer:
```
$ grep LAYERS=default_bathy access.log > access-default_bathy.log
$ ./tile_inspector.sh -g http://geoserver-static-12-nsp-mel.aodn.org.au -l access-default_bathy.log -o tiles
```

All your tiles are now in the `tiles` directory, you can inspect them now.

