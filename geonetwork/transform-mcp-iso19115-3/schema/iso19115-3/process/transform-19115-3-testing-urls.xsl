<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                version="2.0"
                exclude-result-prefixes="#all">

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

  <!-- substitute production service endpoints with systest service endpoints -->
  <xsl:template match="gco:CharacterString[matches(., $urlSubstitutionSelector)]|@xlink:href[matches(., $urlSubstitutionSelector)]">
    <xsl:variable name="url" select="."/>

    <xsl:for-each select="$urlSubstitutions/substitution">
      <xsl:if test="matches(string($url), string(@match))">
        <copy>
          <xsl:value-of select="replace($url, string(@match), string(@replaceWith))"/>
        </copy>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
