<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:gml="http://www.opengis.net/gml"
    exclude-result-prefixes="xs"
    version="2.0">

    <!-- XSL to add required gml:id attributes to gml:Polygons that don't have them in MCP 2.0 metadata -->

    <!-- Default rule - copy node -->

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Add gml:id to all gml:Polygons which don't have one -->
    <xsl:template match="gml:Polygon[not(@gml:id)]">
        <xsl:copy>
            <xsl:attribute name="gml:id" select="concat('polygon-',generate-id())"/>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
