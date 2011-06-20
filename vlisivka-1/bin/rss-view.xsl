<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     >     
 <xsl:output method="html" encoding="utf-8" />
 
 <xsl:template match="/">
    <xsl:apply-templates select="//channel"/>
 </xsl:template>

 <xsl:template match="channel">
<div class="header">
<a href="{link}" target="_content"><xsl:value-of select="title"/></a>
</div>
  <div class="rssMessages">
   <xsl:apply-templates select="item"/>
  </div>
 </xsl:template>


 <xsl:template match="item">
<div class="latestMessage">
   <div class="rssSubject"><a href="{link}" target="_content"><xsl:call-template name="splitLongWordsInText">
            <xsl:with-param name="text" select="title"/>
        </xsl:call-template></a></div>
   <xsl:apply-templates select="description"/>
</div>
 </xsl:template>
 
 <xsl:template match="description">
<div class="rssBody">
<xsl:call-template name="splitLongWordsInText">
            <xsl:with-param name="text" select="node()|*"/>
        </xsl:call-template></div>
 </xsl:template>
 
    <xsl:template name="splitLongWord">
        <xsl:param name="word" />
	<xsl:choose>

          <xsl:when test="string-length($word)>20">
	    <xsl:value-of select="substring($word,0,20)" />
	    <xsl:text disable-output-escaping="yes">&lt;wbr/&gt;</xsl:text>
	    <xsl:call-template name="splitLongWord">
                <xsl:with-param name="word" select="substring($word,20)" />
	    </xsl:call-template>
	  </xsl:when>
          
          <xsl:otherwise>
            <xsl:value-of select="$word" />
          </xsl:otherwise>
          
        </xsl:choose>
    </xsl:template>


 <xsl:template name="splitLongWordsInText">
    
    <xsl:param name="text"/>
	
        <xsl:choose>
           <xsl:when test="contains($text, ' ')">
    	     <xsl:call-template name="splitLongWord">
               <xsl:with-param name="word" select="substring-before($text, ' ')"/>
    	     </xsl:call-template>
             <xsl:text> </xsl:text>
            </xsl:when>
            <xsl:otherwise>
    	      <xsl:call-template name="splitLongWord">
                <xsl:with-param name="word" select="$text"/>
    	      </xsl:call-template>
            </xsl:otherwise>
    	</xsl:choose>
	
	
        <xsl:if test="contains(substring-after($text, ' '), ' ')">
	    
            <xsl:call-template name="splitLongWordsInText">
                <xsl:with-param name="text" select="substring-after($text, ' ')"/>
            </xsl:call-template>
		
        </xsl:if>
	    
    </xsl:template>
    
   
</xsl:stylesheet>
