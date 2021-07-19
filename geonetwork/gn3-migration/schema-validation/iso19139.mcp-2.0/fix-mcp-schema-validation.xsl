<?xml version="1.0" encoding="UTF-8"?>

<!-- Fix ups for iso19139.mcp-2.0 -->

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
    
    <!-- Element `<mcp:DP_Term/>` missing <mcp:usedInDataset> is added with nilReason -->
    <xsl:template match="mcp:DP_Term[not(mcp:usedInDataset)]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <mcp:usedInDataset gco:nilReason="missing" />
        </xsl:copy>
    </xsl:template>
    
    <!-- gco:DateTime missing time replaced with gco:Date -->
    <xsl:template match="gco:DateTime[not(text()[contains(., 'T')])]">
        <xsl:copy>
            <gco:Date><xsl:value-of select="."/></gco:Date>
        </xsl:copy>
    </xsl:template>    
    
    

</xsl:stylesheet>