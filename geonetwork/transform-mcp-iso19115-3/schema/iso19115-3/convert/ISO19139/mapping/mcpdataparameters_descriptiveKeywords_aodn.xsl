<xsl:stylesheet version="2.0"
                xmlns:gcx="http://standards.iso.org/iso/19115/-3/gcx/1.0"
                xmlns:mri="http://standards.iso.org/iso/19115/-3/mri/1.0"
                xmlns:mcc="http://standards.iso.org/iso/19115/-3/mcc/1.0"
                xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/2.0"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"

                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gcoold="http://www.isotc211.org/2005/gco"
                xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
                xmlns:mcp="http://schemas.aodn.org.au/mcp-2.0"
                exclude-result-prefixes="#all">

  <xsl:variable name="excludedParameters">
    <term>Height above bed in the water body</term>
    <term>Speed (over ground) of measurement platform</term>
    <term>Flow rate through instrument</term>
    <term>Depth below surface of the water body</term>
  </xsl:variable>

  <xsl:variable name="samplingParameters">
    <term>Latitude north</term>
    <term>Longitude east</term>
  </xsl:variable>

  <xsl:variable name="thesauri">
    <thesaurus id="platform"
               title="AODN Platform Vocabulary"
               uri="http://catalogue-imos.dev.aodn.org.au/geonetwork/srv/eng/thesaurus.download?ref=external.theme.aodn_aodn-platform-vocabulary"
               name="geonetwork.thesaurus.external.theme.aodn_aodn-platform-vocabulary"/>
    <thesaurus id="instrument"
               title="AODN Instrument Vocabulary"
               uri="http://catalogue-imos.dev.aodn.org.au/geonetwork/srv/eng/thesaurus.download?ref=external.theme.aodn_aodn-instrument-vocabulary"
               name="geonetwork.thesaurus.external.theme.aodn_aodn-instrument-vocabulary"/>
    <thesaurus id="parameter"
               title="AODN Discovery Parameter Vocabulary"
               uri="http://catalogue-imos.dev.aodn.org.au/geonetwork/srv/eng/thesaurus.download?ref=external.theme.aodn_aodn-discovery-parameter-vocabulary"
               name="geonetwork.thesaurus.external.theme.aodn_aodn-discovery-parameter-vocabulary"/>
    <thesaurus id="sampling-parameter"
               title="AODN Sampling Parameter Vocabulary"
               uri="http://catalogue-imos.dev.aodn.org.au/geonetwork/srv/eng/thesaurus.download?ref=external.theme.aodn_aodn-sampling-parameter-vocabulary"
               name="geonetwork.thesaurus.external.theme.aodn_aodn-sampling-parameter-vocabulary"/>
  </xsl:variable>

  <xsl:template match="mcp:dataParameters" mode="from19139to19115-3-aodn">
    <!-- map each term to its keywordTypeCode/thesaurus (excluded parameters aren't included) -->
    <xsl:variable name="termMappings">
      <xsl:apply-templates mode="map-term" select=".//mcp:platform">
        <xsl:with-param name="typeCode" select="'platform'"/>
        <xsl:with-param name="defaultThesaurus" select="'platform'"/>
      </xsl:apply-templates>
      <xsl:apply-templates mode="map-term" select=".//mcp:parameterName">
        <xsl:with-param name="typeCode" select="'theme'"/>
        <xsl:with-param name="defaultThesaurus" select="'parameter'"/>
      </xsl:apply-templates>
      <xsl:apply-templates mode="map-term" select=".//mcp:parameterDeterminationInstrument">
        <xsl:with-param name="typeCode" select="'instrument'"/>
        <xsl:with-param name="defaultThesaurus" select="'instrument'"/>
      </xsl:apply-templates>
    </xsl:variable>

    <!-- create a descriptive keywords section for each typeCode, thesaurus combination -->
    <xsl:for-each-group select="$termMappings/termMapping" group-by="concat(@typeCode, '#', @thesaurus)">
      <mri:descriptiveKeywords>
        <mri:MD_Keywords>
          <xsl:for-each-group select="current-group()" group-by="@term">
            <mri:keyword>
              <xsl:choose>
                <xsl:when test="current-group()[@termUri]">
                  <gcx:Anchor xlink:href="{current-group()[@termUri][1]/@termUri}">
                    <xsl:value-of select="current-grouping-key()"/>
                  </gcx:Anchor>
                </xsl:when>
                <xsl:otherwise>
                  <gco:CharacterString>
                    <xsl:value-of select="current-grouping-key()"/>
                  </gco:CharacterString>
                </xsl:otherwise>
              </xsl:choose>
            </mri:keyword>
          </xsl:for-each-group>
          <mri:type>
            <mri:MD_KeywordTypeCode codeList="http://standards.iso.org/iso/19115/-3/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode"
                                    codeListValue="{current-group()[1]/@typeCode}"/>
          </mri:type>
          <xsl:if test="current-group()[1]/@thesaurus">
            <xsl:variable name="thesaurus" select="$thesauri/thesaurus[@id=current-group()/@thesaurus]"/>
            <mri:thesaurusName>
              <cit:CI_Citation>
                <cit:title>
                  <gcx:Anchor><xsl:value-of select="$thesaurus/@title"/></gcx:Anchor>
                </cit:title>
                <cit:date>
                  <cit:CI_Date>
                    <cit:date>
                      <gco:Date>2020-03-03</gco:Date>
                    </cit:date>
                    <cit:dateType>
                      <cit:CI_DateTypeCode codeList="http://standards.iso.org/iso/19115/resources/Codelists/cat/codelists.xml#CI_DateTypeCode"
                                           codeListValue="publication"/>
                    </cit:dateType>
                  </cit:CI_Date>
                </cit:date>
                <cit:identifier>
                  <mcc:MD_Identifier>
                    <mcc:code>
                      <gcx:Anchor xlink:href="{$thesaurus/@uri}">
                        <xsl:value-of select="$thesaurus/@name"/></gcx:Anchor>
                    </mcc:code>
                  </mcc:MD_Identifier>
                </cit:identifier>
              </cit:CI_Citation>
            </mri:thesaurusName>
          </xsl:if>
        </mri:MD_Keywords>
      </mri:descriptiveKeywords>
    </xsl:for-each-group>
  </xsl:template>

  <!-- default mapping for terms -->

  <xsl:template mode="map-term" match="*">
    <xsl:param name="typeCode"/>
    <xsl:param name="defaultThesaurus"/>

    <termMapping term="{*/mcp:term/*/text()}" termUri="{*/mcp:vocabularyTermURL/*/text()}" typeCode="{$typeCode}" thesaurus="{$defaultThesaurus}"/>
  </xsl:template>

  <!-- mapping for terms without vocabulary references -->

  <xsl:template mode="map-term" match="*[not(*/mcp:vocabularyTermURL/*/text() or */mcp:vocabularyListURL/*/text())]">
    <xsl:param name="typeCode"/>

    <termMapping term="{*/mcp:term/*/text()}" typeCode="{$typeCode}"/>
  </xsl:template>

  <!-- don't add a mapping for excluded parameters -->

  <xsl:template mode="map-term" match="mcp:parameterName[$excludedParameters/term[text()=current()/*/mcp:term/*/text()]]"/>

  <!-- mapping for sampling parameters -->

  <xsl:template mode="map-term" match="mcp:parameterName[$samplingParameters/term[text()=current()/*/mcp:term/*/text()]]">
    <xsl:param name="typeCode"/>

    <termMapping term="{*/mcp:term/*/text()}" termUri="{*/mcp:vocabularyTermURL/*/text()}" typeCode="{$typeCode}" thesaurus="sampling-parameter"/>
  </xsl:template>

</xsl:stylesheet>