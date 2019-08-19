"""
Netcdf record sources and supporting code using xarray to read netcdf data
and returning dataframes instead of sequences

Supports reading global attributes, variable metadata and measurements
as record streams
"""

import pytz
from dateutil.parser import parse
import re

import pandas as pd
import numpy as np
import xarray as xr

ALLOWED_EXPR_FNS = {
    "re": re,
    "parse_datetime": parse,
    "average": np.average,
    "mean": np.mean,
    "amin": np.amin,
    "amax": np.amax,
    "asarray": np.asarray
}


class NetcdfGlobalAttributeSource(object):
    """
        TODO:
    """


class NetcdfVariableSource(object):
    """
        TODO:
    """


class NetcdfVariableAttributeSource(object):
    """
        TODO:
    """


class NetcdfMeasurementSource(object):
    """

    """

    def __init__(self, netcdf_file, mapping):
        self.netcdf_file = netcdf_file
        self.mapping = mapping

        ds = xr.open_dataset(self.netcdf_file.src_path)
        variables = {name: ds[name].to_series() for name in self.mapping["fields"] if name in ds.keys()}
        df = pd.DataFrame(variables).tz_localize(pytz.UTC)
        # add file_id as another index
        self.df = pd.concat([df], keys=[self.netcdf_file.id], names=["file_id"])
        # full list of field names
        self._field_names = self.df.index.names + list(self.df.columns.values)

    def as_dataframe(self):
        return self.df

    def records(self):
        """

        :return:
        """

        for row in self.df.iterrows():
            yield row[0] + tuple(row[1])

    def field_names(self):
        return self._field_names


class NetcdfFileSource(object):
    """
        TODO:
    """


