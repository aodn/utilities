
#### Tools for performing XSL transforms
 Intended for data exported by gn-tool for datasets that cant be transformed on injest by a current GN harvest

 
```
cd utilities/geonetwork/transform-local-mefs/bin
```
Create new files (appended with '_transformed' in this example) to diff new and old
```
./transform-mefs.sh /path/to/mef/dirs [xsl file in transform directory] _transformed
```
Or update files in place
```
./transform-mefs.sh /path/to/mef/dirs [xsl file in transform directory] _transformed
```


####Testing the changes
check the diffs with diff-transformed-mefs.sh
```
./diff-transformed-mefs.sh /path/to/mef/dirs _transformed | more
```


##### Search further...
`grep -r --include="*[new extension]" '[unwanted string]' /path/to/mef/dirs`



