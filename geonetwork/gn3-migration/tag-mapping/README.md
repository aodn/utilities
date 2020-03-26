# find_test_metadata_records.py

`Description`: A script to find the optimal set of sample files that cover all xml tags used within the target directory. The tags from mcp records are then matched against 19115-3.2018 records based on value.

`Options:`
  
  `-s `	Source directory 
  
  `-d` 	Path for a working directory that will contain all outputs

#### Usage 
```
./find_test_metadata_records.py -s '/tmp/gn-dump'  -d '/tmp/matched-tags'
```

#### Note
- Source directory should contain dump from GN2 instance that has been transformed to 19115-3

# get_all_tag_values.py

`Description`: A script to extract all tags and their distinct values.

`Options:`
  
  `-s `	Source directory 
  
  `-d` 	Path for a working directory that will contain all outputs

#### Usage 
```
./get_all_tag_values.py -s '/tmp/gn-dump'  -d '/tmp/exported-tags'
```
