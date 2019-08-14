"""
Netcdf record source and supporting code
"""

import itertools
from collections import OrderedDict

import pytz
from dateutil.parser import parse
import re

import numpy as np

import netCDF4

from harvester.util import expressionparser as expr

ALLOWED_EXPR_FNS = {
    "re": re,
    "parse_datetime": parse,
    "average": np.average,
    "mean": np.mean,
    "amin": np.amin,
    "amax": np.amax,
    "asarray": np.asarray
}


def to_datetime(calendar, units):
    return lambda value: pytz.UTC.localize(netCDF4.num2date(value, units, calendar))


def get_conversion(variable, defn):
    if _is_datetime(variable):
        calendar = variable.calendar if hasattr(variable, 'calendar') else 'standard'
        units = variable.units
        return to_datetime(calendar, units)
    else:
        return lambda value: value


class NetcdfGlobalAttributeSource(object):
    """

    """

    def __init__(self, netcdf_file):
        self.netcdf_file = netcdf_file

    def records(self):
        """

        :return:
        """

        with netCDF4.Dataset(self.netcdf_file.src_path) as dataset:
            for ncattr in dataset.ncattrs():
                yield OrderedDict([
                    ("file_id", self.netcdf_file.id),
                    ("name",  ncattr),
                    ("type", type(dataset.getncattr(ncattr)).__name__),
                    ("value", str(dataset.getncattr(ncattr)))
                ])

    def field_names(self):
        return "file_id", "name", "type", "value"


class NetcdfVariableSource(object):
    """

    """

    def __init__(self, netcdf_file):
        self.netcdf_file = netcdf_file

    def records(self):
        """

        :return:
        """

        with netCDF4.Dataset(self.netcdf_file.src_path) as dataset:
            for variable_name in dataset.variables:
                variable = dataset[variable_name]
                yield OrderedDict([
                    ("file_id", self.netcdf_file.id),
                    ("name", variable_name),
                    ("type", str(variable.dtype)),
                    ("dimensions", ','.join(variable.dimensions)),
                    ("shape", ' '.join(str(shape) for shape in variable.shape))
                ])

    def field_names(self):
        return "file_id", "name", "type", "dimensions", "shape"


class NetcdfVariableAttributeSource(object):
    """

    """

    def __init__(self, netcdf_file):
        self.netcdf_file = netcdf_file

    def records(self):
        """

        :return:
        """

        with netCDF4.Dataset(self.netcdf_file.src_path) as dataset:
            for variable_name in dataset.variables:
                for attr_name in dataset[variable_name].ncattrs():
                    attribute = dataset[variable_name].getncattr(attr_name)
                    yield OrderedDict([
                        ("file_id", self.netcdf_file.id),
                        ("var_name", variable_name),
                        ("attr_name", attr_name),
                        ("type", type(attribute).__name__),
                        ("value", str(attribute))
                    ])

    def field_names(self):
        return "file_id", "var_name", "attr_name", "type", "value"


class NetcdfMeasurementSource(object):
    """

    """

    def __init__(self, netcdf_file, mapping):
        self.netcdf_file = netcdf_file
        self.mapping = mapping

    def records(self):
        """

        :return:
        """

        with netCDF4.Dataset(self.netcdf_file.src_path) as dataset:
            variable_names = [field_name for field_name in self.mapping["fields"] if field_name in dataset.variables]
            field_names = ["file_id"] + variable_names
            conversions = [
                get_conversion(dataset[name], defn)
                for name, defn in self.mapping["fields"].items()
                if name in dataset.variables
            ]
            variables = [dataset[name][:] for name, defn in self.mapping["fields"].items() if name in dataset.variables]
            file_id = self.netcdf_file.id
            # performance sensitive!!
            for row in np.nditer(variables):
                # TODO: handle masked data
                converted_row = [convert(value) for convert, value in itertools.zip_longest(conversions, row)]
                yield OrderedDict(zip(field_names, [file_id] + converted_row))

    def field_names(self):
        return ("file_id",) + tuple(self.mapping["fields"].keys())


def _is_datetime(variable):
    # date/time variables must include a 'units' attribute of the form '<time units> since <reference time>'
    return hasattr(variable, 'units') and re.match(r'.* since .*', variable.units)


class NetcdfFileSource(object):
    """

    """

    def __init__(self, netcdf_file, mapping):
        self.netcdf_file = netcdf_file
        self.mapping = mapping

    def records(self):
        """

        :return:
        """

        with netCDF4.Dataset(self.netcdf_file.src_path) as dataset:
            names = {
                "dataset": dataset,
                "file": self.netcdf_file
            }

            yield OrderedDict(
                [("file_id", self.netcdf_file.id)] +
                [(field_name, expr.parse(defn["value"], variables=names, functions=ALLOWED_EXPR_FNS))
                 for field_name, defn in self.mapping["fields"].items()]
            )

    def field_names(self):
        return ("file_id",) + tuple(self.mapping["fields"].keys())


