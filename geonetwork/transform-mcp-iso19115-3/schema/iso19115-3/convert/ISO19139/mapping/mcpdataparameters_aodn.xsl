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
                xmlns:mcpold="http://schemas.aodn.org.au/mcp-2.0"
                xmlns:mcp="http://schemas.aodn.org.au/mcp-3.0"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                exclude-result-prefixes="#all">

  <xsl:template match="mcpold:dataParameters" mode="from19139to19115-3">
    <mdb:contentInfo>
      <mrc:MD_CoverageDescription>
        <mrc:attributeDescription gco:nilReason="inapplicable"/>
        <mrc:attributeGroup>
          <mrc:MD_AttributeGroup>
            <mrc:contentType>
              <mrc:MD_CoverageContentTypeCode codeList='http://standards.iso.org/iso/19115/resources/Codelist/cat/codelists.xml#MD_CoverageContentTypeCode' codeListValue='physicalMeasurement'/>
            </mrc:contentType>
            <xsl:for-each select="./mcpold:DP_DataParameters/mcpold:dataParameter/mcpold:DP_DataParameter">
              <mrc:attribute>
                <mrc:MD_SampleDimension>
                  <mrc:name>
                    <mcc:MD_Identifier>
                      <mcc:authority/>
                      <mcc:code>
                        <xsl:choose>
                          <xsl:when test="./mcpold:parameterName/mcpold:DP_Term/mcpold:vocabularyTermURL/gmd:URL">
                            <gcx:Anchor xlink:href="{./mcpold:parameterName/mcpold:DP_Term/mcpold:vocabularyTermURL/gmd:URL}">
                              <xsl:value-of select="./mcpold:parameterName/mcpold:DP_Term/mcpold:type/mcpold:DP_TypeCode[@codeListValue='longName']/../../mcpold:term"/>
                            </gcx:Anchor>
                          </xsl:when>
                          <xsl:otherwise>
                            <gco:CharacterString>
                              <xsl:value-of select="./mcpold:parameterName/mcpold:DP_Term/mcpold:type/mcpold:DP_TypeCode[@codeListValue='longName']/../../mcpold:term"/>
                            </gco:CharacterString>
                          </xsl:otherwise>
                        </xsl:choose>
                      </mcc:code>
                      <xsl:choose>
                        <xsl:when test="./mcpold:parameterName//mcpold:vocabularyListURL/gmd:URL">
                          <mcc:codeSpace>
                            <gco:CharacterString>
                              <xsl:value-of select="./mcpold:parameterName//mcpold:vocabularyListURL/gmd:URL"/>
                            </gco:CharacterString>
                          </mcc:codeSpace>
                        </xsl:when>
                      </xsl:choose>
                      <mcc:version gco:nilReason="missing">
                        <gco:CharacterString/>
                      </mcc:version>
                      <xsl:choose>
                        <xsl:when test="./mcpold:parameterDescription/@*[local-name()='nilReason']">
                          <xsl:element name="mcc:description">
                            <xsl:attribute name="gco:nilReason" select="./mcpold:parameterDescription/@*[local-name()='nilReason']"/>
                            <gco:CharacterString/>
                          </xsl:element>
                        </xsl:when>
                        <xsl:when test="./mcpold:parameterDescription">
                          <mcc:description>
                            <gco:CharacterString>
                              <xsl:value-of select="./mcpold:parameterDescription"/>
                            </gco:CharacterString>
                          </mcc:description>
                        </xsl:when>
                        <xsl:when test="./mcpold:parameterName/mcpold:DP_Term/mcpold:termDefinition">
                          <mcc:description>
                            <gco:CharacterString>
                              <xsl:value-of select="./mcpold:parameterName/mcpold:DP_Term/mcpold:termDefinition"/>
                            </gco:CharacterString>
                          </mcc:description>
                        </xsl:when>
                        <xsl:otherwise>
                          <mcc:description  gco:nilReason="missing">
                            <gco:CharacterString />
                          </mcc:description>
                        </xsl:otherwise>
                      </xsl:choose>
                    </mcc:MD_Identifier>
                  </mrc:name>
                  <xsl:if test="string(number(mcpold:parameterMaximumValue/*)) != 'NaN'">
                    <mrc:maxValue>
                      <gco:Real><xsl:value-of select="mcpold:parameterMaximumValue/*"/></gco:Real>
                    </mrc:maxValue>
                  </xsl:if>
                  <xsl:if test="string(number(mcpold:parameterMinimumValue/*)) != 'NaN'">
                    <mrc:minValue>
                      <gco:Real><xsl:value-of select="mcpold:parameterMinimumValue/*"/></gco:Real>
                    </mrc:minValue>
                  </xsl:if>
                  <mrc:units>
                    <gml:BaseUnit gml:id="{generate-id()}">
                      <gml:descriptionReference />
                      <xsl:choose>
                        <xsl:when test="./mcpold:parameterUnits/mcpold:DP_Term/mcpold:vocabularyTermURL/gmd:URL">
                          <xsl:choose>
                            <xsl:when test="./mcpold:parameterUnits/mcpold:DP_Term/mcpold:vocabularyListURL/gmd:URL">
                              <gml:identifier codeSpace="{./mcpold:parameterUnits/mcpold:DP_Term/mcpold:vocabularyListURL/gmd:URL}">
                                <xsl:value-of select="./mcpold:parameterUnits/mcpold:DP_Term/mcpold:vocabularyTermURL/gmd:URL"/>
                              </gml:identifier>
                            </xsl:when>
                            <xsl:otherwise>
                              <gml:identifier codeSpace="unknown">
                                <xsl:value-of select="./mcpold:parameterUnits/mcpold:DP_Term/mcpold:vocabularyTermURL/gmd:URL"/>
                              </gml:identifier>
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                          <gml:identifier codeSpace="unknown"/>
                        </xsl:otherwise>
                      </xsl:choose>
                      <gml:name>
                        <xsl:value-of select="./mcpold:parameterUnits/mcpold:DP_Term/mcpold:term"/>
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

  <xsl:template match="mcpold:dataParameters" mode="from19139to19115-3-acquisition">
    <xsl:if test="./mcpold:DP_DataParameters/mcpold:dataParameter/mcpold:DP_DataParameter/mcpold:platform |
      ./mcpold:DP_DataParameters/mcpold:dataParameter/mcpold:DP_DataParameter/mcpold:parameterDeterminationInstrument">
      <xsl:for-each select="./mcpold:DP_DataParameters/mcpold:dataParameter/mcpold:DP_DataParameter">
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
            <xsl:if test="./mcpold:platform">
              <mac:platform>
                <mac:MI_Platform>
                  <mac:identifier>
                    <mcc:MD_Identifier>
                      <mcc:code>
                        <gcx:Anchor xlink:href="{./mcpold:platform/mcpold:DP_Term/mcpold:vocabularyTermURL/gmd:URL}">
                          <xsl:value-of select="./mcpold:platform/mcpold:DP_Term/mcpold:term"/>
                        </gcx:Anchor>
                      </mcc:code>
                    </mcc:MD_Identifier>
                  </mac:identifier>
                  <mac:description>
                    <gco:CharacterString><xsl:value-of select="./mcpold:platform/mcpold:DP_Term/mcpold:term"/></gco:CharacterString>
                  </mac:description>
                  <xsl:choose>
                    <xsl:when test="./mcpold:parameterDeterminationInstrument">
                      <mac:instrument>
                        <mac:MI_Instrument>
                          <mac:identifier>
                            <mcc:MD_Identifier>
                              <mcc:code>
                                <gcx:Anchor xlink:href="{./mcpold:parameterDeterminationInstrument/mcpold:DP_Term/mcpold:vocabularyTermURL/gmd:URL}">
                                  <xsl:value-of select="./mcpold:parameterDeterminationInstrument/mcpold:DP_Term/mcpold:term"/>
                                </gcx:Anchor>
                              </mcc:code>
                            </mcc:MD_Identifier>
                          </mac:identifier>
                          <mac:type gco:nilReason="missing">
                            <gco:CharacterString/>
                          </mac:type>
                        </mac:MI_Instrument>
                      </mac:instrument>
                    </xsl:when>
                    <xsl:otherwise>
                      <mac:instrument gco:nilReason="unknown"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </mac:MI_Platform>
              </mac:platform>
            </xsl:if>
          </mac:MI_AcquisitionInformation>
        </mdb:acquisitionInformation>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
