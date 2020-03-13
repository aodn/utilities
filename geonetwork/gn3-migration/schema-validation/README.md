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

#### Note
- Make sure `xmllint` (http://xmlsoft.org/xmllint.html) tool is installed. 
- Make sure `xsltproc` (http://xmlsoft.org/XSLT/xsltproc.html) tool is installed. 