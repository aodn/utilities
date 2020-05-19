
# Tool for transforming ISO19139.MCP metadata records to ISO19115-3.
- Converts mcp xml file to 19115-3.
- Converts iso19139.mcp1.4 to iso19139.mcp2.0 using `schema/iso19115-3/convert/ISO19139/to19139.mcp-2.0.xsl` XSL file.
- Converts iso19139.mcp2.0 to iso19115-3 using `schema/iso19115-3/convert/ISO19139/fromISO19139MCP2.xsl` XSL file.
- Intended for data exported by gn3-tool.
- If the `-d` option is specified then the directory will be recursively searched for any file with the name specified by the `-i` option. 
- The converted file will be created with the name specified by the `-o` option at the same level in the directory structure as the input file.
- If the `-u` option is specified then url substitutions specified in the configuration file specified will be applied after the transformation

## Tool

```
java -jar transform-mcp-iso19115-3-1.0-SNAPSHOT-jar-with-dependencies.jar -d <input_directory> -i <input_file_name> -o <output_file_name>
```
Options:
- -d: Directory name containing xml file name at some depth in the directory structure
- -i: Input xml file name
- -o: Output xml file name
- -u: URL substitutions configuration file

## Usage

```
cd utilities/geonetwork/transform-mcp-iso19115-3
```
Run maven tool to package jar file. 
```
mvn package
```
Note: Make sure `transform-mcp-iso19115-3-1.0-SNAPSHOT-jar-with-dependencies.jar` exists in target folder. 
```
java -jar ./target/transform-mcp-iso19115-3-1.0-SNAPSHOT-jar-with-dependencies.jar -d /tmp/gn-dump-local -i metadata.xml -o metadata.iso19115-3.2018.xml -u url-substitutions/imos-prod.xml
```





