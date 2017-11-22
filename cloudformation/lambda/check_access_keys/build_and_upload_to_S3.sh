#!/usr/bin/env bash
set -ex
cd python_source
rm -rf check_access_keys.zip *.pyc lib
pip install -r requirements.txt -t ./lib
zip -x setup.cfg -r check_access_keys.zip .
aws s3 cp check_access_keys.zip s3://imos-binary/lambda/
