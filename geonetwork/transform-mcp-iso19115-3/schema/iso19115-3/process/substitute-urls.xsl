<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
                xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/2.0"
                xmlns:mri="http://standards.iso.org/iso/19115/-3/mri/1.0"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                version="2.0"
                exclude-result-prefixes="#all">

  <xsl:output indent="yes"/>

  <xsl:param name="configFile"/>

  <!-- load url substitutions to be performed -->
  <xsl:variable name="urlSubstitutions" select="document($configFile)/urlSubstitutions"/>

  <xsl:variable name="urlSubstitutionSelector" select="string-join($urlSubstitutions/substitution/@match, '|')"/>

  <xsl:template match="/">
    <!-- abort if we can't load the url substitutions file or there are no substitutions -->
    <xsl:if test="not(doc-available($configFile))">
        <xsl:message terminate="yes" select="concat('Could not load url substitutions configuration file: ', $configFile)"/>
    </xsl:if>
    <!-- abort if there are no substitutions to apply -->
    <xsl:if test="not($urlSubstitutionSelector)">
        <xsl:message terminate="yes" select="concat('No substitutions specified in: ', $configFile)"/>
    </xsl:if>
    <!-- All good - apply templates -->
    <xsl:apply-templates select="@*|node()"/>
  </xsl:template>

  <!-- default action is to copy -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- substitute production service endpoints with integration testing endpoints -->
  <xsl:template match="cit:linkage/gco:CharacterString[matches(., $urlSubstitutionSelector)]">
    <xsl:copy>
      <xsl:apply-templates mode="substitute" select="text()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@xlink:href[matches(., $urlSubstitutionSelector)]">
    <xsl:attribute name="xlink:href">
      <xsl:apply-templates mode="substitute" select="."/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template mode="substitute" match="@*|text()">
    <xsl:variable name="url" select="."/>
    <xsl:for-each select="$urlSubstitutions/substitution">
      <xsl:if test="matches($url, string(@match))">
        <xsl:value-of select="replace($url, string(@match), string(@replaceWith))"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mri:abstract/gco:CharacterString[matches(., $urlSubstitutionSelector)]">
    <xsl:variable name="abstractText" select="text()"/>
    <xsl:copy>
      <xsl:for-each select="$urlSubstitutions/substitution">
        <xsl:if test="matches($abstractText, string(@match))">
          <xsl:value-of select="replace($abstractText, string(@match), string(@replaceWith))"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>

