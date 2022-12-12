import unittest
import re

from harvester.util.expressionparser import ExpressionParser


class TestExpressionParser(unittest.TestCase):

    def setUp(self):
        """ Initialize an ExpressionParser """

        self.expressions = {
            "file_id": {"type": "int64", "value": "context['file_id']"},
            "delivery_mode": {"type": "str", "value": "'RT' if re.match(r'.*Real-time.*', context.url) else 'DM'"},
            "time_coverage_start": {"type": "datetime", "value": "dataset.time_coverage_start"},
            "time_coverage_end": {"type": "datetime", "value": "dataset.time_coverage_end"},
            "date_created": {"type": "datetime", "value": "dataset.date_created"}
        }
        self.functions = {"re": re}
        self.variables = {
            "dataset": {
                "project": "Integrated Marine Observing System",
                "date_created": "2019-08-06T00:25:03Z",
                "time_coverage_start": "2019-08-05T01:59:00Z",
                "time_coverage_end": "2019-08-05T23:59:00Z"
            },
            "context": {
                "file_id": 23,
                "url": "IMOS/ABOS/ASFS/SOFS/Surface_fluxes/Real-time/2018_daily/IMOS_ABOS-ASFS_FMT_20190805T015900Z_SOFS_FV02.nc"
            }
        }

        self.expr = ExpressionParser(self, functions=self.functions, variables=self.variables)

    def test_parse(self):
        """ Test parsing of an expression against an expected output """

        self.assertEqual(self.expr.parse(self.expressions["file_id"]["value"]), 23)
        self.assertEqual(self.expr.parse(self.expressions["delivery_mode"]["value"]), "RT")
        self.assertEqual(self.expr.parse(self.expressions["time_coverage_start"]["value"]), "2019-08-05T01:59:00Z")
        self.assertEqual(self.expr.parse(self.expressions["time_coverage_end"]["value"]), "2019-08-05T23:59:00Z")
        self.assertEqual(self.expr.parse(self.expressions["date_created"]["value"]), "2019-08-06T00:25:03Z")
