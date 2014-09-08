# About

### Dependencies

Ruby.

## geoserver_seeder.rb

A script which can seed a cache by requesting tiles from a specified Geoserver
for specific layers and at a specified range of zoom levels. Utilises the same
logic of OpenLayers (but in Ruby) to generate the URLs to hit.

### Example usage

Seed Geoserver with all layers in catalogue-123.aodn.org.au, zoom level 2 to 5, 4 threads:

`$ ./geoserver_seeder.rb -u https://catalogue-123.aodn.org.au/geonetwork -g http://geoserver-123.aodn.org.au/geoserver/wms -s 2 -e 2 -t 2 -T 256 -G 20 -U "LAYERS=imos%3Aargo_profile_layer_map&TRANSPARENT=TRUE&VERSION=1.1.1&FORMAT=image%2Fpng&QUERYABLE=true&EXCEPTIONS=application%2Fvnd.ogc.se_xml&SERVICE=WMS&REQUEST=GetMap&STYLES=&SRS=EPSG%3A4326&BBOX=88.2421875,-46.7578125,114.2578125,-20.7421875&WIDTH=296&HEIGHT=296"`

Seed the argo and aatams layers, zoom level 4 to 6, 8 threads:
`$ ./geoserver_seeder.rb -l imos:argo_profile_layer_map imos:aatams_sattag_nrt_profile_map -g http://geoserver-123.aodn.org.au/geoserver/wms -s 4 -e 6 -t 8 -T 256 -G 20 -U "LAYERS=imos%3Aargo_profile_layer_map&TRANSPARENT=TRUE&VERSION=1.1.1&FORMAT=image%2Fpng&QUERYABLE=true&EXCEPTIONS=application%2Fvnd.ogc.se_xml&SERVICE=WMS&REQUEST=GetMap&STYLES=&SRS=EPSG%3A4326&BBOX=88.2421875,-46.7578125,114.2578125,-20.7421875&WIDTH=296&HEIGHT=296"`

Seed just argo, zoom levels 2 to 4, 1 thread:
`./geoserver_seeder.rb -l imos:argo_profile_layer_map imos:aatams_sattag_nrt_profile_map -g http://localhost:8080/geoserver/wms -s 2 -e 4 -t 1 -T 256 -G 20 -U "LAYERS=imos%3Aargo_profile_layer_map&TRANSPARENT=TRUE&VERSION=1.1.1&FORMAT=image%2Fpng&QUERYABLE=true&EXCEPTIONS=application%2Fvnd.ogc.se_xml&SERVICE=WMS&REQUEST=GetMap&STYLES=&SRS=EPSG%3A4326&BBOX=88.2421875,-46.7578125,114.2578125,-20.7421875&WIDTH=296&HEIGHT=296"`

Seeding a static layer:
`$ ./geoserver_seeder.rb -l default_bathy -g http://geoserver-static.aodn.org.au/geoserver/wms -s 4 -e 6 -t 8 -T 256 -G 0 -U "LAYERS=imos%3Adefault_bathy&TRANSPARENT=TRUE&VERSION=1.1.1&FORMAT=image%2Fpng&QUERYABLE=false&EXCEPTIONS=application%2Fvnd.ogc.se_xml&SERVICE=WMS&REQUEST=GetMap&STYLES=&SRS=EPSG%3A4326&BBOX=90,-90,180,0&WIDTH=256&HEIGHT=256"
