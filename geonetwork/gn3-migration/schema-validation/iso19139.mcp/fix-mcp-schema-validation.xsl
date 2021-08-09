<?xml version="1.0" encoding="UTF-8"?>

<!-- Fix ups for iso19139.mcp -->

<!-- Records using http://bluenet3.antcrc.utas.edu.au/mcp-1.5-experimental/schema.xsd -->
<!-- These are not validated -->
<!-- e76a13e0-3402-11dc-849f-00188b4c0af8 -->
<!-- 0292f830-723d-11dc-a0c6-00188b4c0af8 -->

<!-- Templates -->
<!-- e8c0865c-8493-4dd8-b9f6-0da85055bd57 -->

<xsl:stylesheet   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    xmlns:gml="http://www.opengis.net/gml"
    xmlns:gco="http://www.isotc211.org/2005/gco"
    xmlns:gmd="http://www.isotc211.org/2005/gmd"
    xmlns:mcp="http://bluenet3.antcrc.utas.edu.au/mcp">
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*"/>
    
    <!-- identity transform -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Element `<gmd:aggregateDataSetIdentifier><gmd:MD_Identifier/>` missing child nodes is updated with nilReason -->
    <xsl:template match="gmd:aggregateDataSetIdentifier[gmd:MD_Identifier[not(*)]]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gmd:aggregateDataSetIdentifier/gmd:MD_Identifier missing child nodes is updated with nilReason')" />
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>
  
    <!-- `<gco:Integer/> Invalid integer value. Remove invalid characters -->
    <xsl:template match="gco:Integer[not(number(.))]/text()">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gco:Integer Invalid integer value. Remove invalid characters')" />
        <xsl:value-of select="replace(., '[^0-9\-]', '')"/>
    </xsl:template>
    
    <!-- `<gco:Real/> missing value. Apply nilReason and remove <gco:Real/> -->
    <xsl:template match="//gmd:maximumValue[gco:Real[not(node())]]|//gmd:minimumValue[gco:Real[not(node())]]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gco:Real missing value. Apply nilReason and remove gco:Real')" />
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>
    
    <!-- gco:Real value is not a number -->
    <xsl:template match="//gmd:minimumValue[gco:Real[string(number(node())) = 'NaN']]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gco:Real value is not a number')" />
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>
    
    <!-- Element `<gco:Date/>` missing value -->
    <xsl:template match="gmd:CI_Date/gmd:date[gco:Date = '']|gmd:dateOfNextUpdate[gco:Date = '']">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gco:Date missing value')" />
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>   
    
    <!-- gco:DateTime missing date removed and labelled missing -->
    <xsl:template match="gmd:plannedAvailableDateTime[gco:DateTime[text()[substring-before(.,'T') = '']]]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gco:DateTime missing date removed and labelled missing')" />
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>    
    
    <!-- `<gco:Decimal/> missing value. Apply nilReason and remove <gco:Decmimal/> -->
    <xsl:template match="//gmd:westBoundLongitude[gco:Decimal[not(node())]]|
        //gmd:eastBoundLongitude[gco:Decimal[not(node())]]|
        //gmd:southBoundLatitude[gco:Decimal[not(node())]]|
        //gmd:northBoundLatitude[gco:Decimal[not(node())]]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gco:Decimal missing value. Apply nilReason and remove gco:Decmimal')" />
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>  
    
    <!-- Element <gmd:graphicOverview> missing <fileName> node is added with nilReason -->
    <xsl:template match="gmd:MD_BrowseGraphic[not(gmd:fileName)]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gmd:graphicOverview missing fileName node is added with nilReason')" />
        <xsl:copy>
            <gmd:fileName gco:nilReason="missing" />
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>
    
    <!-- Element gml:VerticalCRS missing child verticalDatum or usesVerticalDatum -->
    <xsl:template match="gml:VerticalCRS">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gml:VerticalCRS missing child verticalDatum or usesVerticalDatum')" />
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <xsl:if test="not(./gml:usesVerticalDatum) and not(./gml:verticalDatum)">
                <gml:usesVerticalDatum nilReason="missing"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <!-- Element gmd:EX_VerticalExtent missing gmd:minimumValue, maximumValue and verticalCRS  -->
    <xsl:template match="gmd:EX_VerticalExtent[not(gmd:minimumValue) and not(gmd:maximumValue) and not(gmd:verticalCRS)]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gmd:EX_VerticalExtent missing gmd:minimumValue, maximumValue and verticalCRS')" />
        <xsl:copy>
            <gmd:minimumValue gco:nilReason="missing" />
            <gmd:maximumValue gco:nilReason="missing" />
            <gmd:verticalCRS gco:nilReason="missing" />
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template> 
    
    <!-- Element gmd:EX_VerticalExtent missing verticalCRS  -->
    <xsl:template match="gmd:EX_VerticalExtent[not(gmd:verticalCRS) and gmd:minimumValue and gmd:maximumValue]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gmd:EX_VerticalExtent missing verticalCRS')" />
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <gmd:verticalCRS gco:nilReason="missing" />
        </xsl:copy>
    </xsl:template>     
    
    <!-- Element `<gco:DateTime/>` missing value -->
    <xsl:template match="gmd:CI_Date/gmd:date[gco:DateTime = '']">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gco:DateTime` missing value')" />
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>
    
    <!-- Element `gmd:dateStamp/gco:DateTime missing value -->
    <xsl:template match="gmd:dateStamp[gco:DateTime = '']">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gmd:dateStamp/gco:DateTime missing value')" />
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>   
    
    <!-- gco:DateTime missing time replaced with gco:Date -->
    <!-- Non ISO date formats corrected -->
    <xsl:template match="gco:DateTime[text()[not(contains(., 'T'))]]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gco:DateTime missing time replaced with gco:Date')" />
        <xsl:choose>
            <xsl:when test=".='1/2/2015'">
                <!-- 
                    0bef875d-5f77-4b31-bd56-de73fafc2b2e
                    c5a37946-a6cc-463e-be28-711b785d0f9f
                    da7dba82-ef56-426a-bb19-843e5e7e72d8
                -->
                <gco:Date><xsl:value-of select="'2015-02-01'"/></gco:Date>
            </xsl:when>
            <xsl:when test="'.=1/1/2015'">
                <!--
                    45c37065-6aeb-4f31-b107-1a39a977df6f
                    4dae96c7-5be0-4b1d-9a01-160812886a91
                -->
                <gco:Date><xsl:value-of select="'2015-01-01'"/></gco:Date>
            </xsl:when>
            <xsl:when test="'.=2/2/2015'">
                <!--
                    d3169300-ba62-4ac1-823a-0bc43909f8e7
                -->
                <gco:Date><xsl:value-of select="'2015-02-02'"/></gco:Date>
            </xsl:when>
            <xsl:when test="'.=1/2/2008'">
                <!--
                    7d0b4a53-1863-4600-92a4-d385c88e9be9
                -->
                <gco:Date><xsl:value-of select="'2008-02-01'"/></gco:Date>
            </xsl:when>
            <xsl:otherwise>
                <gco:Date><xsl:value-of select="."/></gco:Date>                
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>    
    
    <!-- Element `<gco:Integer/>` missing value -->
    <xsl:template match="gmd:denominator[gco:Integer = '']|gmd:numberOfDimensions[gco:Integer = '']|gmd:dimensionSize[gco:Integer = '']">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gco:Integer missing value')" />
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>     
    
    <!-- Element `<gco:Boolean/>` missing value -->
    <xsl:template match="gmd:transformationParameterAvailability[gco:Boolean = '']">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gco:Boolean missing value')" />
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>    

    <!-- Element mcp:MD_DataIdentification missing gmd:language -->
<!--    <xsl:template match="mcp:MD_DataIdentification[not(./gmd:language)]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <gmd:language gco:nilReason="missing"/>
        </xsl:copy>
    </xsl:template>
    -->
    
    <!-- mcp:MD_DataIdentification missing gmd:language  Add in correct order -->
    <xsl:template match="mcp:MD_DataIdentification[not(gmd:language)]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','mcp:MD_DataIdentification missing gmd:language  Add in correct order')" />
        <xsl:copy>
            <xsl:apply-templates select="@*" />
            <xsl:for-each select="node()">
                <xsl:choose>
                    <xsl:when test="not(self::gmd:characterSet)">
                        <xsl:apply-templates select="." />
                    </xsl:when>
                    <xsl:otherwise>
                        <gmd:language gco:nilReason="missing" />
                        <xsl:copy-of select="." />
                    </xsl:otherwise>
                </xsl:choose>          
            </xsl:for-each>
        </xsl:copy>        
    </xsl:template>    

    <!-- Element gmd:EX_BoundingPolygon missing children -->
    <xsl:template match="gmd:EX_BoundingPolygon[not(*)]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gmd:EX_BoundingPolygon missing children')" />
        <xsl:copy>
            <gmd:polygon gco:nilReason="missing" />
        </xsl:copy>
    </xsl:template>
    
    <!-- Element gmd:CI_Citation missing gmd:date -->
    <xsl:template match="gmd:CI_Citation[.!='' and not(gmd:date)]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gmd:CI_Citation missing gmd:date')" />
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <gmd:date gco:nilReason="missing" />
        </xsl:copy>
    </xsl:template>
    
    <!-- Element gmd:CI_Citation missing gmd:title -->
    <xsl:template match="gmd:CI_Citation[.!='' and not(gmd:title)]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gmd:CI_Citation missing gmd:title')" />
        <xsl:copy>
            <gmd:title gco:nilReason="missing" />
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>
    
    <!-- Element gmd:CI_Citation empty -->
    <xsl:template match="gmd:CI_Citation[.='']">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gmd:CI_Citation empty')" />
        <xsl:copy>
            <gmd:title gco:nilReason="missing" />
            <gmd:date gco:nilReason="missing" />
        </xsl:copy>
    </xsl:template>    
 
    <!-- Element gmd:MD_TopicCategoryCode missing value -->
    <xsl:template match="gmd:topicCategory[gmd:MD_TopicCategoryCode = '']">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gmd:MD_TopicCategoryCode missing value')" />
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="gmd:topicCategory/gmd:MD_TopicCategoryCode[. = '']" />
    
    <!-- Element gmd:MD_Keywords missing gmd:keyword -->
    <xsl:template match="//gmd:MD_Keywords[not(gmd:keyword)]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gmd:MD_Keywords missing gmd:keyword')" />
        <xsl:copy>
            <gmd:keyword gco:nilReason="missing" />
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>  
    
    <!-- Element gmd:EX_GeographicDescription missing all children -->
    <xsl:template match="//gmd:geographicElement[gmd:EX_GeographicDescription[not(gmd:extentTypeCode) and not(gmd:geographicIdentifier)]]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gmd:EX_GeographicDescription missing all children')" />
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>   
    
    <!-- <gmd:MD_TopicCategoryCode>climatology/meteorology/atmosphere</gmd:MD_TopicCategoryCode> not in enumeration -->
    <xsl:template match="//gmd:MD_TopicCategoryCode[text() = 'climatology/meteorology/atmosphere']">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gmd:MD_TopicCategoryCode climatology/meteorology/atmosphere not in enumeration')" />
        <xsl:copy>
            <xsl:value-of select="'climatologyMeteorologyAtmosphere'"/>
        </xsl:copy>
    </xsl:template>  
    

</xsl:stylesheet>