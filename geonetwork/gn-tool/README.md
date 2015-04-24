# gn-tool

A simple utility to export/import records from Geonetwork

## Usage

### Export

```
$ ./gn-tool.sh -o export -l /tmp/gn-dump -g https://catalogue-123.aodn.org.au/geonetwork
```

### Import
```
$ ./gn-tool.sh -o import -l /tmp/gn-dump -g http://10.11.12.13/geonetwork -u admin -p admin
```
