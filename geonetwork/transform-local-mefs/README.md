
#### Tools for performing transforms on data exported by gn-tool

transform download urls and points-of-truth 
```
cd utilities/geonetwork/transform-local-mefs 
./bin/transform-downloads.sh /path/to/mef/dirs https://my-geonetwork.dev.aodn.org.au
```

Transform records with uuid surrounded in '{}' braces
```
./bin/transform-braced-mefs.sh /path/to/mef/dirs
```

