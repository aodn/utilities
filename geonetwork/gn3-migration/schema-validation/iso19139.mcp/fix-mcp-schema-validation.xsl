<?xml version="1.0" encoding="UTF-8"?>

<!-- Fix ups for iso19139.mcp -->

<xsl:stylesheet   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:gml="http://www.opengis.net/gml"
    xmlns:gco="http://www.isotc211.org/2005/gco"
    xmlns:gmd="http://www.isotc211.org/2005/gmd"
    xmlns:mcp="http://schemas.aodn.org.au/mcp-2.0"
    exclude-result-prefixes="#all">
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*"/>
    
    <!-- identity transform -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Element `<gmd:aggregateDataSetIdentifier><gmd:MD_Identifier/>` missing child nodes is updated with nilReason -->
    <xsl:template match="gmd:aggregateDataSetIdentifier[gmd:MD_Identifier[not(*)]]">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>
    
    <!-- `<gco:Integer/> missing value. Apply nilReason and remove <gco:Integer/>-->
    <xsl:template match="gmd:MD_RepresentativeFraction/gmd:denominator[gco:Integer='']">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>
    
    <!-- `<gco:Integer/> Invalid integer value. Remove invalid characters -->
    <xsl:template match="gco:Integer[not(number(.))]/text()">
        <xsl:value-of select="replace(., '[^0-9]', '')"/>
    </xsl:template>
    
    <!-- `<gco:Real/> missing value. Apply nilReason and remove <gco:Real/> -->
    <xsl:template match="//gmd:maximumValue[gco:Real[not(node())]]|//gmd:minimumValue[gco:Real[not(node())]]">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>
    
    <!-- Element `<gco:Date/>` missing value -->
    <xsl:template match="gmd:CI_Date/gmd:date[gco:Date = '']|gmd:dateOfNextUpdate[gco:Date = '']">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>   
    
    <!-- gco:DateTime missing date removed and labelled missing -->
    <xsl:template match="gmd:plannedAvailableDateTime[gco:DateTime[text()[substring-before(.,'T') = '']]]">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>    
    
    <!-- `<gco:Decimal/> missing value. Apply nilReason and remove <gco:Decmimal/> -->
    <xsl:template match="//gmd:westBoundLongitude[gco:Decimal[not(node())]]|
        //gmd:eastBoundLongitude[gco:Decimal[not(node())]]|
        //gmd:southBoundLatitude[gco:Decimal[not(node())]]|
        //gmd:northBoundLatitude[gco:Decimal[not(node())]]">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>  
    
    <!-- Element <gmd:graphicOverview> missing <fileName> node is added with nilReason -->
    <xsl:template match="gmd:MD_BrowseGraphic[not(gmd:fileName)]">
        <xsl:copy>
            <gmd:fileName gco:nilReason="missing" />
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>
    
    <!-- Element gml:VerticalCRS missing child verticalDatum or usesVerticalDatum -->
    <xsl:template match="gml:VerticalCRS">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <xsl:if test="not(./gml:usesVerticalDatum) and not(./gml:verticalDatum)">
                <gml:usesVerticalDatum nilReason="missing"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>   
    
    <!-- Element `<gco:DateTime/>` missing value -->
    <xsl:template match="gmd:CI_Date/gmd:date[gco:DateTime = '']">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>
    
    <!-- Element `gmd:dateStamp/gco:DateTime missing value -->
    <xsl:template match="gmd:dateStamp[gco:DateTime = '']">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>     
    
    <!-- Element `<gco:Integer/>` missing value -->
    <xsl:template match="gmd:denominator[gco:Integer = '']|gmd:numberOfDimensions[gco:Integer = '']|gmd:dimensionSize[gco:Integer = '']">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>     
    
    <!-- Element `<gco:Boolean/>` missing value -->
    <xsl:template match="gmd:transformationParameterAvailability[gco:Boolean = '']">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>    

    <!-- Element `<gco:Integer/>` missing value -->
    <xsl:template match="gmd:denominator[gco:Integer = '']">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>  
    
    <!-- Element mcp:MD_DataIdentification missing gmd:language -->
    <xsl:template match="mcp:MD_DataIdentification[not(./gmd:language)]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <gml:language nilReason="missing"/>
        </xsl:copy>
    </xsl:template>

    <!-- Element gmd:EX_BoundingPolygon missing children -->
    <xsl:template match="gmd:EX_BoundingPolygon[not(*)]">
        <xsl:copy>
            <gmd:polygon gco:nilReason="missing" />
        </xsl:copy>
    </xsl:template>
    
    <!-- Element gmd:CI_Citation missing gmd:date -->
    <xsl:template match="gmd:CI_Citation[not(gmd:date)]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <gmd:date gco:nilReason="missing" />
        </xsl:copy>
    </xsl:template>
    
    <!-- Element gmd:CI_Citation missing gmd:title -->
    <xsl:template match="gmd:CI_Citation[not(gmd:title)]">
        <xsl:copy>
            <gmd:title gco:nilReason="missing" />
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>
    
    <!-- Element gmd:EX_VerticalExtent missing gmd:verticalCRS -->
    <xsl:template match="gmd:EX_VerticalExtent[not(gmd:verticalCRS)]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <gmd:verticalCRS gco:nilReason="missing" />
        </xsl:copy>
    </xsl:template>
    
    <!-- Element gmd:MD_TopicCategoryCode missing value -->
    <xsl:template match="gmd:topicCategory[gmd:MD_TopicCategoryCode = '']">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="gmd:topicCategory/gmd:MD_TopicCategoryCode[. = '']" />
        
    
    <!-- Element `<gmd:CI_Citation/>. Swap ordering of <gmd:citedResponsibleParty> and <gmd:identifier> if both present and <gmd:identifier> follows <gmd:citedResponsibleParty> -->
    <!-- TODO -->
<!--    <xsl:template match = "gmd:CI_Citation[gmd:citedResponsibleParty[following-sibling::gmd:identifier]]">-->
<!--        <xsl:copy>-->
<!--            <xsl:apply-templates select="@* | node()" />      -->
<!--            <xsl:apply-templates select="gmd:identifier, gmd:citedResponsibleParty"/>-->
<!--        </xsl:copy> -->
<!--    </xsl:template>-->

</xsl:stylesheet>