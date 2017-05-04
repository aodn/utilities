# About

### Dependencies

Python.

## Description

  Seed Geoserver tiles using Geowebcache based on results returned from Geonetwork


## Command line execution

```
Options:
  -n, --geonetwork TEXT           Geonetwork URL  [required]
  -g, --geoserver TEXT            Geoserver URL
  -w, --geowebcache TEXT          Geowebcache URL  [required]
  -u, --geowebcache-user TEXT     Geowebcache username  [required]
  -p, --geowebcache-password TEXT
                                  Geowebcache password  [required]
  -t, --req-type [truncate|purge|seed]
                                  truncate, purge or seed (default: seed).
                                  Truncate deletes cache (i.e. S3) files.
                                  Purge kills all running tasks on geowebcache
  -s, --start-zoom INTEGER        Zoom level to start with (default: 0)
  -e, --end-zoom INTEGER          Zoom level to end with (default: 5)
  -l, --layers TEXT               Layers to seed
  -i, --grid-set-id TEXT          Grid Set (default:EPSG:4326)
  -f, --req-format TEXT           Format (default:image/png)
  -c, --thread-count INTEGER      Thread count (default: 2)
  -h, --help                      Show this message and exit.
  ```

### Example usage

####        Seed Geowebcache with all layers:
            python geowebcache_seeder.py -n https://catalogue-imos.aodn.org.au/geonetwork -w http://geowebcache-dev-geowebcache.ap-southeast-2.elasticbeanstalk.com/geowebcache -u geowebcache -p  password -t seed

####        Seed Geowebcache with geoserver all layers:
            python geowebcache_seeder.py -n https://catalogue-imos.aodn.org.au/geonetwork -w http://geowebcache-dev-geowebcache.ap-southeast-2.elasticbeanstalk.com/geowebcache -u geowebcache -p  password -t seed -g http://geoserver-123.aodn.org.au/geoserver/wms

####        Seed Geowebcache with geoserver layers:
            python geowebcache_seeder.py -n https://catalogue-imos.aodn.org.au/geonetwork -w http://geowebcache-dev-geowebcache.ap-southeast-2.elasticbeanstalk.com/geowebcache -u geowebcache -p  password -t seed -g http://geoserver-123.aodn.org.au/geoserver/wms -l imos:argo_profile_map -l imos:aatams_sattag_nrt_profile_map

####        Purge Geowebcache with all layers:
            python geowebcache_seeder.py -n https://catalogue-imos.aodn.org.au/geonetwork -w http://geowebcache-dev-geowebcache.ap-southeast-2.elasticbeanstalk.com/geowebcache -u geowebcache -p  password -t purge

####        Purge Geowebcache with geoserver all layers:
            python geowebcache_seeder.py -n https://catalogue-imos.aodn.org.au/geonetwork -w http://geowebcache-dev-geowebcache.ap-southeast-2.elasticbeanstalk.com/geowebcache -u geowebcache -p  password -t purge -g http://geoserver-123.aodn.org.au/geoserver/wms

####        Purge Geowebcache with geoserver layers:
            python geowebcache_seeder.py -n https://catalogue-imos.aodn.org.au/geonetwork -w http://geowebcache-dev-geowebcache.ap-southeast-2.elasticbeanstalk.com/geowebcache -u geowebcache -p  password -t purge -g http://geoserver-123.aodn.org.au/geoserver/wms -l imos:argo_profile_map -l imos:aatams_sattag_nrt_profile_map

####        Truncate Geowebcache with all layers:
            python geowebcache_seeder.py -n https://catalogue-imos.aodn.org.au/geonetwork -w http://geowebcache-dev-geowebcache.ap-southeast-2.elasticbeanstalk.com/geowebcache -u geowebcache -p  password -t truncate

####        Truncate Geowebcache with geoserver all layers:
            python geowebcache_seeder.py -n https://catalogue-imos.aodn.org.au/geonetwork -w http://geowebcache-dev-geowebcache.ap-southeast-2.elasticbeanstalk.com/geowebcache -u geowebcache -p  password -t truncate -g http://geoserver-123.aodn.org.au/geoserver/wms

####        Truncate Geowebcache with geoserver layers:
            python geowebcache_seeder.py -n https://catalogue-imos.aodn.org.au/geonetwork -w http://geowebcache-dev-geowebcache.ap-southeast-2.elasticbeanstalk.com/geowebcache -u geowebcache -p  password -t truncate -g http://geoserver-123.aodn.org.au/geoserver/wms -l imos:argo_profile_map -l imos:aatams_sattag_nrt_profile_map


## Lambda execution

### Build Instructions

  ```
  cd geowebcache_seeder
  ./build_and_upload_to_S3.sh
  ```

### Reload Lambda code from S3

  ```
  cd geowebcache_seeder
  ./update_lambda_s3_code.sh
  ```

### Create Stack Example

  ```
  cd geowebcache_seeder
  aws cloudformation create-stack --stack-name geowebcache-seeder --template-body file://geowebcache_seeder.yaml --parameters  ParameterKey=geonetwork,ParameterValue=https://catalogue-imos.aodn.org.au/geonetwork ParameterKey=geowebcacheUser,ParameterValue=geowebcache ParameterKey=geowebcachePassword,ParameterValue=password ParameterKey=geowebcache,ParameterValue=http://geowebcache-dev-geowebcache.ap-southeast-2.elasticbeanstalk.com/geowebcache ParameterKey=geoserver,ParameterValue=http://geoserver-123.aodn.org.au/geoserver/wms --capabilities CAPABILITY_IAM
  ```    

### Update Stack Example

  ```
  cd geowebcache_seeder
  aws cloudformation update-stack --stack-name geowebcache-seeder --template-body file://geowebcache_seeder.yaml --parameters  ParameterKey=geonetwork,ParameterValue=https://catalogue-imos.aodn.org.au/geonetwork ParameterKey=geowebcacheUser,ParameterValue=geowebcache ParameterKey=geowebcachePassword,ParameterValue=password ParameterKey=geowebcache,ParameterValue=http://geowebcache-dev-geowebcache.ap-southeast-2.elasticbeanstalk.com/geowebcache ParameterKey=geoserver,ParameterValue=http://geoserver-123.aodn.org.au/geoserver/wms --capabilities CAPABILITY_IAM
  ```    

### Delete Stack Example

  ```
  cd geowebcache_seeder
  aws cloudformation delete-stack --stack-name geowebcache-seeder
  ```    