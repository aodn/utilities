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

Execute validate schema tool against mefs
https://github.com/aodn/utilities/tree/master/geonetwork/gn3-migration/schema-validation
- gather together plugins into a single directory first (Craig will identify)
- work currently underway by Craig to resolve issues here

##### Catalogue AODN hosted MCP records

- Create a fresh working directory in a convenient location

```
mkdir /tmp/catalogue_aodn_hosted_mcp
```

- OPTIONAL: Obtain a list of UUIDS for non harvested mcp records that need correction

This step is only required if a full validation is required and the records to be corrected are unknown.

```
ssh 6-aws-syd "sudo -u postgres psql -d geonetwork_aodn -c \"\\copy (select uuid from metadata where isharvested = 'n' and istemplate = 'n' and (schemaid = 'iso19139.mcp' or schemaid = 'iso19139.mcp-1.4' or schemaid = 'iso19139.mcp-2.0')) to stdout\" > catalogue_aodn_non_harvested_mcp_uuids.txt"
scp 6-aws-syd:catalogue_aodn_non_harvested_mcp_uuids.txt /tmp/uuids.txt
```

- Download the MEFS

Use this list of uuids ([corrected-uuids.txt](https://github.com/aodn/utilities/files/6951934/corrected-uuids.txt)
) or the one generated in the previous step to download the MEFS to be validated. 

```
./download_mefs.sh /tmp/uuids.txt /tmp/catalogue_aodn_hosted_mcp
```

- Locate misplaced info.xml files

Some info.xml files are in an unexpected location for the validator.  Find and move these.

```
for f in $(find /tmp/catalogue_aodn_hosted_mcp -name info.xml | grep metadata); do mv $f $(dirname $(dirname $f)); done
```

- Source and copy the schema plugins to one location

These can be obtained from https://github.com/aodn/schema-plugins/tree/180e374a2f1ac181a79bc3b9432b46739301e0e6

Required schemas are iso19139.mcp-1.4, iso19139.mcp-2.0 and iso19139.mcp

Copy them to a convenient location other than the working directory created in step one (eg /tmp/schemaPlugins)

- Validate and correct

Before running the validation make sure xmllint and saxon9he are installed as per the README.md

```
cd gn3-migration/schema-validation
./run-schema-validation.sh -s /tmp/schemaPlugins -r /tmp/catalogue_aodn_hosted_mcp -e 'catalogue_aodn_hosted_mcp.txt'
```

The script will do the following for each record:
 - Make a backup of the original metadata.xml in metadata.xml.bak
 - Using xmllint validate the metadata.xml.bak against the schema identified in the info.xml file
 - Apply corrections to the metadata.xml file using the associated fix-mcp-schema-validation.xsl file found in the iso19139.mcp, iso19139.mcp-1.4 or iso19139.mcp-2.0 directory.
 - Validate the resulting metadata.xml to generate final reports

During the process several log and report files are generated.
 - catalogue_aodn_hosted_mcp.txt                            Detail of each non-compliant element found in original metadata
 - summary-catalogue_aodn_hosted_mcp.txt                    Counts of non-compliant elements found in original metadata
 - after-fix-validity-errors-catalogue_aodn_hosted_mcp.txt  Remaining errors that the tool could not correct
 - messages-catalogue_aodn_hosted_mcp.txt                   CSV list of "metadata-file-corrected","element-corrected","schema-xsl-used-to-correct","description-of-error"

Check the messages-catalogue_aodn_hosted_mcp.txt and after-fix-validity-errors-catalogue_aodn_hosted_mcp.txt and console

- Report

Using the content of messages-catalogue_aodn_hosted_mcp.txt create an Excel report of all the changes made to the records. 

Example: [messages-catalogue_aodn_hosted_mcp.xlsx](https://github.com/aodn/utilities/files/6951866/messages-catalogue_aodn_hosted_mcp.xlsx)

Using the content of after-fix-validity-errors-catalogue_aodn_hosted_mcp.txt create a list of manual corrections required. Some of these corrections will need to be manually made in the metadata.xml files before import. 

Example:
```
068252d5-773b-4bd5-8980-100ad436ed7b/metadata/metadata.xml:1507: Anchor, attributehref: 'http://metadata.imas.utas.edu.au:/geonetwork/srv/en/thesaurus.download?ref=external.theme.sciencekeywords' is not a valid value of the atomic type 'xs:anyURI'.
07556fa0-d8ae-4b19-95dd-def52db223a1/metadata/metadata.xml:296: DP_DataParameters: Character content other than whitespace is not allowed because the content type is 'element-only'.
1de0e8b1-4777-4526-b3d7-805938b8e6bc/metadata/metadata.xml:1013: Anchor', attributehref: 'http://metadata.imas.utas.edu.au:/geonetwork/srv/en/thesaurus.download?ref=external.theme.sciencekeywords' is not a valid value of the atomic type 'xs:anyURI'.
2a9a9f90-79a3-498b-a2d2-0f822fe35ed9/metadata/metadata.xml:676: Anchor', attributehref: 'http://metadata.imas.utas.edu.au:/geonetwork/srv/en/thesaurus.download?ref=external.theme.sciencekeywords' is not a valid value of the atomic type 'xs:anyURI'.
5344966e-ea85-4c98-b699-546dba9cb39e/metadata/metadata.xml:282: Anchor', attributehref: 'http://metadata.imas.utas.edu.au:/geonetwork/srv/en/thesaurus.download?ref=external.theme.sciencekeywords' is not a valid value of the atomic type 'xs:anyURI'.
5344966e-ea85-4c98-b699-546dba9cb39e/metadata/metadata.xml:366: EX_GeographicBoundingBox: This element is not expected.
95204c39-71b3-4335-8435-d4d4f027bc8a/metadata/metadata.xml:255: code: This element is not expected. Expected is one of ( {http://www.isotc211.org/2005/gmd}codeSpace, {http://www.isotc211.org/2005/gmd}version ).
982bac15-44c6-4424-9844-18337d318d39/metadata/metadata.xml:237: VerticalCRS: Missing child element(s). Expected is one of ( {http://www.opengis.net/gml}verticalDatum, {http://www.opengis.net/gml}usesVerticalDatum ).
a10d4447-73bb-4bba-a12b-20d8c803ef30/metadata/metadata.xml:304: Anchor, attributehref: 'http://metadata.imas.utas.edu.au:/geonetwork/srv/en/thesaurus.download?ref=external.theme.sciencekeywords' is not a valid value of the atomic type 'xs:anyURI'.
e8769cd6-8693-4252-8a5e-1ab2a25d4e4e/metadata/metadata.xml:394: Anchor, attributehref: 'http://metadata.imas.utas.edu.au:/geonetwork/srv/en/thesaurus.download?ref=external.theme.sciencekeywords' is not a valid value of the atomic type 'xs:anyURI'.
e8769cd6-8693-4252-8a5e-1ab2a25d4e4e/metadata/metadata.xml:506: VerticalCRS: Missing child element(s). Expected is one of ( {http://www.opengis.net/gml}scope, {http://www.opengis.net/gml}verticalCS, {http://www.opengis.net/gml}usesVerticalCS ).
fd645850-00c8-47f7-842c-4ef54ebdab52/metadata/metadata.xml:299: Anchor, attributehref: 'http://metadata.imas.utas.edu.au:/geonetwork/srv/en/thesaurus.download?ref=external.theme.sciencekeywords' is not a valid value of the atomic type 'xs:anyURI'.
```

- Import corrected records into catalogue.aodn.org.au (Geonetwork 2)
     
```
./gn-tool.sh -o import -y overwrite -l /tmp/catalogue_aodn_hosted_mcp -g  http://<target_url>/geonetwork -u <username> -p <password>
```

- Perform post import checks and manual corrections

Refer to after-fix-validity-errors-catalogue_aodn_hosted_mcp.txt and [messages-catalogue_aodn_hosted_mcp.xlsx](https://github.com/aodn/utilities/files/6951866/messages-catalogue_aodn_hosted_mcp.xlsx) for notes on specific checks and corrections to be made.


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

Also ignore the only record with the `fgdc-std` schema as it appears to be some kind of template

#### Get UUID list
```
ssh 6-aws-syd "sudo -u postgres psql -d geonetwork_aodn -c \"\\copy (select uuid from metadata where harvestuuid = (select value from settings where parentid = (select parentid from settings where name = 'name' and value = 'bluenet (don''t delete)') and name = 'uuid') and istemplate = 'n' and schemaid not in ('fgdc-std') and uuid != 'a6097db0-7b8c-11dc-b279-00188b4c0af8') to stdout\" > /tmp/catalogue_bluenet_uuids.txt"
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
java -jar ./target/transform-mcp-iso19115-3-1.0-SNAPSHOT-jar-with-dependencies.jar -d /tmp/catalogue_aodn_marvlis -i metadata.xml -o metadata.iso19115-3.2018.xml -u url-substitutions/aodn.xml
```

#### Upload to target

```
./gn3-tool.sh  -o import -l /tmp/catalogue_aodn_marvlis -g http://geonetwork3-gsatimos.dev.aodn.org.au/geonetwork -u admin -p admin
```

