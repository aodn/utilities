# run-schema-validation.sh

`Description`: A simple utility for metadata records schema validation.

`Options:`
  
  `-s `	Schema plugin path 
  
  `-r` 	Path for MEF exported metadata records folder
  
 ` -e `	Filename of the schema validation error file

#### Usage 
```
./run-schema-validation.sh -s '/path/to/schema-plugins'  -r 'path/to/record/folder' -e 'validation-result.txt'
```

#### Output
- Outputs `<filename provide with -e options e.g. validation-result.txt>`. This file contains validation error list before any fixes applied.
- Outputs `diff-result-<filename provide with -e options e.g. validation-result.txt>`. This diff files will includes all the changes made in the `metadata.xml` files after fixes.
- Outputs `after-fix-<filename provide with -e options e.g. validation-result.txt>`. This file contains validation error list. If empty all validation errors are fixed.

#### Requirements
- Make sure `xmllint` (http://xmlsoft.org/xmllint.html) tool is installed. 

#### Choosing XSLT processor
##### XSL 1.0 with xsltproc
- Make sure `xsltproc` (http://xmlsoft.org/XSLT/xsltproc.html) is installed
- Set the version in `<xsl:stylesheet ... version="1.0">`
- Uncomment/comment the appropriate lines
```
  xsltproc -o $record_path/$uuid/metadata/metadata.xml $schema/fix-mcp-schema-validation.xsl $record_path/$uuid/metadata/metadata.xml.bak
#  java -jar saxon9he.jar -s:$record_path/$uuid/metadata/metadata.xml.bak -o:$record_path/$uuid/metadata/metadata.xml -xsl:$schema/fix-mcp-schema-validation.xsl
```
##### XSL 2.0 with saxon9he
- Make sure `saxon9he` (https://www.saxonica.com/documentation9.5/about/installationjava/) is installed
- Set the CLASSPATH to the `saxon9he.jar`  
- Set the version in `<xsl:stylesheet ... version="2.0">`
- Uncomment/comment the appropriate lines
```
#  xsltproc -o $record_path/$uuid/metadata/metadata.xml $schema/fix-mcp-schema-validation.xsl $record_path/$uuid/metadata/metadata.xml.bak
  java -jar saxon9he.jar -s:$record_path/$uuid/metadata/metadata.xml.bak -o:$record_path/$uuid/metadata/metadata.xml -xsl:$schema/fix-mcp-schema-validation.xsl
```