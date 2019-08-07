import petl as etl

# example only

class TimeseriesHarvester:
    def harvest(self, inputs):
        return {
            'timeseries': inputs['global_attributes'],
            'measurements': inputs['variables']
        }
    
# example only - would be loaded based on config using custom netcdf sources

global_attributes = etl.wrap([
    ['time_coverage_start', 'time_coverage_end'],
    ['2012-06-19T10:00:00Z', '2012-06-20T10:00:00Z']
])

variables = etl.wrap([
    ['TIME', 'TEMP'],
    ['2012-06-19T10:00:00Z', 23.65],
    ['2012-06-20T10:00:00Z', 24.13]
])

inputs = {
  "global_attributes": global_attributes,
  "variables": variables
}

# instantiated based on config
harvester = TimeseriesHarvester()

outputs = harvester.harvest(inputs)

# example only - would be output based on config e.g. to postgres tables

for output in outputs:
    etl.tocsv(outputs[output], output+".csv")
    

