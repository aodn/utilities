"""
Netcdf record source and supporting code
"""

import collections
import re
import pytz

import netCDF4
from harvester.util import expressionparser as expr
from dateutil.parser import parse


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

            for indexes in self._index_combinations(dataset):
                names = {
                    "dataset": dataset,
                    "file": self.netcdf_file,
                    "indexes": indexes,
                    "values": _Values(dataset, indexes)
                }
                yield tuple(
                    expr.parse(defn.get("value", "values['{}']".format(field_name)), variables=names)
                    for field_name, defn in self.mapping["fields"].items()
                )

    def field_names(self):
        # TODO: from parent class?
        return tuple(self.mapping["fields"].keys())

    def _index_combinations(self, dataset):
        # Iterate through all possible combinations of dimension index values
        # Each possible index combination is returned as an ordered dict

        dimensions = [dataset.dimensions[dimension_name] for dimension_name in self.mapping['dimensions']]
        return self._iterate(collections.OrderedDict(), dimensions)

    def _iterate(self, index_combination, dimensions):
        # recursively iterate through all possible combinations of the passed index combination with the
        # dimensions passed

        if len(dimensions) == 0:
            # no dimensions to iterate through, just return the passed index combination
            yield index_combination
        else:
            # get first dimension to iterate through
            dimension = dimensions[0]

            # iterate through all possible index values for this dimension
            for index in range(dimension.size):
                #  add possible index_combination for this dimension
                index_combination[dimension.name] = index
                # recursively iterate through all possible combinations of this index combination with the remaining
                # dimensions
                for indexes in self._iterate(index_combination, dimensions[1:]):
                    # return the index combinations returned for the remaining dimensions
                    yield indexes


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
        # TODO: from parent class?
        return tuple(self.mapping["fields"].keys())

