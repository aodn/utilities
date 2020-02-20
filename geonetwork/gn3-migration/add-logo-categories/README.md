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


## Instructions for creating uuid-category mapping file

- The uuid-category.csv file used was generated as follows:

- Downloaded all current catalogue portal harvesters using:

`https://catalogue-portal.aodn.org.au/geonetwork/srv/eng/xml.harvesting.get
(need to be authenticated)`

- Transforming this list to get category to be used for each catalogue-portal harvester using following XSLT.

```
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:template match="/">
        <mappings>
            <xsl:for-each select="nodes/node">
                <mapping sourceId="{site/uuid/text()}" category="portal:{replace(site/icon/text(), '_logo\..*', '')}"/>
            </xsl:for-each>
        </mappings>
    </xsl:template>
</xsl:stylesheet>
```


- Downloading all records harvested to catalogue-portal using:
```
https://catalogue-portal.aodn.org.au/geonetwork/srv/eng/xml.search.imos?fast=index
```
Transforming this list using following XSL file replacing the mappings element with the mappings element generated above.

```
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="text"/>
    
   <xsl:variable name="mapping">
       <mappings>
           <mapping sourceId="ae9c54b8-1a53-423d-bb80-df9f15ee7ecb" category="portal:CDU"></mapping>
           <mapping sourceId="2002ca62-6aab-4de9-acea-778d160b77a2" category="portal:CDU"></mapping>
           <mapping sourceId="544777e9-ae04-4ff8-9348-9e1c9de71033" category="portal:CSIRO"></mapping>
           <mapping sourceId="2486b143-572c-4135-aaec-eb97f77eee32" category="portal:CSIRO"></mapping>
           <mapping sourceId="2aa1d43b-6f3a-4885-96fa-8787525fd3c2" category="portal:CSIRO"></mapping>
           <mapping sourceId="99428354-2613-481f-bf30-e7a65fd03202" category="portal:CSIRO"></mapping>
           <mapping sourceId="80235762-1241-44b1-832c-5978d0a1fcfa" category="portal:CSIRO"></mapping>
           <mapping sourceId="9cbf0c2e-28cc-47d2-8f90-7129654aa290" category="portal:CSIRO"></mapping>
           <mapping sourceId="b902a919-9cfa-460f-a453-84970630640f" category="portal:CSIRO"></mapping>
           <mapping sourceId="409efe87-8b60-465e-934e-ea094dc31b15" category="portal:CSIRO"></mapping>
           <mapping sourceId="05f70aff-010e-48e4-8c06-be45c7fa402f" category="portal:CSIRO"></mapping>
           <mapping sourceId="424e0ecd-712f-4cb0-930f-239ee7c0855a" category="portal:OEH"></mapping>
           <mapping sourceId="3dae0c77-ce9d-4215-a029-fabee689b998" category="portal:AODN"></mapping>
           <mapping sourceId="8b7742a7-705f-42ce-9db9-3dbe34fd39c1" category="portal:WAMSI"></mapping>
           <mapping sourceId="1d54120f-ab3f-409f-959a-03580d2827f2" category="portal:AODN"></mapping>
           <mapping sourceId="08be49a2-78e8-401b-8c8f-6f1417dd9185" category="portal:AODN"></mapping>
           <mapping sourceId="7ee2e527-efae-405a-b36e-a49183d60ece" category="portal:DSTO"></mapping>
           <mapping sourceId="96425e8d-d1e1-4bd0-92d9-b9b2f3d2fbeb" category="portal:AAD"></mapping>
           <mapping sourceId="052d79e4-be0b-4124-81a4-724a5862c40a" category="portal:AAD"></mapping>
           <mapping sourceId="794c8c8e-fa0b-47c8-b962-3d992de2fdd4" category="portal:AIMS"></mapping>
           <mapping sourceId="b230d39a-c1cb-4efa-bbad-174b8d74fba0" category="portal:IMAS"></mapping>
           <mapping sourceId="11caadf5-d52e-46c1-b227-e6bfbca0b919" category="portal:OEH"></mapping>
           <mapping sourceId="99ea3014-8de8-4cae-ad39-b59b5dcc93c5" category="portal:UWA"></mapping>
           <mapping sourceId="a4cc61f5-ec10-41b4-90ae-e72bb9ca278b" category="portal:ACE"></mapping>
           <mapping sourceId="e0f13c0c-5473-4959-8c08-6767edf8ce2c" category="portal:AODN"></mapping>
           <mapping sourceId="3961fb14-12fb-4575-9ee2-386e66f8bfc6" category="portal:NIWA"></mapping>
           <mapping sourceId="9707b912-1ddd-463f-a57f-487482b71e94" category="portal:AIMS"></mapping>
           <mapping sourceId="a79ab1a1-0afe-4cae-b6f8-e8a058d74508" category="portal:RLS"></mapping>
           <mapping sourceId="ba266bbb-5dba-40a5-9a96-deadd823c5ca" category="portal:GA"></mapping>
           <mapping sourceId="b4f8e3b8-f527-42fd-9966-030139513c64" category="portal:GA"></mapping>
           <mapping sourceId="4c677113-1875-4a3d-b7e8-84d6d2f019ce" category="portal:IMAS"></mapping>
           <mapping sourceId="69739489-42f5-4ed0-af75-c6c0aefa8db0" category="portal:IMAS"></mapping>
           <mapping sourceId="bf5999d9-8c47-408e-a25b-19fc898ab39d" category="portal:IMAS"></mapping>
           <mapping sourceId="997c2ceb-a58a-4df6-8dd5-2fbb09111809" category="portal:IMAS"></mapping>
           <mapping sourceId="ed23e365-c459-4aa4-bbc1-5d2cd0274af0" category="portal:IMOS"></mapping>
           <mapping sourceId="b6718c9f-f6e6-467e-8721-01efbc00b7da" category="portal:OEH"></mapping>
           <mapping sourceId="8fc19f74-e4bc-4401-9103-00b3624aefba" category="portal:OEH"></mapping>
           <mapping sourceId="cb4f24e1-4e60-420d-8eac-ad57f9c070fd" category="portal:NOAA"></mapping>
           <mapping sourceId="fa56df7a-6a9c-4ead-a191-36fdf8faba5c" category="portal:RAN"></mapping>
       </mappings>
   </xsl:variable>
    
    <xsl:template match="/">
        <xsl:for-each select="response/metadata">
            <xsl:variable name="source_uuid" select="source"/>
            <xsl:value-of select="concat(*/uuid, ',', source, string($mapping/mappings/mapping[@sourceId=$source_uuid]/@category), '&#x0A;')"/>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
```

Note: XSL files needs to be updated if sourceId are changed.