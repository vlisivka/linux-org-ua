#!/usr/bin/perl -wT
use strict;
use locale;
use utf8;
#use encoding 'utf-8', STDOUT => 'utf-8';

our $group;
if(not defined $group)
{
 $group="test_ph";
 require "./bbcode.pl";
}

print <<HEADER;
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="uk" lang="uk">
<head><title>LOU::Новини</title>

<link rel="SHORTCUT ICON" href="/favicon.ico" />
<meta name="keywords" content="ukrainian,Ukrainian language,linux,internationalization,localization,dictionary,software,program,computer dictionary,лінукс,лінакс,мова,українська мова,інтернаціоналізація,локалізація,операційна система,програма,програмне забезпечення,словник,комп'ютерний,локалізація,переклад,перекладачі" />

<meta http-equiv="expires" content="0" />
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="Author" content="Volodymyr M. Lisivka" />
<meta name="Description" content="Український сайт присвячений використанню та українізації операційної системи Linux" />

<link rel="stylesheet" type="text/css" href="/include/novyny.css" />
<!-- Видерто зі Xaraya -->
<link title="Small classictext" href="/include/style_textsmall.css" type="text/css" rel="alternate stylesheet" />
<link title="Medium classictext" href="/include/style_textmedium.css" type="text/css" rel="stylesheet" />
<link title="Large classictext" href="/include/style_textlarge.css" type="text/css" rel="alternate stylesheet" />
        
<link title="Blue classiccolors" href="/include/colstyle_blue.css" type="text/css" rel="alternate stylesheet" />
<link title="Green classiccolors" href="/include/colstyle_green.css" type="text/css" rel="alternate stylesheet" />
<link title="Orange classiccolors" href="/include/colstyle_orange.css" type="text/css" rel="stylesheet" />
<script src="/include/switch_styles.js" type="text/javascript"></script>
<!-- Для "What related" -->
<link href="yabb2rss?group=$group&amp;body=1&amp;cdata=1" title="RSS" type="application/rss+xml" rel="alternate" />
<script src="http://www.google-analytics.com/urchin.js" type="text/javascript">
</script>
<script type="text/javascript">
<!--
_uacct = "UA-134312-1";
urchinTracker();
//-->
</script>
</head>
<body>

<div class="topline">
<table border="0" width="100%"><tr>
<td align="left">@{[ukrDate(time)]}</td>
<td align="center">

<span class="orfomsg" title="Відмітьте текст та натисніть Ctrl-Enter.">
На сайті працює система <acronym title="Система повідомлення про орфографічні помилки.&#10; Відмітьте текст та натисніть Ctrl-Enter.">Орфо</acronym>.
</span>
<!-- Скрипт для Orfo - я його сховав, щоб не розповзався дизайн -->
<div style="display:none;"><script type="text/javascript" src="/orfo/orfo.js"></script></div>

</td>
<td align="right">
<form action="http://www.google.com.ua/cse" id="cse-search-box">
<div>
  <input type="hidden" name="cx" value="partner-pub-1802369084884681:18v6q3iaju3" />
  <input type="hidden" name="ie" value="UTF-8" />
  <input type="text" name="q" size="18" />
  <input type="submit" name="sa" value="&#x041f;&#x043e;&#x0448;&#x0443;&#x043a;" />
</div>
</form>
<script type="text/javascript" src="http://www.google.com.ua/cse/brand?form=cse-search-box&amp;lang=uk"></script> 
</td>
</tr></table>
</div>

<div class="logo">
<table width="100%">
<tr><td width="20%" class="themeControls">
<!-- Свиснув з Xaraya -->
<a class="blind" accesskey="1" title="Великий текст Alt-1" onclick="setActiveStyleSheetTxt('Large classictext'); createCookie('loumain_textsize','Large classictext',365); return false;" href="#"><img alt="великий" id="butlg" src="/images/txt_large.gif" border="0" /></a>
<a class="blind" accesskey="2" title="Середній текст Alt-2" onclick="setActiveStyleSheetTxt('Medium classictext'); createCookie('loumain_textsize','Medium classictext',365); return false;" href="#"><img alt="середній" id="butmd" src="/images/txt_medium.gif" border="0" /></a>
<a class="blind" accesskey="3" title="Маленький текст Alt-3 (типово)" onclick="setActiveStyleSheetTxt('Small classictext'); createCookie('loumain_textsize','Small classictext',365); return false;" href="#"><img alt="маленький" id="butsm" src="/images/txt_small.gif" border="0" /></a>
<br />
<a class="blind" accesskey="4" title="Коричневі тони Alt-4 (типово)" onclick="setActiveStyleSheetCol('Orange classiccolors'); createCookie('loumain_colscheme','Orange classiccolors',365); return false;" href="#"><img alt="коричневе" id="butor" src="/images/orange.gif" border="0" /></a>
<a class="blind" accesskey="5" title="Зелені тони Alt-5" onclick="setActiveStyleSheetCol('Green classiccolors'); createCookie('loumain_colscheme','Green classiccolors',365); return false;" href="#"><img alt="зелене" id="butgr" src="/images/green.gif" border="0" /></a>
<a class="blind" accesskey="6" title="Блакитні тони Alt-6" onclick="setActiveStyleSheetCol('Blue classiccolors'); createCookie('loumain_colscheme','Blue classiccolors',365); return false;" href="#"><img alt="блакитне" id="butbl" src="/images/blue.gif" border="0" /></a>
</td><td width="80%" class="logo_text">
Новини на <span class="lou">L<span class="lou_i">i</span>nux.org.ua</span>
</td></tr></table>
</div>

<div class="links" align="center">
<!-- :<a class="toplink" href="/">новини</a>: -->
<!-- :<a class="toplink" href="/cgi-bin/ispell/spell">правопис</a>: -->
:<a class="toplink" href="http://docs.linux.org.ua" style="cursor:help;" title="">документація</a>:
<!-- :<a class="toplink" href="/cgi-bin/yabb/YaBB.pl">форум</a>: -->
:<a class="toplink" href="http://dict.linux.org.ua/">англ.-укр. словник</a>:
:<a class="toplink" href="http://www.slovnyk.net/">тлумачний словник</a>:
<!-- :<a class="toplink" href="http://pere.slovnyk.org.ua/">перекладачка</a>: -->
:<a class="toplink" href="/cgi-bin/yabb/YaBB.pl?action=newmesg">нове на форумі</a>:
</div>
<div class="vote" align="center">
HEADER

#require './vote.pl';
require './poll.pl';

print <<BODY;
</div>

<div class="rightColumnSpacer">
<div class="messages">
BODY

1;
