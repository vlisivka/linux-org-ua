###############################################################################
# Printpage.pl                                                                #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.1                                                    #
# Released:       November 8, 2005                                            #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2005 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by: The YaBB Development Team                                      #
#              with assistance from the YaBB community.                       #
# Sponsored by: Xnull Internet Media, Inc. - http://www.ximinc.com            #
#               Your source for web hosting, web design, and domains.         #
###############################################################################

$printplver = 'YaBB 2.1 $Revision: 1.2 $';
if ($action eq 'detailedversion') { return 1; }

sub Print_IM {
	if    ($INFO{'caller'} == 1) { fopen(THREADS, "$memberdir/$username.msg")    || &donoopen; $boxtitle = "$maintxt{'316'}"; $type = "$maintxt{'318'}" }
	elsif ($INFO{'caller'} == 2) { fopen(THREADS, "$memberdir/$username.outbox") || &donoopen; $boxtitle = "$maintxt{'320'}"; $type = "$maintxt{'324'}"; }
	else { fopen(THREADS, "$memberdir/$username.imstore") || &donoopen; $boxtitle = "$load_imtxt{'46'}"; $type = "$maintxt{'318'}/$maintxt{'324'}"; }
	@threads = <THREADS>;
	fclose(THREADS);

	### Lets output all that info. ###
	print "Content-type: text/html\n\n";
	print qq~
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<title>$mbname - $maintxt{'668'}</title>
<meta http-equiv="Content-Type" content="text/html; charset=$yycharset" />
<script language="JavaScript" type="text/javascript">
<!--
function printPage() {
   if (window.print) {
      agree = confirm('$maintxt{773}');
      if (agree) window.print(); 
   }
}
// -->
</script>
</head>


<body onload="printPage()">

<table width="96%" align="center">
  <tr>
    <td>
    <span style="font-family: arial, sans-serif; font-size: 18px; font-weight: bold;">$mbname</span>
    <br />
    <span style="font-family: arial, sans-serif; font-size: 10px;">$scripturl</span>
    <br />
    <span style="font-family: arial, sans-serif; font-size: 14px; font-weight: bold;">$load_imtxt{'71'} $boxtitle $maintxt{'30'} $date</span>
    </td>
  </tr>
</table>

<br />

~;

	# Split the threads up so we can print them.
	foreach $thread (@threads) {
		($threadposter, $threadtitle, $threaddate, $threadpost, $trash) = split(/\|/, $thread);

		&do_print;
		print qq~
		<table width="96%" align="center" cellpadding="10" style="border: 1px solid #000000;">
  <tr>
    <td><span style="font-family: arial, sans-serif; font-size: 12px;">
    $maintxt{'70'}: <b>$threadtitle</b><br />
    $type <b>$threadposter</b> $maintxt{'30'} <b>$threaddate</b>
    </span>
    <hr width="100%" size="1" />
    <span style="font-family: arial, sans-serif; font-size: 12px;">
    $threadpost
    </span></td>
    </tr>
</table>

<br />
~;
	}
	print qq~
<table width="96%" align="center">
  <tr>
    <td align="center">
	  <span style="font-family: arial, sans-serif; font-size: 10px;">
    $yycopyright
    </span>
    </td>
  </tr>
</table>

</body>
</html>~;
	exit;
}

sub Print {
	$num = $INFO{'num'};

	# Determine category
	$curcat = ${$uid.$currentboard}{'cat'};
	&MessageTotals("load", $num);

	my $ishidden;
	if (${$num}{'threadstatus'} =~ /h/i) {
		$ishidden = 1;
	}

	if ($ishidden && !$iammod && !$iamadmin && !$iamgmod) { &fatal_error("$maintxt{'1'}"); }

	# Figure out the name of the category
	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }
	($cat, $catperms) = split(/\|/, $catinfo{"$curcat"});

	($boardname, $boardperms, $boardview) = split(/\|/, $board{"$currentboard"});

	&LoadCensorList;

	# Lets open up the thread file itself
	fopen(THREADS, "$datadir/$num.txt") || &donoopen;
	@threads = <THREADS>;
	fclose(THREADS);
	$cat =~ s/\n//g;

	($messagetitle, $poster, $trash, $date, $trash, $trash, $trash, $trash, $trash) = split(/\|/, $threads[0]);

	$startedby = $poster;
	$startedon = timeformat($date, 1);

	### Lets output all that info. ###
	print "Content-type: text/html\n\n";
	print qq~<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<title>$mbname - $maintxt{'668'}</title>
<meta http-equiv="Content-Type" content="text/html; charset=$yycharset" />
<script language="JavaScript" type="text/javascript">
<!--
function printPage() {
   if (window.print) {
      agree = confirm('$maintxt{773}');
      if (agree) window.print(); 
   }
}
// -->
</script>
</head>

<body onload="printPage()">

<table width="96%" align="center">
  <tr>
    <td>
    <span style="font-family: arial, sans-serif; font-size: 18px; font-weight: bold;">$mbname</span>
    <br />
    <span style="font-family: arial, sans-serif; font-size: 10px;">$scripturl</span>
    <br />
    <span style="font-family: arial, sans-serif; font-size: 16px; font-weight: bold;">$cat &gt;&gt; $boardname &gt;&gt; $messagetitle</span>
    <br />
    <span style="font-family: arial, sans-serif; font-size: 10px;">$scripturl?num=$num</span>
    <br />
    <hr size="1" width="100%" />
    <span style="font-family: arial, sans-serif; font-size: 14px; font-weight: bold;">$maintxt{'195'} $startedby $maintxt{'30'} $startedon</span>
    </td>
  </tr>
</table>

<br />~;

	# Split the threads up so we can print them.
	foreach $thread (@threads) {
		($threadtitle, $threadposter, $trash, $threaddate, $trash, $trash, $trash, $trash, $threadpost) = split(/\|/, $thread);

		&do_print;

		print qq~
<table width="96%" align="center" cellpadding="10" style="border: 1px solid #000000;">
  <tr>
    <td><span style="font-family: arial, sans-serif; font-size: 12px;">
    $maintxt{'196'}: <b>$threadtitle</b><br />
    $maintxt{'197'} <b>$threadposter</b> $maintxt{'30'} <b>$threaddate</b>
    </span>
    <hr width="100%" size="1" />
    <span style="font-family: arial, sans-serif; font-size: 12px;">
    $threadpost
    </span></td>
    </tr>
</table>

<br />~;
	}

	print qq~
<table width="96%" align="center">
  <tr>
    <td align="center">
	  <span style="font-family: arial, sans-serif; font-size: 10px;">
    $yycopyright
    </span>
    </td>
  </tr>
</table>

</body>
</html>~;
	exit;
}

sub sizefont {
	# limit minimum and maximum font pitch as CSS does not restrict it at all.
	my ($tsize, $ttext) = @_;
	if    (!$fontsizemax)         { $fontsizemax = 72; }
	if    (!$fontsizemin)         { $fontsizemin = 6; }
	if    ($tsize < $fontsizemin) { $tsize       = $fontsizemin; }
	elsif ($tsize > $fontsizemax) { $tsize       = $fontsizemax; }
	my $resized = qq~<span style="font-size:$tsize\px;">$ttext</span>~;
	return $resized;
}

{
	my %killhash = (
		';'  => '&#059;',
		'!'  => '&#33;',
		'('  => '&#40;',
		')'  => '&#41;',
		'-'  => '&#45;',
		'.'  => '&#46;',
		'/'  => '&#47;',
		':'  => '&#58;',
		'?'  => '&#63;',
		'['  => '&#91;',
		'\\' => '&#92;',
		']'  => '&#93;',
		'^'  => '&#94;');

	sub codemsg {
		my $code = $_[0];
		if ($code !~ /&\S*;/) { $code =~ s/;/&#059;/g; }
		$code =~ s~([\(\)\-\:\\\/\?\!\]\[\.\^])~$killhash{$1}~g;
		$_ = qq~<br /><b>Code:</b><br /><table cellspacing="1" width="90%"><tr><td width="100%"><table width="100%" cellpadding="2" cellspacing="0"><tr><td><font face="courier" size="1">CODE</font></td></tr></table></td></tr></table>~;
		$_ =~ s~CODE~$code~g;
		return $_;
	}
}

sub donoopen {
	print qq~
<html>
<head>
<title>$maintxt{'199'}</title>
</head>
<body>
<font size="2" face="Arial,Helvetica"><center>$maintxt{'199'}</center></font>
</body>
</html>~;
	exit;
}

sub do_print {

	$threadpost =~ s~<br />~\n~ig;
	$threadpost =~ s~\[highlight(.*?)\](.*?)\[/highlight\]~$2~isg;
	$threadpost =~ s~\[code\]\n*(.+?)\n*\[/code\]~<br /><b>Code:</b><br /><table cellspacing="1"><tr><td><table cellpadding="2" cellspacing="0"><tr><td><font face="Courier" size="1">$1</font></td></tr></table></td></tr></table>~isg;

	$threadpost =~ s~\[([^\]]{0,30})\n([^\]]{0,30})\]~\[$1$2\]~g;
	$threadpost =~ s~\[/([^\]]{0,30})\n([^\]]{0,30})\]~\[/$1$2\]~g;
	$threadpost =~ s~(\w+://[^<>\s\n\"\]\[]+)\n([^<>\s\n\"\]\[]+)~$1\n$2~g;

	$threadpost =~ s~\[b\](.*?)\[/b\]~<b>$1</b>~isg;
	$threadpost =~ s~\[i\](.*?)\[/i\]~<i>$1</i>~isg;
	$threadpost =~ s~\[u\](.*?)\[/u\]~<u>$1</u>~isg;
	$threadpost =~ s~\[s\](.*?)\[/s\]~<s>$1</s>~isg;
	$threadpost =~ s~\[move\](.*?)\[/move\]~$1~isg;

	$threadpost =~ s~\[glow(.*?)\](.*?)\[/glow\]~&elimnests($2)~eisg;
	$threadpost =~ s~\[shadow(.*?)\](.*?)\[/shadow\]~&elimnests($2)~eisg;

	$threadpost =~ s~\[shadow=(\S+?),(.+?),(.+?)\](.+?)\[/shadow\]~$4~eisg;
	$threadpost =~ s~\[glow=(\S+?),(.+?),(.+?)\](.+?)\[/glow\]~$4~eisg;

	$threadpost =~ s~\[color=([\w#]+)\](.*?)\[/color\]~$2~isg;
	$threadpost =~ s~\[black\](.*?)\[/black\]~$1~isg;
	$threadpost =~ s~\[white\](.*?)\[/white\]~$1~isg;
	$threadpost =~ s~\[red\](.*?)\[/red\]~$1~isg;
	$threadpost =~ s~\[green\](.*?)\[/green\]~$1~isg;
	$threadpost =~ s~\[blue\](.*?)\[/blue\]~$1~isg;

	$threadpost =~ s~\[font=(.+?)\](.+?)\[/font\]~<span style="font-family:$1;">$2</span>~isg;
	while ($threadpost =~ s~\[size=(.+?)\](.+?)\[/size\]~&sizefont($1,$2)~eisg) { }

	$threadpost =~ s~\[quote\s+author=(.*?)\s+link=(.*?)\].*\/me\s+(.*?)\[\/quote\]~\[quote author=$1 link=$2\]<i>* $1 $3</i>\[/quote\]~isg;
	$threadpost =~ s~\[quote(.*?)\].*\/me\s+(.*?)\[\/quote\]~\[quote$1\]<i>* Me $2</i>\[/quote\]~isg;
	$threadpost =~ s~\/me\s+(.*)~* $displayname $1~ig;

	$char_160 = chr(160);
	$threadpost =~ s~\[img\][\s*\t*\n*(&nbsp;)*($char_160)*]*(http\:\/\/)*(.+?)[\s*\t*\n*(&nbsp;)*($char_160)*]*\[/img\]~http://$2~isg;
	$threadpost =~ s~\[img width=(\d+) height=(\d+)\][\s*\t*\n*(&nbsp;)*($char_160)*]*(http\:\/\/)*(.+?)[\s*\t*\n*(&nbsp;)*($char_160)*]*\[/img\]~http://$4~isg;

	$threadpost =~ s~\[tt\](.*?)\[/tt\]~<tt>$1</tt>~isg;
	$threadpost =~ s~\[left\](.*?)\[/left\]~<div style="text-align: left;">$1</div>~isg;
	$threadpost =~ s~\[center\](.*?)\[/center\]~<center>$1</center>~isg;
	$threadpost =~ s~\[right\](.*?)\[/right\]~<div style="text-align: right;">$1</div>~isg;
	$threadpost =~ s~\[justify\](.*?)\[/justify\]~<div style="text-align: justify">$1</div>~isg;
	$threadpost =~ s~\[sub\](.*?)\[/sub\]~<sub>$1</sub>~isg;
	$threadpost =~ s~\[sup\](.*?)\[/sup\]~<sup>$1</sup>~isg;
	$threadpost =~ s~\[fixed\](.*?)\[/fixed\]~<span style="font-family: Courier New;">$1</span>~isg;

	$threadpost =~ s~\[\[~\{\{~g;
	$threadpost =~ s~\]\]~\}\}~g;
	$threadpost =~ s~\|~\&#124;~g;
	$threadpost =~ s~\[hr\]\n~<hr width="40%" align="left" size="1" class="hr" />~g;
	$threadpost =~ s~\[hr\]~<hr width="40%" align="left" size="1" class="hr" />~g;
	$threadpost =~ s~\[br\]~\n~ig;

	$threadpost =~ s~\[url\]www\.\s*(.+?)\s*\[/url\]~www.$1~isg;
	$threadpost =~ s~\[url=\s*(\w+\://.+?)\](.+?)\s*\[/url\]~$2 ($1)~isg;
	$threadpost =~ s~\[url=\s*(.+?)\]\s*(.+?)\s*\[/url\]~$2 (http://$1)~isg;
	$threadpost =~ s~\[url\]\s*(.+?)\s*\[/url\]~$1~isg;

	$threadpost =~ s~\[link\]www\.\s*(.+?)\s*\[/link\]~www.$1~isg;
	$threadpost =~ s~\[link=\s*(\w+\://.+?)\](.+?)\s*\[/link\]~$2 ($1)~isg;
	$threadpost =~ s~\[link=\s*(.+?)\]\s*(.+?)\s*\[/link\]~$2 (http://$1)~isg;
	$threadpost =~ s~\[link\]\s*(.+?)\s*\[/link\]~$1~isg;

	$threadpost =~ s~\[email\]\s*(\S+?\@\S+?)\s*\[/email\]~$1~isg;
	$threadpost =~ s~\[email=\s*(\S+?\@\S+?)\]\s*(.*?)\s*\[/email\]~$2 ($1)~isg;

	$threadpost =~ s~\[news\](.+?)\[/news\]~$1~isg;
	$threadpost =~ s~\[gopher\](.+?)\[/gopher\]~$1~isg;
	$threadpost =~ s~\[ftp\](.+?)\[/ftp\]~$1~isg;

	$threadpost =~ s~\[quote\s+author=(.*?)link=(.*?)\s+date=(.*?)\s*\]\n*(.*?)\n*\[/quote\]~<br /><i>$1 wrote</a>:</i><table cellspacing="1" width="90%"><tr><td width="100%"><table cellpadding="2" cellspacing="0" width="100%"><tr><td width="100%"><font size="1">$4</font></td></tr></table></td></tr></table>~isg;
	$threadpost =~ s~\[quote\]\n*(.+?)\n*\[/quote\]~<br /><i>Quote:</i><table cellspacing="1" width="90%"><tr><td width="100%"><table cellpadding="2" cellspacing="0" width="100%"><tr><td width="100%"><font face="Arial,Helvetica" size="1">$1</font></td></tr></table></td></tr></table>~isg;

	$threadpost =~ s~\[list\]~<ul>~isg;
	$threadpost =~ s~\[\*\]~<li>~isg;
	$threadpost =~ s~\[/list\]~</ul>~isg;

	$threadpost =~ s~\[pre\](.+?)\[/pre\]~'<pre>' . dopre($1) . '</pre>'~iseg;

	$threadpost =~ s~\[flash=(\S+?),(\S+?)\](\S+?)\[/flash\]~$3~isg;

	$threadpost =~ s~\{\{~\[~g;
	$threadpost =~ s~\}\}~\]~g;

	if ($threadpost =~ m~\[table\]~i) {
		$threadpost =~ s~\n{0,1}\[table\]\n*(.+?)\n*\[/table\]\n{0,1}~<table>$1</table>~isg;
		while ($threadpost =~ s~\<table\>(.*?)\n*\[tr\]\n*(.*?)\n*\[/tr\]\n*(.*?)\</table\>~<table>$1<tr>$2</tr>$3</table>~is) { }
		while ($threadpost =~ s~\<tr\>(.*?)\n*\[td\]\n{0,1}(.*?)\n{0,1}\[/td\]\n*(.*?)\</tr\>~<tr>$1<td>$2</td>$3</tr>~is)     { }
	}

	$threadpost =~ s~\[\&table(.*?)\]~<table$1>~g;
	$threadpost =~ s~\[/\&table\]~</table>~g;
	$threadpost =~ s~\n~<br />~ig;

	### Censor it ###
	$threadtitle = &Censor($threadtitle);
	$threadpost  = &Censor($threadpost);

	$threaddate = timeformat($threaddate, 1);
}

1;
