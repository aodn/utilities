<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">

    <xsl:output method="text"/>

<xsl:template match="/groups">
    <xsl:apply-templates select="group"/>
</xsl:template>

<xsl:template match="group">
    <xsl:value-of select="report"/>
</xsl:template>

</xsl:stylesheet>
