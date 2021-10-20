<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:geonet="http://www.fao.org/geonetwork"
    exclude-result-prefixes="xs geonet"
    version="2.0">
    
    <xsl:output indent="yes"/>
    
    <!--
        Run this twice to produce two output files than can be easily compared/diffed. The first on the GN2 instance
        and the second on the GN3 instance. Using the configuration in compare-results.xpr on Oxygen results in two 
        output files are called gn2-out.xml and gn3-out.xml. 
        
        input xml values:
        https://catalogue-portal.aodn.org.au/geonetwork/srv/eng/xml.search.imos?fast=index
        http://geonetwork3-ci-aodnstack-gn3-it.dev.aodn.org.au/geonetwork/srv/eng/xml.search.imos?fast=index
        or local file
        
        other-doc values:
        https://catalogue-portal.aodn.org.au/geonetwork/srv/eng/xml.search.imos?fast=index
        http://geonetwork3-ci-aodnstack-gn3-it.dev.aodn.org.au/geonetwork/srv/eng/xml.search.imos?fast=index
        or local file
    -->
    <xsl:param name="other-doc" />  
    <xsl:variable name="gn-doc" select="document($other-doc)" />
    <xsl:key name="uuid-key" match="metadata" use="geonet:info/uuid" />
        
    <xsl:template match="//response">
        <xsl:copy>
            <xsl:for-each select="metadata">
                <xsl:sort select="geonet:info/uuid" data-type="text" order="ascending" />
                <xsl:variable name="uuid" select="geonet:info/uuid/text()"/>
                <xsl:variable name="gn-record-in-other-doc" select="$gn-doc/key('uuid-key', $uuid)"/>
                <xsl:if test="$gn-record-in-other-doc">
                    <xsl:apply-templates select="." />
                </xsl:if>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="metadata">
        <xsl:copy>
            <xsl:apply-templates select="geonet:info/uuid" />
            <xsl:for-each select="link[contains(.,'geoserver') or contains(.,'geowebcache') or contains(.,'tilecache')]">
                <xsl:sort select="." data-type="text" order="ascending" />
                <xsl:apply-templates select="." />
            </xsl:for-each>
            <xsl:apply-templates select="keyword" />
            <xsl:for-each select="responsibleParty">
                <xsl:sort select="." data-type="text" order="ascending" />
                <xsl:apply-templates select="." />
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="link">
        <xsl:copy>
            <xsl:for-each select="tokenize(.,'\|')">
                <xsl:if test="not(.='1')">
                <linkpart><xsl:value-of select="."/></linkpart>
                </xsl:if>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="geonet:info/uuid">
        <xsl:copy><xsl:value-of select="."/></xsl:copy>
    </xsl:template>   
    
    <xsl:template match="keyword">
        <xsl:copy><xsl:value-of select="lower-case(.)"/></xsl:copy>
    </xsl:template>     
    
    <xsl:template match="responsibleParty">
        <xsl:copy><xsl:value-of select="lower-case(replace(.,' ',''))"/></xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>