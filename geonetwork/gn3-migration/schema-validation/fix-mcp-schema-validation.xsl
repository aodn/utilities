<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                  xmlns:gml="http://www.opengis.net/gml"
                  xmlns:gco="http://www.isotc211.org/2005/gco"
                  xmlns:gmd="http://www.isotc211.org/2005/gmd">

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
  <xsl:strip-space elements="*"/>

  <!-- identity transform -->
  <xsl:template match="@*|node()">
      <xsl:copy>
          <xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
  </xsl:template>

  <!-- Element <gco:Boolean/> with empty value is removed -->
  <xsl:template match="mcp:DP_Term/mcp:usedInDataset" xmlns:mcp="http://schemas.aodn.org.au/mcp-2.0">
    <xsl:copy>
      <xsl:if test="./gco:Boolean/*[not(*) and not(normalize-space())]">
        <mcp:usedInDataset />
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <!-- Element `<gco:CharacterString>` is replaced with element `<gmd:URL>` -->
  <xsl:template match="*[local-name() = 'vocabularyListURL']/gco:CharacterString">
      <gmd:URL>
        <xsl:value-of select="text()" />
      </gmd:URL>
  </xsl:template>

  <!-- Added missing child element `<gmd:level/>`  -->
  <xsl:template match="gmd:DQ_Scope">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" />
      <xsl:if test="not(./gmd:level)">
        <gmd:level />
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <!-- Added missing child element `<gmd:has/>` -->
  <xsl:template match="gmd:DS_DataSet">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" />
      <xsl:if test="not(./gmd:has)">
        <gmd:has />
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <!-- Added missing child `<gmd:seriesMetadata/>` element -->
  <xsl:template match="gmd:DS_Initiative">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" />
      <xsl:if test="not(./gmd:seriesMetadata)">
        <gmd:seriesMetadata />
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <!-- Namespace of the element changed from `<mcp:EX_Extent gco:isoType="gmd:EX_Extent">` to `<gmd:EX_Extent>` -->
  <xsl:template match="gmd:extent/mcp:EX_Extent" xmlns:mcp="http://schemas.aodn.org.au/mcp-2.0">
    <gmd:EX_Extent>
      <xsl:apply-templates select="*|node()"/>
    </gmd:EX_Extent>
  </xsl:template>

  <!-- Added missing element `<gmd:verticalCRS>` -->
  <xsl:template match="gmd:EX_VerticalExtent">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" />
      <xsl:if test="not(./gmd:verticalCRS)">
        <gmd:verticalCRS gco:nilReason="unknown" />
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <!-- Attribute commonsType in MCP 1.4 is replaced with MCP 2.0  -->
  <xsl:template match="mcp:MD_Commons" xmlns:mcp="http://schemas.aodn.org.au/mcp-2.0" >
    <xsl:if test="namespace-uri(@*[local-name()='commonsType'])='http://bluenet3.antcrc.utas.edu.au/mcp'">
        <mcp:MD_Commons>
          <xsl:attribute name="gco:isoType"><xsl:value-of select="@gco:isoType"/></xsl:attribute>
          <xsl:attribute name="mcp:commonsType"><xsl:value-of  select="@*[local-name()='commonsType']" /></xsl:attribute>
          <xsl:apply-templates select="*|node()"/>
        </mcp:MD_Commons>
    </xsl:if>
  </xsl:template>

  <!-- Required attribute `<gml:id>` is generated -->
  <xsl:template match="gml:Polygon[not(@gml:id)]">
    <gml:Polygon gml:id="{generate-id(.)}">
      <xsl:apply-templates select="@*|node()"/>
    </gml:Polygon>
  </xsl:template>

  <!-- Empty `<gco:Real>` element removed  -->
  <xsl:template match="gmd:EX_VerticalExtent/gmd:minimumValue">
    <xsl:copy>
      <xsl:if test="./gco:Real/*[not(*) and not(normalize-space())]">
        <gmd:minimumValue gco:nilReason="unknown" />
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <!-- Empty `<gco:Real>` element removed  -->
  <xsl:template match="gmd:EX_VerticalExtent/gmd:maximumValue">
    <xsl:copy>
      <xsl:if test="./gco:Real/*[not(*) and not(normalize-space())]">
        <gmd:maximumValue gco:nilReason="unknown" />
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <!-- Empty `<gco:Real>` element removed  -->
  <xsl:template match="gmd:MD_DigitalTransferOptions/gmd:transferSize">
    <xsl:copy>
      <xsl:if test="./gco:Real/*[not(*) and not(normalize-space())]">
        <gmd:transferSize gco:nilReason="unknown" />
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <!-- Added required child element `<gml:end/>` -->
  <xsl:template match="gmd:extent/gml:TimePeriod" xmlns:mcp="http://schemas.aodn.org.au/mcp-2.0">
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="(./gml:beginPosition) and (./gml:end) and not(./gml:endPosition)">
          <xsl:apply-templates select="@* | gml:beginPosition" />
          <gml:endPosition>
            <xsl:apply-templates select="./gml:end/gml:TimeInstant/gml:timePosition/text()" />
          </gml:endPosition>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="@* | node()" />
          <xsl:choose>
            <xsl:when test="(./gml:begin) and not(./gml:end)">
              <gml:end />
            </xsl:when>
            <xsl:when test="(./gml:beginPosition) and not(./gml:endPosition)">
              <gml:endPosition />
            </xsl:when>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <!-- Replaced `:` with `/` to make it valid URL -->
  <xsl:template match="*[local-name() = 'vocabularyTermURL']/gmd:URL[.='5cc12a4f-6784-372a-801a-09d227bc67c4:concept:477']">
    <gmd:URL>
        <xsl:value-of select="translate(text(),':','/')" />
    </gmd:URL>
  </xsl:template>

  <!-- Replace `<gmd:alternativeTitle>` with `<gmd:alternateTitle>` -->
  <xsl:template match="gmd:CI_Citation/gmd:alternativeTitle">
    <gmd:alternateTitle>
      <xsl:apply-templates select="@*|node()"/>
    </gmd:alternateTitle>
  </xsl:template>

<!-- Missing `<gmd:date>` element added  -->
  <xsl:template match="gmd:CI_Date">
    <xsl:copy>
      <xsl:if test="not(./gmd:date)">
        <gmd:date />
      </xsl:if>
       <xsl:apply-templates select="@* | node()" />
    </xsl:copy>
  </xsl:template>
  
  <!-- Missing `<mcp:term>` element added  -->
  <xsl:template match="mcp:parameterUnits/mcp:DP_Term" xmlns:mcp="http://schemas.aodn.org.au/mcp-2.0">
    <xsl:copy>
      <xsl:if test="not(./mcp:term)">
        <mcp:term />
      </xsl:if>
       <xsl:apply-templates select="@* | node()" />
    </xsl:copy>
  </xsl:template>

  
  
<xsl:template match="gmd:spatialResolution/gmd:MD_Resolution/gmd:distance/gco:Distance">
      <xsl:if test="not(number(./text()))">
        <xsl:apply-templates select="@*" />
          <xsl:value-of select="substring(./text(), 1, 1)" />
      </xsl:if>
  </xsl:template>
  

  
  

  

  
</xsl:stylesheet>
