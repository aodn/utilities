<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gcoold="http://www.isotc211.org/2005/gco"
                xmlns:gmi="http://www.isotc211.org/2005/gmi"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gsr="http://www.isotc211.org/2005/gsr"
                xmlns:gss="http://www.isotc211.org/2005/gss"
                xmlns:gts="http://www.isotc211.org/2005/gts"
                xmlns:srvold="http://www.isotc211.org/2005/srv"
                xmlns:gml30="http://www.opengis.net/gml"
                xmlns:cat="http://standards.iso.org/iso/19115/-3/cat/1.0"
                xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/2.0"
                xmlns:gcx="http://standards.iso.org/iso/19115/-3/gcx/1.0"
                xmlns:gex="http://standards.iso.org/iso/19115/-3/gex/1.0"
                xmlns:lan="http://standards.iso.org/iso/19115/-3/lan/1.0"
                xmlns:srv="http://standards.iso.org/iso/19115/-3/srv/2.0"
                xmlns:mac="http://standards.iso.org/iso/19115/-3/mac/2.0"
                xmlns:mas="http://standards.iso.org/iso/19115/-3/mas/1.0"
                xmlns:mcc="http://standards.iso.org/iso/19115/-3/mcc/1.0"
                xmlns:mco="http://standards.iso.org/iso/19115/-3/mco/1.0"
                xmlns:mda="http://standards.iso.org/iso/19115/-3/mda/1.0"
                xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/2.0"
                xmlns:mdt="http://standards.iso.org/iso/19115/-3/mdt/1.0"
                xmlns:mex="http://standards.iso.org/iso/19115/-3/mex/1.0"
                xmlns:mic="http://standards.iso.org/iso/19115/-3/mic/1.0"
                xmlns:mil="http://standards.iso.org/iso/19115/-3/mil/1.0"
                xmlns:mrl="http://standards.iso.org/iso/19115/-3/mrl/2.0"
                xmlns:mds="http://standards.iso.org/iso/19115/-3/mds/1.0"
                xmlns:mmi="http://standards.iso.org/iso/19115/-3/mmi/1.0"
                xmlns:mpc="http://standards.iso.org/iso/19115/-3/mpc/1.0"
                xmlns:mrc="http://standards.iso.org/iso/19115/-3/mrc/2.0"
                xmlns:mrd="http://standards.iso.org/iso/19115/-3/mrd/1.0"
                xmlns:mri="http://standards.iso.org/iso/19115/-3/mri/1.0"
                xmlns:mrs="http://standards.iso.org/iso/19115/-3/mrs/1.0"
                xmlns:msr="http://standards.iso.org/iso/19115/-3/msr/2.0"
                xmlns:mai="http://standards.iso.org/iso/19115/-3/mai/1.0"
                xmlns:mdq="http://standards.iso.org/iso/19157/-2/mdq/1.0"
                xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:mcp="http://schemas.aodn.org.au/mcp-2.0"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                exclude-result-prefixes="#all">

  <xsl:template match="mcp:dataParameters" mode="from19139to19115-3">
    <mdb:contentInfo>
      <mrc:MD_CoverageDescription>
        <mrc:attributeDescription gco:nilReason="inapplicable"/>
        <mrc:attributeGroup>
          <mrc:MD_AttributeGroup>
            <mrc:contentType>
              <mrc:MD_CoverageContentTypeCode codeList='http://standards.iso.org/iso/19115/resources/Codelist/cat/codelists.xml#MD_CoverageContentTypeCode' codeListValue='physicalMeasurement'/>
            </mrc:contentType>
            <xsl:for-each select="./mcp:DP_DataParameters/mcp:dataParameter/mcp:DP_DataParameter">
              <mrc:attribute>
                <mrc:MD_SampleDimension>
                  <mrc:name>
                    <mcc:MD_Identifier>
                      <mcc:code>
                        <xsl:choose>
                          <xsl:when test="./mcp:parameterName/mcp:DP_Term/mcp:vocabularyTermURL/gmd:URL">
                            <gcx:Anchor xlink:href="{./mcp:parameterName/mcp:DP_Term/mcp:vocabularyTermURL/gmd:URL}">
                              <xsl:value-of select="./mcp:parameterName/mcp:DP_Term/mcp:type/mcp:DP_TypeCode[@codeListValue='longName']/../../mcp:term"/>
                            </gcx:Anchor>
                          </xsl:when>
                          <xsl:otherwise>
                            <gco:CharacterString>
                              <xsl:value-of select="./mcp:parameterName/mcp:DP_Term/mcp:type/mcp:DP_TypeCode[@codeListValue='longName']/../../mcp:term"/>
                            </gco:CharacterString>
                          </xsl:otherwise>
                        </xsl:choose>
                      </mcc:code>
                      <xsl:choose>
                        <xsl:when test="./mcp:parameterName//mcp:vocabularyListURL/gmd:URL">
                          <mcc:codeSpace>
                            <gco:CharacterString>
                              <xsl:value-of select="./mcp:parameterName//mcp:vocabularyListURL/gmd:URL"/>
                            </gco:CharacterString>
                          </mcc:codeSpace>
                        </xsl:when>
                      </xsl:choose>
                      <xsl:choose>
                        <xsl:when test="./mcp:parameterDescription/@*[local-name()='nilReason']">
                          <xsl:element name="mcc:description">
                            <xsl:attribute name="gco:nilReason" select="./mcp:parameterDescription/@*[local-name()='nilReason']"/>
                            <gco:CharacterString/>
                          </xsl:element>
                        </xsl:when>
                        <xsl:when test="./mcp:parameterDescription">
                          <mcc:description>
                            <gco:CharacterString>
                              <xsl:value-of select="./mcp:parameterDescription"/>
                            </gco:CharacterString>
                          </mcc:description>
                        </xsl:when>
                        <xsl:when test="./mcp:parameterName/mcp:DP_Term/mcp:termDefinition">
                          <mcc:description>
                            <gco:CharacterString>
                              <xsl:value-of select="./mcp:parameterName/mcp:DP_Term/mcp:termDefinition"/>
                            </gco:CharacterString>
                          </mcc:description>
                        </xsl:when>
                      </xsl:choose>
                    </mcc:MD_Identifier>
                  </mrc:name>
                  <xsl:if test="string(number(mcp:parameterMaximumValue/*)) != 'NaN'">
                    <mrc:maxValue>
                      <gco:Real><xsl:value-of select="mcp:parameterMaximumValue/*"/></gco:Real>
                    </mrc:maxValue>
                  </xsl:if>
                  <xsl:if test="string(number(mcp:parameterMinimumValue/*)) != 'NaN'">
                    <mrc:minValue>
                      <gco:Real><xsl:value-of select="mcp:parameterMinimumValue/*"/></gco:Real>
                    </mrc:minValue>
                  </xsl:if>
                  <mrc:units>
                    <gml:BaseUnit gml:id="{generate-id()}">
                      <xsl:choose>
                        <xsl:when test="./mcp:parameterUnits/mcp:DP_Term/mcp:vocabularyTermURL/gmd:URL">
                          <xsl:choose>
                            <xsl:when test="./mcp:parameterUnits/mcp:DP_Term/mcp:vocabularyListURL/gmd:URL">
                              <gml:identifier codeSpace="{./mcp:parameterUnits/mcp:DP_Term/mcp:vocabularyListURL/gmd:URL}">
                                <xsl:value-of select="./mcp:parameterUnits/mcp:DP_Term/mcp:vocabularyTermURL/gmd:URL"/>
                              </gml:identifier>
                            </xsl:when>
                            <xsl:otherwise>
                              <gml:identifier codeSpace="unknown">
                                <xsl:value-of select="./mcp:parameterUnits/mcp:DP_Term/mcp:vocabularyTermURL/gmd:URL"/>
                              </gml:identifier>
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                          <gml:identifier codeSpace="unknown"/>
                        </xsl:otherwise>
                      </xsl:choose>
                      <gml:name>
                        <xsl:value-of select="./mcp:parameterUnits/mcp:DP_Term/mcp:term"/>
                      </gml:name>
                      <gml:quantityType/>
                      <gml:unitsSystem/>
                    </gml:BaseUnit>
                  </mrc:units>
                </mrc:MD_SampleDimension>
              </mrc:attribute>
            </xsl:for-each>
          </mrc:MD_AttributeGroup>
        </mrc:attributeGroup>
      </mrc:MD_CoverageDescription>
    </mdb:contentInfo>
  </xsl:template>

  <xsl:template match="mcp:dataParameters" mode="from19139to19115-3-acquisition">
      <!-- platforms and there instruments -->
      <xsl:for-each-group select="./mcp:DP_DataParameters/mcp:dataParameter/mcp:DP_DataParameter"
                          group-by="./mcp:platform/*/mcp:term/*/text()">
        <mdb:acquisitionInformation>
          <mac:MI_AcquisitionInformation>
            <mac:scope>
              <mcc:MD_Scope>
                <mcc:level>
                  <mcc:MD_ScopeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_ScopeCode"
                                    codeListValue="dataset"/>
                </mcc:level>
              </mcc:MD_Scope>
            </mac:scope>
              <mac:platform>
                <mac:MI_Platform>
                  <mac:identifier>
                    <mcc:MD_Identifier>
                      <mcc:code>
                        <gcx:Anchor xlink:href="{current-group()[1]/mcp:platform/mcp:DP_Term/mcp:vocabularyTermURL/gmd:URL}">
                          <xsl:value-of select="current-group()[1]/mcp:platform/mcp:DP_Term/mcp:term"/>
                        </gcx:Anchor>
                      </mcc:code>
                    </mcc:MD_Identifier>
                  </mac:identifier>
                  <mac:description>
                    <gco:CharacterString><xsl:value-of select="current-grouping-key()"/></gco:CharacterString>
                  </mac:description>
                  <xsl:for-each-group
                          select="current-group()/mcp:parameterDeterminationInstrument"
                          group-by="*/mcp:term/*/text()">
                        <mac:instrument>
                          <mac:MI_Instrument>
                            <mac:identifier>
                              <mcc:MD_Identifier>
                                <mcc:code>
                                  <gcx:Anchor xlink:href="{current-group()[1]/*/mcp:vocabularyTermURL/*/text()}">
                                    <xsl:value-of select="current-grouping-key()"/>
                                  </gcx:Anchor>
                                </mcc:code>
                              </mcc:MD_Identifier>
                            </mac:identifier>
                            <mac:type gco:nilReason="missing">
                              <gco:CharacterString/>
                            </mac:type>
                          </mac:MI_Instrument>
                        </mac:instrument>
                  </xsl:for-each-group>
                </mac:MI_Platform>
              </mac:platform>
          </mac:MI_AcquisitionInformation>
        </mdb:acquisitionInformation>
      </xsl:for-each-group>
      <!-- instruments without platforms -->
      <xsl:for-each-group
              select="//mcp:dataParameters/*/*/mcp:DP_DataParameter[normalize-space(mcp:platform/*/mcp:term/*/text())='']"
              group-by="mcp:parameterDeterminationInstrument/*/mcp:term/*/text()">
          <mdb:acquisitionInformation>
            <mac:MI_AcquisitionInformation>
              <mac:scope>
                <mcc:MD_Scope>
                  <mcc:level>
                    <mcc:MD_ScopeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_ScopeCode"
                                      codeListValue="dataset"/>
                  </mcc:level>
                </mcc:MD_Scope>
              </mac:scope>
              <mac:instrument>
                <mac:MI_Instrument>
                  <mac:identifier>
                    <mcc:MD_Identifier>
                      <mcc:code>
                        <gcx:Anchor xlink:href="{current-group()[1]/mcp:parameterDeterminationInstrument/*/mcp:vocabularyTermURL/*/text()}">
                          <xsl:value-of select="current-grouping-key()"/>
                        </gcx:Anchor>
                      </mcc:code>
                    </mcc:MD_Identifier>
                  </mac:identifier>
                  <mac:type gco:nilReason="missing">
                    <gco:CharacterString/>
                  </mac:type>
                </mac:MI_Instrument>
              </mac:instrument>
          </mac:MI_AcquisitionInformation>
        </mdb:acquisitionInformation>
      </xsl:for-each-group>
  </xsl:template>
</xsl:stylesheet>
