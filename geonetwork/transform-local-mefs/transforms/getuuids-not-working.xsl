<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:impl="urn:X-EXPath:httpclient:samples:exist:impl"
                xmlns:http="http://expath.org/ns/http-client"
                exclude-result-prefixes="#all"
                version="2.0">

    <xsl:import href="http://expath.org/ns/http-client.xsl"/>

    <xsl:output indent="yes"/>
    <xsl:param name="catalogue"/>
    <xsl:param name="username" select="admin"/>
    <xsl:param name="password" required="yes"/>

    <xsl:function name="impl:get-in" as="document-node()">
        <xsl:param name="groupId"/>
        <xsl:variable name="req" as="element()">
            <http:request href="{ $catalogue }/geonetwork/srv/eng/xml.search?group={ $groupId }"
                          method="get"
                          username="{ $username }"
                          password="{ $password }"
                          auth-method="basic"
                          send-authorization="true"/>
        </xsl:variable>
        <xsl:sequence select="http:send-request($req)[2]"/>
    </xsl:function>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/groups/group">
        <xsl:copy>
            <xsl:apply-templates/>
            <!--            <xsl:message select="concat($catalogue,'/geonetwork/srv/eng/xml.search?group=',encode-for-uri(groupId))"></xsl:message>-->
            <xsl:apply-templates select="impl:get-in(encode-for-uri(groupId))//uuid"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="*:info/uuid">
        <!--        <xsl:apply-templates />-->
        <!--        <xsl:copy-of select="." copy-namespaces="no"/>-->
        <uuid>
            <xsl:value-of select="text()"/>
        </uuid>
    </xsl:template>

</xsl:stylesheet>
