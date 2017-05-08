<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">

    <xsl:param name="zeitraumOderDieLetztenX" required="yes"/>
    <xsl:param name="dieLetztenWieviele"/>
    <xsl:param name="startDate"/>
    <xsl:param name="endDate"/>
    <xsl:param name="welchesRessort"/>


    <xsl:output method="xml" encoding="UTF-8" indent="no"/>

    <xsl:template match="/">
        <xsl:text>&#xa;</xsl:text>
        <indesign>
            <xsl:choose>
                <xsl:when test="$zeitraumOderDieLetztenX = 'dieLetztenXItems'">
                    <xsl:apply-templates select="rss/channel/item[position() &lt;= number($dieLetztenWieviele)]"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Zeitraum wurde angegeben: -->
                    <xsl:variable name="bereinigtes_startDate" select="format-number(number(concat(tokenize($startDate, '\.')[3], tokenize($startDate, '\.')[2], tokenize($startDate, '\.')[1])),'#')"/>
                    <xsl:variable name="bereinigtes_endDate" select="format-number(number(concat(tokenize($endDate, '\.')[3], tokenize($endDate, '\.')[2], tokenize($endDate, '\.')[1])),'#')"/>
                    
                    <xsl:variable name="rules" select="'&lt; Betriebswirtschaft &lt; Steuerrecht &lt; Arbeitsrecht &lt; Wirtschaftsrecht'" />

                    <xsl:apply-templates select="rss/channel/item[(format-number(number(replace(meldung_erstellungsdatum,'-','')),'#') &lt;= $bereinigtes_endDate ) and (format-number(number(replace(meldung_erstellungsdatum,'-','')),'#') &gt;= $bereinigtes_startDate) ]">
                        <!--<xsl:if test="welchesRessort = 'Alle'">-->
                            <xsl:sort select="category[not(text()='Meldung')]/text()"
                                collation="http://saxon.sf.net/collation?rules={encode-for-uri($rules)}"/>
                        <!--</xsl:if>-->
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>&#xa;</xsl:text>
        </indesign>
    </xsl:template>

    <xsl:template match="item">
        <xsl:text>&#xa;</xsl:text>
        <MEL-RUBRIK>
            <xsl:value-of select="category[not(text() = 'Meldung')]"/>
        </MEL-RUBRIK>
        <xsl:text>&#xa;</xsl:text>
        <MEL-TITEL>
            <xsl:value-of select="title"/>
        </MEL-TITEL>
        <xsl:text>&#xa;</xsl:text>
        <MEL-ABSTRACT>
            <xsl:apply-templates select="description"/>
        </MEL-ABSTRACT>
        <xsl:apply-templates select="content/*[position()>1]"/>
    </xsl:template>

    <!--<xsl:template match="node()">
        <xsl:copy>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>-->


    <xsl:template match="description">
        <xsl:value-of select="normalize-space(text())"/>
    </xsl:template>
    
    <!-- Weiterlesen Verlinkungen aus der Description entfernen... -->
    <xsl:template match="description/a[contains(lower-case(text()), 'weiterlesen')]"> </xsl:template>

    <xsl:template match="content//a">
        <xsl:choose>
            <xsl:when test="parent::em">
                <xsl:apply-templates select="text()"/>
            </xsl:when>
            <xsl:otherwise>
                <ABS-KURSIV>
                    <xsl:apply-templates select="text()"/>
                </ABS-KURSIV>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="content//br">
        <br/>
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    
    <!--<xsl:template match="content/p[count(child::*) = 1]/em"> 
        <ABS-KURSIV><xsl:value-of select="replace(text()[contains(., 'Viola')],'Viola C. Didier','Online-Redaktion')"/></ABS-KURSIV>
    </xsl:template>-->
    
    <xsl:template match="content//em">
        <ABS-KURSIV>
            <xsl:apply-templates/>
        </ABS-KURSIV>
    </xsl:template>
    
    <xsl:template match="content//li">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="content//ul">
        <xsl:text>&#xa;</xsl:text>
        <MEL-LISTE>
            <xsl:apply-templates/>
        </MEL-LISTE>
    </xsl:template>
    
    <xsl:template match="content//ol">
        <xsl:text>&#xa;</xsl:text>
        <MEL-LISTE-NUM>
            <xsl:apply-templates/>
        </MEL-LISTE-NUM>
    </xsl:template>
    
    <xsl:template match="content/p[not(count(child::*)=1 and child::*[name()=('strong')])]">
        <xsl:choose>
            <xsl:when test="(.[preceding-sibling::*[1][name()=('ul','ol') or (name()='p' and count(child::*)=1 and child::strong)]]) or not(following-sibling::p)">
                <xsl:text>&#xa;</xsl:text>
                <ABS>
                    <xsl:apply-templates/>
                </ABS>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>&#xa;</xsl:text>
                <ABS-EINZUG>
                    <xsl:apply-templates/>
                </ABS-EINZUG>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="content/p[count(child::*)=1 and child::*[name()=('strong')]]">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="content//strong[not(parent::p[count(child::*) = 1])]">
        <ABS-FETT>
            <xsl:apply-templates/>
        </ABS-FETT>
    </xsl:template>
    
    <xsl:template match="content/p[count(child::*) = 1]/strong">
        <xsl:text>&#xa;</xsl:text>
        <ZWI>
            <ABS_GRÜN>
                <xsl:apply-templates/>
            </ABS_GRÜN>
        </ZWI>
    </xsl:template>

</xsl:stylesheet>
