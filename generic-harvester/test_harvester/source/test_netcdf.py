from collections import OrderedDict
import itertools
import json
import os
import unittest
from dateutil import parser

from harvester.source.netcdf import (NetcdfGlobalAttributeSource, NetcdfVariableAttributeSource,
                                     NetcdfMeasurementSource, NetcdfFileSource, NetcdfVariableSource)
from harvester.stubs.aodncore import PipelineFile
from harvester.util.collections import zip_list

TEST_FILE = os.path.join(os.path.dirname(__file__), 'IMOS_ABOS-ASFS_FMT_20190805T015900Z_SOFS_FV02.nc')


class TestNetcdfVariableSource(unittest.TestCase):

    def setUp(self):
        """ Initialise common test data """

        self.nc_file = PipelineFile(id=25, src_path=TEST_FILE, dest_path=TEST_FILE)

    def test_global_attribute_source(self):
        """ Test NetcdfGlobalAttributeSource """

        source = NetcdfGlobalAttributeSource(self.nc_file)

        # check field_names

        expected_field_names = ("file_id", "name", "type", "value")

        self.assertEqual(expected_field_names, source.field_names())

        # check records

        first_eight = list(itertools.islice(source.records(), 8))
        count = sum(1 for _ in source.records())

        expected_values = [
            (25, 'project', 'str', 'Integrated Marine Observing System'),
            (25, 'conventions', 'str', 'IMOS version 1.3'),
            (25, 'title', 'str', 'Heat and radiative flux data from Southern Ocean Flux Station'),
            (25, 'institution', 'str', 'Australian Bureau of Meteorology'),
            (25, 'date_created', 'str', '2019-08-06T00:25:03Z'), (25, 'abstract', 'str', ''),
            (25, 'comment', 'str', 'COARE Bulk Flux Algorithm version 3.0b (Fairall et \n'
                                   'al.,2003: J.Climate,16,571-591). Net heat flux does not include flux due to '
                                   'a rainfall (H_RAIN).'), (25, 'source', 'str', 'Mooring observation')
        ]

        expected_rows = zip_list(expected_field_names, expected_values)

        self.assertEqual(expected_rows, first_eight)
        self.assertEqual(46, count)

    def test_variable_attribute_source(self):
        """ Test NetcdfVariableAttributeSource """

        source = NetcdfVariableAttributeSource(self.nc_file)

        # check field_names
        expected_field_names = ('file_id', 'var_name', 'attr_name', 'type', 'value')
        self.assertEqual(expected_field_names, source.field_names())

        # check records

        first_16 = list(itertools.islice(source.records(), 16))
        count = sum(1 for _ in source.records())

        expected_values = [
            (25, 'TIME', 'standard_name', 'str', 'time'), (25, 'TIME', 'long_name', 'str', 'time'),
            (25, 'TIME', 'units', 'str', 'days since 1950-01-01 00:00:00Z'), (25, 'TIME', 'axis', 'str', 'T'),
            (25, 'TIME', 'valid_min', 'int32', '0'), (25, 'TIME', 'valid_max', 'float64', '90000.0'),
            (25, 'TIME', '_FillValue', 'float64', '-9999.0'),
            (25, 'TIME', 'comment', 'str', 'Relative julian days with decimal part as parts of the day'),
            (25, 'LATITUDE', 'standard_name', 'str', 'latitude'), (25, 'LATITUDE', 'long_name', 'str', 'latitude'),
            (25, 'LATITUDE', 'units', 'str', 'degrees_north'), (25, 'LATITUDE', 'axis', 'str', 'Y'),
            (25, 'LATITUDE', 'valid_min', 'int32', '-90'), (25, 'LATITUDE', 'valid_max', 'int32', '90'),
            (25, 'LATITUDE', '_FillValue', 'float32', '-9999.0'),
            (25, 'LATITUDE', 'reference_datum', 'str', 'geographical coordinates, WGS84')
        ]

        expected_rows = zip_list(expected_field_names, expected_values)

        self.assertEqual(expected_rows, first_16)

        self.assertEqual(179, count)

    def test_variable_source(self):
        """ Test NetcdfVariableSource """

        source = NetcdfVariableSource(self.nc_file)

        # check field_names
        expected_field_names = ('file_id', 'name', 'type', 'dimensions', 'shape')
        self.assertEqual(expected_field_names, source.field_names())

        # check records

        first_16 = itertools.islice(source.records(), 16)

        expected_rows = zip_list(
            expected_field_names,
            [
                (25, 'TIME', 'float64', 'TIME', '22'),
                (25, 'LATITUDE', 'float32', 'TIME', '22'),
                (25, 'LONGITUDE', 'float32', 'TIME', '22'),
                (25, 'PL_CMP', 'float32', 'TIME', '22'),
                (25, 'WDIR', 'float32', 'TIME', '22'),
                (25, 'WSPD', 'float32', 'TIME', '22'),
                (25, 'WIND_H', 'float32', 'TIME', '22'),
                (25, 'WIND_FLAG', 'int16', 'TIME', '22'),
                (25, 'ATMP', 'float32', 'TIME', '22'),
                (25, 'ATMP_H', 'float32', 'TIME', '22'),
                (25, 'ATMP_FLAG', 'int16', 'TIME', '22'),
                (25, 'AIRT', 'float32', 'TIME', '22'),
                (25, 'AIRT_H', 'float32', 'TIME', '22'),
                (25, 'AIRT_FLAG', 'int16', 'TIME', '22'),
                (25, 'RELH', 'float32', 'TIME', '22'),
                (25, 'RELH_H', 'float32', 'TIME', '22')
            ]
        )
        self.assertEqual(expected_rows, list(first_16))

        count = sum(1 for _ in source.records())
        self.assertEqual(44, count)

    def test_measurement_source(self):
        """ Test NetcdfMeasurementSource"""

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

        source = NetcdfMeasurementSource(self.nc_file, mapping)

        # check field_names

        expected_field_names = ("file_id", "index", "TIME", "LATITUDE", "LONGITUDE", "PL_CMP", "WDIR", "WSPD")
        self.assertEqual(expected_field_names, source.field_names())

        # check records (first two and count)

        first_two_recs = list(itertools.islice(source.records(), 2))
        count = sum(1 for _ in source.records())

        expected_values = [
            (25, 0, parser.parse("2019-08-05T01:59:00.000017Z"), -46.905799865722656, 142.38800048828125,
             348.3999938964844, 143.3000030517578, 10.199999809265137),
            (25, 1, parser.parse("2019-08-05T02:59:00.000004Z"), -46.905799865722656, 142.38800048828125,
             27.399999618530273, 143.1999969482422, 11.0)
        ]

        expected_rows = zip_list(expected_field_names, expected_values)

        self.assertEqual(expected_rows, first_two_recs)
        self.assertEqual(22, count)

    def test_file_source(self):
        """ Test NetcdfFileSource"""

        json_mapping = """{
                "name": "timeseries_file",
                "fields": {
                    "file_id": {"value": "file.id"},
                    "deployment_number": {"value": "dataset.deployment_number"},
                    "delivery_mode": {"value": "'RT' if re.match(r'.*Real-time.*', file.dest_path) else 'DM'"},
                    "latitude": {"value": "mean(dataset['LATITUDE']).item()"},
                    "longitude": {"value": "mean(dataset['LONGITUDE']).item()"},
                    "time_coverage_start": {"value": "parse_datetime(dataset.time_coverage_start)"},
                    "time_coverage_end": {"value": "parse_datetime(dataset.time_coverage_start)"},
                    "date_created": {"value": "parse_datetime(dataset.date_created)"}
                }
            }"""

        mapping = json.loads(json_mapping, object_pairs_hook=OrderedDict)

        source = NetcdfFileSource(self.nc_file, mapping)

        # check field_names

        expected_field_names = (
            "file_id", "deployment_number", "delivery_mode", "latitude", "longitude", "time_coverage_start",
            "time_coverage_end", "date_created"
        )

        self.assertEqual(expected_field_names, source.field_names())

        # check records (1)

        expected_values = [(25, "", "DM", -46.90268325805664, 142.38839721679688, parser.parse("2019-08-05T01:59Z"),
               parser.parse("2019-08-05T01:59Z"), parser.parse("2019-08-06T00:25:03Z"))]

        expected_rows = zip_list(expected_field_names, expected_values)

        self.assertEqual(expected_rows, list(source.records()))
