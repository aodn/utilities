# add-logo-categories.sh

`Description`: A simple utility to add logo categories into mef exported info.xml file 

`Options`:

  `-o`        Operation, must be 'add-logo-categories'.
  
 ` -l `       Location to read/write records from/to.
  
 ` -m `       A uuid-category mapping file.

#### Usage 
```
./add-logo-categories.sh -o add-logo-categories -l /tmp/gn-dump-test -m uuid-category.csv
```
