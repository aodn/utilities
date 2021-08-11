<?xml version="1.0" encoding="UTF-8"?>

<!-- Fix ups for iso19139.mcp-1.4 -->

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
  

    <!-- iso19139.mcp-1.4 Element <gmd:verticalCRS/>. Replace <gml:usesVerticalDatum/> with <gml:verticalCS/> and <gml:verticalDatum/> -->
<!--    <xsl:template match="gml:VerticalCRS[gml:usesVerticalDatum and not(gml:verticalCS) and not(gml:verticalDatum)]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />      
            <gml:verticalCS />
            <gml:verticalDatum />
        </xsl:copy>
    </xsl:template>
    <xsl:template match="gml:VerticalCRS[gml:usesVerticalDatum and not(gml:verticalCS) and not(gml:verticalDatum)]/gml:usesVerticalDatum" /> 
-->
    
    <!-- iso19139.mcp-1.4 Element <gm1:VerticalCRS/>. Add <gml:verticalCS/> and <gml:verticalDatum/> -->
<!--    <xsl:template match="gml:VerticalCRS[not(gml:verticalCS) and not(gml:verticalDatum)]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />      
            <gml:verticalCS />
            <gml:verticalDatum />
        </xsl:copy>
    </xsl:template>
--> 
    
    <!-- <gm1:VerticalCRS/>. Empty gml:identifier and gml:scope. Remove gml:identifier gml:scope and set nilReason -->
    <xsl:template match="gmd:verticalCRS[gml:VerticalCRS[gml:scope='' and gml:identifier='']]">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>       
        </xsl:copy>
    </xsl:template>

    <!-- Element `<gmd:EX_VerticalExtent>` missing <gmd:verticalCRS> is added with nilReason -->
    <xsl:template match="gmd:EX_VerticalExtent[not(gmd:verticalCRS)]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gmd:EX_VerticalExtent missing gmd:verticalCRS is added with nilReason')" />
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <gmd:verticalCRS gco:nilReason="missing" />
        </xsl:copy>
    </xsl:template>

    <!-- mcp:EX_TemporalExtent time period missing gmd:extent -->
    <xsl:template match="mcp:EX_TemporalExtent[not(gmd:extent) and mcp:beginTime[following-sibling::mcp:endTime]]" >
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','mcp:EX_TemporalExtent time period missing gmd:extent')" />
        <xsl:copy>
            <xsl:apply-templates select="@*" />
            <gmd:extent>
                <gml:TimePeriod gml:id='a'>
                    <gml:begin>
                        <gml:TimeInstant gml:id='b'>
                            <gml:timePosition>
                                <xsl:value-of select="mcp:beginTime" />
                            </gml:timePosition>
                        </gml:TimeInstant>
                    </gml:begin>
                    <gml:end>
                        <gml:TimeInstant gml:id='c'>
                            <gml:timePosition>
                                <xsl:value-of select="mcp:endTime" />
                            </gml:timePosition>
                        </gml:TimeInstant>
                    </gml:end>
                </gml:TimePeriod>
            </gmd:extent>
        </xsl:copy>
    </xsl:template>
    
    <!-- Element `<gml:VerticalCRS>` remove extra <gm1:verticalCS> -->
<!--    <xsl:template match="gmd:verticalCRS/gml:VerticalCRS[gml:usesVerticalCS][gml:verticalCS='']">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>
    <xsl:template match="gmd:verticalCRS/gml:VerticalCRS[gml:usesVerticalCS][gml:verticalCS='']/gml:verticalCS" />    
-->    
    
    <!-- iso19139.mcp-1.4 Element <gml:verticalCRS/>. Add <gml:verticalDatum/> -->
    <xsl:template match="gml:VerticalCRS[@gml:id='balderdash' and not(gml:verticalDatum)]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gml:verticalCRS. Add gml:verticalDatum')" />
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <gml:verticalDatum />
        </xsl:copy>
    </xsl:template>
    
    <!-- Element `<gmd:CI_Date/>` missing <gmd:date> is added with nilReason -->
    <xsl:template match="gmd:CI_Date[not(gmd:date)]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gmd:CI_Date missing gmd:date is added with nilReason')" />
        <xsl:copy>
            <gmd:date gco:nilReason="missing" />
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>
    
    <!-- gmd:CI_ResponsibleParty missing gmd:role -->
    <xsl:template match="gmd:CI_ResponsibleParty[not(gmd:role)]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gmd:CI_ResponsibleParty missing gmd:role')" />
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <gmd:role gco:nilReason="missing" />
        </xsl:copy>        
    </xsl:template>
    
    <!-- Element `<gco:Date/>` missing value -->
    <xsl:template match="gmd:CI_Date/gmd:date[gco:Date = '']">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gco:Date missing value')" />
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>  
    
    <!-- Element `<gco:DateTime/>` missing value -->
    <xsl:template match="gmd:CI_Date/gmd:date[gco:DateTime = '']">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gco:DateTime missing value')" />
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>   
    
    <!-- Element `<gco:DateTime/>` missing value -->
    <xsl:template match="gmd:dateStamp[gco:DateTime = '']">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gco:DateTime missing value')" />
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>  

    <!-- gco:DateTime missing time replaced with gco:Date -->
    <xsl:template match="gco:DateTime[text()[not(contains(., 'T'))]]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gco:DateTime missing time replaced with gco:Date')" />
        <gco:Date><xsl:value-of select="."/></gco:Date>
    </xsl:template>
    
    <!-- Element `<gco:Integer/>` missing value -->
    <xsl:template match="gmd:denominator[gco:Integer = '']">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gco:Integer missing value',',post manual check?')" />
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>    
    
    <!-- Element `<gmd:EX_BoundingPolygon>` missing <gmd:polygon> is added with nilReason -->
    <xsl:template match="gmd:EX_BoundingPolygon[not(gmd:polygon)]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gmd:EX_BoundingPolygon missing gmd:polygon is added with nilReason')" />
        <xsl:copy>
            <gmd:polygon gco:nilReason="missing" />
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>
    
    <!-- Element `<gmd:DQ_Scope>` missing <gmd:level> is added with nilReason -->
    <xsl:template match="gmd:DQ_Scope[not(gmd:level)]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gmd:DQ_Scope missing gmd:level is added with nilReason')" />
        <xsl:copy>
            <gmd:level gco:nilReason="missing" />
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>

    <!-- `<gco:Decimal/> missing value. Apply nilReason and remove <gco:Decimal/>-->
    <xsl:template match="gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude|gmd:eastBoundLongitude|gmd:southBoundLatitude|gmd:northBoundLatitude[gco:Decimal='']">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gco:Decimal missing value. Apply nilReason and remove gco:Decimal',',post manual values enter?')" />
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>
    
    <!-- `<gco:Real/> missing value. Apply nilReason and remove <gco:Real/> -->
    <xsl:template match="//gmd:maximumValue[gco:Real[not(node())]]|//gmd:minimumValue[gco:Real[not(node())]]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gco:Real missing value. Apply nilReason and remove gco:Real',',post manual check?')" />
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>  
    
    <!-- <gmd:minimumValue> or <gmd:maximumValue> invalid 'n/a' value. Apply nilReason and remove <gco:Real/> -->
    <xsl:template match="//gmd:maximumValue[gco:Real = 'n/a']|//gmd:minimumValue[gco:Real = 'n/a']">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gmd:minimumValue or gmd:maximumValue invalid na value. Apply nilReason and remove gco:Real',',check and fix? before transform')" />
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>     
    
    <!-- More than one mcp:dataParameters.  Move the parameters into the first. -->
    <xsl:template match="mcp:dataParameters[following-sibling::mcp:dataParameters[1]]/mcp:DP_DataParameters">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','More than one mcp:dataParameters.  Move the parameters into the first',',check before transform')" />
        <xsl:variable name="dataParameters" select="parent::node()/following-sibling::mcp:dataParameters/mcp:DP_DataParameters/mcp:dataParameter"/>
        <xsl:copy>v
            <xsl:apply-templates select="@* | node()" />
            <xsl:for-each select="$dataParameters">
                <xsl:copy-of select="."/>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="mcp:dataParameters[position()>1]" />

    <!-- mcp:DP_DataParameter missing mcp:parameterUnits. Add with nilReason-->
    <xsl:template match="mcp:DP_DataParameter[not(mcp:parameterUnits) and mcp:parameterMinimumValue and mcp:parameterMaximumValue]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','mcp:DP_DataParameter missing mcp:parameterUnits. Add with nilReason')" />
        <xsl:copy>
            <xsl:apply-templates select="@*" />
            <xsl:for-each select="node()">
                <xsl:choose>
                    <xsl:when test="not(self::mcp:parameterMinimumValue)">
                        <xsl:apply-templates select="." />
                    </xsl:when>
                    <xsl:otherwise>
                        <mcp:parameterUnits gco:nilReason="missing" />
                        <xsl:copy-of select="." />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    
    <!-- mcp:DP_DataParameter missing mcp:parameterUnits, mcp:parameterMinimumValue and mcp:parameterMaximumValue. Add with nilReason-->
    <xsl:template match="mcp:DP_DataParameter[not(mcp:parameterUnits) and not(mcp:parameterMinimumValue) and not(mcp:parameterMaximumValue)]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','mcp:DP_DataParameter missing mcp:parameterUnits, mcp:parameterMinimumValue and mcp:parameterMaximumValue. Add with nilReason')" />
        <xsl:copy>
            <xsl:apply-templates select="@*" />
            <xsl:for-each select="node()">
                <xsl:choose>
                    <xsl:when test="not(self::mcp:parameterDescription)">
                        <xsl:apply-templates select="." />
                    </xsl:when>
                    <xsl:otherwise>
                        <mcp:parameterUnits gco:nilReason="missing" />
                        <mcp:parameterMinimumValue gco:nilReason="missing" />
                        <mcp:parameterMaximumValue gco:nilReason="missing" />
                        <xsl:copy-of select="." />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>   
    
    <!-- mcp:DP_DataParameter missing mcp:parameterMinimumValue and mcp:parameterMaximumValue. Add with nilReason-->
    <xsl:template match="mcp:DP_DataParameter[mcp:parameterUnits and not(mcp:parameterMinimumValue) and not(mcp:parameterMaximumValue)]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','mcp:DP_DataParameter missing mcp:parameterMinimumValue and mcp:parameterMaximumValue. Add with nilReason')" />
        <xsl:copy>
            <xsl:apply-templates select="@*" />
            <xsl:for-each select="node()">
                <xsl:choose>
                    <xsl:when test="not(self::mcp:parameterDescription)">
                        <xsl:apply-templates select="." />
                    </xsl:when>
                    <xsl:otherwise>
                        <mcp:parameterMinimumValue gco:nilReason="missing" />
                        <mcp:parameterMaximumValue gco:nilReason="missing" />
                        <xsl:copy-of select="." />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>      
   
   <!-- gmd:LI_Lineage has more than one gmd:statement Combine into one -->
    <xsl:template match="gmd:LI_Lineage[gmd:statement[following-sibling::gmd:statement]]/gmd:statement[1]">
        <xsl:message select="concat(base-uri(),',',replace(path(),'Q\{[^}]*\}',''),',',base-uri(document('')),',','gmd:LI_Lineage has more than one gmd:statement Combine into one')" />
        <xsl:copy>
            <gco:CharacterString>
                <xsl:value-of select="concat(.,./following-sibling::gmd:statement)" />
            </gco:CharacterString>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="gmd:LI_Lineage/gmd:statement[position()>1]" />    
    
<!--    
    <gmd:LI_Lineage>
        <gmd:statement>
            <gco:CharacterString>Original record compiled for the Western Australian Marine Science Institution (WAMSI), Project 3.8, 2008. Originally sourced from several databases compiled by WA DEC Marine Science Branch of projects relevant to the marine parks of WA. Variable metadata information was available.</gco:CharacterString>
        </gmd:statement>
        <gmd:statement>
            <gco:CharacterString>The following data was collected from surveys and other sources: * Site attributes (fish stocks, coral health, accessibility, scenery, distance or closeness to camping sites, etc.) * Recreational activity data (site choice, fishing expenditure, fishing gear, trip expenses, expectations about site attributes, etc.) * Individual socio-economic data (employment status, income, age, education, household size, etc.)</gco:CharacterString>
        </gmd:statement>
    </gmd:LI_Lineage>
-->

</xsl:stylesheet>