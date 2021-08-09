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

Example: [messages-corrected-catalogue_aodn_hosted_mcp.xlsx](https://github.com/aodn/utilities/files/6952212/messages-corrected-catalogue_aodn_hosted_mcp.xlsx)

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

Refer to after-fix-validity-errors-catalogue_aodn_hosted_mcp.txt and [messages-corrected-catalogue_aodn_hosted_mcp.xlsx](https://github.com/aodn/utilities/files/6952212/messages-corrected-catalogue_aodn_hosted_mcp.xlsx) for notes on specific checks and corrections to be made.
