# About

This is a utility tools to re-create the mini-map in the portal. The mini-map comes from the spatial extents
of geonetwork. Initially the spatial extents will be created by talend, however sometimes it didn't work
as expected and instead of modifying the talend which is on demise path, this utility tools is created 
to re-create the spatial extents by extract the code in talend.

# Argument
You can run the tools by using the following command
```shell
java -jar target/spatialextents-0.0.1-SNAPSHOT.jar --uuid=7e13b5f3-4a70-4e31-9e95-335efa491c5c --schema=anmn_ts --dbtable=timeseries --resolution=1 --printOnly=y
```

| argument | description                                                                                                                                                                                                                 |
| ----- |-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| --uuid | The uuid of the geonetwork record, for example  7e13b5f3-4a70-4e31-9e95-335efa491c5c refers to "IMOS - Australian National Mooring Network (ANMN) Facility - Temperature and salinity time-series"                          |
| --schema | The database schema store in havestor db, in this case - anms_ts store the geospatial info of "IMOS - Australian National Mooring Network (ANMN) Facility - Temperature and salinity time-series", PO should know the value |
| --dtable | The name of the table in the schema that store the geosptail record | 
| -- resolution | Usually 1 but can be 2 depends on PO preference | 
| --printOnly | default is y, which means you only want to print the record in console for debug without update geonetwork, use --printOnly=n if you want update |


> :exclamation:
> You need to add this argument if you want to connect and update catalog-systest,
> 
> -Dspring.profiles.active=systest
> 
> if You want to update production geonetwork
> 
> -Dspring.profiles.active=prod
> 
> That is
> 
> java -jar -Dspring.profiles.active=prod target/spatialextents-0.0.1-SNAPSHOT.jar --uuid=7e13b5f3-4a70-4e31-9e95-335efa491c5c --schema=anmn_ts --dbtable=timeseries --resolution=1 --printOnly=n 
