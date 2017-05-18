<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">

    <xsl:output encoding="UTF-8" indent="no"/>
    
    <xsl:param name="zeitraumOderDieLetztenX" required="yes"/>
    <xsl:param name="dieLetztenWieviele"/>
    <xsl:param name="startDate"/>
    <xsl:param name="endDate"/>

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
                    
                    <xsl:apply-templates select="rss/channel/item[(format-number(number(replace(meldung_erstellungsdatum,'-','')),'#') &lt;= $bereinigtes_endDate ) and (format-number(number(replace(meldung_erstellungsdatum,'-','')),'#') &gt;= $bereinigtes_startDate) ]"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>&#xa;</xsl:text>
        </indesign>
    </xsl:template>

    <xsl:template match="item">
        <xsl:text>&#xa;</xsl:text>
        <TITEL-2SP-ZENTR>
            <xsl:value-of select="title"/>
        </TITEL-2SP-ZENTR>
        <xsl:text>&#xa;</xsl:text>
        <ABSTRACT-ZENTR>
            <xsl:value-of select="description"/>
        </ABSTRACT-ZENTR>
        <xsl:text>&#xa;</xsl:text>
        <VORNAME>
            <xsl:value-of select="interviewpartnert"/>
        </VORNAME>
        <xsl:text>&#xa;</xsl:text>
        <BIO-ZENTRIERT>
            <xsl:value-of select="content/p[1]/strong"/>
        </BIO-ZENTRIERT>

        <xsl:apply-templates select="content/*[position()>1]"/>
    </xsl:template>

    <xsl:template match="content/p">
        <xsl:choose>
            <xsl:when test=".[count(child::*)=1 and strong]">
                <xsl:text>&#xa;</xsl:text>
                <INT-FRAGE>
                    <xsl:apply-templates/>
                </INT-FRAGE>
            </xsl:when>
            <!-- die letzten beiden Interview Zeilen enthalten keine Fragen/Antworten mehr: -->
            <xsl:when test=".[count(following-sibling::p) &lt; 2]">
                <xsl:text>&#xa;</xsl:text>
                <ABS>
                    <xsl:apply-templates/>
                </ABS>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>&#xa;</xsl:text>
                <INT-ANTWORT>
                    <xsl:apply-templates/>
                </INT-ANTWORT>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--hier noch strong abfangen, ob es einziges kind ist von content/p oder obs im text vorkommt-->

    <xsl:template match="strong[not(parent::p[count(child::*)=1])]">
        <ABS-FETT>
            <xsl:apply-templates/>
        </ABS-FETT>
    </xsl:template>

    <xsl:template match="strong[parent::p[count(child::*)=1]]">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="em">
        <ABS-KURSIV>
            <xsl:apply-templates/>
        </ABS-KURSIV>
    </xsl:template>

    <xsl:template match="a">
        <xsl:value-of select="text()"/>
    </xsl:template>

    <xsl:template match="br"> </xsl:template>

    <xsl:template match="text()">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>

    <xsl:template match="li">
        <xsl:if test="preceding-sibling::li"><xsl:text>&#xa;</xsl:text></xsl:if>
        <li>
            <xsl:apply-templates/>
        </li>
    </xsl:template>
    <xsl:template match="ul">
        <xsl:text>&#xa;</xsl:text>
        <MEL-LISTE>
            <xsl:apply-templates/>
        </MEL-LISTE>
    </xsl:template>
    <xsl:template match="ol">
        <xsl:text>&#xa;</xsl:text>
        <MEL-LISTE-NUM>
            <xsl:apply-templates/>
        </MEL-LISTE-NUM>
    </xsl:template>


</xsl:stylesheet>
