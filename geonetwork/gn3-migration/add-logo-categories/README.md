# add-logo-categories.sh

`Description`: A simple utility to add logo categories into mef exported info.xml file 

`Options:`
  
 ` -l` Location to read/write records from/to.
  
  `-g` Geonetwork address of `catalogue portal` (e.g. http://a.b.c.d/geonetwork)
  
  `-u`  Username to login with.
 
 ` -p` Password to login with.

#### Usage 
```
./add-logo-categories.sh -l /tmp/gn-dump -g http://a.b.c.d/geonetwork -u admin -p admin
```

#### Note
- Make sure `xsltproc` (http://xmlsoft.org/XSLT/xsltproc.html) tool is installed. 