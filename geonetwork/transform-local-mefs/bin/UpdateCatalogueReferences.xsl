<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
						xmlns:gml="http://www.opengis.net/gml"
						xmlns:srv="http://www.isotc211.org/2005/srv"
						xmlns:gmx="http://www.isotc211.org/2005/gmx"
						xmlns:gco="http://www.isotc211.org/2005/gco"
						xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
						xmlns:xlink="http://www.w3.org/1999/xlink"
						xmlns:mcp="http://schemas.aodn.org.au/mcp-2.0"
						xmlns:dwc="http://rs.tdwg.org/dwc/terms/"
						xmlns:gmd="http://www.isotc211.org/2005/gmd">
    
    <xsl:output method="xml"/>

    <!-- ================================================================= -->
    <!-- new Site url must be passed as a parameter -->
    <!-- ================================================================= -->
    
    <xsl:param name="siteURL"/>
    
    <!-- ================================================================= -->
    <!-- the uuid is stored in gmd:fileIdentifier -->
    <!-- ================================================================= -->
    
    <xsl:variable name="uuid" select="/*/gmd:fileIdentifier/*/text()"/>
    
    <!-- ================================================================= -->
    <!-- default action is to copy existing nodes -->
    <!-- ================================================================= -->
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- ================================================================= -->
	<!-- update geonetwork download links with new siteURL -->
	<!-- ================================================================= -->

    <xsl:template match="gmd:CI_OnlineResource[starts-with(gmd:protocol/gco:CharacterString,'WWW:DOWNLOAD-') and contains(gmd:protocol/gco:CharacterString,'http--download') and gmd:name]
        /gmd:linkage/gmd:URL[contains(.,'resources.get?') or contains(.,'file.disclaimer?')]">
        <xsl:variable name="fname" select="../../gmd:name/*/text()"/>
        
        <xsl:element name="gmd:URL">
            <xsl:choose>
                <xsl:when test="contains(.,'resources.get?')">
                    <xsl:value-of select="concat($siteURL,'/geonetwork/srv/en/resources.get?uuid=',$uuid,'&amp;fname=',$fname,'&amp;access=private')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($siteURL,'/geonetwork/srv/en/file.disclaimer?uuid=',$uuid,'&amp;fname=',$fname,'&amp;access=private')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    
    <!-- ================================================================= -->
    <!-- Update point of truth URL if present (its for MCP only) -->
    <!-- ================================================================= -->
    
    <xsl:template match="gmd:distributionInfo//gmd:CI_OnlineResource[starts-with(gmd:protocol/*,'WWW:LINK-') and contains(gmd:protocol/*,'metadata-URL')]//gmd:URL">
        <gmd:URL><xsl:value-of select="concat($siteURL,'/geonetwork/srv/en/metadata.show?uuid=',$uuid)"/></gmd:URL>
    </xsl:template>
    
</xsl:stylesheet>