<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">
    
    <xsl:param name="zeitraumOderDieLetztenX" required="yes"/>
    <xsl:param name="dieLetztenWieviele"/>
    <xsl:param name="startDate"/>
    <xsl:param name="endDate"/>
    <xsl:param name="welchesRessort"/>
    
    <xsl:output method="xml" encoding="UTF-8" indent="no"/>
    
    <xsl:variable name="bereinigtes_startDate">
        <xsl:choose>
            <xsl:when test="not($startDate = '')">
                <xsl:value-of select="format-number(number(concat(tokenize($startDate, '\.')[3], tokenize($startDate, '\.')[2], tokenize($startDate, '\.')[1])),'#')"/>
            </xsl:when>
            <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="bereinigtes_endDate">
        <xsl:choose>
            <xsl:when test="not($endDate = '')">
                <xsl:value-of select="format-number(number(concat(tokenize($endDate, '\.')[3], tokenize($endDate, '\.')[2], tokenize($endDate, '\.')[1])),'#')"/>
            </xsl:when>
            <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="rules" select="'&lt; Betriebswirtschaft &lt; Steuerrecht &lt; Wirtschaftsrecht &lt; Arbeitsrecht'" />
    
    <xsl:template match="/">
        <xsl:text>&#xa;</xsl:text>
        <indesign>
            <xsl:choose>
                <xsl:when test="$zeitraumOderDieLetztenX = 'dieLetztenXItems'">
                    <xsl:apply-templates select="rss/channel/item[position() &lt;= number($dieLetztenWieviele)]">
                        <xsl:sort select="category[not(text()='Meldung')]/text()"
                            collation="http://saxon.sf.net/collation?rules={encode-for-uri($rules)}"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Zeitraum wurde angegeben: -->
                    <xsl:apply-templates select="rss/channel/item[(format-number(number(replace(meldung_erstellungsdatum,'-','')),'#') &lt;= $bereinigtes_endDate ) and (format-number(number(replace(meldung_erstellungsdatum,'-','')),'#') &gt;= $bereinigtes_startDate) ]">
                        <xsl:sort select="category[not(text()='Meldung')]/text()"
                            collation="http://saxon.sf.net/collation?rules={encode-for-uri($rules)}"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>&#xa;</xsl:text>
        </indesign>
    </xsl:template>
    
    <xsl:template match="item">
        <xsl:variable name="items_kategorie" select="category[not(text() = 'Meldung')]/text()"/>
        <xsl:text>&#xa;</xsl:text>
        <xsl:choose>
            <!-- Falls alle Ressorts durchsucht werden und ein Zeitintervall angegeben wurde -->
            <xsl:when test="$zeitraumOderDieLetztenX = 'itemAusInterval' and (deep-equal(//item[(format-number(number(replace(meldung_erstellungsdatum,'-','')),'#') &lt;= $bereinigtes_endDate ) and (format-number(number(replace(meldung_erstellungsdatum,'-','')),'#') &gt;= $bereinigtes_startDate) ][category[text()=$items_kategorie]][1], .))">
                <MEL-RUBRIK>
                    <xsl:value-of select="$items_kategorie"/>
                </MEL-RUBRIK>
                <xsl:text>&#xa;</xsl:text>
                <MEL-TITEL>
                    <xsl:value-of select="title"/>
                </MEL-TITEL>
            </xsl:when>
            <xsl:when test="$zeitraumOderDieLetztenX = 'dieLetztenXItems' and (deep-equal(//item[position() &lt;= number($dieLetztenWieviele)][category[text()=$items_kategorie]][1], .))">
                <MEL-RUBRIK>
                    <xsl:value-of select="$items_kategorie"/>
                </MEL-RUBRIK>
                <xsl:text>&#xa;</xsl:text>
                <MEL-TITEL>
                    <xsl:value-of select="title"/>
                </MEL-TITEL>
            </xsl:when>
            <xsl:otherwise>
                <MEL-TITEL-ABSATZLINIE><xsl:value-of select="title"/></MEL-TITEL-ABSATZLINIE>
            </xsl:otherwise>
        </xsl:choose>
        
        <xsl:text>&#xa;</xsl:text>
        <MEL-ABSTRACT>
            <xsl:apply-templates select="description"/>
        </MEL-ABSTRACT>
        <xsl:apply-templates select="content/*[position()>1]"/>
    </xsl:template>
    
    <xsl:template match="description">
        <xsl:value-of select="normalize-space(text())"/>
    </xsl:template>
    
    <!-- Weiterlesen Verlinkungen aus der Description entfernen... -->
    <xsl:template match="description/a[contains(lower-case(text()), 'weiterlesen')]"> </xsl:template>
    
    <xsl:template match="content//a">
        <xsl:apply-templates select="text()"/>
    </xsl:template>
    
    <xsl:template match="content//br">
        <br/>
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:choose>
            <!-- Im letzten Abschnitt soll eine Textersetzung stattfinden: -->
            <xsl:when test="parent::em[parent::p[count(child::*)=1 and parent::content]]">
                <xsl:value-of select="normalize-space(replace(.,'Viola C. Didier','Online-Redaktion'))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>        
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="content//em">
        <ABS-KURSIV>
            <xsl:apply-templates/>
        </ABS-KURSIV>
    </xsl:template>
    
    <xsl:template match="li">
        <xsl:if test="preceding-sibling::li"><xsl:text>&#xa;</xsl:text></xsl:if>
        <li>
            <xsl:apply-templates/>
        </li>
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
            <!-- Eingerückte Absätze immer, nur nicht nach Listen oder Zwischenüberschriften -->
            <xsl:when test="((.[preceding-sibling::*[1][name()=('ul','ol') or (name()='p' and count(child::*)=1 and child::strong)]]) or not(following-sibling::p)) and count(preceding-sibling::p) &gt; 1">
                <xsl:text>&#xa;</xsl:text>
                <ABS>
                    <xsl:apply-templates/>
                </ABS>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>&#xa;</xsl:text>
                <ABS>
                    <xsl:apply-templates/>
                </ABS>
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
    
    <!--<xsl:template match="content/p[count(child::*) = 1]/strong">--> <!-- alt: Zwischenüberschriften sind ab sofort h2 Elemente -->
    <xsl:template match="content/h2">
        <xsl:text>&#xa;</xsl:text>
        <ZWI>
            <!-- ABS_GRÜN ist verworfen worden -->
            <!--<ABS_GRÜN>-->
                <xsl:apply-templates/>
            <!--</ABS_GRÜN>-->
        </ZWI>
    </xsl:template>
    
    <xsl:template match="h4[@class='otherDocs']">
    </xsl:template>
    
</xsl:stylesheet>
