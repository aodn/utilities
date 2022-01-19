### CSV Harvester Prototypes

Some prototyped approaches to a CSV harvester.

Two approaches are represented here:
1. An _opinionated_ approach - uses high-level methods to harvest data in an opinionated way
2. An _unopinionated_ (or less opinionated) approach - exposes both high- and lower-level methods and a declarative method of calling these from a config file

Both approaches use config to create a database connection and cursor, perform database interactions, and then close the connection.

If the methods all complete successfully the transactions are committed, otherwise they are rolled back.

The _opinionated_ approach runs through the following steps, acting on files in config-defined directories:

1. run DDL  
  a. check for a schema_version table and if it exists, compare the version against the version defined in config, and if indicated:  
    * removes all schema objects
    * creates tables based on tableschema resource yaml files (from directory defined in config)
    * creates other schema objects based on sql files (from directory defined in config)  
  b. if schema_version matches then the step ends without making any change  
2. load CSVs into database
3. run dml scripts
4. refresh materialized views
5. update metadata (placeholder - this step was not prototyped, but requires the database connection in order to determine extents... so could possibly be an associated method)

The _unopinionated_ approach runs the DDL step above, then uses config defined steps to call methods... it is unopinionated in the sense that it doesn't dictate the order of steps (after run DDL) and only acts on the information provided (rather than _all files in a pre-defined directory_)  

The format of these steps is in json format (but could also be yaml):

_example_config.json_
```json
{
    ...
    "steps": [
        {"name": "copy_from_csv", "args": {"path": "data/BGC_Phyto_ChangeLog.csv","truncate": "true"}},
        {"name": "copy_from_csv", "args": {"path": "data/BGC_Phyto_Raw.csv","truncate": "true"}},
        {"name": "copy_from_csv", "args": {"path": "data/BGC_Trip.csv","truncate": "true"}},
        {"name": "copy_from_csv", "args": {"path": "data/BGC_Zoop_ChangeLog.csv","truncate": "true"}},
        {"name": "copy_from_csv", "args": {"path": "data/BGC_Zoop_Raw.csv","truncate": "true"}},
        {"name": "refresh_materialized_view", "args":  {"name":  "bgc_phyto_aggregation"}},
        {"name": "refresh_materialized_view", "args":  {"name":  "bgc_zoop_aggregation"}}
    ]
}
```
