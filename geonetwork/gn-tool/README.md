# gn-tool.sh

A simple utility to export/import records from Geonetwork. This tool allows updating defined list of records or the entire catalogue contents via the transform-mefs.sh script see: transform-local-mefs/README.md

There is an alternative set of tools that operates on the entire Geonetwork catalog with additional functionality including in-place updates https://github.com/aodn/metadata-utils

## Usage

#### Export

```
$ ./gn-tool.sh -o export -l /tmp/gn-dump -g https://catalogue-123.aodn.org.au/geonetwork
```

#### Import (after transforms)
```
$ ./gn-tool.sh -o import -l /tmp/gn-dump -g http://10.11.12.13/geonetwork -u admin -p admin
```


## Problems:

Geonetwork will change the name of the record source catalogue, if the record was once imported. The fix is to create and run SQL on the Geonetwork DB 

#####Example setting source name back to 'BlueNet'
```$xslt
# python get-uuids-from-file.py  ~/Desktop/geoserver.imos.org.au_geoserver_wms.xml identifier "update sources set name = 'BlueNet' where uuid = '{}'"
```