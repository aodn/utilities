<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mcp="http://bluenet3.antcrc.utas.edu.au/mcp"
                xmlns:mcp-2.0="http://schemas.aodn.org.au/mcp-2.0"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                version="2.0">

    <xsl:output method="text"/>

    <xsl:template match="/">

        <xsl:text>&#xa;MCP 1.4, </xsl:text><xsl:value-of select="count(//mcp:MD_Metadata)"/>
        <xsl:text>&#xa;MCP 2.0, </xsl:text><xsl:value-of select="count(//mcp-2.0:MD_Metadata)"/>
        <xsl:text>&#xa;ISO19139, </xsl:text><xsl:value-of select="count(//gmd:MD_Metadata)"/>
        <xsl:text>&#xa;</xsl:text>
    </xsl:template>

</xsl:stylesheet>