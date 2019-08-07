import petl as etl
import xarray as xr

def fromnetcdf(source, variables=None):
    """
    Extract a table from a `netcdf <https://unidata.github.io/netcdf4-python/netCDF4/>`_ Dataset.
    E.g.::

        >>> import petl as etl
        >>> ...
        >>> table = fromnetcdf('example.nc')
        >>> table
        +-----------+------+------+
        | TIME      | TEMP | PSAL |
        +===========+======+======+
        ...
    """

    return NetcdfView(source, variables)



class NetcdfView(etl.Table):

    def __init__(self, source, variables):
        self.source = source
        self.variables = variables

    def __iter__(self):
        DS = xr.open_dataset(self.source)
        
        for variable in DS.data_vars:
            if variable not in self.variables:
                DS = DS.drop(variable)
                
        for coord in DS.coords:
            if coord not in self.variables:
                DS = DS.drop(coord)
                
        df = DS.to_dataframe()
        
        yield df.columns

        for row in df.itertuples():
            print(row)
            yield row[2]._asdict().values()
            