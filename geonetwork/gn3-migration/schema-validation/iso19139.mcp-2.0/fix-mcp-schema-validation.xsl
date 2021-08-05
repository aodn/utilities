<?xml version="1.0" encoding="UTF-8"?>

<!-- Manual edits -->
<!-- 5344966e-ea85-4c98-b699-546dba9cb39e 
        More than one gmd:EX_GeographicBoundingBox not allowed
        <gmd:geographicElement>
          <gmd:EX_GeographicBoundingBox>
             <gmd:westBoundLongitude gco:nilReason="missing"/>
             <gmd:eastBoundLongitude gco:nilReason="missing"/>
             <gmd:southBoundLatitude gco:nilReason="missing"/>
             <gmd:northBoundLatitude>
                <gco:Decimal>-31.67195</gco:Decimal>
             </gmd:northBoundLatitude>
          </gmd:EX_GeographicBoundingBox>
          <gmd:EX_GeographicBoundingBox>
             <gmd:westBoundLongitude gco:nilReason="missing"/>
             <gmd:eastBoundLongitude gco:nilReason="missing"/>
             <gmd:southBoundLatitude gco:nilReason="missing"/>
             <gmd:northBoundLatitude>
                <gco:Decimal>-29.69225</gco:Decimal>
             </gmd:northBoundLatitude>
          </gmd:EX_GeographicBoundingBox>
        </gmd:geographicElement>
               
         Invalid xlink:href 
         <gmx:Anchor xlink:href="http://metadata.imas.utas.edu.au:/geonetwork/srv/en/thesaurus.download?ref=external.theme.sciencekeywords">geonetwork.thesaurus.external.theme.sciencekeywords</gmx:Anchor>
-->


<!-- Fix ups for iso19139.mcp-2.0 -->


<xsl:stylesheet   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:gml="http://www.opengis.net/gml"
    xmlns:gco="http://www.isotc211.org/2005/gco"
    xmlns:gmd="http://www.isotc211.org/2005/gmd"
    xmlns:mcp="http://schemas.aodn.org.au/mcp-2.0"
    xmlns:gmx="http://www.isotc211.org/2005/gmx"
    xmlns:xlink="http://www.w3.org/1999/xlink">
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*"/>
    
    <!-- identity transform -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Element `<mcp:DP_Term/>` missing <mcp:usedInDataset> is added with nilReason -->
    <xsl:template match="mcp:DP_Term[not(mcp:usedInDataset)]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <mcp:usedInDataset gco:nilReason="missing" />
        </xsl:copy>
    </xsl:template>
    
    <!-- gco:DateTime missing time replaced with gco:Date -->
    <xsl:template match="gco:DateTime[text()[not(contains(., 'T'))]]">
        <gco:Date><xsl:value-of select="."/></gco:Date>
    </xsl:template>
    
    <!-- gco:DateTime which is a date has invalid children replaced with gco:Date. Make sure the content is a date and not datetime -->
    <xsl:template match="gco:DateTime[gco:Date[not(text()[contains(., 'T')])]]">
        <xsl:copy-of select="gco:Date" />
    </xsl:template>

    <!-- iso19139.mcp-2.0 gmx:Anchor Incorrectly formatted href -->
    <!-- Missing port -->
    <!-- uri encode parameters -->
    <xsl:template match="gmx:Anchor/@xlink:href">
        <xsl:attribute name="xlink:href">
            <xsl:value-of select="concat(replace(substring-before(.,'?'),'http://metadata.imas.utas.edu.au:/','http://metadata.imas.utas.edu.au/'),'?',replace(replace(encode-for-uri(substring-after(.,'?')),'%3D','='),'%26','&amp;'))"/>
        </xsl:attribute>
    </xsl:template>
    
    <!-- mcp:MD_DataIdentification missing gmd:language  Add in correct order -->
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
    
    <!-- gmd:CI_Citation has gmd:citedResponsibleParty and gmd:identifier incorrectly ordered -->
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
    
    <!-- `<gco:Decimal/> missing value. Apply nilReason and remove <gco:Decimal/>-->
    <xsl:template match="gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude|gmd:eastBoundLongitude|gmd:southBoundLatitude|gmd:northBoundLatitude[gco:Decimal='']">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>
    
    <!-- `<gco:Real/> missing value. Apply nilReason and remove <gco:Real/> -->
    <xsl:template match="//gmd:maximumValue[gco:Real[not(node())]]|//gmd:minimumValue[gco:Real[not(node())]]">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>  

    <!-- Element `<gco:DateTime/>` missing value -->
    <xsl:template match="gmd:CI_Date/gmd:date[gco:DateTime = '']">
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
    
    <!-- Element <gm1:verticalCRS/>. Add <gml:verticalDatum/> -->
    <xsl:template match="gml:VerticalCRS[not(gml:verticalDatum)]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />      
            <gml:verticalDatum />
        </xsl:copy>
    </xsl:template>   
    
    <!-- Element gmd:EX_VerticalExtent missing verticalCRS  -->
    <xsl:template match="gmd:EX_VerticalExtent[not(gmd:verticalCRS)]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <gmd:verticalCRS gco:nilReason="missing" />
        </xsl:copy>
    </xsl:template>        
    
    <!-- Element `<mcp:DP_DataParameter/>` missing value -->
    <xsl:template match="mcp:dataParameter[mcp:DP_DataParameter = '']">
        <xsl:copy>
            <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        </xsl:copy>
    </xsl:template>   
    
    <!-- Element `<mcp:dataParameters/>` expected but have <mcp:dataparameters/> -->
    <xsl:template match="mcp:dataparameters">
        <xsl:element name="mcp:dataParameters">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>     
    
    <!-- <gml:TimePeriod> without endPosition -->
    <xsl:template match="gml:TimePeriod[gml:beginPosition][not(gml:endPosition)]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />      
            <gml:endPosition indeterminatePosition="unknown" />
        </xsl:copy>
    </xsl:template>  

    <!-- More than one gmd:supplementalInformation in mcp:MD_DataIdentification combine the CharacterStrings into one --> 
    <xsl:template match="mcp:MD_DataIdentification[gmd:supplementalInformation[following-sibling::gmd:supplementalInformation]]/gmd:supplementalInformation[1]">
        <xsl:copy>
            <gco:CharacterString>
                <xsl:value-of select="concat(.,./following-sibling::gmd:supplementalInformation)" />
            </gco:CharacterString>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="mcp:MD_DataIdentification/gmd:supplementalInformation[position()>1]" />
    
    <!-- <gmd:MD_Format> without gmd:version -->
    <xsl:template match="gmd:MD_Format[not(gmd:version)]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />      
            <gmd:version gco:nilReason="missing" />
        </xsl:copy>
    </xsl:template>  
    
    

</xsl:stylesheet>