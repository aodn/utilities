<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gcoold="http://www.isotc211.org/2005/gco"
                xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/2.0"
                xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
                exclude-result-prefixes="#all">

<!--    <xsl:import href="../utility/multiLingualCharacterStrings.xsl"/>-->

    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b>December 5, 2014 </xd:p>
            <xd:p>These templates transform ISO 19139 CI_Responsibility XML content into ISO 19115-3 CI_Responsibility They are designed to be imported as a template library</xd:p>
            <xd:p>
                <xd:b>Version December 5, 2014</xd:b>
                <xd:ul>
                    <xd:li>Initial Version</xd:li>
                </xd:ul>
            </xd:p>
            <xd:p><xd:b>Author:</xd:b>thabermann@hdfgroup.org</xd:p>
        </xd:desc>
    </xd:doc>

    <xsl:template match="gmd:CI_ResponsibleParty" mode="from19139to19115-3">
       <xsl:element name="cit:CI_Responsibility">
           <xsl:apply-templates select="./@*" mode="from19139to19115-3"/>
            <xsl:choose>
                <xsl:when test="./gmd:role/gmd:CI_RoleCode/@codeListValue != ''">
                  <xsl:choose>
                    <xsl:when test="gmd:role/gmd:CI_RoleCode/@codeListValue = 'coInvestigator'">
                      <xsl:call-template name="writeCodelistElement">
                        <xsl:with-param name="elementName" select="'cit:role'"/>
                        <xsl:with-param name="codeListName" select="'cit:CI_RoleCode'"/>
                        <xsl:with-param name="codeListValue" select="'collaborator'"/>
                      </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="gmd:role/gmd:CI_RoleCode/@codeListValue = 'metadataContact'">
                      <xsl:call-template name="writeCodelistElement">
                        <xsl:with-param name="elementName" select="'cit:role'"/>
                        <xsl:with-param name="codeListName" select="'cit:CI_RoleCode'"/>
                        <xsl:with-param name="codeListValue" select="'pointOfContact'"/>
                      </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:call-template name="writeCodelistElement">
                        <xsl:with-param name="elementName" select="'cit:role'"/>
                        <xsl:with-param name="codeListName" select="'cit:CI_RoleCode'"/>
                        <xsl:with-param name="codeListValue" select="gmd:role/gmd:CI_RoleCode/@codeListValue"/>
                      </xsl:call-template>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:when test="./gmd:role/@*">
                    <cit:role>
                        <xsl:apply-templates select="./gmd:role/@*" mode="from19139to19115-3"/>
                    </cit:role>
                </xsl:when>
                <xsl:otherwise>
                    <cit:role gco:nilReason="missing"/>
                </xsl:otherwise>
            </xsl:choose>
            <cit:party>
                <xsl:choose>
                    <xsl:when test="gmd:organisationName">
                        <cit:CI_Organisation>
                            <xsl:call-template name="writeCharacterStringElement">
                                <xsl:with-param name="elementName" select="'cit:name'"/>
                                <xsl:with-param name="nodeWithStringToWrite" select="gmd:organisationName"/>
                            </xsl:call-template>
                            <xsl:variable name="contactIsForIndividual"
                                          select="ancestor::gmd:citation
                                                 |ancestor::gmd:pointOfContact
                                                 |ancestor::gmd:distributorContact
                                                 |ancestor::gmd:contact[local-name(..)='MD_Metadata']"/>
                            <xsl:choose>
                                <xsl:when test="gmd:individualName | gmd:positionName">
                                    <xsl:if test="not($contactIsForIndividual)">
                                        <xsl:call-template name="writeContactInformation"/>
                                    </xsl:if>
                                    <cit:individual>
                                        <cit:CI_Individual>
                                            <xsl:if test="gmd:individualName">
                                                <xsl:call-template name="writeCharacterStringElement">
                                                    <xsl:with-param name="elementName" select="'cit:name'"/>
                                                    <xsl:with-param name="nodeWithStringToWrite" select="gmd:individualName"/>
                                                </xsl:call-template>
                                            </xsl:if>
                                            <xsl:if test="$contactIsForIndividual">
                                                <xsl:call-template name="writeContactInformation"/>
                                            </xsl:if>
                                            <xsl:if test="gmd:positionName">
                                                <xsl:call-template name="writeCharacterStringElement">
                                                    <xsl:with-param name="elementName" select="'cit:positionName'"/>
                                                    <xsl:with-param name="nodeWithStringToWrite" select="gmd:positionName"/>
                                                </xsl:call-template>
                                            </xsl:if>
                                        </cit:CI_Individual>
                                    </cit:individual>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="writeContactInformation"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </cit:CI_Organisation>
                    </xsl:when>
                    <xsl:otherwise>
                        <cit:CI_Individual>
                            <xsl:if test="gmd:individualName">
                                <xsl:call-template name="writeCharacterStringElement">
                                    <xsl:with-param name="elementName" select="'cit:name'"/>
                                    <xsl:with-param name="nodeWithStringToWrite" select="gmd:individualName"/>
                                </xsl:call-template>
                            </xsl:if>
                            <xsl:call-template name="writeContactInformation"/>
                            <xsl:if test="gmd:positionName">
                                <xsl:call-template name="writeCharacterStringElement">
                                    <xsl:with-param name="elementName" select="'cit:positionName'"/>
                                    <xsl:with-param name="nodeWithStringToWrite" select="gmd:positionName"/>
                                </xsl:call-template>
                            </xsl:if>
                        </cit:CI_Individual>
                    </xsl:otherwise>
                </xsl:choose>
                <!--<xsl:apply-templates/>-->
            </cit:party>
        </xsl:element>
    </xsl:template>
    <xsl:template name="CI_ResponsiblePartyToOnlineResource">
        <!--
        CI_ResponsibleParties that have no name elements and only a CI_OnlineResource
        are assumed to be used to add CI_OnlineResources to CI_Citations in 19115 where
        CI_Citations do not include CI_OnlineResources. In this case we, transform
        only the CI_OnlineResource element of the CI_ResponsibleParty
    -->
        <xsl:apply-templates select=".//gmd:onlineResource" mode="from19139to19115-3"/>
    </xsl:template>

    <xsl:template match="gmd:contactInfo/gmd:CI_Contact/gmd:phone" mode="from19139to19115-3">
      <xsl:for-each select="gmd:CI_Telephone/*">
        <cit:phone>
          <cit:CI_Telephone>
            <xsl:choose>
              <xsl:when test="@*[local-name()='nilReason']">
                <cit:number>
                  <xsl:attribute name="gco:nilReason">
                    <xsl:value-of select="@*[local-name()='nilReason']"/>
                  </xsl:attribute>
                  <gco:CharacterString/>
                </cit:number>
              </xsl:when>
              <xsl:otherwise>
                <cit:number>
                  <gco:CharacterString>
                    <xsl:value-of select="./gcoold:CharacterString"/>
                  </gco:CharacterString>
                </cit:number>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="writeCodelistElement">
              <xsl:with-param name="elementName" select="'cit:numberType'"/>
              <xsl:with-param name="codeListName" select="'cit:CI_TelephoneTypeCode'"/>
              <xsl:with-param name="codeListValue">
                <xsl:choose>
                  <xsl:when test="local-name()='voice'">
                    <xsl:value-of select="'voice'"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="'facsimile'"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:with-param>
            </xsl:call-template>
          </cit:CI_Telephone>
        </cit:phone>
      </xsl:for-each>
    </xsl:template>

    <!-- Empty high-priority templates are used for elements that move to new locations in the output -->
    <xsl:template match="gmd:CI_ResponsibleParty/gmd:role" priority="5" mode="from19139to19115-3"/>
    <xsl:template match="gmd:CI_ResponsibleParty/gmd:organisationName" priority="5" mode="from19139to19115-3"/>
    <xsl:template match="gmd:CI_ResponsibleParty/gmd:individualName" priority="5" mode="from19139to19115-3"/>
    <xsl:template match="gmd:CI_ResponsibleParty/gmd:positionName" priority="5" mode="from19139to19115-3"/>

    <xsl:template name="writeContactInformation">
        <xsl:for-each select="gmd:contactInfo">
            <cit:contactInfo>
                <xsl:apply-templates select="@*" mode="from19139to19115-3"/>
                <xsl:apply-templates mode="from19139to19115-3"/>
            </cit:contactInfo>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
