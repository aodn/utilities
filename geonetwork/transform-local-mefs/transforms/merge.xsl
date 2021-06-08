<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">

<xsl:output indent="yes"/>
<xsl:param name="path"/>

<xsl:template match="@*|node()">
    <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
</xsl:template>

<xsl:template match="/groups/group">
    <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>
        <records>
            <xsl:apply-templates mode="metadata" select="uuid"/>
        </records>
    </xsl:copy>
</xsl:template>

<xsl:template match="uuid" mode="metadata" >
    <xsl:copy-of select="document(concat($path,encode-for-uri(text()),'/metadata/metadata.xml'))//*:MD_Metadata"/>
</xsl:template>

</xsl:stylesheet>
