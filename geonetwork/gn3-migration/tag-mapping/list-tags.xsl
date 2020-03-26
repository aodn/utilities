<?xml version="1.0"?>
<!--
	Stylesheet to list all tag-name paths in an XML file, including attributes.

	2013 Sven-S. Porst <porst@sub.uni-goettingen.de>
-->
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    
    <xsl:output method="text" />
    
    <xsl:template match="node()">
        <xsl:if test="not(*)">
            <xsl:for-each select="ancestor-or-self::*">
                <xsl:value-of select="concat('/',name(.))"/>
            </xsl:for-each>
            <xsl:value-of select="concat('||', text(), '```')"/>
            <xsl:text>&#xA;</xsl:text>
        </xsl:if>
        
        <xsl:apply-templates select="*|@*"/>
    </xsl:template>
    
    <xsl:template match="@*">
        <xsl:for-each select="ancestor::*">
            <xsl:value-of select="concat('/',name(.))"/>
        </xsl:for-each>   
        <xsl:text>/@</xsl:text>
        <xsl:value-of select="name(.)"/>
        <xsl:value-of select="concat('||', ., '```')"/>
        <xsl:text>&#xA;</xsl:text>
    </xsl:template>
    
</xsl:transform>