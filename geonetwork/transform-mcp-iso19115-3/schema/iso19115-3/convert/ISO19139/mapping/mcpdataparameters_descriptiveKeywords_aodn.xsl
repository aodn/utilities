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

  <xsl:param name="geonetwork_url" />
  <xsl:variable name="geonetUri" select="concat($geonetwork_url, '/srv/')"/>
  <xsl:variable name="thesauri" select="document(concat($geonetUri,'eng/thesaurus'))/response/thesauri" />

  <xsl:template match="mcpold:dataParameters" mode="from19139to19115-3-aodn">
    <xsl:variable name="descriptiveKeywords" as="node()*">
      <xsl:call-template name="createDescriptiveKeywords">
        <xsl:with-param name="uris" select="./mcpold:DP_DataParameters/mcpold:dataParameter/mcpold:DP_DataParameter/mcpold:parameterName//gmd:URL"/>
        <xsl:with-param name="typeCode" select="'theme'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:copy-of select="$descriptiveKeywords//mri:descriptiveKeywords" copy-namespaces="no" />

    <xsl:variable name="descriptiveKeywords" as="node()*">
      <xsl:call-template name="createDescriptiveKeywords">
        <xsl:with-param name="uris" select="./mcpold:DP_DataParameters/mcpold:dataParameter/mcpold:DP_DataParameter/mcpold:parameterDeterminationInstrument//gmd:URL"/>
        <xsl:with-param name="typeCode" select="'instrument'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:copy-of select="$descriptiveKeywords//mri:descriptiveKeywords" copy-namespaces="no" />

    <xsl:variable name="descriptiveKeywords" as="node()*">
      <xsl:call-template name="createDescriptiveKeywords">
        <xsl:with-param name="uris" select="./mcpold:DP_DataParameters/mcpold:dataParameter/mcpold:DP_DataParameter/mcpold:platform//gmd:URL"/>
        <xsl:with-param name="typeCode" select="'platform'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:copy-of select="$descriptiveKeywords//mri:descriptiveKeywords" copy-namespaces="no"/>


  </xsl:template>

  <xsl:template name="createDescriptiveKeywords">
    <xsl:param name="uris"/>
    <xsl:param name="typeCode"/>
    <mcpold:MD_Metadata>
      <gmd:identificationInfo>
        <mcpold:MD_DataIdentification gcoold:isoType="gmd:MD_DataIdentification">
          <xsl:variable name="uri" select="string-join(distinct-values($uris/text()),'%2C')"/>
          <xsl:for-each select="$thesauri/thesaurus">
            <xsl:variable name="selectedKeyword" select="document(concat($geonetUri,'api/registries/vocabularies/keyword?thesaurus=',./key/text(),'&amp;transformation=to-iso19139-keyword-with-anchor','&amp;id=',$uri))" />
            <xsl:if test="string($selectedKeyword//gmd:keyword[1])">
                <xsl:call-template name="drawDescriptiveKeywords">
                  <xsl:with-param name="selectedKeyword" select="$selectedKeyword"/>
                  <xsl:with-param name="typeCode" select="$typeCode"/>
                  <xsl:with-param name="currentThesaurus" as="node()*" select="./key/text()"/>
                </xsl:call-template>
            </xsl:if>
          </xsl:for-each>
        </mcpold:MD_DataIdentification>
      </gmd:identificationInfo>
    </mcpold:MD_Metadata>
  </xsl:template>


  <xsl:template name="drawDescriptiveKeywords">
    <xsl:param name="selectedKeyword"/>
    <xsl:param name="typeCode"/>
    <xsl:param name="currentThesaurus"/>

    <xsl:variable name="withAnchor" select="true()"/>
    <xsl:variable name="withThesaurusAnchor" select="true()"/>

    <mri:descriptiveKeywords>
      <mri:MD_Keywords>
        <xsl:for-each select="$selectedKeyword//gmd:keyword">
          <mri:keyword>
            <xsl:choose>
              <xsl:when test="$withAnchor">
                <gcx:Anchor xlink:href="{.//@xlink:href}">
                  <xsl:value-of select="./gmx:Anchor/text()" />
                </gcx:Anchor>
              </xsl:when>
              <xsl:otherwise>
                <gco:CharacterString>
                  <xsl:value-of select="./text()" />
                </gco:CharacterString>
              </xsl:otherwise>
            </xsl:choose>
          </mri:keyword>
        </xsl:for-each>
        <mri:type>
          <mri:MD_KeywordTypeCode codeList="http://standards.iso.org/iso/19115/-3/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode" codeListValue="{$typeCode}"/>
        </mri:type>
        <xsl:copy-of select="geonet:add-iso19115-3-thesaurus-info($currentThesaurus, $withThesaurusAnchor, $thesauri, true())" />
      </mri:MD_Keywords>
    </mri:descriptiveKeywords>
  </xsl:template>


  <xsl:function name="geonet:add-iso19115-3-thesaurus-info">
    <xsl:param name="currentThesaurus" as="xs:string"/>
    <xsl:param name="withThesaurusAnchor" as="xs:boolean"/>
    <xsl:param name="thesauri" as="node()"/>
    <xsl:param name="thesaurusInfo" as="xs:boolean"/>

<!--    &lt;!&ndash; Add thesaurus theme &ndash;&gt;-->
<!--    <mri:type>-->
<!--      <mri:MD_KeywordTypeCode codeList="http://standards.iso.org/iso/19115/-3/resources/codeList.xml#MD_KeywordTypeCode"-->
<!--                              codeListValue="{$thesauri/thesaurus[key = $currentThesaurus]/dname}" />-->
<!--    </mri:type>-->
    <xsl:if test="$thesaurusInfo">
      <mri:thesaurusName>
        <cit:CI_Citation>
          <cit:title>
            <gcx:Anchor>
              <xsl:value-of select="$thesauri/thesaurus[key = $currentThesaurus]/title" />
            </gcx:Anchor>
          </cit:title>

          <xsl:variable name="thesaurusDate"
                        select="normalize-space($thesauri/thesaurus[key = $currentThesaurus]/date)" />

          <xsl:if test="$thesaurusDate != ''">
            <cit:date>
              <cit:CI_Date>
                <cit:date>
                  <xsl:choose>
                    <xsl:when test="contains($thesaurusDate, 'T')">
                      <gco:DateTime>
                        <xsl:value-of select="$thesaurusDate" />
                      </gco:DateTime>
                    </xsl:when>
                    <xsl:otherwise>
                      <gco:Date>
                        <xsl:value-of select="$thesaurusDate" />
                      </gco:Date>
                    </xsl:otherwise>
                  </xsl:choose>
                </cit:date>
                <cit:dateType>
                  <cit:CI_DateTypeCode
                    codeList="http://standards.iso.org/iso/19115/-3/resources/codeList.xml#CI_DateTypeCode"
                    codeListValue="publication" />
                </cit:dateType>
              </cit:CI_Date>
            </cit:date>
          </xsl:if>

          <xsl:if test="$withThesaurusAnchor">
            <cit:identifier>
              <mcc:MD_Identifier>
                <mcc:code>
                  <gcx:Anchor xlink:href="{$thesauri/thesaurus[key = $currentThesaurus]/url}">
                    geonetwork.thesaurus.<xsl:value-of select="$currentThesaurus" />
                  </gcx:Anchor>
                </mcc:code>
              </mcc:MD_Identifier>
            </cit:identifier>
          </xsl:if>
        </cit:CI_Citation>
      </mri:thesaurusName>
    </xsl:if>
  </xsl:function>

  <!--  <xsl:template match="mcpold:dataParameters" mode="from19139to19115-3-aodn">-->

  <!--    <xsl:variable name="textgroupOnly" select="false()"/>-->
  <!--    <xsl:variable name="listOfLanguage" select="false()"/>-->
  <!--    <xsl:variable name="withAnchor" select="true()"/>-->
  <!--    <xsl:variable name="withThesaurusAnchor" select="true()"/>-->
  <!--    -->
  <!--    <xsl:for-each select="./mcpold:DP_DataParameters/mcpold:dataParameter">-->
  <!--      <xsl:for-each select="./mcpold:DP_DataParameter/*/mcpold:DP_Term">-->
  <!--        <xsl:variable name="uri" select="./mcpold:vocabularyTermURL/gmd:URL" />-->
  <!--        <xsl:variable name="label" select="./mcpold:term" />-->
  <!--        <xsl:variable name="typeCode" select="./mcpold:type/mcpold:DP_TypeCode" />-->

  <!--        <xsl:variable name="currentThesaurus" as="node()*">-->
  <!--          <xsl:call-template name="findThesaurus">-->
  <!--            <xsl:with-param name="uri" select="$uri"/>-->
  <!--          </xsl:call-template>-->
  <!--        </xsl:variable>-->

  <!--        <xsl:for-each select="$currentThesaurus">-->
  <!--          <mri:descriptiveKeywords>-->
  <!--            <mri:MD_Keywords>-->
  <!--              <mri:keyword>-->
  <!--                <xsl:choose>-->
  <!--                  <xsl:when test="$withAnchor">-->
  <!--                    <gcx:Anchor xlink:href="{$uri}">-->
  <!--                      <xsl:value-of select="$label" />-->
  <!--                    </gcx:Anchor>-->
  <!--                  </xsl:when>-->
  <!--                  <xsl:otherwise>-->
  <!--                    <gco:CharacterString>-->
  <!--                      <xsl:value-of select="$label" />-->
  <!--                    </gco:CharacterString>-->
  <!--                  </xsl:otherwise>-->
  <!--                </xsl:choose>-->
  <!--              </mri:keyword>-->
  <!--              &lt;!&ndash;          <mri:type>&ndash;&gt;-->
  <!--              &lt;!&ndash;            <mri:MD_KeywordTypeCode codeList="http://standards.iso.org/iso/19115/-3/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode" codeListValue="{$typeCode}"/>&ndash;&gt;-->
  <!--              &lt;!&ndash;          </mri:type>&ndash;&gt;-->
  <!--              &lt;!&ndash;                <xsl:copy-of select="$selectedKeyword//gmd:thesaurusName" />&ndash;&gt;-->

  <!--            </mri:MD_Keywords>-->
  <!--          </mri:descriptiveKeywords>-->
  <!--        </xsl:for-each>-->
  <!--      </xsl:for-each>-->
  <!--      <xsl:copy-of select="geonet:add-iso19115-3-thesaurus-info($currentThesaurus, $withThesaurusAnchor, $thesauri, true())" />-->
  <!--    </xsl:for-each>-->
  <!--  </xsl:template>-->

  <!--  <xsl:template name="findThesaurus">-->
  <!--    <xsl:param name="uri"/>-->
  <!--    <xsl:for-each select="$thesauri/thesaurus">-->
  <!--      <xsl:variable name="selectedKeyword" select="document(concat($geonetUri,'api/registries/vocabularies/keyword?thesaurus=',./key/text(),'&amp;id=',$uri))" />-->
  <!--        <xsl:if test="string($selectedKeyword//gmd:keyword)">-->
  <!--          <xsl:value-of select="./key/text()" />-->
  <!--        </xsl:if>-->
  <!--    </xsl:for-each>-->
  <!--  </xsl:template>-->

</xsl:stylesheet>
