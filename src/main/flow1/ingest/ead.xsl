<xsl:stylesheet
        version="2.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xlink="http://www.w3.org/1999/xlink"
        xmlns:ext="java:org.Ead"
        xmlns:ead="urn:isbn:1-931666-22-9"
        exclude-result-prefixes="ext xlink ead"
        >

    <xsl:param name="archiveIDs" select="'archiveIDs.xml'"/>
    <xsl:variable name="list" select="document($archiveIDs)"/>
    <xsl:variable name="archivalID" select="substring(ead:ead/ead:eadheader/ead:eadid/@identifier, 4)" />

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="ead:did/ead:unitid">

        <xsl:variable name="unitid" select="normalize-space(text())"/>
        <unitid>
            <xsl:value-of select="$unitid"/>
        </unitid>

        <xsl:choose>
            <xsl:when test="../../../ead:archdesc"/>
            <xsl:otherwise>
                <xsl:variable name="pid"
                              select="concat($archivalID, '%2E', replace($unitid, ' ', '%20'))"/>
                <xsl:if test="$list[item/text()=$unitid]">
                    <daogrp xlink:type="extended">
                        <xsl:element name="daoloc">
                            <xsl:attribute name="xlink:href"
                                           select="concat('http://hdl.handle.net/', $pid,  '?locatt=view:level3')"/>
                            <xsl:attribute name="xlink:type">locator</xsl:attribute>
                            <xsl:attribute name="xlink:label">thumbnail</xsl:attribute>
                        </xsl:element>
                        <xsl:element name="daoloc">
                            <xsl:attribute name="xlink:href"
                                           select="concat('http://hdl.handle.net/', $pid,  '?locatt=view:pdf')"/>
                            <xsl:attribute name="xlink:type">locator</xsl:attribute>
                            <xsl:attribute name="xlink:label">pdf</xsl:attribute>
                        </xsl:element>
                        <xsl:element name="daoloc">
                            <xsl:attribute name="xlink:href"
                                           select="concat('http://hdl.handle.net/', $pid,  '?locatt=view:mets')"/>
                            <xsl:attribute name="xlink:type">locator</xsl:attribute>
                            <xsl:attribute name="xlink:label">mets</xsl:attribute>
                        </xsl:element>
                        <xsl:element name="daoloc">
                            <xsl:attribute name="xlink:href"
                                           select="concat('http://hdl.handle.net/', $pid,  '?locatt=view:catalog')"/>
                            <xsl:attribute name="xlink:type">locator</xsl:attribute>
                            <xsl:attribute name="xlink:label">catalog</xsl:attribute>
                        </xsl:element>
                    </daogrp>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
