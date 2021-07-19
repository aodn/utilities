<?xml version="1.0" encoding="UTF-8"?>

<!-- Fix ups for iso19139.mcp-1.4 -->

<xsl:stylesheet   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:gml="http://www.opengis.net/gml"
    xmlns:gco="http://www.isotc211.org/2005/gco"
    xmlns:gmd="http://www.isotc211.org/2005/gmd"
    xmlns:mcp="http://schemas.aodn.org.au/mcp-2.0"
    exclude-result-prefixes="#all">
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*"/>
    
    <!-- identity transform -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- iso19139.mcp-1.4 Element <gmd:verticalCRS/>. Replace <gml:usesVerticalDatum/> with <gml:verticalCS/> and <gml:verticalDatum/> -->
    <xsl:template match="gml:VerticalCRS[gml:usesVerticalDatum and not(gml:verticalCS) and not(gml:verticalDatum)]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />      
            <gml:verticalCS />
            <gml:verticalDatum />
        </xsl:copy>
    </xsl:template>
    <xsl:template match="gml:VerticalCRS[gml:usesVerticalDatum and not(gml:verticalCS) and not(gml:verticalDatum)]/gml:usesVerticalDatum" />
    
    <!-- iso19139.mcp-1.4 Element <gm1:verticalCRS/>. Add <gml:verticalCS/> and <gml:verticalDatum/> -->
    <xsl:template match="gml:VerticalCRS[not(gml:verticalCS) and not(gml:verticalDatum)]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />      
            <gml:verticalCS />
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
    
    <!-- Element `<gmd:EX_VerticalExtent>` missing <gmd:verticalCRS> is added with nilReason -->
    <xsl:template match="gmd:EX_VerticalExtent[not(gmd:verticalCRS)]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <gmd:verticalCRS gco:nilReason="missing" />
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>