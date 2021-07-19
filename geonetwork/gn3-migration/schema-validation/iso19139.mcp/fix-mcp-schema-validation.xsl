<?xml version="1.0" encoding="UTF-8"?>

<!-- Fix ups for iso19139.mcp -->

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
    
    <!-- Element `<gmd:aggregateDataSetIdentifier><gmd:MD_Identifier/>` missing child nodes is updated with nilReason -->
    <xsl:template match="gmd:aggregateDataSetIdentifier[gmd:MD_Identifier[not(*)]]">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>
    
    <!-- `<gco:Integer/> missing value. Apply nilReason and remove <gco:Integer/>-->
    <xsl:template match="gmd:MD_RepresentativeFraction/gmd:denominator[gco:Integer='']">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>
    
    <!-- `<gco:Integer/> Invalid integer value. Remove invalid characters -->
    <xsl:template match="gco:Integer[not(number(.))]/text()">
        <xsl:value-of select="replace(., '[^0-9]', '')"/>
    </xsl:template>
    
    <!-- `<gco:Real/> missing value. Apply nilReason and remove <gco:Real/> -->
    <xsl:template match="//gmd:maximumValue[gco:Real[not(node())]]|//gmd:minimumValue[gco:Real[not(node())]]">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>    
    
    <!-- Element <gmd:graphicOverview> missing <fileName> node is added with nilReason -->
    <xsl:template match="gmd:MD_BrowseGraphic[not(gmd:fileName)]">
        <xsl:copy>
            <gmd:fileName gco:nilReason="missing" />
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>    
    
    <!-- Element `<gmd:CI_Citation/>. Swap ordering of <gmd:citedResponsibleParty> and <gmd:identifier> if both present and <gmd:identifier> follows <gmd:citedResponsibleParty> -->
    <!-- TODO -->
<!--    <xsl:template match = "gmd:CI_Citation[gmd:citedResponsibleParty[following-sibling::gmd:identifier]]">-->
<!--        <xsl:copy>-->
<!--            <xsl:apply-templates select="@* | node()" />      -->
<!--            <xsl:apply-templates select="gmd:identifier, gmd:citedResponsibleParty"/>-->
<!--        </xsl:copy> -->
<!--    </xsl:template>-->

</xsl:stylesheet>