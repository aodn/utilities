from collections import OrderedDict
import itertools
import json
import os
import unittest
from dateutil import parser

import numpy as np

from harvester.source.netcdf import (NetcdfVariableSource, NetcdfFileSource)
from harvester.stubs.aodncore import PipelineFile

TEST_FILE = os.path.join(os.path.dirname(__file__), 'IMOS_ABOS-ASFS_FMT_20190805T015900Z_SOFS_FV02.nc')


class TestNetcdfVariableSource(unittest.TestCase):

    def setUp(self):
        """ Initialise common test data """

        self.nc_file = PipelineFile(id=25, src_path=TEST_FILE, dest_path=TEST_FILE)

    def test_variable_source(self):
        """ Test NetcdfVariableSource"""

        json_mapping = """{
            "name": "measurement",
            "dimensions": ["TIME"],
            "fields": {
                "file_id": {"value": "file.id"},
                "index": {"value": "indexes['TIME']"},
                "TIME": {},
                "LATITUDE": {},
                "LONGITUDE": {},
                "PL_CMP": {},
                "WDIR": {},
                "WSPD": {}
            }
        }"""

        mapping = json.loads(json_mapping, object_pairs_hook=OrderedDict)

        source = NetcdfVariableSource(self.nc_file, mapping)

        # check field_names

        self.assertEqual(
            ("file_id", "index", "TIME", "LATITUDE", "LONGITUDE", "PL_CMP", "WDIR", "WSPD"),
            source.field_names()
        )

        # check records (first two and count)

        first_two_recs = list(itertools.islice(source.records(), 2))
        count = sum(1 for _ in source.records())

        self.assertEqual(
            [(25, 0, parser.parse("2019-08-05T01:59:00.000017Z"), -46.905799865722656, 142.38800048828125,
              348.3999938964844, 143.3000030517578, 10.199999809265137),
             (25, 1, parser.parse("2019-08-05T02:59:00.000004Z"), -46.905799865722656, 142.38800048828125,
              27.399999618530273, 143.1999969482422, 11.0)],
            first_two_recs
        )

        self.assertEqual(22, count)

    def test_file_source(self):
        """ Test NetcdfFileSource"""

        json_mapping = """{
                "name": "timeseries_file",
                "fields": {
                    "file_id": {"value": "file.id"},
                    "deployment_number": {"value": "dataset.deployment_number"},
                    "delivery_mode": {"value": "'RT' if re.match(r'.*Real-time.*', file.dest_path) else 'DM'"},
                    "latitude": {"value": "dataset['LATITUDE'][(0)]"},
                    "longitude": {"value": "dataset['LONGITUDE'][(0)]"},
                    "time_coverage_start": {"value": "parse_datetime(dataset.time_coverage_start)"},
                    "time_coverage_end": {"value": "parse_datetime(dataset.time_coverage_start)"},
                    "date_created": {"value": "parse_datetime(dataset.date_created)"}
                }
            }"""

        mapping = json.loads(json_mapping, object_pairs_hook=OrderedDict)

        source = NetcdfFileSource(self.nc_file, mapping)

        # check field_names

        self.assertEqual(
            ("file_id", "deployment_number", "delivery_mode", "latitude", "longitude", "time_coverage_start",
             "time_coverage_end", "date_created"),
            source.field_names()
        )

        # check records (1)

        self.assertEqual(
            [(25, '', 'DM', np.float32(-46.9058), np.float32(142.388), parser.parse("2019-08-05T01:59Z"),
              parser.parse("2019-08-05T01:59Z"), parser.parse("2019-08-06T00:25:03Z"))],
            list(source.records())
        )
