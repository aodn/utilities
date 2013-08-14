#!/bin/bash

psql -h localhost -c "update metadata set data = replace(data, 'search string', 'replace string');" imosmest
