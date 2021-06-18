<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mcp="http://bluenet3.antcrc.utas.edu.au/mcp"
                xmlns:mcp-2.0="http://schemas.aodn.org.au/mcp-2.0"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                version="2.0">

    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/groups/group">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <report>
                <xsl:text>### Group: </xsl:text><xsl:value-of select="name"/><xsl:text>&#xa;</xsl:text>
                <xsl:text>&#xa;</xsl:text>
                <xsl:apply-templates mode="report" select="records"/>
                <xsl:text>&#xa;</xsl:text>
            </report>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="records" mode="report" >

        <xsl:variable name="main_root" select="."/>

        <xsl:variable name="contributors-set" as="node()*">
            <xsl:call-template name="findContributors">
                <xsl:with-param name="pot_text" select="'Point of truth URL of this metadata record'"/>
                <xsl:with-param name="main_root" select="$main_root"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:text>| Metadata Schema | No of metadata records |&#xa;</xsl:text>
        <xsl:text>|--|:--:|&#xa;</xsl:text>
        <xsl:text>| MCP 1.4 | </xsl:text><xsl:value-of select="count($main_root/mcp:MD_Metadata)"/><xsl:text> |&#xa;</xsl:text>
        <xsl:text>| MCP 2.0 | </xsl:text><xsl:value-of select="count($main_root/mcp-2.0:MD_Metadata)"/><xsl:text> |&#xa;</xsl:text>
        <xsl:text>| ISO19139 | </xsl:text><xsl:value-of select="count($main_root/gmd:MD_Metadata)"/><xsl:text> |&#xa;</xsl:text>
        <xsl:text>&#xa;</xsl:text>
        <xsl:text>| Contributors | No of metadata records |&#xa;</xsl:text>
        <xsl:text>|--|:--:|&#xa;</xsl:text>

        <xsl:for-each select="distinct-values($contributors-set)">
            <xsl:variable name="contributor" select="." />

            <xsl:variable name="contributor-records" as="node()*">
                <xsl:call-template name="getPointOfTruthMatchedRecords">
                    <xsl:with-param name="pot_text" select="'Point of truth URL of this metadata record'"/>
                    <xsl:with-param name="pot_url" select="$contributor"/>
                    <xsl:with-param name="separator" select="'://'"/>
                    <xsl:with-param name="main_root" select="$main_root"/>
                </xsl:call-template>
            </xsl:variable>

            <xsl:text>| </xsl:text><xsl:value-of select="$contributor"/><xsl:text> | </xsl:text><xsl:value-of select="count($contributor-records)"/><xsl:text> |&#xa;</xsl:text>
        </xsl:for-each>

        <xsl:variable name="unknown-contributors-records" as="node()*">
            <xsl:call-template name="findUnknownContributors">
                <xsl:with-param name="pot_text" select="'Point of truth URL of this metadata record'"/>
                <xsl:with-param name="main_root" select="$main_root"/>
            </xsl:call-template>
        </xsl:variable>

<!--        <xsl:text>&#xa;Known, </xsl:text>-->
<!--        <xsl:value-of select="count($contributors-set)"/>-->
<!--        <xsl:text>&#xa;Unknown, </xsl:text>-->
<!--        <xsl:copy-of select="count($unknown-contributors-records)"/>-->
        <xsl:text>| Unknown | </xsl:text><xsl:value-of select="count($unknown-contributors-records)"/><xsl:text> |&#xa;</xsl:text>
        <xsl:text>&#xa;&#xa;</xsl:text>

        <xsl:for-each select="distinct-values($contributors-set)">
            <xsl:variable name="contributor" select="." />

            <xsl:variable name="contributor-records" as="node()*">
                <xsl:call-template name="getPointOfTruthMatchedRecords">
                    <xsl:with-param name="pot_text" select="'Point of truth URL of this metadata record'"/>
                    <xsl:with-param name="pot_url" select="$contributor"/>
                    <xsl:with-param name="separator" select="'://'"/>
                    <xsl:with-param name="main_root" select="$main_root"/>
                </xsl:call-template>
            </xsl:variable>

            <xsl:variable name="varcountMetadataElements">
                <xsl:call-template name="countMetadataElements">
                    <xsl:with-param name="records" select="$contributor-records"/>
                    <xsl:with-param name="main_root" select="$main_root"/>
                </xsl:call-template>
            </xsl:variable>

            <xsl:call-template name="printOutput">
                <xsl:with-param name="contributor" select="$contributor"/>
                <xsl:with-param name="varcountMetadataElements" select="$varcountMetadataElements"/>
            </xsl:call-template>

        </xsl:for-each>

    </xsl:template>

    <!-- Called Templates -->
    <!-- List contributors URL -->
    <xsl:template name="findContributors">
        <xsl:param name="pot_text"/>
        <xsl:param name="main_root"/>

        <xsl:for-each select="$main_root//gmd:distributionInfo//gmd:CI_OnlineResource/gmd:description/gco:CharacterString[starts-with(., $pot_text)]/ancestor::node()/gmd:linkage/gmd:URL/text()" >
            <xsl:value-of select="substring-before(substring-after(., '://'), '/')"/>
        </xsl:for-each>
    </xsl:template>

    <!-- List metadata records with provided contributor's Point of Truth URL -->
    <xsl:template name="getPointOfTruthMatchedRecords" as="node()*">
        <xsl:param name="pot_text"/>
        <xsl:param name="pot_url"/>
        <xsl:param name="separator"/>
        <xsl:param name="main_root"/>

        <xsl:for-each select="$main_root//gmd:distributionInfo//gmd:CI_OnlineResource/gmd:description/gco:CharacterString[starts-with(., $pot_text)]/ancestor::node()/gmd:linkage" >
            <xsl:choose>
                <xsl:when test="substring-after(./gmd:URL, $separator)[starts-with(., $pot_url)]">
                    <xsl:value-of select="./ancestor-or-self::node()/gmd:fileIdentifier/gco:CharacterString/node()"/>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <!-- List Unknown contributors URL -->
    <xsl:template name="findUnknownContributors">
        <xsl:param name="pot_text"/>
        <xsl:param name="main_root"/>
        <xsl:for-each select="$main_root//*[local-name() = 'MD_Metadata']" >
            <xsl:choose>
                <xsl:when test="not(.//gmd:distributionInfo//gmd:CI_OnlineResource/gmd:description/gco:CharacterString[starts-with(., $pot_text)]) or not(boolean(.//gmd:distributionInfo))">
                    <xsl:copy-of select="./ancestor-or-self::node()/gmd:fileIdentifier/gco:CharacterString/node()" />
                </xsl:when>
            </xsl:choose>
<!--            Following reports on multiple points of truth in records -->
<!--            <xsl:choose>-->
<!--                <xsl:when test="count(.//gmd:distributionInfo//gmd:CI_OnlineResource/gmd:description/gco:CharacterString[starts-with(., $pot_text)]) > 1" >-->
<!--                    <xsl:message select="count(.//gmd:distributionInfo//gmd:CI_OnlineResource/gmd:description/gco:CharacterString[starts-with(., $pot_text)])" />-->
<!--                    <xsl:message select="./ancestor-or-self::node()/gmd:fileIdentifier/gco:CharacterString/node()" />-->
<!--                </xsl:when>-->
<!--            </xsl:choose>-->
        </xsl:for-each>
    </xsl:template>

    <!-- List metadata records with provided contributor's Point of Truth URL -->
    <xsl:template name="countMetadataElements" as="node()*">
        <xsl:param name="records"/>
        <xsl:param name="main_root"/>
        <results>
            <xsl:for-each select="$records">
                <xsl:variable name="record" select="$main_root//gmd:fileIdentifier/gco:CharacterString[node()=current()]"/>
                <xsl:call-template name="countEachMetadataElement">
                    <xsl:with-param name="record" select="$record"/>
                </xsl:call-template>
            </xsl:for-each>
        </results>
    </xsl:template>

    <!-- Count occurences of metadata elements -->
    <xsl:template name="countEachMetadataElement">
        <xsl:param name="record"/>
        <uuid>
            <xsl:value-of select="$record" />
        </uuid>

        <DP_DataParameters>
            <xsl:value-of select="(count($record/parent::node()/parent::node()//mcp-2.0:DP_DataParameters) + count($record/parent::node()/parent::node()//mcp:DP_DataParameters))" />
        </DP_DataParameters>

        <parameterName>
            <xsl:value-of select="(count($record/parent::node()/parent::node()//mcp-2.0:parameterName) + count($record/parent::node()/parent::node()//mcp:parameterName))" />
        </parameterName>

        <parameterName-DP_Term>
            <xsl:value-of select="(count($record/parent::node()/parent::node()//mcp-2.0:parameterName/mcp-2.0:DP_term) + count($record/parent::node()/parent::node()//mcp:parameterName/mcp:DP_Term))" />
        </parameterName-DP_Term>

        <parameterUnits-DP_Term>
            <xsl:value-of select="(count($record/parent::node()/parent::node()//mcp-2.0:parameterUnits/mcp-2.0:DP_term) + count($record/parent::node()/parent::node()//mcp:parameterUnits/mcp:DP_Term))" />
        </parameterUnits-DP_Term>

        <parameterDeterminationInstrument-DP_Term>
            <xsl:value-of select="(count($record/parent::node()/parent::node()//mcp-2.0:parameterDeterminationInstrument/mcp-2.0:DP_Term) + count($record/parent::node()/parent::node()//mcp:parameterDeterminationInstrument/mcp:DP_Term))" />
        </parameterDeterminationInstrument-DP_Term>

        <parameterAnalysisMethod>
            <xsl:value-of select="(count($record/parent::node()/parent::node()//mcp-2.0:parameterAnalysisMethod) + count($record/parent::node()/parent::node()//mcp:parameterAnalysisMethod))" />
        </parameterAnalysisMethod>

        <parameterAnalysisMethod-DP_Term>
            <xsl:value-of select="(count($record/parent::node()/parent::node()//mcp-2.0:parameterAnalysisMethod/mcp-2.0:DP_Term) + count($record/parent::node()/parent::node()//mcp:parameterAnalysisMethod/mcp:DP_Term))" />
        </parameterAnalysisMethod-DP_Term>

        <platform-DP_Term>
            <xsl:value-of select="(count($record/parent::node()/parent::node()//mcp-2.0:platform/mcp-2.0:DP_Term) + count($record/parent::node()/parent::node()//mcp:platform/mcp:DP_Term))" />
        </platform-DP_Term>

        <parameterMinimumValue-FreeText>
            <xsl:value-of select="(count($record/parent::node()/parent::node()//mcp-2.0:parameterMinimumValue) + count($record/parent::node()/parent::node()//mcp:parameterMinimumValue))" />
        </parameterMinimumValue-FreeText>

        <parameterMaximumValue-FreeText>
            <xsl:value-of select="(count($record/parent::node()/parent::node()//mcp-2.0:parameterMaximumValue) + count($record/parent::node()/parent::node()//mcp:parameterMaximumValue))" />
        </parameterMaximumValue-FreeText>

        <parameterDescription-FreeText>
            <xsl:value-of select="(count($record/parent::node()/parent::node()//mcp-2.0:parameterDescription) + count($record/parent::node()/parent::node()//mcp:parameterDescription))" />
        </parameterDescription-FreeText>

        <termDefinition-FreeText>
            <xsl:value-of select="(count($record/parent::node()/parent::node()//mcp-2.0:termDefinition) + count($record/parent::node()/parent::node()//mcp:termDefinition))" />
        </termDefinition-FreeText>

        <otherConstraints>
            <xsl:value-of select="(count($record/parent::node()/parent::node()//mcp-2.0:otherConstraints) + count($record/parent::node()/parent::node()//mcp:otherConstraints))" />
        </otherConstraints>

        <samplingFrequency>
            <xsl:attribute name="count"><xsl:value-of select="(count($record/parent::node()/parent::node()//mcp-2.0:samplingFrequency) + count($record/parent::node()/parent::node()//mcp:samplingFrequency))" /></xsl:attribute>
            <xsl:for-each-group select="$record/parent::node()/parent::node()//mcp-2.0:samplingFrequency/gmd:MD_MaintenanceFrequencyCode | $record/parent::node()/parent::node()//mcp:samplingFrequency/gmd:MD_MaintenanceFrequencyCode" group-by="@codeListValue">
                <MD_MaintenanceFrequencyCode>
                    <xsl:attribute name="codeListValue"><xsl:value-of select="current-grouping-key()"/></xsl:attribute>
                    <xsl:for-each select="current-group()">
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                </MD_MaintenanceFrequencyCode>
            </xsl:for-each-group>
        </samplingFrequency>

        <currency>
            <xsl:attribute name="count"><xsl:value-of select="(count($record/parent::node()/parent::node()//mcp-2.0:currency) + count($record/parent::node()/parent::node()//mcp:currency))" /></xsl:attribute>
            <xsl:for-each-group select="$record/parent::node()/parent::node()//mcp-2.0:currency/mcp-2.0:MD_CurrencyTypeCode | $record/parent::node()/parent::node()//mcp:currency/mcp:MD_CurrencyTypeCode" group-by="@codeListValue">
                <MD_CurrencyTypeCode>
                    <xsl:attribute name="codeListValue"><xsl:value-of select="current-grouping-key()"/></xsl:attribute>
                    <xsl:for-each select="current-group()">
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                </MD_CurrencyTypeCode>
            </xsl:for-each-group>
        </currency>

        <temporalAggregation>
            <xsl:attribute name="count"><xsl:value-of select="(count($record/parent::node()/parent::node()//mcp-2.0:temporalAggregation) + count($record/parent::node()/parent::node()//mcp:temporalAggregation))" /></xsl:attribute>
            <xsl:for-each-group select="$record/parent::node()/parent::node()//mcp-2.0:temporalAggregation/mcp-2.0:MD_TemporalAggregationUnitCode | $record/parent::node()/parent::node()//mcp:temporalAggregation/mcp:MD_TemporalAggregationUnitCode" group-by="@codeListValue">
                <MD_TemporalAggregationUnitCode>
                    <xsl:attribute name="codeListValue"><xsl:value-of select="current-grouping-key()"/></xsl:attribute>
                    <xsl:for-each select="current-group()">
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                </MD_TemporalAggregationUnitCode>
            </xsl:for-each-group>
        </temporalAggregation>

        <TC_TaxonomicCoverage>
            <xsl:value-of select="(count($record/parent::node()/parent::node()//mcp-2.0:TC_TaxonomicCoverage) + count($record/parent::node()/parent::node()//mcp:TC_TaxonomicCoverage))" />
        </TC_TaxonomicCoverage>

        <CI_DateTypeCode codeListValue="unknown">
            <xsl:value-of select="count($record/parent::node()/parent::node()//gmd:CI_DateTypeCode[@codeListValue = 'unknown'])" />
        </CI_DateTypeCode>

        <CI_RoleCode codeListValue="coInvestigator">
            <xsl:value-of select="count($record/parent::node()/parent::node()//gmd:CI_RoleCode[@codeListValue = 'coInvestigator'])" />
        </CI_RoleCode>
        <CI_RoleCode codeListValue="licensor">
            <xsl:value-of select="count($record/parent::node()/parent::node()//gmd:CI_RoleCode[@codeListValue = 'licensor'])" />
        </CI_RoleCode>
        <CI_RoleCode codeListValue="researchAssistant">
            <xsl:value-of select="count($record/parent::node()/parent::node()//gmd:CI_RoleCode[@codeListValue = 'researchAssistant'])" />
        </CI_RoleCode>
        <CI_RoleCode codeListValue="ipOwner">
            <xsl:value-of select="count($record/parent::node()/parent::node()//gmd:CI_RoleCode[@codeListValue = 'ipOwner'])" />
        </CI_RoleCode>
        <CI_RoleCode codeListValue="moralRightsOwner">
            <xsl:value-of select="count($record/parent::node()/parent::node()//gmd:CI_RoleCode[@codeListValue = 'moralRightsOwner'])" />
        </CI_RoleCode>
        <CI_RoleCode codeListValue="metadataContact">
            <xsl:value-of select="count($record/parent::node()/parent::node()//gmd:CI_RoleCode[@codeListValue = 'metadataContact'])" />
        </CI_RoleCode>

        <MD_ScopeCode codeListValue="observed">
            <xsl:value-of select="count($record/parent::node()/parent::node()//gmd:MD_ScopeCode[@codeListValue = 'observed'])" />
        </MD_ScopeCode>
        <MD_ScopeCode codeListValue="derived">
            <xsl:value-of select="count($record/parent::node()/parent::node()//gmd:MD_ScopeCode[@codeListValue = 'derived'])" />
        </MD_ScopeCode>
        <MD_ScopeCode codeListValue="publication">
            <xsl:value-of select="count($record/parent::node()/parent::node()//gmd:MD_ScopeCode[@codeListValue = 'publication'])" />
        </MD_ScopeCode>
        <MD_ScopeCode codeListValue="dataObject">
            <xsl:value-of select="count($record/parent::node()/parent::node()//gmd:MD_ScopeCode[@codeListValue = 'dataObject'])" />
        </MD_ScopeCode>
        <MD_ScopeCode codeListValue="project">
            <xsl:value-of select="count($record/parent::node()/parent::node()//gmd:MD_ScopeCode[@codeListValue = 'project'])" />
        </MD_ScopeCode>
    </xsl:template>

    <xsl:template name="printOutput" as="node()*">
        <xsl:param name="contributor"/>
        <xsl:param name="varcountMetadataElements"/>

        <xsl:text>| MCP Elements | </xsl:text><xsl:value-of select="$contributor"/><xsl:text> |&#xa;</xsl:text>
        <xsl:text>|--|:--:|&#xa;</xsl:text>
        <!--        <xsl:value-of select="count($varcountMetadataElements/results/uuid)"/>-->
<!--        <xsl:text>&#xa;records count:</xsl:text><xsl:copy-of select="count($varcountMetadataElements/results/uuid)"/>-->
        <xsl:text>| DP_DataParameters | </xsl:text><xsl:value-of select="sum($varcountMetadataElements/results/DP_DataParameters)"/><xsl:text> |&#xa;</xsl:text>
        <xsl:text>| DP_DataParameters:parameterName | </xsl:text><xsl:value-of select="sum($varcountMetadataElements/results/parameterName)"/><xsl:text> |&#xa;</xsl:text>
        <xsl:text>| DP_DataParameters:parameterName:DP_Term | </xsl:text><xsl:value-of select="sum($varcountMetadataElements/results/parameterName-DP_Term)"/><xsl:text> |&#xa;</xsl:text>
        <xsl:text>| DP_DataParameters:parameterUnits:DP_Term | </xsl:text><xsl:value-of select="sum($varcountMetadataElements/results/parameterUnits-DP_Term)"/><xsl:text> |&#xa;</xsl:text>
        <xsl:text>| DP_DataParameters:parameterDeterminationInstrument:DP_Term | </xsl:text><xsl:value-of select="sum($varcountMetadataElements/results/parameterDeterminationInstrument-DP_Term)"/><xsl:text> |&#xa;</xsl:text>
        <xsl:text>| DP_DataParameters:parameterAnalysisMethod | </xsl:text><xsl:value-of select="sum($varcountMetadataElements/results/parameterAnalysisMethod)"/><xsl:text> |&#xa;</xsl:text>
        <xsl:text>| DP_DataParameters:parameterAnalysisMethod:DP_Term | </xsl:text><xsl:value-of select="sum($varcountMetadataElements/results/parameterAnalysisMethod-DP_Term)"/><xsl:text> |&#xa;</xsl:text>
        <xsl:text>| DP_DataParameters:platform:DP_Term | </xsl:text><xsl:value-of select="sum($varcountMetadataElements/results/platform-DP_Term)"/><xsl:text> |&#xa;</xsl:text>
        <xsl:text>| DP_DataParameters:parameterMinimumValue:FreeText | </xsl:text><xsl:value-of select="sum($varcountMetadataElements/results/parameterMinimumValue-FreeText)"/><xsl:text> |&#xa;</xsl:text>
        <xsl:text>| DP_DataParameters:parameterMaximumValue:FreeText | </xsl:text><xsl:value-of select="sum($varcountMetadataElements/results/parameterMaximumValue-FreeText)"/><xsl:text> |&#xa;</xsl:text>
        <xsl:text>| DP_DataParameters:parameterDescription:FreeText | </xsl:text><xsl:value-of select="sum($varcountMetadataElements/results/parameterDescription-FreeText)"/><xsl:text> |&#xa;</xsl:text>
        <xsl:text>| DP_DataParameters:termDefinition:FreeText | </xsl:text><xsl:value-of select="sum($varcountMetadataElements/results/termDefinition-FreeText)"/><xsl:text> |&#xa;</xsl:text>
        <xsl:text>| MD_Constraints:otherConstraints:FreeText | </xsl:text><xsl:value-of select="sum($varcountMetadataElements/results/otherConstraints)"/><xsl:text> |&#xa;</xsl:text>
        <xsl:text>| MD_DataIdentification:samplingFrequency | </xsl:text><xsl:value-of select="sum($varcountMetadataElements/results/samplingFrequency/@count)"/><xsl:text> |&#xa;</xsl:text>
        <xsl:for-each-group select="$varcountMetadataElements/results/samplingFrequency/MD_MaintenanceFrequencyCode" group-by="@codeListValue">
            <xsl:text>| MD_DataIdentification:samplingFrequency:MD_MaintenanceFrequencyCode (</xsl:text><xsl:value-of select="current-grouping-key()"/><xsl:text>) | </xsl:text><xsl:value-of select="count(current-group())"/><xsl:text> |&#xa;</xsl:text>
        </xsl:for-each-group>
        <xsl:text>| EX_TemporalExtent:currency | </xsl:text><xsl:value-of select="sum($varcountMetadataElements/results/currency/@count)"/><xsl:text> |&#xa;</xsl:text>
        <xsl:for-each-group select="$varcountMetadataElements/results/currency/MD_CurrencyTypeCode" group-by="@codeListValue">
            <xsl:text>| EX_TemporalExtent:currency:MD_CurrencyTypeCode (</xsl:text><xsl:value-of select="current-grouping-key()"/><xsl:text>) | </xsl:text><xsl:value-of select="count(current-group())"/><xsl:text> |&#xa;</xsl:text>
        </xsl:for-each-group>
        <xsl:text>| EX_TemporalExtent:temporalAggregation | </xsl:text><xsl:value-of select="sum($varcountMetadataElements/results/temporalAggregation/@count)"/><xsl:text> |&#xa;</xsl:text>
        <xsl:for-each-group select="$varcountMetadataElements/results/temporalAggregation/MD_TemporalAggregationUnitCode" group-by="@codeListValue">
            <xsl:text>| EX_TemporalExtent:temporalAggregation:MD_TemporalAggregationUnitCode (</xsl:text><xsl:value-of select="current-grouping-key()"/><xsl:text>) | </xsl:text><xsl:value-of select="count(current-group())"/><xsl:text> |&#xa;</xsl:text>
        </xsl:for-each-group>
        <xsl:text>| MD_DataIdentification:TC_TaxonomicCoverage | </xsl:text><xsl:value-of select="sum($varcountMetadataElements/results/TC_TaxonomicCoverage)"/><xsl:text> |&#xa;</xsl:text>
        <xsl:text>| CI_DateTypeCode (unknown) | </xsl:text><xsl:value-of select="sum($varcountMetadataElements/results/CI_DateTypeCode[@codeListValue = 'unknown'])"/><xsl:text> |&#xa;</xsl:text>
        <xsl:text>| CI_RoleCode (coInvestigator) | </xsl:text><xsl:value-of select="sum($varcountMetadataElements/results/CI_RoleCode[@codeListValue = 'coInvestigator'])"/><xsl:text> |&#xa;</xsl:text>
        <xsl:text>| CI_RoleCode (licensor) | </xsl:text><xsl:value-of select="sum($varcountMetadataElements/results/CI_RoleCode[@codeListValue = 'licensor'])"/><xsl:text> |&#xa;</xsl:text>
        <xsl:text>| CI_RoleCode (researchAssistant) | </xsl:text><xsl:value-of select="sum($varcountMetadataElements/results/CI_RoleCode[@codeListValue = 'researchAssistant'])"/><xsl:text> |&#xa;</xsl:text>
        <xsl:text>| CI_RoleCode (ipOwner) | </xsl:text><xsl:value-of select="sum($varcountMetadataElements/results/CI_RoleCode[@codeListValue = 'ipOwner'])"/><xsl:text> |&#xa;</xsl:text>
        <xsl:text>| CI_RoleCode (moralRightsOwner) | </xsl:text><xsl:value-of select="sum($varcountMetadataElements/results/CI_RoleCode[@codeListValue = 'moralRightsOwner'])"/><xsl:text> |&#xa;</xsl:text>
        <xsl:text>| CI_RoleCode (metadataContact) | </xsl:text><xsl:value-of select="sum($varcountMetadataElements/results/CI_RoleCode[@codeListValue = 'metadataContact'])"/><xsl:text> |&#xa;</xsl:text>
        <xsl:text>| MD_ScopeCode (observed) | </xsl:text><xsl:value-of select="sum($varcountMetadataElements/results/MD_ScopeCode[@codeListValue = 'observed'])"/><xsl:text> |&#xa;</xsl:text>
        <xsl:text>| MD_ScopeCode (derived) | </xsl:text><xsl:value-of select="sum($varcountMetadataElements/results/MD_ScopeCode[@codeListValue = 'derived'])"/><xsl:text> |&#xa;</xsl:text>
        <xsl:text>| MD_ScopeCode (publication) | </xsl:text><xsl:value-of select="sum($varcountMetadataElements/results/MD_ScopeCode[@codeListValue = 'publication'])"/><xsl:text> |&#xa;</xsl:text>
        <xsl:text>| MD_ScopeCode (dataObject) | </xsl:text><xsl:value-of select="sum($varcountMetadataElements/results/MD_ScopeCode[@codeListValue = 'dataObject'])"/><xsl:text> |&#xa;</xsl:text>
        <xsl:text>| MD_ScopeCode (project) | </xsl:text><xsl:value-of select="sum($varcountMetadataElements/results/MD_ScopeCode[@codeListValue = 'project'])"/><xsl:text> |&#xa;</xsl:text>
        <xsl:text>&#xa;</xsl:text>
    </xsl:template>


</xsl:stylesheet>

<!--&lt;!&ndash;        <xsl:variable name="orgName-contributors-set" as="node()*">&ndash;&gt;-->
<!--&lt;!&ndash;            <xsl:call-template name="findOrgNameMatchedRecords">&ndash;&gt;-->
<!--&lt;!&ndash;                <xsl:with-param name="pot_text" select="'Point of truth URL of this metadata record'"/>&ndash;&gt;-->
<!--&lt;!&ndash;            </xsl:call-template>&ndash;&gt;-->
<!--&lt;!&ndash;        </xsl:variable>&ndash;&gt;-->

<!--&lt;!&ndash;        <xsl:text>&#xa;orgName, </xsl:text>&ndash;&gt;-->
<!--&lt;!&ndash;        <xsl:value-of select="count($orgName-contributors-set)"/>&ndash;&gt;-->

<!--&lt;!&ndash;        <xsl:for-each select="distinct-values($orgName-contributors-set)">&ndash;&gt;-->
<!--&lt;!&ndash;            <xsl:variable name="orgName-contributor" select="." />&ndash;&gt;-->
<!--&lt;!&ndash;            <xsl:variable name="orgName-contributor-records" as="node()*">&ndash;&gt;-->
<!--&lt;!&ndash;                <xsl:call-template name="getOrganisationNameMatchedRecords">&ndash;&gt;-->
<!--&lt;!&ndash;                    <xsl:with-param name="orgName" select="$orgName-contributor"/>&ndash;&gt;-->
<!--&lt;!&ndash;                </xsl:call-template>&ndash;&gt;-->
<!--&lt;!&ndash;            </xsl:variable>&ndash;&gt;-->

<!--&lt;!&ndash;            <xsl:text>&#xa;</xsl:text><xsl:value-of select="$orgName-contributor"/><xsl:text>, </xsl:text>&ndash;&gt;-->
<!--&lt;!&ndash;            <xsl:value-of select="count($orgName-contributor-records)"/>&ndash;&gt;-->

<!--&lt;!&ndash;        </xsl:for-each>&ndash;&gt;-->

<!--&lt;!&ndash;        <xsl:for-each select="distinct-values($orgName-contributors-set)">&ndash;&gt;-->
<!--&lt;!&ndash;            <xsl:variable name="orgName-contributor" select="." />&ndash;&gt;-->

<!--&lt;!&ndash;            <xsl:variable name="orgName-contributor-records" as="node()*">&ndash;&gt;-->
<!--&lt;!&ndash;                <xsl:call-template name="getOrganisationNameMatchedRecords">&ndash;&gt;-->
<!--&lt;!&ndash;                    <xsl:with-param name="orgName" select="$orgName-contributor"/>&ndash;&gt;-->
<!--&lt;!&ndash;                </xsl:call-template>&ndash;&gt;-->
<!--&lt;!&ndash;            </xsl:variable>&ndash;&gt;-->

<!--&lt;!&ndash;            <xsl:variable name="orgName-varcountMetadataElements">&ndash;&gt;-->
<!--&lt;!&ndash;                <xsl:call-template name="countMetadataElements">&ndash;&gt;-->
<!--&lt;!&ndash;                    <xsl:with-param name="records" select="$orgName-contributor-records"/>&ndash;&gt;-->
<!--&lt;!&ndash;                </xsl:call-template>&ndash;&gt;-->
<!--&lt;!&ndash;            </xsl:variable>&ndash;&gt;-->

<!--&lt;!&ndash;            <xsl:call-template name="printOutput">&ndash;&gt;-->
<!--&lt;!&ndash;                <xsl:with-param name="contributor" select="$orgName-contributor"/>&ndash;&gt;-->
<!--&lt;!&ndash;                <xsl:with-param name="varcountMetadataElements" select="$orgName-varcountMetadataElements"/>&ndash;&gt;-->
<!--&lt;!&ndash;            </xsl:call-template>&ndash;&gt;-->

<!--&lt;!&ndash;        </xsl:for-each>&ndash;&gt;-->

<!--        <xsl:variable name="varcountMetadataElements">-->
<!--            <xsl:call-template name="countMetadataElements">-->
<!--                <xsl:with-param name="records" select="$unknown-contributors-records"/>-->
<!--            </xsl:call-template>-->
<!--        </xsl:variable>-->

<!--        <xsl:call-template name="printOutput">-->
<!--            <xsl:with-param name="contributor" select="'Unknown'"/>-->
<!--            <xsl:with-param name="varcountMetadataElements" select="$varcountMetadataElements"/>-->
<!--        </xsl:call-template>-->

<!--    </xsl:template>-->

<!--    &lt;!&ndash; List contributors orgName &ndash;&gt;-->
<!--    <xsl:template name="findOrgNameMatchedRecords">-->
<!--        <xsl:param name="pot_text"/>-->
<!--        <xsl:for-each select="gmd:distributionInfo" >-->
<!--            <xsl:choose>-->
<!--                <xsl:when test="not(.//gmd:CI_OnlineResource/gmd:description/gco:CharacterString[text()= $pot_text])">-->
<!--                    <xsl:copy-of select=".//gmd:distributor//gmd:organisationName/gco:CharacterString" />-->
<!--                </xsl:when>-->
<!--            </xsl:choose>-->
<!--        </xsl:for-each>-->
<!--    </xsl:template>-->

<!--    &lt;!&ndash; List metadata records with provided contributor's Point of Truth URL &ndash;&gt;-->
<!--    <xsl:template name="getOrganisationNameMatchedRecords" as="node()*">-->
<!--        <xsl:param name="orgName"/>-->

<!--        <xsl:for-each select="gmd:distributionInfo" >-->
<!--            <xsl:choose>-->
<!--                <xsl:when test=".//gmd:distributor//gmd:organisationName/gco:CharacterString[starts-with(., $orgName)]">-->
<!--                    <xsl:copy-of select="./ancestor-or-self::node()/gmd:fileIdentifier/gco:CharacterString/node()"/>-->
<!--                </xsl:when>-->
<!--            </xsl:choose>-->
<!--        </xsl:for-each>-->
<!--    </xsl:template>-->





