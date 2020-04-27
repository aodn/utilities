<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="1.0">

    <xsl:template match="/">
        <mappings>
            <xsl:for-each select="nodes/node">
                <mapping sourceId="{site/uuid/text()}" ownerGroup="{ownerGroup/id/text()}"/>
            </xsl:for-each>
        </mappings>
    </xsl:template>

</xsl:stylesheet>