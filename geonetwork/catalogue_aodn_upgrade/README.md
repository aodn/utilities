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
./download_mefs.sh catalogue_aodn_hosted_uuids.txt /tmp/catalogue_aodn_hosted_backup
```

#### Execute Tool to validate schemas (and fixes them if needed)

See: README-Validation.md for details

#### Transform MCP -> 19115-3

TODO:
- fix url-substitutions (if needed)

```
rm -rf /tmp/catalogue_aodn_hosted
cp -R /tmp/catalogue_aodn_hosted_backup /tmp/catalogue_aodn_hosted
java -jar ./target/transform-mcp-iso19115-3-1.0-SNAPSHOT-jar-with-dependencies.jar -d /tmp/catalogue_aodn_hosted -i metadata.xml -o metadata.iso19115-3.2018.xml -u url-substitutions/aodn-test.xml
```

#### 5. Import into target GN3 catalogue

```
./gn3-tool.sh -o import -l /path/to/mefs -g  http://<target_url>/geonetwork -u <username> -p <password>
```

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
  
  
## Frozen harvester records to import as hosted records

### Bluenet

#### Ignore record

Ignore this record, Nat has identified it as not migrate-able (appears to be a test record anyway)
```
a6097db0-7b8c-11dc-b279-00188b4c0af8
```

Also ignore these junk/template records identified by Craig

```
211d2692-b120-4dc0-a204-866fe734433d
2a6cc5e1-f4fe-479c-8b41-9e2cdbe89aca
4d55aee7-94e8-4c62-923c-412f376b2f13
533c94dd-1b89-46d4-b999-e1418ab811a2
69058797-cb81-47c4-824a-402440c75dee
8a735fe4-9136-494d-964c-14265a0ed069
b586905d-09dc-4ed9-8241-1a91c5bc4e1e
b836f4df-3576-4151-8a89-f92b7e4a48bc
e3f83178-fe7d-4165-8d2d-c52eccc791d7
f312d2ab-0750-40c9-8217-97c39a1f4332
```

Also ignore the only record with the `fgdc-std` schema as it appears to be some kind of template

#### Get UUID list
```
ssh 6-aws-syd "sudo -u postgres psql -d geonetwork_aodn -c \"\\copy (select uuid from metadata where harvestuuid = (select value from settings where parentid = (select parentid from settings where name = 'name' and value = 'bluenet (don''t delete)') and name = 'uuid') and istemplate = 'n' and schemaid not in ('fgdc-std') and uuid not in ('211d2692-b120-4dc0-a204-866fe734433d', '2a6cc5e1-f4fe-479c-8b41-9e2cdbe89aca', '4d55aee7-94e8-4c62-923c-412f376b2f13', '533c94dd-1b89-46d4-b999-e1418ab811a2', '69058797-cb81-47c4-824a-402440c75dee', '8a735fe4-9136-494d-964c-14265a0ed069', 'b586905d-09dc-4ed9-8241-1a91c5bc4e1e', 'b836f4df-3576-4151-8a89-f92b7e4a48bc', 'e3f83178-fe7d-4165-8d2d-c52eccc791d7', 'f312d2ab-0750-40c9-8217-97c39a1f4332', 'a6097db0-7b8c-11dc-b279-00188b4c0af8')) to stdout\" > /tmp/catalogue_aodn_bluenet_uuids.txt"
scp 6-aws-syd:/tmp/catalogue_aodn_bluenet_uuids.txt .
```

#### Download bluenet MEFS

Count: 968
By grepping it appears the number of 1.5-experimental: 955

```
./download_mefs.sh catalogue_aodn_bluenet_uuids.txt /tmp/catalogue_aodn_bluenet_backup
```

We don't need to run schema validations because they will all be done in-situ in catalogue-aodn GN2

#### Transform MCP

NOTE: There is potentially an issue where records are not converted to -3. Use git to confirm

```
rm -rf /tmp/catalogue_aodn_bluenet
cp -R /tmp/catalogue_aodn_bluenet_backup /tmp/catalogue_aodn_bluenet
(cd /tmp/catalogue_aodn_bluenet ; git init)
(cd /tmp/catalogue_aodn_bluenet ; git add .)
(cd /tmp/catalogue_aodn_bluenet ; git commit -m "init commit")
java -jar ./target/transform-mcp-iso19115-3-1.0-SNAPSHOT-jar-with-dependencies.jar -d /tmp/catalogue_aodn_bluenet -i metadata.xml -o metadata.iso19115-3.2018.xml -u url-substitutions/aodn-test.xml
```
Check git to confirm -3 records added

#### Upload to target

```
./gn3-tool.sh  -o import -l /tmp/catalogue_aodn_bluenet -g http://geonetwork3-gsatimos.dev.aodn.org.au/geonetwork -u admin -p admin
```

#### Pots
- pots are http://geonetwork.marvlis... (need to check with Bene/Nat)


### MARVLIS

#### Get UUID list
```
ssh 6-aws-syd "sudo -u postgres psql -d geonetwork_aodn -c \"\\copy (select uuid from metadata where harvestuuid = (select value from settings where parentid = (select parentid from settings where name = 'name' and value = 'MARVLIS') and name = 'uuid') and istemplate = 'n' and schemaid not in ('fgdc-std')) to stdout\" > /tmp/catalogue_aodn_marvlis_uuids.txt"
scp 6-aws-syd:/tmp/catalogue_aodn_marvlis_uuids.txt .
```

#### Download MEFS

```
./download_mefs.sh catalogue_aodn_marvlis_uuids.txt /tmp/catalogue_aodn_marvlis_backup
```

#### transform to 19115-3
```
rm -rf /tmp/catalogue_aodn_marvlis
cp -R /tmp/catalogue_aodn_marvlis_backup /tmp/catalogue_aodn_marvlis
java -jar ./target/transform-mcp-iso19115-3-1.0-SNAPSHOT-jar-with-dependencies.jar -d /tmp/catalogue_aodn_marvlis -i metadata.xml -o metadata.iso19115-3.2018.xml -u url-substitutions/aodn.xml
```

#### Upload to target

```
./gn3-tool.sh  -o import -l /tmp/catalogue_aodn_marvlis -g http://geonetwork3-gsatimos.dev.aodn.org.au/geonetwork -u admin -p admin
```

