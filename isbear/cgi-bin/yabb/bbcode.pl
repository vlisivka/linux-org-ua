#!/usr/bin/perl -T
use strict;
use locale;
use utf8;
#use encoding 'utf-8', STDOUT => 'utf-8';

my %bbtags=(
 '[b]'=>'<b>', '[/b]'=>'</b>',
 '[i]'=>'<i>', '[/i]'=>'</i>',
 '[u]'=>'<u>', '[/u]'=>'</u>',
 '[s]'=>'<strike>', '[/s]'=>'</strike>',
 '[tt]'=>'<code>', '[/tt]'=>'</code>',
 '[sub]'=>'<sub>', '[/sub]'=>'</sub>',
 '[sup]'=>'<sup>', '[/sup]'=>'</sup>',
 '[table]'=>'<table>', '[/table]'=>'</table>',
 '[tr]'=>'<tr>', '[/tr]'=>'</tr>',
 '[td]'=>'<td>', '[/td]'=>'</td>',
 '[quote]'=>'<br /><b>Цитата:</b><div class="msgBody_quote">', '[/quote]'=>'</div>',
 '[edit]'=>'<br /><b>Редаговано:</b><div style="display:block;border:1px solid red;background-color:#ee9">','[/edit]'=>'</div>',
 '[pre]'=>'<pre>', '[/pre]'=>'</pre>',
 '[left]'=>'<div align="left">', '[/left]'=>'</div>',
 '[center]'=>'<div align="center">', '[/center]'=>'</div>',
 '[right]'=>'<div align="right">', '[/right]'=>'</div>',
 '[hr]'=>'<hr />',
 '[br]'=>'<br />',
 '[black]'=>'<span style="color:black">', '[/black]'=>'</span>',
 '[white]'=>'<span style="color:white">', '[/white]'=>'</span>',
 '[red]'=>'<span style="color:red">', '[/red]'=>'</span>',
 '[green]'=>'<span style="color:green">', '[/green]'=>'</span>',
 '[blue]'=>'<span style="color:blue">', '[/blue]'=>'</span>',
);

my %smilleys=(
':)'=>'smiley',
';)'=>'wink',
':D'=>'cheesy',
';D'=>'grin',
'&amp;gt;:('=>'angry', ## really, >:(
':('=>'sad',
':o'=>'shocked',
'8)'=>'cool',
'::)'=>'rolleyes',
':P'=>'tongue',
':-['=>'embarassed',
':-X'=>'lipsrsealed',
':-/'=>'undecided',
':-*'=>'kiss',
':\'('=>'cry'
);

sub plural
{
  my ($n,$f1,$f2,$f3)=@_;
  my $remainder=$n%10;
  my $remainder2=$n%100;
  return $f3 if($remainder==0 || ($remainder2>=5 && $remainder2<=20));
  return $f1 if($remainder==1);
  return $f2 if($remainder>=2 && $remainder<=4);
  return $f3;
}

sub parseListItems
{
  my $txt=shift;
  $txt=~s/\[\*\]/<li>/;
  $txt=~s/\[\*\]/<\/li><li>/g;
  $txt.='</li>';
  return $txt;
}

sub prepareCode
{
  my $txt=shift;
  $txt=~s/\[/&#91;/g;
  $txt=~s/\]/&#93;/g;
  return $txt;
}

sub insertWbrs
{
  my $line=shift;
  $line=~s{([^\s]{40})}{$1<wbr/>}g;
  $line=~s{(\&[a-z0-9#]*)(<wbr/>)([a-z0-9#]*;)}{$1$3$2}gi;
  return $line;
}

sub parseBBCode
{
  my $body=shift;
  
  $body=~s{\&nbsp;}{ }g;
  $body=~s{\[code\](.*?)\[/code\]}{'<br /><b>Код:</b><div class="msgBody_code">'.prepareCode($1).'</div>'}gse;

  $body=~s{\[table\].*?\[td\].*?\[tr\](.*)\[/td\].*?\[/tr\].*?\[/table\]}{$bbtags{'[table]'}$bbtags{'[tr]'}$bbtags{'[td]'}$1$bbtags{'[/td]'}$bbtags{'[/tr]'}$bbtags{'[/table]'}}isg;
  $body=~s{(\[/?(b|i|u|s|quote|edit|pre|left|center|right|hr|sub|sup|tt|table|tr|td|black|white|green|red|blue)\])}{$bbtags{lc($1)}}gie;
  
  $body=~s~([^\w\"\=\[\]\<]|[\n\b]|\A)\\*(\w+://[\w\~\.\;\:\,\$\-\+\!\*\?/\=\&\@\#\%]+\.[\w\~\;\:\$\-\+\!\*\?/\=\&\@\#\%]+[\w\~\;\:\$\-\+\!\*\?/\=\&\@\#\%])~$1<a href="$2">$2</a>~isg;
  
  $body=~s{\[url\]([a-zA-Z0-9]+://[^\[]*)\[/url\]}{<a href="$1">$1</a>}gi;
  $body=~s{\[url\]([^\[]*)\[/url\]}{<a href="http://$1">$1</a>}gi;

  $body=~s{\[ftp\]([a-zA-Z0-9]+://[^\[]*)\[/ftp\]}{<a href="$1">$1</a>}gi;
  $body=~s{\[ftp\]([^\[]*)\[/ftp\]}{<a href="ftp://$1">$1</a>}gi;
  
  $body=~s{\[email\]([^\[]*)\[/email\]}{<a href="mailto:$1">$1</a>}gi;
  $body=~s{\[img\]([^\[]*)\[/img\]}{<img src="$1" alt="$1" border="0" />}gi;
# $body=~s{\[list\](.*?)\[/list\]}{"<ul>".parseListItems($1)."</ul>"}gise;
  while($body=~s{\[list\].*?(\[\*\].*?)\[/list\]}{"<ul>".parseListItems($1)."</ul>"}gise){};
  $body=~s{\[color=([^\[\]]*)\](.*?)\[\/\1\]}{<span style="color: $1;">$2</span>}gis;
  $body=~s{\[font=([^\[\]]*)\](.*?)\[\/\1\]}{<span style="font-family: $1;">$2</span>}gis;
  $body=~s{\[size=([^\[\]]*)\](.*?)\[\/size\]}{<span style="font-size: ${1}px">$2</span>}gis;
  $body=~s{\[link=([^\[\]]*://[^\[\]]*)\](.*?)\[\/link\]}{<a href="$1">$2</a>}gis;
  $body=~s{\[link=([^\[\]]*)\](.*?)\[\/link\]}{<a href="http://$1">$2</a>}gis;
  $body=~s{\[url=([^\[\]]*://[^\[\]]*)\](.*?)\[\/url\]}{<a href="$1">$2</a>}gis;
  $body=~s{\[url=([^\[\]]*)\](.*?)\[\/url\]}{<a href="http://$1">$2</a>}gis;
  
  $body=~s{(\W|\A)(\:\)|;\)|:D|;D|&amp;gt;:\(|:\(|:o|8\)|::\)|:P|:-\[|:-X|:-/|:-\*|:\'\()}{"$1<img src=\"/yabbfiles/Templates/Forum/default/".$smilleys{$2}.".gif\" alt=\"$2\" title=\"$2\" />"}ge;

  $body=~s/\[ch(\d{3,}?)\]/&#$1;/ig;
  
  return $body;
}

my @weekDays=("неділя","понеділок","вівторок","середа","четвер","п'ятниця","субота","неділя");
my @months=qw(січня лютого березня квітня травня червня липня серпня вересня жовтня листопада грудня);
sub ukrDate
{
 my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(shift);
 $year+=1900;
 $min="0$min" if($min<10);
 $hour="0$hour" if($hour<10);
 return "$weekDays[$wday], $mday $months[$mon] $year $hour:$min";
}

1;
