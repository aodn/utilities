<?xml version="1.0" encoding="UTF-8"?>

<!-- Fix ups for iso19139 -->

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
    
    <!-- Proposed manual change - namespace update -->
    <!-- fb4a64a0-4cf3-42da-b6ee-358b64ea2c6d/metadata/metadata.xml:310 -->
    <!-- 00ce1c70-1bbc-4f3f-8345-7091484d6ed4/metadata/metadata.xml:352 -->
    <!-- element TimePeriod: Schemas validity error : Element '{http://www.opengis.net/gml}TimePeriod': This element is not expected. Expected is one of ( {http://www.opengis.net/gml/3.2}AbstractTimePrimitive, {http://www.opengis.net/gml/3.2}TimeInstant, {http://www.opengis.net/gml/3.2}TimePeriod, {http://www.opengis.net/gml/3.2}TimeNode, {http://www.opengis.net/gml/3.2}TimeEdge ). -->
    <!-- [gmd:fileIdentifier/gco:CharacterString='00ce1c70-1bbc-4f3f-8345-7091484d6ed4'] -->
    <!-- From xmlns:gml="http://www.opengis.net/gml" to xmlns:gml="http://www.opengis.net/gml/3.2" -->  

</xsl:stylesheet>