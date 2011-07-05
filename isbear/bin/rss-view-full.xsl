<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     >     
 <xsl:output method="html" />
 
 <xsl:template match="/">
  <html>
   <head>
    <title>Linux.org.ua news</title>
<link rel="SHORTCUT ICON" href="/favicon.ico" />
<meta name="keywords" content="ukrainian,Ukrainian language,linux,internationalization,localization,dictionary,software,program,computer dictionary,̦����,̦����,����,���������� ����,�������æ���̦��æ�,����̦��æ�,�����æ��� �������,��������,��������� ������������,�������,����'�������,����̦��æ�,��������,���������ަ" />

<meta http-equiv="expires" content="0" />
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="Author" content="Volodymyr M. Lisivka" />
<meta name="Description" content="����������� ���� ����������� ������������ �� �����Φ��æ� �����æ��ϧ ������� Linux" />

<link rel="stylesheet" type="text/css" href="/include/novyny.css" />
<link rel="stylesheet" type="text/css" href="/include/sidebar.css" />

<!-- ������� ڦ Xaraya -->
<link title="Small classictext" href="/include/style_textsmall.css" type="text/css" rel="alternate stylesheet" />
<link title="Medium classictext" href="/include/style_textmedium.css" type="text/css" rel="stylesheet" />
<link title="Large classictext" href="/include/style_textlarge.css" type="text/css" rel="alternate stylesheet" />
        
<link title="Blue classiccolors" href="/include/colstyle_sidebar_blue.css" type="text/css" rel="alternate stylesheet" />
<link title="Green classiccolors" href="/include/colstyle_sidebar_green.css" type="text/css" rel="alternate stylesheet" />
<link title="Orange classiccolors" href="/include/colstyle_sidebar_orange.css" type="text/css" rel="stylesheet" />
<script src="/include/switch_styles.js" type="text/javascript"></script>

  </head>
<body>
<div class="topline">
<div class="themeControls">
<!-- ������� � Xaraya -->
<a class="blind" accesskey="1" title="������� ����� Alt-1" onclick="setActiveStyleSheetTxt('Large classictext'); createCookie('loumain_textsize','Large classictext',365); return false;" href="#"><img alt="�������" id="butlg" src="/images/txt_large.gif" border="0" /></a>
<a class="blind" accesskey="2" title="�����Φ� ����� Alt-2" onclick="setActiveStyleSheetTxt('Medium classictext'); createCookie('loumain_textsize','Medium classictext',365); return false;" href="#"><img alt="�����Φ�" id="butmd" src="/images/txt_medium.gif" border="0" /></a>
<a class="blind" accesskey="3" title="��������� ����� Alt-3 (������)" onclick="setActiveStyleSheetTxt('Small classictext'); createCookie('loumain_textsize','Small classictext',365); return false;" href="#"><img alt="���������" id="butsm" src="/images/txt_small.gif" border="0" /></a>
<a class="blind" accesskey="4" title="�������צ ���� Alt-4 (������)" onclick="setActiveStyleSheetCol('Orange classiccolors'); createCookie('loumain_colscheme','Orange classiccolors',365); return false;" href="#"><img alt="���������" id="butor" src="/images/orange.gif" border="0" /></a>
<a class="blind" accesskey="5" title="����Φ ���� Alt-5" onclick="setActiveStyleSheetCol('Green classiccolors'); createCookie('loumain_colscheme','Green classiccolors',365); return false;" href="#"><img alt="������" id="butgr" src="/images/green.gif" border="0" /></a>
<a class="blind" accesskey="6" title="������Φ ���� Alt-6" onclick="setActiveStyleSheetCol('Blue classiccolors'); createCookie('loumain_colscheme','Blue classiccolors',365); return false;" href="#"><img alt="��������" id="butbl" src="/images/blue.gif" border="0" /></a>
</div>
</div>
<div class="logo" align="center" >������ �� <span class="lou">L<span class="lou_i">i</span>nux.org.ua</span></div>
<div class="links" align="center">
:<a target="_content" href="/">������</a>:
:<a target="_content" href="http://dict.linux.org.ua/dict/">�������</a>:
:<a target="_content" href="http://pere.slovnyk.org.ua/">������������</a>:
:<a target="_content" href="/cgi-bin/yabb/YaBB.pl">�����</a>:
</div>

    <xsl:apply-templates select="//channel"/>
<div class="footer">
 WebMaster: <a href="mailto:{//channel/webMaster}"><xsl:value-of select="//channel/webMaster"/></a><br />
</div>
</body>
</html>
 </xsl:template>

 <xsl:template match="channel">
<div class="header">
<a href="{link}" target="_content"><xsl:value-of select="title"/></a>
</div>
  <div class="messages">
   <xsl:apply-templates select="item"/>
  </div>
 </xsl:template>


 <xsl:template match="item">
<div class="message">
<div class="msgHeader"><div class="msgSubject"><a href="{link}" target="_content"><xsl:value-of select="title"/></a></div></div>
   <xsl:apply-templates select="description"/>
</div>
 </xsl:template>
 
 <xsl:template match="description">
<div class="msgBody"><xsl:copy-of select="."/></div>
 </xsl:template>
 
</xsl:stylesheet>
