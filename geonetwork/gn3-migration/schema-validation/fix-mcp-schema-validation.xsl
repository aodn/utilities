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
      <xsl:if test="not(./gmd:level)">
        <gmd:level />
      </xsl:if>
      <xsl:apply-templates select="@* | node()" />
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

  <!-- Element `<gco:Date/>` with empty value is removed -->
  <xsl:template match="gmd:CI_Date/gmd:date">
    <xsl:copy>
      <xsl:if test="./gco:Date/*[not(*) and not(normalize-space())]">
        <gmd:date />
      </xsl:if>
    </xsl:copy>
  </xsl:template>

    <!-- 2a044b8f-249a-4ed4-bfb7-20f49d563811 -->
  <!-- Removed unnecessary `<mcp:beginTime>` element   -->
  <xsl:template match="gmd:temporalElement/mcp:EX_TemporalExtent/mcp:beginTime[./gco:DateTime[not(*) and not(normalize-space())]]" xmlns:mcp="http://bluenet3.antcrc.utas.edu.au/mcp"/>


  <!--  /tmp/gn-validate/9e1414b2-3f8e-47c4-85df-dcc84444c325/metadata/metadata.xml:521: element Decimal: Schemas validity error : Element '{http://www.isotc211.org/2005/gco}Decimal': '-17.91.73' is not a valid value of the atomic type 'xs:decimal'.-->
  <xsl:template match="gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude/gco:Decimal[./text()='-17.91.73']">
    <gco:Decimal>
      <xsl:apply-templates select="@*"/>
      <xsl:value-of select="number('-17.9173')" />
    </gco:Decimal>
  </xsl:template>
  <!--  /tmp/gn-validate/9f8e77e3-8ea8-44cb-96b5-3cd2efb38e51/metadata/metadata.xml:591: element Decimal: Schemas validity error : Element '{http://www.isotc211.org/2005/gco}Decimal': '147.53.08' is not a valid value of the atomic type 'xs:decimal'.-->
  <!--  /tmp/gn-validate/e1350e76-4e55-4fb6-856a-b9cb5108d88c/metadata/metadata.xml:591: element Decimal: Schemas validity error : Element '{http://www.isotc211.org/2005/gco}Decimal': '147.53.08' is not a valid value of the atomic type 'xs:decimal'.-->
  <xsl:template match="gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:eastBoundLongitude/gco:Decimal[./text()='147.53.08']">
    <gco:Decimal>
      <xsl:apply-templates select="@*"/>
      <xsl:value-of select="number('147.5308')" />
    </gco:Decimal>
  </xsl:template>

  <!--  <xsl:template match="gmd:spatialResolution/gmd:MD_Resolution/gmd:distance/gco:Distance[not(number(./text()))]">-->
<!--    <gco:Distance>-->
<!--      <xsl:apply-templates select="@*"/>-->
<!--      <xsl:value-of select="number(substring(./text(), 1, 1))" />-->
<!--    </gco:Distance>-->
<!--  </xsl:template>-->

  <!--  7 element Distance: Schemas validity error : Element '{http://www.isotc211.org/2005/gco}Distance': '1.5 Km range resolution determined by radar bandwidth' is not a valid value of the atomic type 'xs:double'.-->
  <xsl:template match="gmd:spatialResolution/gmd:MD_Resolution/gmd:distance/gco:Distance[./text()='1.5 Km range resolution determined by radar bandwidth']">
    <gco:Distance>
      <xsl:apply-templates select="@*"/>
      <xsl:value-of select="number('1.5')" />
    </gco:Distance>
  </xsl:template>

  <!--  11 element Distance: Schemas validity error : Element '{http://www.isotc211.org/2005/gco}Distance': '3 Km range resolution determined by radar bandwidth' is not a valid value of the atomic type 'xs:double'.-->
  <xsl:template match="gmd:spatialResolution/gmd:MD_Resolution/gmd:distance/gco:Distance[./text()='3 Km range resolution determined by radar bandwidth']">
    <gco:Distance>
      <xsl:apply-templates select="@*"/>
      <xsl:value-of select="number('3')" />
    </gco:Distance>
  </xsl:template>

  <!--  14 element Distance: Schemas validity error : Element '{http://www.isotc211.org/2005/gco}Distance': '4.5 Km range resolution determined by radar bandwidth' is not a valid value of the atomic type 'xs:double'.-->
  <xsl:template match="gmd:spatialResolution/gmd:MD_Resolution/gmd:distance/gco:Distance[./text()='4.5 Km range resolution determined by radar bandwidth']">
    <gco:Distance>
      <xsl:apply-templates select="@*"/>
      <xsl:value-of select="number('4.5')" />
    </gco:Distance>
  </xsl:template>

  <!--  8 element Distance: Schemas validity error : Element '{http://www.isotc211.org/2005/gco}Distance': '6 Km range resolution determined by radar bandwidth' is not a valid value of the atomic type 'xs:double'.-->
  <xsl:template match="gmd:spatialResolution/gmd:MD_Resolution/gmd:distance/gco:Distance[./text()='6 Km range resolution determined by radar bandwidth']">
    <gco:Distance>
      <xsl:apply-templates select="@*"/>
      <xsl:value-of select="number('6')" />
    </gco:Distance>
  </xsl:template>

  <!--  2 element Distance: Schemas validity error : Element '{http://www.isotc211.org/2005/gco}Distance': 'Nominally 4.5 Km' is not a valid value of the atomic type 'xs:double'.-->
  <xsl:template match="gmd:spatialResolution/gmd:MD_Resolution/gmd:distance/gco:Distance[./text()='Nominally 4.5 Km']">
    <gco:Distance>
      <xsl:apply-templates select="@*"/>
      <xsl:value-of select="number('4.5')" />
    </gco:Distance>
  </xsl:template>

  <!--  5 element Distance: Schemas validity error : Element '{http://www.isotc211.org/2005/gco}Distance': 'nominally 4.5 Km' is not a valid value of the atomic type 'xs:double'.-->
  <xsl:template match="gmd:spatialResolution/gmd:MD_Resolution/gmd:distance/gco:Distance[./text()='nominally 4.5 Km']">
    <gco:Distance>
      <xsl:apply-templates select="@*"/>
      <xsl:value-of select="number('4.5')" />
    </gco:Distance>
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

  <!--9f16351d-eec1-4223-a761-c711ebb9c7d9-->
  <!--   Missing `<gml:usesVerticalDatum>` element added -->
  <xsl:template match="gml:VerticalCRS">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" />
      <xsl:if test="not(./gml:usesVerticalDatum) and not(./gml:verticalDatum)">
        <gml:usesVerticalDatum />
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <!-- Replace `<gmd:alternativeTitle>` with `<gmd:alternateTitle>` -->
  <xsl:template match="gmd:CI_Citation/gmd:alternativeTitle">
    <gmd:alternateTitle>
      <xsl:apply-templates select="@*|node()"/>
    </gmd:alternateTitle>
  </xsl:template>


  <!--  Element `<mcp:beginTime>` replaced with `<gml:beginPosition>` and added `<gml:endPosition />` if missing-->
  <xsl:template match="gmd:temporalElement/mcp:EX_TemporalExtent" xmlns:mcp="http://schemas.aodn.org.au/mcp-2.0">
    <xsl:if test="(./mcp:beginTime) and not(./mcp:endTime)">
        <mcp:EX_TemporalExtent>
          <xsl:attribute name="gco:isoType"><xsl:value-of select="@gco:isoType"/></xsl:attribute>
          <gmd:extent>
            <gml:TimePeriod gml:id="{generate-id(.)}">
              <gml:beginPosition>
                  <xsl:apply-templates select="./mcp:beginTime/gco:DateTime/text()"/>
              </gml:beginPosition>
              <gml:endPosition />
            </gml:TimePeriod>
          </gmd:extent>
        </mcp:EX_TemporalExtent>
    </xsl:if>
  </xsl:template>

   <!--  4402cb50-e20a-44ee-93e6-4728259250d2  -->
  <!--   Missing `<gmd:code>` element added  -->
  <xsl:template match="gmd:RS_Identifier">
    <xsl:copy>
      <xsl:if test="not(./gmd:code)">
        <gmd:code />
      </xsl:if>
      <xsl:apply-templates select="@* | node()" />
    </xsl:copy>
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

  <!--  f47a6929-1f19-4724-b74b-7c8579872cb7-->
  <!-- Removed unnecessary `<gml:duration>` element   -->
  <xsl:template match="gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:duration" />

  <!--  bae2b8ce-e1b4-40ea-b7bb-4e4c8341b277-->
  <!-- Removed empty `<gmd:function/gmd:CI_OnLineFunctionCode>` element   -->
  <xsl:template match="gmd:CI_OnlineResource/gmd:function[./gmd:CI_OnLineFunctionCode/@codeList = '' and ./gmd:CI_OnLineFunctionCode/@codeListValue='']" />

  <!-- Missing `<mcp:term>` element added  -->
  <xsl:template match="mcp:parameterUnits/mcp:DP_Term" xmlns:mcp="http://schemas.aodn.org.au/mcp-2.0">
    <xsl:copy>
      <xsl:if test="not(./mcp:term)">
        <mcp:term />
      </xsl:if>
       <xsl:apply-templates select="@* | node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
