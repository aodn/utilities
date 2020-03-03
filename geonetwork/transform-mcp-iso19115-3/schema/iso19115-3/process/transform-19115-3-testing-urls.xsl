<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
                xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/2.0"
                xmlns:mri="http://standards.iso.org/iso/19115/-3/mri/1.0"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                version="2.0"
                exclude-result-prefixes="#all">
  
  <xsl:output indent="yes"/>

  <!-- url substitutions to be performed -->
  <xsl:variable name="urlSubstitutions">
    <!-- Stack endpoints -->
    <substitution match="https?://portal.aodn.org.au" replaceWith="http://portal-gn3-integration.dev.aodn.org.au"/>
    <substitution match="https?://geoserver.123.aodn.org.au" replaceWith="http://geoserver-gn3-integration.dev.aodn.org.au"/>
    <substitution match="https?://thredds.aodn.org.au" replaceWith="http://thredds-gn3-integration.dev.aodn.org.au"/>
    <substitution match="https?://tilecache.aodn.org.au" replaceWith="http://tilecache-gn3-integration.dev.aodn.org.au"/>
    <substitution match="https?://processes.aodn.org.au" replaceWith="https://processes-gn3-integration.dev.aodn.org.au"/>
    <!-- Instance keyword thesauri links -->
    <substitution match="https?://catalogue-imos.aodn.org.au(:443)?/geonetwork/srv/eng?/thesaurus" replaceWith="http://catalogue-imos.dev.aodn.org.au/geonetwork/srv/eng/thesaurus"/>
    <!-- Instance point of truth links --> 
    <substitution match="https?://catalogue-imos.aodn.org.au(:443)?/geonetwork/srv/eng?/metadata.show\?uuid=" replaceWith="http://catalogue-imos.dev.aodn.org.au/geonetwork/srv/api/records/"/>
    <!-- Instance references to metadata -->
    <substitution match="https?://catalogue-123.aodn.org.au(:443)?/geonetwork/srv/eng?/metadata.show\?uuid=" replaceWith="http://catalogue-imos.dev.aodn.org.au/geonetwork/srv/api/records/"/>
    <!-- Instance download links - no disclaimer option - just change to download link for the moment until we work out what we're going to do about that -->
    <substitution match="https?://catalogue-imos.aodn.org.au(:443)?/geonetwork/srv/eng?/file.disclaimer\?uuid=(.*)&amp;fname=(.*)&amp;access=private" replaceWith="http://catalogue-imos.dev.aodn.org.au/geonetwork/srv/api/records/$2/attachments/$3"/>
  </xsl:variable>

  <xsl:variable name="urlSubstitutionSelector" select="string-join($urlSubstitutions/substitution/@match, '|')"/>

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

  <xsl:template match="mri:abstract/gco:CharacterString">
    <xsl:variable name="abstractText" select="text()"/>
    <xsl:for-each select="$urlSubstitutions/substitution">
      <xsl:if test="matches($abstractText, string(@match))">
        <xsl:value-of select="replace($abstractText, string(@match), string(@replaceWith))"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>

