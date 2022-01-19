# Generic CSV Harvester
This prototype demonstrates running a harvester using a (rudimentary) pipeline file collection, specific config (harvest_params) and schema definitions / ddl  

## Usage (in PyCharm)

1. Open a new project pointing at the harvester directory
2. Ensure a Docker daemon is running on your machine, and your PyCharm project has a docker-compose plugin configured 
3. Run docker-compose up (click the double green arrow against "services" in the docker-compose.yml file)
4. After the build is complete you should have 2 services running:  
   - app (eg. harvester_app_1)  
   - db (eg. harvester_db_1)  

## Connecting to the database
1. You should be able to connect to the database outside the container using the following credentials:
   - host: "172.18.0.2" _* or see note below_
   - database: "harvest"
   - port: "5435"
   - user: "test"
   - password: "test"
   - schema: "test"

_note: the hostname above might differ.  With the docker container active, run the following in terminal to find out the actual database ip address_
```
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' harvester_db_1
```

## Running the harvester
Because docker really requires some kind of listener service in front of the python script, we're using a Flask web front-end

To run the harvester:
1. Open a browser and navigate to http://localhost:5000
2. If the harvester was successful you should get a response like this:
```json
{
  "status": "success", 
  "data": [
    {
      "is_harvested": true, 
      "local_path": "data/BGC_Phyto_Raw.csv"
    }, 
    {
      "is_harvested": true, 
      "local_path": "data/BGC_Phyto_ChangeLog.csv"
    }, 
    {
      "is_harvested": true, 
      "local_path": "data/BGC_Trip.csv"
    },
    {
      "is_harvested": true, 
      "local_path": "data/BGC_Zoop_Raw.csv"
    },
    {
      "is_harvested": true,
      "local_path": "data/BGC_Zoop_ChangeLog.csv"
    }
  ]
}
```
3. You can also add an argument eg. http://localhost:5000/?ingest=truncate (options include "replace", "truncate" and "append") although "replace" is the default ingest type and will probably be the only one used for the original implementation (as it won't require schema version checking).

## Modifying the inputs
* The process loads the pipeline file collection from the _data_ directory
* and refers to a harvest_params list / array in the _config.py_ file
* finally it looks for matching schema and transaction files (yaml and sql) in the _public-schema_ directory for the different database transactions

To modify the process change or extend any of the above, remove the harvest_app_1 container and underlying image, then run docker-compose up app (ie. just for the app service)

