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
                xmlns:mda="http://standards.iso.org/iso/19115/-3/mda/2.0"
                xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/2.0"
                xmlns:mdt="http://standards.iso.org/iso/19115/-3/mdt/2.0"
                xmlns:mex="http://standards.iso.org/iso/19115/-3/mex/1.0"
                xmlns:mic="http://standards.iso.org/iso/19115/-3/mic/1.0"
                xmlns:mil="http://standards.iso.org/iso/19115/-3/mil/1.0"
                xmlns:mrl="http://standards.iso.org/iso/19115/-3/mrl/2.0"
                xmlns:mds="http://standards.iso.org/iso/19115/-3/mds/2.0"
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
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                xmlns:mcp="http://schemas.aodn.org.au/mcp-2.0"
                exclude-result-prefixes="#all">

  <xsl:import href="utility/create19115-3Namespaces.xsl"/>
  <xsl:import href="utility/dateTime.xsl"/>
  <xsl:import href="utility/multiLingualCharacterStrings.xsl"/>
  <xsl:import href="utility/mcpStandardInfo.xsl"/>

  <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
    <xd:desc>
      <xd:p>
        <xd:b>Created on:</xd:b>March 8, 2014 </xd:p>
      <xd:p>Translates from ISO 19139 for ISO 19115 and ISO 19139-2 for 19115-2 to ISO 19139-1 for ISO 19115-1</xd:p>
      <xd:p>
        <xd:b>Version June 13, 2014</xd:b>
        <xd:ul>
          <xd:li>Converged the 19115-2 transform into 19115-1 namespaces</xd:li>
        </xd:ul>
      </xd:p>
      <xd:p>
        <xd:b>Version August 7, 2014</xd:b>
        <xd:ul>
          <xd:li>Changed namespace dates to 2014-07-11</xd:li>
          <xd:li>Fixed DistributedComputingPlatform element</xd:li>
        </xd:ul>
      </xd:p>
      <xd:p>
        <xd:b>Version August 15, 2014</xd:b>
        <xd:ul>
          <xd:li>Add multilingual metadata support by converting gmd:locale and copying gmd:PT_FreeText and element attributes (eg. gco:nilReason, xsi:type) for gmd:CharacterString elements (Author:
            fx.prunayre@gmail.com).</xd:li>
        </xd:ul>
      </xd:p>
      <xd:p>
        <xd:b>Version September 4, 2014</xd:b>
        <xd:ul>
          <xd:li>Added transform for MD_FeatureCatalogueDescription (problem identified by Tobias Spears</xd:li>
        </xd:ul>
      </xd:p>
      <xd:p>
        <xd:b>Version February 5, 2015</xd:b>
        <xd:ul>
          <xd:li>Update to 2014-12-25 version</xd:li>
        </xd:ul>
      </xd:p>
      <xd:p><xd:b>Author:</xd:b>thabermann@hdfgroup.org</xd:p>
      <xd:p>
        <xd:b>Version May 15, 2019</xd:b>
        <xd:ul>
          <xd:li>Update to 2018-12 and mcp-3.0 version</xd:li>
        </xd:ul>
      </xd:p>
      <xd:p><xd:b>Author:</xd:b>simon.pigot@csiro.au</xd:p>
    </xd:desc>
  </xd:doc>

  <xsl:output method="xml" indent="yes"/>

  <xsl:strip-space elements="*"/>

  <xsl:variable name="stylesheetVersion" select="'0.1'"/>


  <xsl:template match="/">
    <!--
    root element (MD_Metadata or MI_Metadata)
    -->
    <xsl:for-each select="/*">
      <xsl:variable name="nameSpacePrefix">
        <xsl:call-template name="getNamespacePrefix"/>
      </xsl:variable>

      <xsl:element name="mdb:MD_Metadata">
        <xsl:attribute name="xsi:schemaLocation">http://standards.iso.org/iso/19115/-3/cat/1.0 http://standards.iso.org/iso/19115/-3/cat/1.0/cat.xsd http://standards.iso.org/iso/19115/-3/cit/2.0 http://standards.iso.org/iso/19115/-3/cit/2.0/cit.xsd http://standards.iso.org/iso/19115/-3/gcx/1.0 http://standards.iso.org/iso/19115/-3/gcx/1.0/gcx.xsd http://standards.iso.org/iso/19115/-3/gex/1.0 http://standards.iso.org/iso/19115/-3/gex/1.0/gex.xsd http://standards.iso.org/iso/19115/-3/lan/1.0 http://standards.iso.org/iso/19115/-3/lan/1.0/lan.xsd http://standards.iso.org/iso/19115/-3/srv/2.0 http://standards.iso.org/iso/19115/-3/srv/2.0/srv.xsd http://standards.iso.org/iso/19115/-3/mas/1.0 http://standards.iso.org/iso/19115/-3/mas/1.0/mas.xsd http://standards.iso.org/iso/19115/-3/mcc/1.0 http://standards.iso.org/iso/19115/-3/mcc/1.0/mcc.xsd http://standards.iso.org/iso/19115/-3/mco/1.0 http://standards.iso.org/iso/19115/-3/mco/1.0/mco.xsd http://standards.iso.org/iso/19115/-3/mda/2.0 http://standards.iso.org/iso/19115/-3/mda/2.0/mda.xsd http://standards.iso.org/iso/19115/-3/mdb/2.0 http://standards.iso.org/iso/19115/-3/mdb/2.0/mdb.xsd http://standards.iso.org/iso/19115/-3/mds/2.0 http://standards.iso.org/iso/19115/-3/mds/2.0/mds.xsd http://standards.iso.org/iso/19115/-3/mdt/2.0 http://standards.iso.org/iso/19115/-3/mdt/2.0/mdt.xsd http://standards.iso.org/iso/19115/-3/mex/1.0 http://standards.iso.org/iso/19115/-3/mex/1.0/mex.xsd http://standards.iso.org/iso/19115/-3/mmi/1.0 http://standards.iso.org/iso/19115/-3/mmi/1.0/mmi.xsd http://standards.iso.org/iso/19115/-3/mpc/1.0 http://standards.iso.org/iso/19115/-3/mpc/1.0/mpc.xsd http://standards.iso.org/iso/19115/-3/mrc/2.0 http://standards.iso.org/iso/19115/-3/mrc/2.0/mrc.xsd http://standards.iso.org/iso/19115/-3/mrd/1.0 http://standards.iso.org/iso/19115/-3/mrd/1.0/mrd.xsd http://standards.iso.org/iso/19115/-3/mri/1.0 http://standards.iso.org/iso/19115/-3/mri/1.0/mri.xsd http://standards.iso.org/iso/19115/-3/mrl/2.0 http://standards.iso.org/iso/19115/-3/mrl/2.0/mrl.xsd http://standards.iso.org/iso/19115/-3/mrs/1.0 http://standards.iso.org/iso/19115/-3/mrs/1.0/mrs.xsd http://standards.iso.org/iso/19115/-3/msr/2.0 http://standards.iso.org/iso/19115/-3/msr/2.0/msr.xsd http://standards.iso.org/iso/19157/-2/mdq/1.0 http://standards.iso.org/iso/19157/-2/mdq/1.0/mdq.xsd http://standards.iso.org/iso/19115/-3/mac/2.0 http://standards.iso.org/iso/19115/-3/mac/2.0/mac.xsd http://standards.iso.org/iso/19115/-3/gco/1.0 http://standards.iso.org/iso/19115/-3/gco/1.0/gco.xsd http://standards.iso.org/iso/19115/-3/gmw/1.0 http://standards.iso.org/iso/19115/-3/gmw/1.0/gmw.xsd http://www.opengis.net/gml/3.2 http://schemas.opengis.net/gml/3.2.1/gml.xsd http://www.w3.org/1999/xlink http://www.w3.org/1999/xlink.xsd</xsl:attribute>
        <!-- new namespaces -->
        <xsl:call-template name="add-iso19115-3-namespaces"/>

        <xsl:apply-templates select="gmd:fileIdentifier" mode="from19139to19115-3"/>
        <xsl:apply-templates select="gmd:language" mode="from19139to19115-3"/>
        <xsl:apply-templates select="gmd:characterSet" mode="from19139to19115-3"/>
        <xsl:apply-templates select="gmd:parentIdentifier" mode="from19139to19115-3"/>
        <xsl:apply-templates select="gmd:hierarchyLevel" mode="from19139to19115-3"/>
        <xsl:apply-templates select="gmd:contact" mode="from19139to19115-3"/>
        <xsl:apply-templates select="mcp:metadataContactInfo" mode="from19139to19115-3"/>
        <xsl:apply-templates select="gmd:dateStamp" mode="from19139to19115-3"/>
        <xsl:apply-templates select="mcp:revisionDate" mode="from19139to19115-3"/>
        <!--<xsl:apply-templates select="gmd:metadataStandardName" mode="from19139to19115-3"/>-->
        <xsl:call-template name="mcpStandardInfo"/>
        <xsl:apply-templates select="gmd:locale" mode="from19139to19115-3"/>
        <xsl:apply-templates select="gmd:distributionInfo//gmd:onLine[descendant::gmd:protocol[gcoold:CharacterString='WWW:LINK-1.0-http--metadata-URL']]" mode="mcpmetadatalinkage"/>
        <xsl:apply-templates select="gmd:spatialRepresentationInfo" mode="from19139to19115-3"/>
        <xsl:apply-templates select="gmd:referenceSystemInfo" mode="from19139to19115-3"/>
        <xsl:apply-templates select="gmd:metadataExtensionInfo" mode="from19139to19115-3"/>
        <xsl:apply-templates select="gmd:identificationInfo" mode="from19139to19115-3"/>
        <xsl:apply-templates select="gmd:contentInfo" mode="from19139to19115-3"/>
        <!-- Slot mcp:dataParameters into place where contentInfo lives -->
        <xsl:apply-templates select="gmd:identificationInfo//mcp:dataParameters" mode="from19139to19115-3"/>
        <xsl:call-template name="onlineSourceDispatcher">
          <xsl:with-param name="type" select="'featureCatalogueCitation'"/>
        </xsl:call-template>

        <xsl:apply-templates select="gmd:distributionInfo" mode="from19139to19115-3"/>
        <xsl:apply-templates select="gmd:dataQualityInfo" mode="from19139to19115-3"/>
        <xsl:apply-templates select="gmd:portrayalCatalogueInfo" mode="from19139to19115-3"/>
        <xsl:call-template name="onlineSourceDispatcher">
          <xsl:with-param name="type" select="'portrayalCatalogueCitation'"/>
        </xsl:call-template>

        <xsl:apply-templates select="gmd:metadataConstraints" mode="from19139to19115-3"/>
        <xsl:apply-templates select="gmd:applicationSchemaInfo" mode="from19139to19115-3"/>
        <xsl:apply-templates select="gmd:metadataMaintenance" mode="from19139to19115-3"/>
        <xsl:apply-templates select="gmi:acquisitionInformation" mode="from19139to19115-3"/>
        <!-- Slot mcp:dataParameters (platform & instrument) into place where acquisitionInformation lives -->
        <xsl:apply-templates select="gmd:identificationInfo//mcp:dataParameters" mode="from19139to19115-3-acquisition"/>
      </xsl:element>
    </xsl:for-each>
  </xsl:template>

  <xsl:include href="mapping/core.xsl"/>
  <xsl:include href="mapping/CI_ResponsibleParty.xsl"/>
  <xsl:include href="mapping/CI_Citation.xsl"/>
  <xsl:include href="mapping/SRV.xsl"/>
  <xsl:include href="mapping/DQ.xsl"/>
  <xsl:include href="mapping/mcpdataparameters_aodn.xsl"/>
  <xsl:include href="mapping/mcpmetadatalinkage.xsl"/>

  <!-- Depending on the function of online source in ISO19139,
  categorized them in more descriptive sections. -->
  <xsl:variable name="onlineFunctionMap">
    <entry key="portrayalCatalogueCitation" value="information.portrayal"/>
    <entry key="additionalDocumentation" ns="mrl" value="information.lineage" type="dq"/>
    <entry key="specification" value="information.qualitySpecification" type="dq"/>
    <entry key="reportReference" value="information.qualityReport" type="dq"/>
    <entry key="featureCatalogueCitation" value="information.content"/>
  </xsl:variable>

  <xsl:template match="gmd:onLine[*/gmd:function/*/@codeListValue = $onlineFunctionMap/entry/@value]"
                mode="from19139to19115-3"
                priority="200"/>

  <xsl:template name="onlineSourceDispatcher">
    <xsl:param name="type" as="xs:string"/>

    <xsl:for-each select="(.|ancestor::gmd:MD_Metadata)/descendant::gmd:CI_OnlineResource[
                    gmd:function/*/@codeListValue = $onlineFunctionMap/entry[@key = $type]/@value
                    ]">
    <!-- Convert onlineSource to a citation in the corresponding element. -->
    <xsl:choose>
      <xsl:when test="$type = 'portrayalCatalogueCitation'">
        <mdb:portrayalCatalogueInfo>
          <mpc:MD_PortrayalCatalogueReference>
            <mpc:portrayalCatalogueCitation>
              <xsl:call-template name="buildCitation"/>
            </mpc:portrayalCatalogueCitation>
          </mpc:MD_PortrayalCatalogueReference>
        </mdb:portrayalCatalogueInfo>
      </xsl:when>
      <xsl:when test="$type = 'featureCatalogueCitation'">
        <mdb:contentInfo>
          <mrc:MD_FeatureCatalogueDescription>
            <mrc:featureCatalogueCitation>
              <xsl:call-template name="buildCitation"/>
            </mrc:featureCatalogueCitation>
          </mrc:MD_FeatureCatalogueDescription>
        </mdb:contentInfo>
      </xsl:when>
      <xsl:when test="$type = 'specification'">
        <mdq:report>
          <mdq:DQ_DomainConsistency>
            <mdq:result>
              <mdq:DQ_ConformanceResult>
                <mdq:specification>
                  <xsl:call-template name="buildCitation">
                    <xsl:with-param name="withDescription" select="false()"/>
                  </xsl:call-template>
                </mdq:specification>

                <xsl:call-template name="writeCharacterStringElement">
                  <xsl:with-param name="elementName" select="'mdq:explanation'"/>
                  <xsl:with-param name="nodeWithStringToWrite" select="gmd:description"/>
                </xsl:call-template>

                <mdq:pass>
                  <gco:Boolean>true</gco:Boolean>
                </mdq:pass>
              </mdq:DQ_ConformanceResult>
            </mdq:result>
          </mdq:DQ_DomainConsistency>
        </mdq:report>
      </xsl:when>
      <xsl:when test="$type = 'reportReference'">
        <mdq:standaloneQualityReport>
          <mdq:DQ_StandaloneQualityReportInformation>
            <mdq:reportReference>
              <xsl:call-template name="buildCitation">
                <xsl:with-param name="withDescription" select="false()"/>
              </xsl:call-template>
            </mdq:reportReference>

            <xsl:call-template name="writeCharacterStringElement">
              <xsl:with-param name="elementName" select="'mdq:abstract'"/>
              <xsl:with-param name="nodeWithStringToWrite" select="gmd:description"/>
            </xsl:call-template>

          </mdq:DQ_StandaloneQualityReportInformation>
        </mdq:standaloneQualityReport>
      </xsl:when>
      <xsl:when test="$type = 'additionalDocumentation'">
        <xsl:element name="{concat($onlineFunctionMap/entry[@key = $type]/@ns, ':', $type)}">
          <xsl:call-template name="buildCitation"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>Unsupported type: <xsl:value-of select="$type"/></xsl:message>
      </xsl:otherwise>
    </xsl:choose>

    </xsl:for-each>
  </xsl:template>

  <xsl:template name="buildCitation">
    <xsl:param name="withDescription" select="true()"/>
    <cit:CI_Citation>
      <xsl:call-template name="writeCharacterStringElement">
        <xsl:with-param name="elementName" select="'cit:title'"/>
        <xsl:with-param name="nodeWithStringToWrite" select="gmd:name"/>
      </xsl:call-template>

      <cit:onlineResource>
        <cit:CI_OnlineResource>
          <xsl:apply-templates select="gmd:linkage"
                               mode="from19139to19115-3"/>
          <xsl:apply-templates select="gmd:protocol"
                               mode="from19139to19115-3"/>
          <xsl:apply-templates select="gmd:applicationProfile"
                               mode="from19139to19115-3"/>

          <xsl:if test="$withDescription">
            <xsl:call-template name="writeCharacterStringElement">
              <xsl:with-param name="elementName" select="'cit:description'"/>
              <xsl:with-param name="nodeWithStringToWrite" select="gmd:description"/>
            </xsl:call-template>
          </xsl:if>

          <xsl:apply-templates select="gmd:function"
                               mode="from19139to19115-3"/>
        </cit:CI_OnlineResource>
      </cit:onlineResource>
    </cit:CI_Citation>
  </xsl:template>
</xsl:stylesheet>
