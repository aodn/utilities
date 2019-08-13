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
    "amax": np.amax
}


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
            requested_dimensions = [
                dimension
                for dimension in dataset.dimensions.values()
                if dimension.name in self.mapping["dimensions"]
            ]

            requested_dimension_index_values = [
                range(dimension.size)
                for dimension in requested_dimensions
            ]

            for index_tuple in itertools.product(*requested_dimension_index_values):
                # TODO: revisit _Values
                index_dict = self._indexes(index_tuple)
                names = {
                    "dataset": dataset,
                    "file": self.netcdf_file,
                    "indexes": index_dict,
                    "values": _Values(dataset, index_dict)
                }
                yield OrderedDict(
                    (field_name, expr.parse(defn.get("value", "values['{}']".format(field_name)), variables=names))
                    for field_name, defn in self.mapping["fields"].items()
                )

    def field_names(self):
        return tuple(self.mapping["fields"].keys())

    def _indexes(self, index_tuple):
        return dict(zip(self.mapping["dimensions"], index_tuple))


class _Values(object):
    """

    """

    def __init__(self, dataset, indexes):
        self.dataset = dataset
        self.indexes = indexes

    def __getitem__(self, key):
        return self._get_value(key)

    def _get_value(self, variable_name):
        # TODO: handle masked arrays
        # get requested variable
        variable = self.dataset[variable_name]
        # get the index of the value to return for this variable (the indexes of dimensions used by this variable)
        variable_index = [self.indexes[name] for name in self.indexes.keys() if name in variable.dimensions]
        # return the value of the variable for this index
        value_array = variable[tuple(variable_index)]
        # return as scalar if one value only
        # TODO: consider automatically 'unboxing scalars' in expression parsing instead of here
        value = value_array.item() if value_array.size == 1 else value_array

        if _is_datetime(variable):
            # convert to UTC datetime
            calendar = variable.calendar if hasattr(variable, 'calendar') else 'standard'
            naive_datetime = netCDF4.num2date(value, variable.units, calendar)
            return pytz.timezone("UTC").localize(naive_datetime)
        else:
            return value


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
                (field_name, expr.parse(defn["value"], variables=names, functions=ALLOWED_EXPR_FNS))
                for field_name, defn in self.mapping["fields"].items()
            )

    def field_names(self):
        return tuple(self.mapping["fields"].keys())


def subset(dictionary, keys):
    return OrderedDict((key,value) for key,value in dictionary.items() if key in keys)
