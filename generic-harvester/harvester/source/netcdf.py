"""
This module contains classes for reading global attributes, variable metadata and variable values from a netcdf file.

In contrast to the way that the netCDF4 and xarray modules provide access to this information (dictionaries/properties/
numpy arrays etc) this module provides a single model for retrieving this type of information from the netcdf file
which is suitable for ingest into a database or other data store by other components in the harvester package.

In particular, instances of these classes will contain a records method which will return an iterator that can be used
to iterate over the records returned by that instance and a field_names property that contains the names of the
fields returned in each record.

A record is defined here as a dictionary of field_name, value pairs returned by instances of classes in this
module.

Example use:

    from harvester.source.netcdf import NetcdfGlobalAttributeSource
    from harvester.stubs.aodncore import PipelineFile

    ncFile = PipelineFile(file_id=24, src_path="IMOS_ABOS-ASFS_FMT_20190805T015900Z_SOFS_FV02.nc")

    source = NetcdfGlobalAttributeSource(ncFile)

    print(source.field_names)

    for record in source.records():
        print(record)

Returns:

    ('file_id', 'name', 'type', 'value')
    {'type': 'str', 'name': 'project', 'value': 'Integrated Marine Observing System', 'file_id': 24}
    {'type': 'str', 'name': 'conventions', 'value': 'IMOS version 1.3', 'file_id': 24}
    {'type': 'str', 'name': 'title', 'value': 'Heat and radiative flux data from Southern Ocean Flux Station',
        'file_id': 24}
    {'type': 'str', 'name': 'institution', 'value': 'Australian Bureau of Meteorology', 'file_id': 24}
    ...

"""
import pendulum
from dateutil.parser import parse
import re

import netCDF4
import numpy as np

from harvester.spatial.geometry import point
from harvester.util import expressionparser as expr

# functions that can be when used in config expressions


def parse_datetime(value):
    parsed_datetime = parse(value)
    if parsed_datetime.tzinfo:
        return parsed_datetime
    else:
        return pendulum.timezone('UTC').convert(parsed_datetime)


ALLOWED_EXPR_FNS = {
    "re": re,
    "parse_datetime": parse_datetime,
    "average": np.average,
    "mean": np.mean,
    "amin": np.amin,
    "amax": np.amax,
    "getattr": getattr,
    "point": point
}


class NetcdfGlobalAttributeSource(object):
    """
    Class for iterating over each global attribute in a netcdf file

    Each invocation of the iterator returns the id of the file and the name, type and value of a global attribute in
    the file as a dictionary
    """

    def __init__(self, netcdf_file):
        """

        :param netcdf_file:
        """
        self.netcdf_file = netcdf_file
        self.field_names = "file_id", "name", "type", "value"

    def records(self):
        """
        :return: iterator returning each record as a dictionary of field/value pairs
        """

        with netCDF4.Dataset(self.netcdf_file.src_path) as dataset:
            for ncattr in dataset.ncattrs():
                record_values = self.netcdf_file.id, ncattr, type(dataset.getncattr(ncattr)).__name__,\
                      str(dataset.getncattr(ncattr))
                yield dict(zip(self.field_names, record_values))


class NetcdfVariableSource(object):
    """
    Class for iterating over each variable in a netcdf file

    Each invocation of the iterator returns the id of the file and the name, type, dimensions and shape of a global
    attribute in the file as a dictionary
    """

    def __init__(self, netcdf_file):
        self.netcdf_file = netcdf_file
        self.field_names = "file_id", "name", "type", "dimensions", "shape"

    def records(self):
        """
        :return: iterator returning each record as a dictionary of field/value pairs
        """

        with netCDF4.Dataset(self.netcdf_file.src_path) as dataset:
            for variable_name in dataset.variables:
                variable = dataset[variable_name]
                record_values = self.netcdf_file.id, variable_name, str(variable.dtype), ','.join(variable.dimensions),\
                    ' '.join(str(shape) for shape in variable.shape)
                yield dict(zip(self.field_names, record_values))


class NetcdfVariableAttributeSource(object):
    """
    Class for iterating each variable attribute in a netcdf file

    Each invocation of the iterator returns the id of the file, the name of a variable and the name, type and value
    of an attribute for the variable in the file as a dictionary
    """

    def __init__(self, netcdf_file):
        self.netcdf_file = netcdf_file
        self.field_names = "file_id", "var_name", "attr_name", "type", "value"

    def records(self):
        """
        :return: iterator returning each record as a dictionary of field/value pairs
        """

        with netCDF4.Dataset(self.netcdf_file.src_path) as dataset:
            for variable_name in dataset.variables:
                for attr_name in dataset[variable_name].ncattrs():
                    attribute = dataset[variable_name].getncattr(attr_name)
                    record_values = self.netcdf_file.id, variable_name, attr_name, type(attribute).__name__, str(attribute)
                    yield dict(zip(self.field_names, record_values))


# Return a function that maps the variable values passed to the required output value
# as specified in the associated mapping definition
#
# Performance sensitive!!  Applied to each row of measurements

def _get_mapper(name, defn, variables):
    if name not in variables:
        return lambda values: None

    variable = variables[name]
    fill_value = variable[:].fill_value

    return lambda values: values[name].item() if values[name].item() != fill_value else None


# function used to determine whether a variable contains date/time values

def _is_datetime(variable):
    # date/time variables must include a 'units' attribute of the form '<time units> since <reference time>'
    return hasattr(variable, 'units') and re.match(r'.* since .*', variable.units)


# returns numpy arrays containing variable values - date/time variables are converted to UTC date/time arrays

def _get_values(variable):
    if _is_datetime(variable):
        calendar = variable.calendar if hasattr(variable, 'calendar') else 'standard'
        units = variable.units
        dates = netCDF4.num2date(variable[:], units, calendar)
        make_utc = np.vectorize(pendulum.timezone('UTC').convert)
        return make_utc(dates)
    else:
        return variable[:]


class NetcdfValueSource(object):
    """
    Class for iterating over variable values in a netcdf file

    Each invocation of the iterator returns the id of the file, and the next set of values for variables in the file
    requested in the supplied mapping as a dictionary
    """

    def __init__(self, netcdf_file, mapping):
        self.netcdf_file = netcdf_file
        self.mapping = mapping
        self.field_names = ("file_id",) + tuple(self.mapping["fields"].keys())

    def records(self):
        """
        :return: iterator returning each record as a dictionary of field/value pairs
        """

        with netCDF4.Dataset(self.netcdf_file.src_path) as dataset:
            dataset.set_auto_scale(True)
            variables = dict((name, variable) for name, variable in dataset.variables.items()
                             if variable.dimensions == tuple(self.mapping["dimensions"]))
            field_mappers = [_get_mapper(name, defn, variables) for name, defn in self.mapping["fields"].items()]
            file_id = self.netcdf_file.id
            # iterate through each variables values - can be millions so performance sensitive!
            iterators = {name: np.nditer(_get_values(variable), flags=["refs_ok"]) for name, variable in variables.items()}
            first_iterator = list(iterators.values())[0]
            for index in range(*first_iterator.iterrange):
                variable_values = {name: next(iterator) for name, iterator in iterators.items()}
                record_values = [file_id] + [map(variable_values) for map in field_mappers]
                yield dict(zip(self.field_names, record_values))


class NetcdfFileSource(object):
    """
    Class for extracting metadata from a netcdf file as a single record

    An invocation of the iterator returns the id of the file, and the requested values from the netcdf file
    as requested in the supplied mapping as a dictionary

    Supports using simple python expressions to perform basic mapping/transformation
    """

    def __init__(self, netcdf_file, mappings):
        self.netcdf_file = netcdf_file
        self.mappings = mappings
        self.field_names = ("file_id",) + tuple(self.mappings["fields"].keys())

    def records(self):
        """
        :return: iterator returning each record as a dictionary of field/value pairs
        """

        with netCDF4.Dataset(self.netcdf_file.src_path) as dataset:
            names = {
                "dataset": dataset,
                "file": self.netcdf_file
            }

            core_fields = (self.netcdf_file.id, )

            derived_fields = tuple([
                expr.parse(self._mapping_expr(field_name, field_mapping), variables=names, functions=ALLOWED_EXPR_FNS)
                for field_name, field_mapping in self.mappings["fields"].items()
            ])

            record_values = core_fields + derived_fields

            yield dict(zip(self.field_names, record_values))

    @staticmethod
    def _mapping_expr(field_name, field_mapping):
        if not field_mapping:
            # default is to return attribute with field_name
            return "getattr(dataset, '{}', None)".format(field_name)
        elif "type" in field_mapping and field_mapping["type"] == "datetime":
            # parse as a datetime
            return "parse_datetime(dataset.{})".format(field_name)
        else:
            return field_mapping["value"]

        # TODO: raise an exception if no value
