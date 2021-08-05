<?xml version="1.0" encoding="UTF-8"?>

<!-- Templates -->
<!-- d6cf3c60-9f49-4fb5-9125-27043dc9e7e9 -->
<!-- 308784f4-11ac-45f5-a489-078044420c33 -->

<!-- Fix ups for iso19139.mcp-1.4 -->

<xsl:stylesheet   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
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
    
    <!-- iso19139.mcp-1.4 Element <gm1:verticalCRS/>. Add <gml:verticalCS/> and <gml:verticalDatum/> -->
<!--    <xsl:template match="gml:VerticalCRS[not(gml:verticalCS) and not(gml:verticalDatum)]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />      
            <gml:verticalCS />
            <gml:verticalDatum />
        </xsl:copy>
    </xsl:template>
--> 

    <!-- Element `<gmd:EX_VerticalExtent>` missing <gmd:verticalCRS> is added with nilReason -->
    <xsl:template match="gmd:EX_VerticalExtent[not(gmd:verticalCRS)]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <gmd:verticalCRS gco:nilReason="missing" />
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
    
    <!-- iso19139.mcp-1.4 Element <gm1:verticalCRS/>. Add <gml:verticalDatum/> -->
    <xsl:template match="gml:VerticalCRS[not(gml:verticalDatum)]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />      
            <gml:verticalDatum />
        </xsl:copy>
    </xsl:template>
    
    <!-- Element `<gmd:CI_Date/>` missing <gmd:date> is added with nilReason -->
    <xsl:template match="gmd:CI_Date[not(gmd:date)]">
        <xsl:copy>
            <gmd:date gco:nilReason="missing" />
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>
    
    <!-- Element `<gco:Date/>` missing value -->
    <xsl:template match="gmd:CI_Date/gmd:date[gco:Date = '']">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>  
    
    <!-- Element `<gco:DateTime/>` missing value -->
    <xsl:template match="gmd:CI_Date/gmd:date[gco:DateTime = '']">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>   
    
    <!-- Element `<gco:DateTime/>` missing value -->
    <xsl:template match="gmd:dateStamp[gco:DateTime = '']">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>  

    <!-- gco:DateTime missing time replaced with gco:Date -->
    <xsl:template match="gco:DateTime[text()[not(contains(., 'T'))]]">
        <gco:Date><xsl:value-of select="."/></gco:Date>
    </xsl:template>
    
    <!-- Element `<gco:Integer/>` missing value -->
    <xsl:template match="gmd:denominator[gco:Integer = '']">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>    
    
    <!-- Element `<gmd:EX_BoundingPolygon>` missing <gmd:polygon> is added with nilReason -->
    <xsl:template match="gmd:EX_BoundingPolygon[not(gmd:polygon)]">
        <xsl:copy>
            <gmd:polygon gco:nilReason="missing" />
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>

    <!-- `<gco:Decimal/> missing value. Apply nilReason and remove <gco:Decimal/>-->
    <xsl:template match="gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude|gmd:eastBoundLongitude|gmd:southBoundLatitude|gmd:northBoundLatitude[gco:Decimal='']">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>
    
    <!-- `<gco:Real/> missing value. Apply nilReason and remove <gco:Real/> -->
    <xsl:template match="//gmd:maximumValue[gco:Real[not(node())]]|//gmd:minimumValue[gco:Real[not(node())]]">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>  
    
    <!-- <gmd:minimumValue> or <gmd:maximumValue> invalid 'n/a' value. Apply nilReason and remove <gco:Real/> -->
    <xsl:template match="//gmd:maximumValue[gco:Real = 'n/a']|//gmd:minimumValue[gco:Real = 'n/a']">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>     
    
    <!-- More than one mcp:dataParameters.  Move the parameters into the first. -->
    <xsl:template match="mcp:dataParameters[following-sibling::mcp:dataParameters][1]/mcp:DP_DataParameters">
        <xsl:variable name="container" select="."/>
        <xsl:variable name="dataParameters" select="parent::node()/following-sibling::mcp:dataParameters/mcp:DP_DataParameters/mcp:dataParameter"/>
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <xsl:for-each select="$dataParameters">
                <xsl:copy-of select="."/>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="mcp:dataParameters[position()>1]" /> 
    

</xsl:stylesheet>