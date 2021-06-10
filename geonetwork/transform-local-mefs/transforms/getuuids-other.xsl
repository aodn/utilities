<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0" xmlns:xls="http://www.w3.org/1999/XSL/Transform">

    <xsl:output indent="yes"/>
    <xsl:param name="localPath"/>
    <xsl:variable name="root" select="/" />

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/groups/group[contains(.,'Other')]">
        <xsl:copy>
            <xsl:apply-templates />
            <xsl:apply-templates select="document(concat($localPath,'Other','/response.xml'))//*:info/uuid"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="*:info/uuid" >
        <xsl:variable name="candidate" select="text()"/>
        <xsl:if test="not($root//uuid[text()=$candidate])">
            <uuid>
                <xsl:value-of select="$candidate" />
            </uuid>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
