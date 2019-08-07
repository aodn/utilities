import collections
import re

import pytz
from petl import Table
import netCDF4

def fromnetcdf(source, variables=None):
    """
    Extract a table from a `netcdf <https://unidata.github.io/netcdf4-python/netCDF4/>`_ Dataset.
    E.g.::

        >>> import petl as etl
        >>> ...
        >>> table = fromnetcdf('example.nc', variables={'TIME': {}, 'TEMP': {}, 'PSAL': {}})
        >>> table
        +----------------------------------------------------------------+--------------------+--------------------+
        | TIME                                                           | TEMP               | PSAL               |
        +================================================================+====================+====================+
        | datetime.datetime(2014, 4, 2, 8, 45, 50, 4, tzinfo=<UTC>)      | 19.402074813842773 |     33.42919921875 |
        +----------------------------------------------------------------+--------------------+--------------------+
        | datetime.datetime(2014, 4, 2, 8, 46, tzinfo=<UTC>)             | 19.396944046020508 | 33.458980560302734 |
        +----------------------------------------------------------------+--------------------+--------------------+
        | datetime.datetime(2014, 4, 2, 8, 46, 10, 6, tzinfo=<UTC>)      | 19.388500213623047 |  33.51691818237305 |
        +----------------------------------------------------------------+--------------------+--------------------+
        | datetime.datetime(2014, 4, 2, 8, 46, 20, 2, tzinfo=<UTC>)      | 19.381269454956055 | 33.583274841308594 |
        +----------------------------------------------------------------+--------------------+--------------------+
        | datetime.datetime(2014, 4, 2, 8, 46, 29, 999998, tzinfo=<UTC>) |  19.37234878540039 |   33.6402473449707 |
        +----------------------------------------------------------------+--------------------+--------------------+
        ...
    """

    return NetcdfView(source, variables)

class NetcdfView(Table):

    def __init__(self, source, variables):
        self.source = source
        self.variables = variables

    def __iter__(self):
        dataset = netCDF4.Dataset(self.source)
        
        try:
            # set netcdf processing options (should perhaps be configurable)
            
            dataset.set_auto_mask(False)
            dataset.set_auto_scale(True)
            
            # determine variables to source rows from
            
            if self.variables is None:
                requested_variables = dataset.variables.values() # return all variables if not specified
            else:
                requested_variables = [variable for variable in dataset.variables.values() if variable.name in self.variables.keys()]

            # return the variable names for the column headings
            
            yield tuple([variable.name for variable in requested_variables])
            
            # get dimensions to iterate over in the order that they are first used
            
            dimensions = []
            
            for variable in requested_variables:
                for dimension_name in variable.dimensions:
                    dimension = dataset.dimensions[dimension_name]
                    if dimension not in dimensions:
                        dimensions.append(dimension)

            # iterate over every possible combination of indexes for these dimensions

            for index_combination in index_combinations(dimensions):
                # get the value of each requested variable for this combination of indexes
                variable_values = [get_value(variable, index_combination) for variable in requested_variables]
                # return them as the next row
                yield tuple(variable_values)
            
        finally:
            dataset.close()

def index_combinations(dimensions):
    # recursively iterate through all possible index combinations for passed dimensions
    # starting with an empty index combination (OrderedDict)
    return _index_combinations(dimensions, collections.OrderedDict())
        
def _index_combinations(dimensions, index_combination):
    # recursively iterate through all possible index combinations
    # for the passed dimensions appending them to the passed index combination
    if len(dimensions) == 0:
        # no dimensions left to iterate through just return passed combination
        yield index_combination
    else:
        # get the first dimension passed
        dimension = dimensions[0]

        # iterate through all possible indexes for this dimension
        for index in range(dimension.size):
            # append this index to passed index combination 
            index_combination[dimension.name] = index
            # iterate through all possible index combinations for the remaining
            # dimensions appending them to the updated index combination 
            for index in _index_combinations(dimensions[1:], index_combination):
                # return the index combinations returned for the remaining dimensions 
                yield index

def get_value(variable, index_combination):
    # get the index of the value to return for this variable (the indexes of dimensions used by this variable)
    variable_index = [index_combination[name] for name in index_combination.keys() if name in variable.dimensions]
    # return the value of the variable for this index
    value = variable[tuple(variable_index)].item()
    
    if is_datetime(variable):
        # convert to UTC datetime
        calendar = variable.calendar if hasattr(variable, 'calendar') else 'standard'
        naive_datetime = netCDF4.num2date(value, variable.units, calendar)        
        return pytz.timezone("UTC").localize(naive_datetime)
    else:
        return value

def is_datetime(variable):
    # date/time variables must include a 'units' attribute of the form '<time units> since <reference time>'
    return hasattr(variable, 'units') and re.match(r'.* since .*', variable.units)
    
