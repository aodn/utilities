<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
                version="2.0"
                exclude-result-prefixes="#all">

  <!-- url substitutions to be performed -->
  <xsl:variable name="urlSubstitutions">
    <substitution match="geoserver.123.aodn.org.au" replaceWith="geoserver-gn3-integration.dev.aodn.org.au"/>
    <substitution match="https?://thredds.aodn.org.au(:443)?" replaceWith="http://thredds-gn3-integration.dev.aodn.org.au"/>
    <substitution match="catalogue-imos.aodn.org.au" replaceWith="catalogue-imos.dev.aodn.org.au"/>
    <substitution match="https?://tilecache.aodn.org.au(:443)?" replaceWith="http://tilecache-gn3-integration.dev.aodn.org.au"/>
    <substitution match="https?://processes.aodn.org.au" replaceWith="https://processes-gn3-integration.dev.aodn.org.au"/>
  </xsl:variable>

  <xsl:variable name="urlSubstitutionSelector" select="string-join($urlSubstitutions/substitution/@match, '|')"/>

  <!-- default action is to copy -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- substitute production service endpoints with systest service endpoints -->
  <xsl:template match="gco:CharacterString[matches(., $urlSubstitutionSelector)]">
    <xsl:variable name="url" select="."/>

    <xsl:for-each select="$urlSubstitutions/substitution">
      <xsl:if test="matches(string($url), string(@match))">
        <gco:CharacterString>
          <xsl:value-of select="replace($url, string(@match), string(@replaceWith))"/>
        </gco:CharacterString>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
