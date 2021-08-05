<?xml version="1.0" encoding="UTF-8"?>

<!-- Fix ups for iso19139 -->

<!-- Templates -->
<!--
    b836f4df-3576-4151-8a89-f92b7e4a48bc
-->

<xsl:stylesheet   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:gml="http://www.opengis.net/gml"
    xmlns:gco="http://www.isotc211.org/2005/gco"
    xmlns:gmd="http://www.isotc211.org/2005/gmd">
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*"/>
    
    <!-- identity transform -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- `<gco:Decimal/> missing value. Apply nilReason and remove <gco:Decimal/>-->
    <xsl:template match="gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude|gmd:eastBoundLongitude|gmd:southBoundLatitude|gmd:northBoundLatitude[gco:Decimal='']">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>
    
    <!-- Element `<gco:DateTime/>` missing value -->
    <xsl:template match="gmd:date[gco:DateTime = '']">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>   

    <!-- Element `<gmd:CI_Date/>` missing <gmd:date> is added with nilReason -->
    <xsl:template match="gmd:CI_Date[not(gmd:date)]">
        <xsl:copy>
            <gmd:date gco:nilReason="missing" />
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>
    
    <!-- Element `<gmd:MD_TopicCategoryCode/>` missing value -->
    <xsl:template match="gmd:topicCategory[gmd:MD_TopicCategoryCode = '']">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>    
    
    <!-- gco:Distance missing value -->
    <xsl:template match="gmd:distance[gco:Distance = '']">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>      
    
</xsl:stylesheet>