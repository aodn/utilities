"""
Netcdf record source and supporting code
"""

from dateutil.parser import parse
import itertools
import pytz
import re

import netCDF4

from harvester.util import expressionparser as expr


class NetcdfVariableSource(object):
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
            dataset.set_auto_mask(False)  # TODO: need to use masked arrays!

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
                index_dict = self._indexes(index_tuple)
                names = {
                    "dataset": dataset,
                    "file": self.netcdf_file,
                    "indexes": index_dict,
                    "values": _Values(dataset, index_dict)
                }
                yield tuple(
                    expr.parse(defn.get("value", "values['{}']".format(field_name)), variables=names)
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
        # get requested variable
        variable = self.dataset[variable_name]
        # get the index of the value to return for this variable (the indexes of dimensions used by this variable)
        variable_index = [self.indexes[name] for name in self.indexes.keys() if name in variable.dimensions]
        # return the value of the variable for this index
        value_array = variable[tuple(variable_index)]
        # return as scalar if one value only
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
            dataset.set_auto_mask(False)  # TODO: need to use masked arrays!

            names = {
                "dataset": dataset,
                "file": self.netcdf_file
            }

            yield tuple(
                # TODO: look at using a type key on mapping
                expr.parse(defn["value"], variables=names, functions={"re": re, "parse_datetime": parse})
                for field_name, defn in self.mapping["fields"].items()
            )

    def field_names(self):
        return tuple(self.mapping["fields"].keys())

