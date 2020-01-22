# gn-tool.sh

A simple utility to export/import records from Geonetwork. 

There is an alternative set of tools that operates on the entire Geonetwork catalog with additional functionality including in-place updates https://github.com/aodn/metadata-utils


####Problems with using this tool as a record updater:

https://geonetwork-opensource.org/manuals/2.10.4/eng/developer/xml_services/services_mef.html#mef-import

Version 1.0 of the MEF format does not capture the metadata owner (the creator) and the group owner. During import, the user that is performing this operation will become the metadata owner and the group owner will be set to null.


## Usage

#### Export

```
$ ./gn-tool.sh -o export -l /tmp/gn-dump -g https://catalogue-123.aodn.org.au/geonetwork
```

#### Import (after any transforms)
```
$ ./gn-tool.sh -o import -l /tmp/gn-dump -g http://10.11.12.13/geonetwork -u admin -p admin
```

## For Geonetwork3, use `gn3-tool.sh` tool 

- User credentials is required for export as we need to extract user ownership information.
- Requires python 3
- Install requirements.txt

#### Export 
```
./gn3-tool.sh -o export -l /tmp/gn-dump -g http://localhost:8882/geonetwork -u admin -p admin
```

#### Import 
```
./gn3-tool.sh -o import -l /tmp/gn-dump -g http://localhost:8883/geonetwork -u admin -p admin
```
