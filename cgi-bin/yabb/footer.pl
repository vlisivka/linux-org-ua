#!/usr/bin/perl -wT
use strict;
use locale;
use utf8;
#use encoding 'utf-8', STDOUT => 'utf-8';

our $group;

$group="test_ph" if(not defined $group);

#Latest messages
print <<FOOTER;
</div>
<div align="center">
<div class="rightColumn">
<div class="header">Останні повідомлення</div>
FOOTER
require "./latest.pl";

# Latest images
print <<FOOTER;
<div class="header">Останні малюнки</div>
FOOTER
require "./gallery.pl";

#linux-news.org.ua RSS feed
#open(FILE,'rss/linux-news.org.ua.rss.html');
#print $_ while(<FILE>);
#close(FILE);

#Gnome.org.ua RSS feed
#open(FILE,'rss/gnome.org.ua.rss.html');
#print $_ while(<FILE>);
#close(FILE);

#docs.linux.org.ua RSS feed
#open(FILE,'rss/docs.linux.org.ua.rss.html');
#print $_ while(<FILE>);
#close(FILE);

print <<FOOTER;
</div><!-- rightColumn -->
</div><!-- rightColumnSpacer -->

<hr class="clearer" />
<div class="bottomLinks" align="center">
<a href="YaBB.pl?board=stagging;action=post;title=%F0%CF%DE%C1%D4%C9+%CE%CF%D7%D5+%D4%C5%CD%D5">[Додати]</a>
<a href="yabb2rss?group=$group">[RSS]</a>
<a href="yabb2rss?group=$group&amp;body=yes">[RSS/FULL]</a>
<!-- <a href='#' onclick='javascript:try{window.sidebar.addPanel("Linux.org.ua news","http://linux.org.ua/cgi-bin/yabb/yabb2rss?group=$group&amp;group=news","http://linux.org.ua/cgi-bin/yabb/novyny");}catch(e){alert("Mozilla or Netscape6 required!")};return false;'>[Sidebar]</a>
<a href='#' onclick='javascript:try{window.sidebar.addPanel("Linux.org.ua news/FULL","http://linux.org.ua/cgi-bin/yabb/yabb2rss?group=$group&amp;group=news&amp;body=yes","http://linux.org.ua/cgi-bin/yabb/novyny");}catch(e){alert("Mozilla or Netscape6 required!")};return false;'>[Sidebar/FULL]</a>
<a href='http://linux.org.ua/rss/linux.org.ua-short.rss.html' rel="sidebar">[Sidebar(Opera)]</a>
<a href='http://linux.org.ua/rss/linux.org.ua.rss.html' rel="sidebar">[Sidebar(Opera)/FULL]</a> -->
</div>
<div class="footer">
<a class="blind" href="http://www.tsua.net"><img style="border:0;width:88px;height:31px" src="/images/tsua.gif" alt="Hosted by TSUA" title="Hosted by TSUA" /></a>
<!--<a class="blind" href="http://validator.w3.org/check?uri=http://linux.org.ua/cgi-bin/yabb/novyny"><img src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0!" title="Valid XHTML 1.0!" style="border:0;width:88px;height:31px" /></a>-->
<a class="blind" href="http://jigsaw.w3.org/css-validator/validator?uri=http://linux.org.ua/cgi-bin/yabb/novyny"><img style="border:0;width:88px;height:31px" src="http://jigsaw.w3.org/css-validator/images/vcss" alt="Valid CSS!" title="Valid CSS!" /></a>
<br />
Вся інформація з повідомлень на цій сторінці є власністю їх авторів.<br />
Дозволяється копіювати та розповсюджувати інформацію з цього сайту при збереженні посилання на оригінал.<br />
Розробка - <a href="http://linux.org.ua/cgi-bin/twiki/view/Main/VolodymyrLisivka">Володимира Лісівки</a>.
Дизайн - <a href="http://linux.org.ua/cgi-bin/twiki/view/Main/VolodymyrLisivka">Володимира Лісівки</a>.<br />
</div>
</div>
</body>
</html>
FOOTER
1;
