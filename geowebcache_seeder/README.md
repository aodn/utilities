# About

### Dependencies

Ruby.

## geoserver_seeder.rb

  Seed Geoserver tiles using Geowebcache based on results returned from Geonetwork

```
    Options:
  -u, --geonetwork=<s>    Geonetwork URL to use
  -g, --geoserver=<s>     Geoserver URL
  -T, --type=<s>          truncate, reseed or seed (default: seed)
  -s, --start-zoom=<i>    Zoom level to start with (default: 2)
  -e, --end-zoom=<i>      Zoom level to end with (8 if not specified) (default: 8)
  -l, --layers=<s+>       Layers to seed
  -d, --dry-run           Dry run, only print commands
  -h, --help              Show this message
  ```

### Example usage


#### Seed Geowebcache with all layers in catalogue-imos.aodn.org.au, zoom level 2 to default (dry run):
           geoserver_seeder.rb -d -u https://catalogue-imos.aodn.org.au/geonetwork -s 2 

####        Seed  all layers in catalogue-imos.aodn.org.au from http://maps.aims.gov.au/geoserver/wms (dry run):
            geoserver_seeder.rb -d -u https://catalogue-imos.aodn.org.au/geonetwork -g http://maps.aims.gov.au/geoserver/wms

####        Seed the argo and aatams layers, zoom level 4 to 6  (dry run):
           geoserver_seeder.rb -T reseed  -d -u https://catalogue-portal.aodn.org.au/geonetwork -l imos:argo_profile_layer_map imos:aatams_sattag_nrt_profile_map -g http://geoserver-123.aodn.org.au/geoserver/wms  -s 4 -e 6 

####       Truncate the argo layer without reference to the geoserver or catalogue (dry run):
           geoserver_seeder.rb -T truncate  -d  -l imos:argo_profile_layer_map 



