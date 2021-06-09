<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">

    <xsl:output indent="yes"/>
    <xsl:param name="localPath"/>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
<!--[not(/groups/group/name/text()='Other')]-->
<!--    chapter[contains(.,'the')]-->
    <xsl:template match="/groups/group[not(contains(.,'Other'))]">
        <xsl:copy>
            <xsl:apply-templates/>
            <xsl:apply-templates select="document(concat($localPath,encode-for-uri(name),'/response.xml'))//*:info/uuid"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/groups/group[contains(.,'Other')]">
        <xsl:copy>
            <xsl:apply-templates/>
            <!-- TODO: only add uuids to 'other' group if not already found. This should only be run after all the groupings are done -->
<!--            <xsl:apply-templates select="document(concat($localPath,encode-for-uri(name),'/response.xml'))//*:info/uuid"/>-->
        </xsl:copy>
    </xsl:template>

    <xsl:template match="*:info/uuid">
        <uuid>
            <xsl:value-of select="text()"/>
        </uuid>
    </xsl:template>

</xsl:stylesheet>
