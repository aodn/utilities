<?xml version="1.0" encoding="UTF-8"?>

<!-- Fix ups for iso19139.mcp -->

<xsl:stylesheet   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    xmlns:gml="http://www.opengis.net/gml"
    xmlns:gco="http://www.isotc211.org/2005/gco"
    xmlns:gmd="http://www.isotc211.org/2005/gmd"
    xmlns:mcp="http://bluenet3.antcrc.utas.edu.au/mcp"
    xmlns:srv="http://www.isotc211.org/2005/srv">
    
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
  
    <!-- gco:Integer Invalid integer value. Remove invalid characters -->
    <xsl:template match="gco:Integer[not(number(.))]/text()">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gco:Integer Invalid integer value. Remove invalid characters',',check and fix before transform')" />
        <xsl:value-of select="replace(., '[^0-9\-]', '')"/>
    </xsl:template>
    
    <!-- `<gco:Real/> missing value. Apply nilReason and remove <gco:Real/> -->
 <!--   <xsl:template match="//gmd:maximumValue[gco:Real[not(node())]]|//gmd:minimumValue[gco:Real[not(node())]]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gco:Real missing value. Apply nilReason and remove gco:Real','post manual values enter?',',check and fix before transform')" />
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template> -->
    
    <!-- gco:Real value is not a number -->
 <!--   <xsl:template match="//gmd:minimumValue[gco:Real[string(number(node())) = 'NaN']]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gco:Real value is not a number')" />
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
    </xsl:template> -->
       
    <!-- `<gco:Real/> missing value. Apply nilReason and remove <gco:Real/> -->
    <xsl:template match="gmd:maximumValue[gco:Real = '']|gmd:minimumValue[gco:Real = '']">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gco:Real missing value. Apply nilReason and remove gco:Real','post manual values enter?',',check and fix before transform')" />
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>
    
    <!-- gco:Real value is not a number -->
    <xsl:template match="gmd:minimumValue[gco:Real = 'NaN']">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gco:Real value is not a number')" />
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>    
    
    <!-- Element gco:Date missing value -->
    <xsl:template match="gmd:CI_Date/gmd:date[gco:Date = '']|gmd:dateOfNextUpdate[gco:Date = '']">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gco:Date missing value')" />
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template> 
    
    <!-- gmd:CI_Date has too many gmd:date. The extras are empty -->
    <xsl:template match="gmd:CI_Date[gmd:date[following-sibling::gmd:date/gco:Date = '']]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gmd:CI_Date had too many gmd:date. The extras are empty')" />
        <xsl:copy>
            <xsl:for-each select="node()">
                <xsl:choose>
                    <xsl:when test="not(self::gmd:date/gco:Date = '')">
                        <xsl:apply-templates select="." />
                    </xsl:when>
                </xsl:choose>          
            </xsl:for-each>            
        </xsl:copy>
    </xsl:template>

    <!-- gco:DateTime missing date removed and labelled missing -->
    <xsl:template match="gmd:plannedAvailableDateTime[gco:DateTime[text()[substring-before(.,'T') = '']]]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gco:DateTime missing date removed and labelled missing',',check and fix? before transform')" />
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>    
    
    <!-- `<gco:Decimal/> missing value. Apply nilReason and remove <gco:Decmimal/> -->
    <xsl:template match="//gmd:westBoundLongitude[gco:Decimal[not(node())]]|
        //gmd:eastBoundLongitude[gco:Decimal[not(node())]]|
        //gmd:southBoundLatitude[gco:Decimal[not(node())]]|
        //gmd:northBoundLatitude[gco:Decimal[not(node())]]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gco:Decimal missing value. Apply nilReason and remove gco:Decmimal',',post manual values enter?')" />
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
    
    <!-- gmd:CI_Date missing gmd:date -->
    <xsl:template match="gmd:CI_Date[not(gmd:date)]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gmd:CI_Date missing gmd:date')" />
        <xsl:copy>
            <gmd:date gco:nilReason="missing" />
            <xsl:apply-templates select="@* | node()" />
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
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gco:DateTime missing time replaced with gco:Date',',check and fix before transform')" />
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
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gco:Integer missing value',',post manual check?')" />
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>     
    
    <!-- Element `<gco:Boolean/>` missing value -->
    <xsl:template match="gmd:transformationParameterAvailability[gco:Boolean = '']">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gco:Boolean missing value',',pre transform check missing/true/false')" />
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>    
    
    <!-- Element `<gco:Boolean/>` missing value -->
    <xsl:template match="gmd:extentTypeCode[gco:Boolean = '']">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gco:Boolean missing value',',pre transform check missing/true/false')" />
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
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','mcp:MD_DataIdentification missing gmd:language  Add in correct order',',check and fix? before transform, make eng?')" />
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
    <xsl:template match="gmd:CI_Citation[not(gmd:date) and not(gmd:alternateTitle) and gmd:title]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gmd:CI_Citation missing gmd:date')" />
        <xsl:copy>
            <xsl:apply-templates select="@*" />
            <xsl:for-each select="node()">
                <xsl:choose>
                    <xsl:when test="self::gmd:title">
                        <xsl:copy-of select="." />                        
                        <gmd:date gco:nilReason="missing" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="." />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:copy>        
    </xsl:template>
    <xsl:template match="gmd:CI_Citation[not(gmd:date) and gmd:alternateTitle and gmd:title]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gmd:CI_Citation missing gmd:date')" />
        <xsl:copy>
            <xsl:apply-templates select="@*" />
            <xsl:for-each select="node()">
                <xsl:choose>
                    <xsl:when test="self::gmd:alternateTitle">
                        <xsl:copy-of select="." />                        
                        <gmd:date gco:nilReason="missing" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="." />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:copy>        
    </xsl:template>

    <!-- mcp:DP_DataParameter missing mcp:parameterMinimumValue, mcp:parameterMaximumValue and mcp:parameterDescription. Add with nilReason -->
<!--    <xsl:template match="mcp:DP_DataParameter[not(mcp:parameterMinimumValue) and not(mcp:parameterMaximumValue) and not(mcp:parameterDescription)]">-->
<!--        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','mcp:DP_DataParameter missing mcp:parameterMinimumValue, mcp:parameterMaximumValue and mcp:parameterDescription. Add with nilReason')" />-->
<!--        <xsl:copy>-->
<!--            <xsl:apply-templates select="@* | node()" />-->
<!--            <mcp:parameterMinimumValue gco:nilReason="missing" />-->
<!--            <mcp:parameterMaximumValue gco:nilReason="missing" />-->
<!--            <mcp:parameterDescription gco:nilReason="missing" />-->
<!--        </xsl:copy>-->
<!--    </xsl:template>-->

    <!-- Element gmd:CI_Citation missing gmd:title -->
    <xsl:template match="gmd:CI_Citation[.!='' and not(gmd:title)]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gmd:CI_Citation missing gmd:title',',check and fix? before transform')" />
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
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gmd:MD_TopicCategoryCode missing value',',make sure there is at least on Topic Category (if none add oceans)')" />
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
    
    <!-- gmd:MD_Keywords has gmd:keyword in wrong order -->
    <!--  THIS IS NOT COMPLETE
    <xsl:template match="gmd:MD_Keywords[gmd:type[following-sibling::gmd:keyword] or gmd:thesaurus[following-sibling::gmd:keyword]]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gmd:MD_Keywords has gmd:keyword in wrong order')" />
        <xsl:copy>
            <xsl:apply-templates select="@*" />
            <xsl:for-each select="node()">
                <xsl:choose>
                    <xsl:when test="self::gmd:keyword">
                        <xsl:apply-templates select="." />
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
            <xsl:for-each select="node()">
                <xsl:choose>
                    <xsl:when test="not(self::gmd:keyword)">
                        <xsl:apply-templates select="." />
                    </xsl:when>
                    <xsl
                </xsl:choose>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>  -->
    
    <!-- gmd:CI_ResponsibleParty has gmd:organisationName in wrong order -->
    <!-- NOT COMPLETE -->
   <!-- <xsl:template match="gmd:CI_ResponsibleParty[gmd:individualName[not(following-sibling::gmd:organisationName)]]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gmd:CI_ResponsibleParty has gmd:organisationName in wrong order')" />
        <xsl:copy>
            <xsl:apply-templates select="@*" />
            <xsl:for-each select="node()">
                <xsl:choose>
                    <xsl:when test="self::gmd:individualName">
                        <xsl:apply-templates select="." />
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>       -->
    
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
    
    <!-- mcp:DP_DataParameter missing mcp:parameterMinimumValue, mcp:parameterMaximumValue and mcp:ParameterDescription. Add with nilReason-->
    <xsl:template match="mcp:DP_DataParameter[mcp:parameterUnits and not(mcp:parameterMinimumValue) and not(mcp:parameterMaximumValue) and not(mcp:parameterDescription)]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','mcp:DP_DataParameter missing mcp:parameterMinimumValue. Add with nilReason')" />
        <xsl:copy>
            <xsl:apply-templates select="@*" />
            <xsl:for-each select="node()">
                <xsl:choose>
                    <xsl:when test="not(self::mcp:parameterUnits)">
                        <xsl:apply-templates select="." />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="." />                        
                        <mcp:parameterMinimumValue gco:nilReason="missing" />
                        <mcp:parameterMaximumValue gco:nilReason="missing" />
                        <mcp:parameterDescription gco:nilReason="missing" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>   

    <!-- gmd:CI_Contact more than one gmd:onlineResource -->
    <!-- element onlineResource: Schemas validity error : Element '{http://www.isotc211.org/2005/gmd}onlineResource': This element is not expected. Expected is one of ( {http://www.isotc211.org/2005/gmd}hoursOfService, {http://www.isotc211.org/2005/gmd}contactInstructions ) -->
    <xsl:template match="gmd:CI_Contact[gmd:onlineResource[following-sibling::gmd:onlineResource]]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gmd:CI_Contact more than one gmd:onlineResource',',correct manually')" />
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>    
    
    <!-- gmd:EX_SpatialTemporalExtent missing gmd:spatialExtent.  Convert to a gmd:EX_TemporalExtent -->
    <xsl:template match="gmd:EX_SpatialTemporalExtent[not(gmd:EX_TemporalExtent)]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gmd:EX_SpatialTemporalExtent missing gmd:spatialExtent.  Convert to a gmd:EX_TemporalExtent')" />
        <gmd:EX_TemporalExtent>
            <xsl:apply-templates select="@* | node()" />
        </gmd:EX_TemporalExtent>
    </xsl:template>
    
    <!-- gmd:EX_TemporalExtent missing gmd:extent and no beginTime or endTime -->
    <xsl:template match="mcp:EX_TemporalExtent[not(gmd:extent) and mcp:beginTime[gco:DateTime = ''] and mcp:endTime[gco:DateTime = '']]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gmd:EX_TemporalExtent missing gmd:extent and no beginTime or endTime')" />
        <xsl:copy>
            <xsl:apply-templates select="@*" />
            <gmd:extent gco:nilReason="missing" />
        </xsl:copy>
    </xsl:template>

<!--    <xsl:template match="mcp:EX_TemporalExtent[not(gmd:extent) and not(mcp:beginTime) and not(mcp:endTime)]">-->
<!--        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gmd:EX_TemporalExtent missing gmd:extent, mcp:beginTime and mcp:endTime')" />-->
<!--        <xsl:copy>-->
<!--            <gmd:extent gco:nilReason="missing" />-->
<!--            <xsl:apply-templates select="@* | node()" />-->
<!--        </xsl:copy>-->
<!--    </xsl:template>-->

    <!-- gmd:identificationInfo has srv:SV_ServiceIdentification, should be gmd:MD_ServiceIdentification -->
    <xsl:template match="gmd:identificationInfo/srv:SV_ServiceIdentification">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gmd:identificationInfo has srv:SV_ServiceIdentification, should be gmd:MD_ServiceIdentification')" />
        <gmd:MD_ServiceIdentification>
            <xsl:apply-templates select="@* | node()" />
        </gmd:MD_ServiceIdentification>
    </xsl:template>
    <xsl:template match="gmd:identificationInfo/srv:SV_ServiceIdentification/srv:couplingType | gmd:identificationInfo/srv:SV_ServiceIdentification/srv:containsOperations" />
    
    <!-- gml:VerticalCS -->

</xsl:stylesheet>