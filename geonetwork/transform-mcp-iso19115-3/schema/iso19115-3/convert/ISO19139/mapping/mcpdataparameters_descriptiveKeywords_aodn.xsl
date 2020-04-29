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
                xmlns:mcpold="http://schemas.aodn.org.au/mcp-2.0"
                exclude-result-prefixes="#all">

  <xsl:template match="mcpold:dataParameters" mode="from19139to19115-3-aodn">

      <xsl:call-template name="transformKeywords">
        <xsl:with-param name="parameter" select="./mcpold:DP_DataParameters//mcpold:platform"/>
        <xsl:with-param name="typeCode" select="'platform'"/>
      </xsl:call-template>

      <xsl:call-template name="transformKeywords">
        <xsl:with-param name="parameter" select="./mcpold:DP_DataParameters//mcpold:parameterName"/>
        <xsl:with-param name="typeCode" select="'theme'"/>
      </xsl:call-template>

      <xsl:call-template name="transformKeywords">
        <xsl:with-param name="parameter" select="./mcpold:DP_DataParameters//mcpold:parameterDeterminationInstrument"/>
        <xsl:with-param name="typeCode" select="'instrument'"/>
      </xsl:call-template>

  </xsl:template>

  <xsl:template name="transformKeywords">
    <xsl:param name="parameter"/>
    <xsl:param name="typeCode"/>
    <xsl:variable name="withAnchor" select="true()"/>
    <xsl:variable name="withThesaurusAnchor" select="true()"/>

    <xsl:if test="$parameter/mcpold:DP_Term[.//(mcpold:vocabularyTermURL|mcpold:vocabularyListURL)]">
      <mri:descriptiveKeywords>
        <mri:MD_Keywords>
          <xsl:for-each-group select="$parameter/mcpold:DP_Term[.//gcoold:CharacterString/text()]" group-by="./mcpold:term|mcpold:name/gcoold:CharacterString/text()">
            <xsl:if test=".//(mcpold:vocabularyTermURL|mcpold:vocabularyListURL)">
              <mri:keyword>
                <gcx:Anchor xlink:href="{.//(mcpold:vocabularyTermURL|mcpold:vocabularyListURL)/gmd:URL/text()}">
                  <xsl:value-of select="./mcpold:term|mcpold:name/gcoold:CharacterString/text()" />
                </gcx:Anchor>
              </mri:keyword>
            </xsl:if>
          </xsl:for-each-group>
          <xsl:call-template name="createThesaurusInfo">
            <xsl:with-param name="typeCode" select="$typeCode"/>
          </xsl:call-template>
        </mri:MD_Keywords>
      </mri:descriptiveKeywords>
    </xsl:if>

    <!-- For keywords that do not have a thesaurus -->
    <xsl:for-each-group select="$parameter/mcpold:DP_Term[.//gcoold:CharacterString/text()]" group-by="./mcpold:term|mcpold:name/gcoold:CharacterString/text()">
      <xsl:if test="not(.//(mcpold:vocabularyTermURL|mcpold:vocabularyListURL))">
        <mri:descriptiveKeywords>
          <mri:MD_Keywords>
            <mri:keyword>
              <gco:CharacterString>
                <xsl:value-of select="./mcpold:term|mcpold:name/gcoold:CharacterString/text()" />
              </gco:CharacterString>
            </mri:keyword>
          </mri:MD_Keywords>
        </mri:descriptiveKeywords>
      </xsl:if>
    </xsl:for-each-group>
  </xsl:template>

  <xsl:template name="createThesaurusInfo">
    <xsl:param name="typeCode"/>
    <mri:type>
      <mri:MD_KeywordTypeCode codeList="http://standards.iso.org/iso/19115/-3/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode" codeListValue="{$typeCode}"/>
    </mri:type>
    <xsl:choose>
      <xsl:when test="$typeCode='platform'">
        <xsl:call-template name="createThesaurusElement">
          <xsl:with-param name="title" select="'AODN Platform Vocabulary'"/>
          <xsl:with-param name="uri" select="'http://catalogue-imos.dev.aodn.org.au/geonetwork/srv/eng/thesaurus.download?ref=external.theme.aodn_aodn-platform-vocabulary'"/>
          <xsl:with-param name="name" select="'geonetwork.thesaurus.external.theme.aodn_aodn-platform-vocabulary'"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$typeCode='theme'">
        <xsl:call-template name="createThesaurusElement">
          <xsl:with-param name="title" select="'AODN Discovery Parameter Vocabulary'"/>
          <xsl:with-param name="uri" select="'http://catalogue-imos.dev.aodn.org.au/geonetwork/srv/eng/thesaurus.download?ref=external.theme.aodn_aodn-discovery-parameter-vocabulary'"/>
          <xsl:with-param name="name" select="'geonetwork.thesaurus.external.theme.aodn_aodn-discovery-parameter-vocabulary'"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$typeCode='instrument'">
        <xsl:call-template name="createThesaurusElement">
          <xsl:with-param name="title" select="'AODN Instrument Vocabulary'"/>
          <xsl:with-param name="uri" select="'http://catalogue-imos.dev.aodn.org.au/geonetwork/srv/eng/thesaurus.download?ref=external.theme.aodn_aodn-instrument-vocabulary'"/>
          <xsl:with-param name="name" select="'geonetwork.thesaurus.external.theme.aodn_aodn-instrument-vocabulary'"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="createThesaurusElement">
    <xsl:param name="title"/>
    <xsl:param name="uri"/>
    <xsl:param name="name"/>
    <mri:thesaurusName>
      <cit:CI_Citation>
        <cit:title>
          <gcx:Anchor><xsl:value-of select="$title"/></gcx:Anchor>
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
              <gcx:Anchor xlink:href="{$uri}">
                <xsl:value-of select="$name"/></gcx:Anchor>
            </mcc:code>
          </mcc:MD_Identifier>
        </cit:identifier>
      </cit:CI_Citation>
    </mri:thesaurusName>
  </xsl:template>

</xsl:stylesheet>
