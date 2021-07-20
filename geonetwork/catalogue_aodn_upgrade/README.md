### catalogue_aodn_upgrade

### Analysis of records in catalogue-aodn

Schemas of hosted records
```
geonetwork_aodn=# select schemaid, count(schemaid) from metadata where isharvested = 'n' group by schemaid order by schemaid;
     schemaid     | count 
------------------+-------
 dublin-core      |     2 <-- not required
 iso19110         |     1 <-- not required
 iso19139         |    48
 iso19139.anzlic  |    20
 iso19139.mcp     |    18
 iso19139.mcp-1.4 |  1187
 iso19139.mcp-2.0 |   164
(7 rows)
```


### 1. Export list of UUIDs

Export a list records from the catalogue-aodn database
Note that this filters out:
 - harvested records
 - template records
 - records for schemas that we have confirmed we don't require
```
# all
ssh 6-aws-syd "sudo -u postgres psql -d geonetwork_aodn -c \"\\copy (select uuid from metadata where isharvested = 'n' and istemplate = 'n' and schemaid not in ('dublin-core', 'iso19110')) to stdout\" > /tmp/catalogue_aodn_non_harvested_uuids.txt"
scp 6-aws-syd:/tmp/catalogue_aodn_non_harvested_uuids.txt .

# only mcp
ssh 6-aws-syd "sudo -u postgres psql -d geonetwork_aodn -c \"\\copy (select uuid from metadata where isharvested = 'n' and istemplate = 'n' and (schemaid = 'iso19139.mcp' or schemaid = 'iso19139.mcp-1.4' or schemaid = 'iso19139.mcp-2.0')) to stdout\" > /tmp/catalogue_aodn_non_harvested_mcp_uuids.txt"
scp 6-aws-syd:/tmp/catalogue_aodn_non_harvested_mcp_uuids.txt .
```

### MCP Records

#### Download MCP MEFs

Note that gn-tool is capable of exporting all MEFs by not supplying the uuid of a particular collection but using this method will mean that a subset of collections can be tested e.g. all collections in _X_ group

```
# e.g.
./download_mefs.sh catalogue_aodn_non_harvested_uuids.txt /tmp/catalogue_aodn_mcp
```

#### Execute Tool to validate schemas (and fixes them if needed)

Execute validate schema tool against mefs
https://github.com/aodn/utilities/tree/master/geonetwork/gn3-migration/schema-validation
- gather together plugins into a single directory first (Craig will identify)
- work currently underway by Craig to resolve issues here

#### Transform MCP -> 19115-3

TODO:
- fix url-substitutions (if needed)

java -jar ./target/transform-mcp-iso19115-3-1.0-SNAPSHOT-jar-with-dependencies.jar -d /tmp/output -i metadata.xml -o metadata.iso19115-3.2018.xml -u url-substitutions/imos-prod.xml

#### 5. Import into target GN3 catalogue

./gn3-tool.sh  -o import -l /path/to/mefs -g  http://<target_url>/geonetwork -u <username> -p <password>

## Verification
- [x] 19139 records can be transformed using transform-mcp-iso19115-3 and result in iso19115-3.2018 when imported
- [x] 19139-anzlic records can be transformed using transform-mcp-iso19115-3 and result in iso19115-3.2018 when imported
- [x] 19139-mcp records can be transformed using transform-mcp-iso19115-3 and result in iso19115-3.2018 when imported

## Issues
- 19139-mcp-1.4 records can be transformed using transform-mcp-iso19115-3 and result in iso19115-3.2018 when imported
  - 61/1187 will not transform and the effect of importing is that 61 are 19139 (the rest are fine)
  - when Craig has resoved transformation issues we will see if any of these still remain
- 19139-mcp-2.0 records can be transformed using transform-mcp-iso19115-3 and result in iso19115-3.2018 when imported
  - 13/164 will not transform and the effect of importing is that 61 are 19139 (the rest are fine)
  - when Craig has resoved transformation issues we will see if any of these still remain
 
### Post import verification

We should:
- check database metadata table for
  - count of records
  - unique schemas (should only be 19115-3)
  
 