[bluenet_marvlis_uuids.txt](https://github.com/aodn/utilities/files/6952457/bluenet_marvlis_uuids.txt)
[bluenet_marvlis_uuids.txt](https://github.com/aodn/utilities/files/6952460/bluenet_marvlis_uuids.txt)
# Catalogue AODN hosted MCP records

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

These can be obtained from https://github.com/aodn/schema-plugins

Required schemas are iso19139.mcp-1.4, iso19139.mcp-2.0 and iso19139.mcp

Copy them to a convenient location other than the working directory created in step one (eg /tmp/schemaPlugins)

- Validate and correct

Before running the validation make sure xmllint and saxon9he are installed as per the README.md (see: https://github.com/aodn/utilities/pull/259/files#diff-b2a78821534e880090aae11187ad4a87c454f501dc3b8a6aa36e65f8ac7b84bd)

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

Example: [after-fix-validity-errors-catalogue_aodn_hosted_mcp.txt](https://github.com/aodn/utilities/files/6965392/after-fix-validity-errors-catalogue_aodn_hosted_mcp.txt)


- Import corrected records into catalogue.aodn.org.au (Geonetwork 2)

```
./gn-tool.sh -o import -y overwrite -l /tmp/catalogue_aodn_hosted_mcp -g  http://<target_url>/geonetwork -u <username> -p <password>
```

- Perform post import checks and manual corrections

Refer to after-fix-validity-errors-catalogue_aodn_hosted_mcp.txt and [messages-corrected-catalogue_aodn_hosted_mcp.xlsx](https://github.com/aodn/utilities/files/6952212/messages-corrected-catalogue_aodn_hosted_mcp.xlsx) for notes on specific checks and corrections to be made.

# Catalogue AODN MARVL and Bluenet MCP records

Repeat as per hosted records using the one of following uuid lists:

For all Bluenet and MARVL records: [bluenet_marvlis_uuids.txt](https://github.com/aodn/utilities/files/6952461/bluenet_marvlis_uuids.txt)

For Bluenet and MARVL records that require correction: [corrected-uuids-bluenet_marvlis.txt](https://github.com/aodn/utilities/files/6965365/corrected-uuids-bluenet_marvlis.txt)

Example report file: [messages-corrected-catalogue_aodn_hosted_mcp.xlsx](https://github.com/aodn/utilities/files/6965372/messages-corrected-catalogue_aodn_hosted_mcp.xlsx)

Example remaining validity errors for manual correction: [after-fix-validity-errors-bluenet_marvlis.txt](https://github.com/aodn/utilities/files/6965380/after-fix-validity-errors-bluenet_marvlis.txt)





