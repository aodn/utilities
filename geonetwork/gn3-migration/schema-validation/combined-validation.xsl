<?xml version="1.0" encoding="UTF-8"?>

<!-- Templates -->
<!-- iso19139           b836f4df-3576-4151-8a89-f92b7e4a48bc -->
<!-- iso19139.mcp       e8c0865c-8493-4dd8-b9f6-0da85055bd57 -->
<!-- iso19139.mcp-1.4   d6cf3c60-9f49-4fb5-9125-27043dc9e7e9 -->
<!-- iso19139.mcp-1.4   308784f4-11ac-45f5-a489-078044420c33 -->

<!-- Records using http://bluenet3.antcrc.utas.edu.au/mcp-1.5-experimental/schema.xsd -->
<!-- These are not validated -->
<!-- iso19139.mcp e76a13e0-3402-11dc-849f-00188b4c0af8 -->
<!-- iso19139.mcp 0292f830-723d-11dc-a0c6-00188b4c0af8 -->

<!-- TODO: produce report listing records for items where post transform manual updates are to be performed -->

<xsl:stylesheet   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                  xmlns:gml="http://www.opengis.net/gml"
                  xmlns:gco="http://www.isotc211.org/2005/gco"
                  xmlns:gmd="http://www.isotc211.org/2005/gmd"
                  xmlns:mcp="http://bluenet3.antcrc.utas.edu.au/mcp"
                  xmlns:gmx="http://www.isotc211.org/2005/gmx"
                  xmlns:xlink="http://www.w3.org/1999/xlink">

<!--              xmlns:mcp="http://schemas.aodn.org.au/mcp-2.0"-->

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*"/>

    <!-- identity transform -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- MISSING VALUES -->

    <!-- iso19139 `<gco:Decimal/> missing value. Apply nilReason and remove <gco:Decimal/>-->
    <!-- post manual values enter? -->
    <xsl:template match="gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude|gmd:eastBoundLongitude|gmd:southBoundLatitude|gmd:northBoundLatitude[gco:Decimal='']">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp `<gco:Decimal/> missing value. Apply nilReason and remove <gco:Decmimal/> -->
    <!-- post manual values enter? -->
    <xsl:template match="//gmd:westBoundLongitude[gco:Decimal[not(node())]]|
        //gmd:eastBoundLongitude[gco:Decimal[not(node())]]|
        //gmd:southBoundLatitude[gco:Decimal[not(node())]]|
        //gmd:northBoundLatitude[gco:Decimal[not(node())]]">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp-1.4 `<gco:Decimal/> missing value. Apply nilReason and remove <gco:Decimal/>-->
    <!-- post manual values enter? -->
    <xsl:template match="gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude|gmd:eastBoundLongitude|gmd:southBoundLatitude|gmd:northBoundLatitude[gco:Decimal='']">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp-2.0 `<gco:Decimal/> missing value. Apply nilReason and remove <gco:Decimal/>-->
    <!-- post manual values enter? -->
    <xsl:template match="gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude|gmd:eastBoundLongitude|gmd:southBoundLatitude|gmd:northBoundLatitude[gco:Decimal='']">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp `<gco:Real/> missing value. Apply nilReason and remove <gco:Real/> -->
    <!-- post manual check? -->
    <xsl:template match="//gmd:maximumValue[gco:Real[not(node())]]|//gmd:minimumValue[gco:Real[not(node())]]">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp-1.4 `<gco:Real/> missing value. Apply nilReason and remove <gco:Real/> -->
    <!-- post manual check? -->
    <xsl:template match="//gmd:maximumValue[gco:Real[not(node())]]|//gmd:minimumValue[gco:Real[not(node())]]">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp-2.0 `<gco:Real/> missing value. Apply nilReason and remove <gco:Real/> -->
    <!-- post manual check?  parameters?-->
    <xsl:template match="//gmd:maximumValue[gco:Real[not(node())]]|//gmd:minimumValue[gco:Real[not(node())]]">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp-1.4 `<gco:Integer/>` missing value -->
    <!-- post manual check? -->
    <xsl:template match="gmd:denominator[gco:Integer = '']">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp `<gco:Integer/>` missing value -->
    <!-- post manual check? -->
    <xsl:template match="gmd:denominator[gco:Integer = '']|gmd:numberOfDimensions[gco:Integer = '']|gmd:dimensionSize[gco:Integer = '']">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp-2.0 `<gco:Integer/>` missing value -->
    <!-- post manual check? -->
    <xsl:template match="gmd:denominator[gco:Integer = '']">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp `<gco:Boolean/>` missing value -->
    <!-- pre transform check missing/true/false -->
    <xsl:template match="gmd:transformationParameterAvailability[gco:Boolean = '']">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <!-- iso19139 <gco:DateTime/> missing value -->
    <xsl:template match="gmd:date[gco:DateTime = '']">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp `<gco:DateTime/>` missing value -->
    <xsl:template match="gmd:CI_Date/gmd:date[gco:DateTime = '']">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp `gco:DateTime missing value -->
    <xsl:template match="gmd:dateStamp[gco:DateTime = '']">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp-1.4 `<gco:DateTime/>` missing value -->
    <xsl:template match="gmd:CI_Date/gmd:date[gco:DateTime = '']">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp-1.4 `<gco:DateTime/>` missing value -->
    <xsl:template match="gmd:dateStamp[gco:DateTime = '']">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp-2.0 `<gco:DateTime/>` missing value -->
    <xsl:template match="gmd:CI_Date/gmd:date[gco:DateTime = '']">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp `<gco:Date/>` missing value -->
    <xsl:template match="gmd:CI_Date/gmd:date[gco:Date = '']|gmd:dateOfNextUpdate[gco:Date = '']">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp-1.4 `<gco:Date/>` missing value -->
    <xsl:template match="gmd:CI_Date/gmd:date[gco:Date = '']">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <!-- iso19139 gco:Distance missing value -->
    <!-- where is Distance being used -->
    <xsl:template match="gmd:distance[gco:Distance = '']">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <!-- iso19139 `<gmd:MD_TopicCategoryCode/>` missing value -->
    <!-- make sure there is at least on Topic Category (if none add "oceans") -->
    <xsl:template match="gmd:topicCategory[gmd:MD_TopicCategoryCode = '']">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp gmd:MD_TopicCategoryCode missing value -->
    <!-- make sure there is at least on Topic Category (if none add "oceans") -->
    <xsl:template match="gmd:topicCategory[gmd:MD_TopicCategoryCode = '']">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="gmd:topicCategory/gmd:MD_TopicCategoryCode[. = '']" />

    <!-- iso19139.mcp-2.0 `<mcp:DP_DataParameter/>` missing value -->
    <xsl:template match="mcp:dataParameter[mcp:DP_DataParameter = '']">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <!-- INVALID VALUES (other than '') -->

    <!-- iso19139.mcp `<gco:Integer/> Invalid integer value. Remove invalid characters -->
    <!-- allow for negative -->
    <!-- check and fix before transform -->
    <xsl:template match="gco:Integer[not(number(.))]/text()">
        <xsl:value-of select="replace(., '[^0-9]', '')"/>
    </xsl:template>

    <!-- iso19139.mcp gco:Real value is not a number -->
    <!-- check and fix before transform -->
    <xsl:template match="//gmd:minimumValue[gco:Real[string(number(node())) = 'NaN']]">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp gco:DateTime missing date removed and labelled missing -->
    <!-- check and fix? before transform -->
    <xsl:template match="gmd:plannedAvailableDateTime[gco:DateTime[text()[substring-before(.,'T') = '']]]">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp-1.4 gco:DateTime missing time replaced with gco:Date -->
    <xsl:template match="gco:DateTime[text()[not(contains(., 'T'))]]">
        <gco:Date><xsl:value-of select="."/></gco:Date>
    </xsl:template>

    <!-- iso19139.mcp-2.0 gco:DateTime missing time replaced with gco:Date -->
    <xsl:template match="gco:DateTime[text()[not(contains(., 'T'))]]">
        <gco:Date><xsl:value-of select="."/></gco:Date>
    </xsl:template>

    <!-- iso19139.mcp gco:DateTime missing time replaced with gco:Date -->
    <!-- Non ISO date formats corrected -->
    <!-- check and fix before transform -->
    <xsl:template match="gco:DateTime[text()[not(contains(., 'T'))]]">
        <xsl:choose>
            <xsl:when test=".='1/2/2015'">
                <!--
                    0bef875d-5f77-4b31-bd56-de73fafc2b2e
                    c5a37946-a6cc-463e-be28-711b785d0f9f
                    da7dba82-ef56-426a-bb19-843e5e7e72d8
                -->
                <gco:Date><xsl:value-of select="'2015-02-01'"/></gco:Date>
            </xsl:when>
            <xsl:when test="'.=1/1/2015'">
                <!--
                    45c37065-6aeb-4f31-b107-1a39a977df6f
                    4dae96c7-5be0-4b1d-9a01-160812886a91
                -->
                <gco:Date><xsl:value-of select="'2015-01-01'"/></gco:Date>
            </xsl:when>
            <xsl:when test="'.=2/2/2015'">
                <!--
                    d3169300-ba62-4ac1-823a-0bc43909f8e7
                -->
                <gco:Date><xsl:value-of select="'2015-02-02'"/></gco:Date>
            </xsl:when>
            <xsl:when test="'.=1/2/2008'">
                <!--
                    7d0b4a53-1863-4600-92a4-d385c88e9be9
                -->
                <gco:Date><xsl:value-of select="'2008-02-01'"/></gco:Date>
            </xsl:when>
            <xsl:otherwise>
                <gco:Date><xsl:value-of select="."/></gco:Date>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- iso19139.mcp <gmd:MD_TopicCategoryCode>climatology/meteorology/atmosphere</gmd:MD_TopicCategoryCode> not in enumeration -->
    <xsl:template match="//gmd:MD_TopicCategoryCode[text() = 'climatology/meteorology/atmosphere']">
        <xsl:copy>
            <xsl:value-of select="'climatologyMeteorologyAtmosphere'"/>
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp-1.4 <gmd:minimumValue> or <gmd:maximumValue> invalid 'n/a' value. Apply nilReason and remove <gco:Real/> -->
    <!-- check and fix? before transform -->
    <xsl:template match="//gmd:maximumValue[gco:Real = 'n/a']|//gmd:minimumValue[gco:Real = 'n/a']">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp-2.0 gmx:Anchor Incorrectly formatted href -->
    <xsl:template match="gmx:Anchor/@xlink:href">
        <xsl:attribute name="xlink:href" select="concat(substring-before(.,'?'),'?',encode-for-uri(substring-after(.,'?')))"/>
    </xsl:template>

    <!-- MISSING CHILD NODES -->

    <!-- iso19139 `<gmd:CI_Date/>` missing <gmd:date> is added with nilReason -->
    <xsl:template match="gmd:CI_Date[not(gmd:date)]">
        <xsl:copy>
            <gmd:date gco:nilReason="missing" />
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp-1.4 `<gmd:CI_Date/>` missing <gmd:date> is added with nilReason -->
    <xsl:template match="gmd:CI_Date[not(gmd:date)]">
        <xsl:copy>
            <gmd:date gco:nilReason="missing" />
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>

    <!--iso19139.mcp-2.0 <gml:TimePeriod> without endPosition -->
    <xsl:template match="gml:TimePeriod[gml:beginPosition][not(gml:endPosition)]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <gml:endPosition indeterminatePosition="unknown" />
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp gmd:EX_VerticalExtent missing gmd:minimumValue, maximumValue and verticalCRS  -->
    <xsl:template match="gmd:EX_VerticalExtent[not(gmd:minimumValue) and not(gmd:maximumValue) and not(gmd:verticalCRS)]">
        <xsl:copy>
            <gmd:minimumValue gco:nilReason="missing" />
            <gmd:maximumValue gco:nilReason="missing" />
            <gmd:verticalCRS gco:nilReason="missing" />
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp-1.4 `<gmd:EX_VerticalExtent>` missing <gmd:verticalCRS> is added with nilReason -->
    <xsl:template match="gmd:EX_VerticalExtent[not(gmd:verticalCRS)]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <gmd:verticalCRS gco:nilReason="missing" />
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp gmd:EX_VerticalExtent missing verticalCRS  -->
    <xsl:template match="gmd:EX_VerticalExtent[not(gmd:verticalCRS) and gmd:minimumValue and gmd:maximumValue]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <gmd:verticalCRS gco:nilReason="missing" />
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp-2.0 gmd:EX_VerticalExtent missing verticalCRS  -->
    <xsl:template match="gmd:EX_VerticalExtent[not(gmd:verticalCRS)]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <gmd:verticalCRS gco:nilReason="missing" />
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp gml:VerticalCRS missing child verticalDatum or usesVerticalDatum -->
    <xsl:template match="gml:VerticalCRS">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <xsl:if test="not(./gml:usesVerticalDatum) and not(./gml:verticalDatum)">
                <gml:usesVerticalDatum nilReason="missing"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp-1.4  <gm1:verticalCRS/>. Add <gml:verticalDatum/> -->
    <xsl:template match="gml:VerticalCRS[not(gml:verticalDatum)]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <gml:verticalDatum />
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp-2.0 <gm1:verticalCRS/>. Add <gml:verticalDatum/> -->
    <xsl:template match="gml:VerticalCRS[not(gml:verticalDatum)]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <gml:verticalDatum />
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp mcp:MD_DataIdentification missing gmd:language  Add in correct order -->
    <!-- check and fix? before transform, make eng? -->
    <xsl:template match="mcp:MD_DataIdentification[not(gmd:language)]">
        <xsl:copy>
            <xsl:apply-templates select="@*" />
            <xsl:for-each select="node()">
                <xsl:choose>
                    <xsl:when test="not(self::gmd:characterSet)">
                        <xsl:apply-templates select="." />
                    </xsl:when>
                    <xsl:otherwise>
                        <gmd:language gco:nilReason="missing" />
                        <xsl:copy-of select="." />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp gmd:EX_BoundingPolygon missing children -->
    <xsl:template match="gmd:EX_BoundingPolygon[not(*)]">
        <xsl:copy>
            <gmd:polygon gco:nilReason="missing" />
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp gmd:CI_Citation missing gmd:date -->
    <xsl:template match="gmd:CI_Citation[.!=''][not(gmd:date)]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <gmd:date gco:nilReason="missing" />
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp gmd:CI_Citation missing gmd:title -->
    <!-- check and fix? before transform -->
    <xsl:template match="gmd:CI_Citation[.!=''][not(gmd:title)]">
        <xsl:copy>
            <gmd:title gco:nilReason="missing" />
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp gmd:CI_Citation empty -->
    <xsl:template match="gmd:CI_Citation[.='']">
        <xsl:copy>
            <gmd:title gco:nilReason="missing" />
            <gmd:date gco:nilReason="missing" />
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp gmd:MD_Keywords missing gmd:keyword -->
    <xsl:template match="//gmd:MD_Keywords[not(gmd:keyword)]">
        <xsl:copy>
            <gmd:keyword gco:nilReason="missing" />
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp gmd:EX_GeographicDescription missing all children -->
    <xsl:template match="//gmd:geographicElement[gmd:EX_GeographicDescription[not(gmd:extentTypeCode) and not(gmd:geographicIdentifier)]]">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp `<gmd:aggregateDataSetIdentifier><gmd:MD_Identifier/>` missing child nodes is updated with nilReason -->
    <xsl:template match="gmd:aggregateDataSetIdentifier[gmd:MD_Identifier[not(*)]]">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp <gmd:graphicOverview> missing <fileName> node is added with nilReason -->
    <xsl:template match="gmd:MD_BrowseGraphic[not(gmd:fileName)]">
        <xsl:copy>
            <gmd:fileName gco:nilReason="missing" />
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp-1.4 `<gmd:EX_BoundingPolygon>` missing <gmd:polygon> is added with nilReason -->
    <xsl:template match="gmd:EX_BoundingPolygon[not(gmd:polygon)]">
        <xsl:copy>
            <gmd:polygon gco:nilReason="missing" />
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp-2.0 `<mcp:DP_Term/>` missing <mcp:usedInDataset> is added with nilReason -->
    <!-- check and fix? before transform -->
    <xsl:template match="mcp:DP_Term[not(mcp:usedInDataset)]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <mcp:usedInDataset gco:nilReason="missing" />
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp-2.0 mcp:MD_DataIdentification missing gmd:language  Add in correct order -->
    <!-- duplicate -->
    <xsl:template match="mcp:MD_DataIdentification[not(gmd:language)]">
        <xsl:copy>
            <xsl:apply-templates select="@*" />
            <xsl:for-each select="node()">
                <xsl:choose>
                    <xsl:when test="not(self::gmd:characterSet)">
                        <xsl:apply-templates select="." />
                    </xsl:when>
                    <xsl:otherwise>
                        <gmd:language gco:nilReason="missing" />
                        <xsl:copy-of select="." />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>

    <!-- OTHER -->

    <!-- iso19139.mcp-1.4 (Similar to Issue 3210?) More than one mcp:dataParameters.  Move the parameters into the first. -->
    <!-- check before transform -->
    <xsl:template match="mcp:dataParameters[following-sibling::mcp:dataParameters][1]/mcp:DP_DataParameters">
        <xsl:variable name="container" select="."/>
        <xsl:variable name="dataParameters" select="parent::node()/following-sibling::mcp:dataParameters/mcp:DP_DataParameters/mcp:dataParameter"/>
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <xsl:for-each select="$dataParameters">
                <xsl:copy-of select="."/>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="mcp:dataParameters[position()>1]" />

    <!-- iso19139.mcp-2.0 gco:DateTime which is a date has invalid children replaced with gco:Date. Make sure the content is a date and not datetime -->
    <xsl:template match="gco:DateTime[gco:Date[not(text()[contains(., 'T')])]]">
        <xsl:copy-of select="gco:Date" />
    </xsl:template>

    <!-- iso19139.mcp-2.0 gmd:CI_Citation has gmd:citedResponsibleParty and gmd:identifier incorrectly ordered -->
    <!-- check before transform -->
    <xsl:template match="gmd:CI_Citation[gmd:citedResponsibleParty[following-sibling::gmd:identifier]]">
        <xsl:copy>
            <xsl:apply-templates select="@*" />
            <xsl:for-each select="node()">
                <xsl:choose>
                    <xsl:when test="not(self::gmd:citedResponsibleParty) and not(self::gmd:identifier)">
                        <xsl:apply-templates select="." />
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
            <xsl:copy-of select="gmd:identifier"/>
            <xsl:copy-of select="gmd:citedResponsibleParty"/>
        </xsl:copy>
    </xsl:template>

    <!-- iso19139.mcp-2.0 `<mcp:dataParameters/>` expected but have <mcp:dataparameters/> -->
    <xsl:template match="mcp:dataparameters">
        <xsl:element name="mcp:dataParameters">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
