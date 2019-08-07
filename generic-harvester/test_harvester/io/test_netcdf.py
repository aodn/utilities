import unittest
import datetime
import pytz

from harvester.io import netcdf


class TestNetcdf(unittest.TestCase):

    def test_fromnetcdf(self):
        filename = 'IMOS_ANMN-NSW_TZ_20141118T130000Z_BMP070_FV01_BMP070-1411-Aqualogger-520PT-16_END-20150504T063500Z_C-20160901T044727Z.nc'
        
        variables = (
            'TIME',
            'TEMP',
            'TEMP_quality_control',
            'PRES',
            'PRES_quality_control',
            'DEPTH',
            'DEPTH_quality_control'
        )

        source = netcdf.fromnetcdf(filename, variables)
        
        self.assertSequenceEqual(
            source.rowslice(2),
            (
                variables,
                (datetime.datetime(2014, 11, 18, 13, 0, 0, 7, datetime.timezone.utc), 22.20854377746582, 4, 10.269700050354004, 4, 0.13619545102119446, 4),
                (datetime.datetime(2014, 11, 18, 13, 4, 59, 999999, datetime.timezone.utc), 22.20565414428711, 4, 10.26375961303711, 4, 0.13029851019382477, 4)
            )
        )
