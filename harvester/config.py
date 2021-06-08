# this file acts as a prototype drop-in for LazyConfigBuilder()
pipeline = "test"

# harvest_params is part of imos_po_watches json schema but will need to be extended
harvest_params = {
    # ingest_type is an attribute aimed at future-proofing.  For now it will just default to "replace", but future
    # values might include "truncate" and "append"
    "ingest_type": "replace",
    # each db_object represents a database object (table, materialized view, view, etc)
    # they are processed in the order in which they are displayed
    "db_objects": [
        {
            "name": "bgc_phyto_changelog",
            "type": "table",
        },
        {
            "name": "bgc_phyto_raw",
            "type": "table",
        },
        {
            "name": "bgc_trip",
            "type": "table",
        },
        {
            "name": "bgc_zoop_changelog",
            "type": "table",
        },
        {
            "name": "bgc_zoop_raw",
            "type": "table",
        },
        {
            "name": "bgc_phyto_aggregation",
            "type": "materialized view",
            "dependencies": ["bgc_phyto_raw"]
        },
        {
            "name": "bgc_zoop_aggregation",
            "type": "materialized view",
            "dependencies": ["bgc_zoop_raw"]
        }
    ]
}

# create as part of chef build?
additional = {
    # base path on the pipeline box for use with harvest_params.db_objects.source strings
    # the public-schema directory will also need to be copied to this location as part of the chef build?
    "schema_base_path": "public-schema/imos_bgc_db",
    # db connection parameters
    "db": {
        "host": "db",
        # "host": "172.18.0.2",
        "database": "harvest",
        "port": "5435",
        "user": pipeline,
        "password": pipeline,
        "options": "-c search_path={}".format(pipeline)
    }
}

config = {'harvest_params': harvest_params, 'additional': additional}

