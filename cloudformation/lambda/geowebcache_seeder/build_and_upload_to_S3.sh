#!/usr/bin/env bash
set -ex
rm -rf geowebcache_seeder.zip *.pyc lib
pip install -r requirements.txt -t ./lib
zip -r geowebcache_seeder.zip .
aws s3 cp geowebcache_seeder.zip s3://imos-binary/lambda/
