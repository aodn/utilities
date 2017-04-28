#!/usr/bin/env bash
set -ex
aws lambda update-function-code --function-name geowebcache_seed --s3-bucket imos-binary --s3-key lambda/geowebcache_seeder.zip
aws lambda update-function-code --function-name geowebcache_purge --s3-bucket imos-binary --s3-key lambda/geowebcache_seeder.zip
aws lambda update-function-code --function-name geowebcache_truncate --s3-bucket imos-binary --s3-key lambda/geowebcache_seeder.zip
