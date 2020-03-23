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

#### Note
- Make sure `xmllint` (http://xmlsoft.org/xmllint.html) tool is installed. 
- Make sure `xsltproc` (http://xmlsoft.org/XSLT/xsltproc.html) tool is installed. 