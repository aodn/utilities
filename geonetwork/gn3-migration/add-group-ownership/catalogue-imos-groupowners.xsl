<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="xs"
                version="1.0">

    <xsl:output method="text"/>

    <xsl:template match="/">
        <xsl:for-each select="response/metadata">
            <xsl:variable name="source_uuid" select="source"/>
            <xsl:variable name="ownerGroup" select="document('mappings.xml')/mappings/mapping[@sourceId=$source_uuid]/@ownerGroup"/>
            <xsl:value-of select="concat(*/uuid, ',', $ownerGroup, '&#x0A;')"/>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>