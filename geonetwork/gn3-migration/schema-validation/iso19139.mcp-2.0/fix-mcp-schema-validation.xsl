<?xml version="1.0" encoding="UTF-8"?>

<!-- Fix ups for iso19139.mcp-2.0 -->


<xsl:stylesheet   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:gml="http://www.opengis.net/gml"
    xmlns:gco="http://www.isotc211.org/2005/gco"
    xmlns:gmd="http://www.isotc211.org/2005/gmd"
    xmlns:mcp="http://schemas.aodn.org.au/mcp-2.0"
    xmlns:gmx="http://www.isotc211.org/2005/gmx"
    xmlns:xlink="http://www.w3.org/1999/xlink">
    
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
    <xsl:template match="gco:DateTime[text()[not(contains(., 'T'))]]">
        <gco:Date><xsl:value-of select="."/></gco:Date>
    </xsl:template>
    
    <!-- gco:DateTime which is a date has invalid children replaced with gco:Date. Make sure the content is a date and not datetime -->
    <xsl:template match="gco:DateTime[gco:Date[not(text()[contains(., 'T')])]]">
        <xsl:copy-of select="gco:Date" />
    </xsl:template> 
    
    <xsl:template match="gmx:Anchor/@xlink:href">
        <xsl:attribute name="xlink:href" select="concat(substring-before(.,'?'),'?',encode-for-uri(substring-after(.,'?')))"/>
    </xsl:template>
    

</xsl:stylesheet>