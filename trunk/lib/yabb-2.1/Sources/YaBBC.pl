###############################################################################
# YaBBC.pl                                                                    #
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

$yabbcplver = 'YaBB 2.1 $Revision: 1.22 $';
if ($action eq 'detailedversion') { return 1; }

LoadLanguage("Post");
LoadLanguage("CYaBBC");

$yyYaBBCloaded = 1;
$loaded{'YaBBC.pl'} = 1;

sub decode_direction {
	$_ = $_[0];
	$_ =~ s~left~270~ig;
	$_ =~ s~right~90~ig;
	$_ =~ s~top~0~ig;
	$_ =~ s~bottom~180~ig;
	$_ =~ s~topright~45~ig;
	$_ =~ s~bottomright~135~ig;
	$_ =~ s~bottomleft~225~ig;
	$_ =~ s~topleft~315~ig;
	return $_;
}

sub validwidth { return ($_[0] > 400 ? 400 : $_[0]); }

sub MakeSmileys {
	$message =~ s/\[smilie=(\S+?\.(gif|jpg|png|bmp))\]/\<img border="0" src="$smiliesurl\/$1" alt="$post_txt{'287'}" \/\>/isg;
	$message =~ s/\[smiley=(\S+?\.(gif|jpg|png|bmp))\]/\<img border="0" src="$smiliesurl\/$1" alt="$post_txt{'287'}" \/\>/isg;
	$message =~ s/(\W|\A)\;\)/$1\<img border="0" src="$defaultimagesdir\/wink.gif\" alt="$post_txt{'292'}" \/>/g;
	$message =~ s/(\W|\A)\;\-\)/$1\<img border="0" src="$defaultimagesdir\/wink.gif\" alt="$post_txt{'292'}" \/>/g;
	$message =~ s/(\W|\A)\;D/$1\<img border="0" src="$defaultimagesdir\/grin.gif\" alt="$post_txt{'293'}" \/>/g;
	$message =~ s/\Q:'(\E/\<img border="0" src="$defaultimagesdir\/cry.gif\" alt="$post_txt{'530'}" \/>/g;
	$message =~ s/(\W|\A)\:\-\//$1\<img border="0" src="$defaultimagesdir\/undecided.gif\" alt="$post_txt{'528'}" \/>/g;
	$message =~ s/\Q:-X\E/\<img border="0" src="$defaultimagesdir\/lipsrsealed.gif\" alt="$post_txt{'527'}" \/>/g;
	$message =~ s/\Q:-[\E/\<img border="0" src="$defaultimagesdir\/embarassed.gif\" alt="$post_txt{'526'}" \/>/g;
	$message =~ s/\Q:-*\E/\<img border="0" src="$defaultimagesdir\/kiss.gif\" alt="$post_txt{'529'}" \/>/g;
	$message =~ s/\Q&gt;:(\E/\<img border="0" src="$defaultimagesdir\/angry.gif\" alt="$post_txt{'288'}" \/>/g;
	$message =~ s/\Q::)\E/\<img border="0" src="$defaultimagesdir\/rolleyes\.gif\" alt="$post_txt{'450'}" \/>/g;
	$message =~ s/\Q:P\E/\<img border="0" src="$defaultimagesdir\/tongue\.gif\" alt="$post_txt{'451'}" \/>/g;
	$message =~ s/\Q:)\E/\<img border="0" src="$defaultimagesdir\/smiley\.gif\" alt="$post_txt{'287'}" \/>/g;
	$message =~ s/\Q:-)\E/\<img border="0" src="$defaultimagesdir\/smiley\.gif\" alt="$post_txt{'287'}" \/>/g;
	$message =~ s/\Q:D\E/\<img border="0" src="$defaultimagesdir\/cheesy.gif\" alt="$post_txt{'289'}" \/>/g;
	$message =~ s/\Q:-(\E/\<img border="0" src="$defaultimagesdir\/sad.gif\" alt="$post_txt{'291'}" \/>/g;
	$message =~ s/\Q:(\E/\<img border="0" src="$defaultimagesdir\/sad.gif\" alt="$post_txt{'291'}" \/>/g;
	$message =~ s/\Q:o\E/\<img border="0" src="$defaultimagesdir\/shocked.gif\" alt="$post_txt{'294'}" \/>/gi;
	$message =~ s/\Q8-)\E/\<img border="0" src="$defaultimagesdir\/cool.gif\" alt="$post_txt{'295'}" \/>/g;
	$message =~ s/\Q:-?\E/\<img border="0" src="$defaultimagesdir\/huh.gif\" alt="$post_txt{'296'}" \/>/g;
	$message =~ s/\Q^_^\E/\<img border="0" src="$defaultimagesdir\/happy.gif\" alt="$post_txt{'801'}" \/>/g;
	$message =~ s/\Q:thumb:\E/\<img border="0" src="$defaultimagesdir\/thumbsup.gif\" alt="$post_txt{'282'}" \/>/g;
	$message =~ s/\Q&gt;:-D\E/\<img border="0" src="$defaultimagesdir\/evil.gif\" alt="$post_txt{'802'}" \/>/g;
	$count = 0;

	while ($SmilieURL[$count]) {
		if ($SmilieURL[$count] =~ /\//i) { $tmpurl = $SmilieURL[$count]; }
		else { $tmpurl = qq~$defaultimagesdir/$SmilieURL[$count]~; }
		$tmpcode = $SmilieCode[$count];
		$tmpcode =~ s/&#36;/\$/g;
		$tmpcode =~ s/&#64;/\@/g;
		$message =~ s/\Q$tmpcode\E/\<img border="0" src="$tmpurl" alt="" \/\>/g;
		$count++;
	}
}

$MAXIMGWIDTH  = 400;
$MAXIMGHEIGHT = 500;

sub restrictimage {
	my ($w, $h, $s) = @_;
	$w = $w <= $MAXIMGWIDTH  ? $w : $MAXIMGWIDTH;
	$h = $h <= $MAXIMGHEIGHT ? $h : $MAXIMGHEIGHT;
	return qq~<img src="$s" width="$w" height="$h" alt="" border="0" />~;
}

sub quotemsg {
	my ($noquot, $qauthor, $qlink, $qdate, $qmessage) = @_;
	if ($qauthor) {
		$qmessage =~ s~\/me\s+(.*?)(\n|\Z)(.*?)~<span style="font-style: italic; font-weight: bolder; color: #007788;">* $qauthor $1</span>$2$3~ig;
	}
	$qmessage = &parseimgflash($qmessage);
	$qdate    = &timeformat($qdate);
	if ($action ne "imshow") { $_ = $post_txt{'600'}; }
	if ($qauthor eq "" || $qlink eq "" || $qdate eq "") { $_ = $post_txt{'601'}; }
	else { $_ = $post_txt{'599'}; }
	$_ =~ s~AUTHOR~$qauthor~g;
	$_ =~ s~QUOTELINK~$scripturl?num=$qlink~g;
	$_ =~ s~DATE~$qdate~g;
	$_ =~ s~QUOTE~$qmessage~g;
	$cnvmessage = qq~$noquot$_~;
	return $cnvmessage;
}

sub parseimgflash {
	my $tmp_message = $_[0];
	my $char_160    = '';

	$tmp_message =~ s~\[flash\=(\S+?),(\S+?)](\S+?)\[\/flash\]~<b>$display_txt{'769'} ($1 x $2):</b> <a href="$3" target="_blank" onclick="window.open('$3', 'flash', 'resizable,width=$1,height=$2'); return false;">$3</a>~g;
	$char_160  = chr(160);
	$hardspace = q~&nbsp;~;
#	$tmp_message =~ s~\&nbsp\;~~g;
	$tmp_message =~ s~\[img\](?:\s|\t|\n|$hardspace|$char_160)*(http\:\/\/)*(.+?)(?:\s|\t|\n|$hardspace|$char_160)*\[/img\]~<a href="http\:\/\/$2" alt="" border="0" target="_blank">http\:\/\/$2</a>~isg;
	$tmp_message =~ s~\[img width=(\d+) height=(\d+)\](?:\s|\t|\n|$hardspace|$char_160)*(http\:\/\/)*(.+?)(?:\s|\t|\n|$hardspace|$char_160)*\[\/img\]~<a href="http:\\$4" alt="" target="_blank" border="0" onclick="window.open('http\:\/\/$4', 'image', 'resizable,width=$1,height=$2'); return false;">http:\/\/$4</a>~ig;
	return $tmp_message;

}

if (!$fontsizemax) { $fontsizemax = 72; }
if (!$fontsizemin) { $fontsizemin = 6;  }

sub sizefont {
	## limit minimum and maximum font pitch as CSS does not restrict it at all. ##
	my ($tsize, $ttext) = @_;
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
		&ToChars($code);
		if ($code !~ /&\S*;/) { $code =~ s/;/&#059;/g; }
		$code =~ s~([\(\)\-\:\\\/\?\!\]\[\.\^])~$killhash{$1}~g;
		$code =~ s~\&\#91\;highlight\&\#93\;(.*?)\&\#91\;\&\#47\;highlight\&\#93\;~<span class="highlight">$1</span>~isg;
		$_ = $post_txt{'602'};

		# Thx. to Michael Prager for the improved Code boxes
		# count lines in code
		$linecount = () = $code =~ /\n/g;

		# if more that 20 lines then limit code box height
		if ($linecount > 20) {
			$height = "height: 300px;";
		} else {
			$height = "";
		}

		# try to display text as it was originally intended
		$code =~ s~ \&nbsp; \&nbsp; \&nbsp;~\t~ig;
		$code =~ s~\&nbsp;~ ~ig;
#		$code =~ s~ ?\n ?~\[code_br\]~ig;            # we need to keep normal linebreaks inside <pre> tag
		$code =~ s~\n~\[code_br\]~ig;            # we need to keep normal linebreaks inside <pre> tag
		$code = qq~<pre class="code" style="margin: 0px; width: 90%; $height overflow: auto;">$code\[code_br\][code_br\]</pre>~;
		$_ =~ s~CODE~$code~g;
		return $_;
	}
}

sub killimgurls {
	$_ = $_[0];
	$_ =~ s~\[url(.*?)\](.*?)\[\/url\]~~ig;
	$_ =~ s~\[link(.*?)\](.*?)\[\/link\]~~ig;
	$_ =~ s~http\:\/\/~~ig;
	return $_;
}

sub DoUBBC {
	$message =~ s~\[code\]~ \[code\]~ig;
	$message =~ s~\[/code\]~ \[/code\]~ig;
	$message =~ s~\[quote\]~ \[quote\]~ig;
	$message =~ s~\[/quote\]~ \[/quote\]~ig;
	$message =~ s~\[img\]~ \[img\]~ig;

	$message =~ s~\[img(.*?)\](.*?)\[/img\]~qq^[img$1\]^ . &killimgurls($2) . q^[/img]^~eisg;

	$message =~ s~\[glow\]~ \[glow\]~ig;
	$message =~ s~\[/glow\]~ \[/glow\]~ig;
	$message =~ s~<br>~\n~ig;
	$message =~ s~<br />~\n~ig;
	$message =~ s~\[code\]\n*(.+?)\n*\[/code\]~&codemsg($1)~eisg;
	if ($message =~ /\#nosmileys/isg || $ns =~ "NS") { $message =~ s/\#nosmileys//isg; }
	else { &MakeSmileys; }
	$message =~ s~\[([^\]\[]{0,30})\n([^\]\[]{0,30})\]~\[$1$2\]~g;
	$message =~ s~\[/([^\]\[]{0,30})\n([^\]\[]{0,30})\]~\[/$1$2\]~g;
#	$message =~ s~(\w+://[^<>\s\n\"\]\[]+)\n([^<>\s\n\"\]\[]+)~$1\n$2~g;
	$message =~ s~\[b\](.*?)\[/b\]~<b>$1</b>~isg;
	$message =~ s~\[i\](.*?)\[/i\]~<i>$1</i>~isg;
	$message =~ s~\[u\](.*?)\[/u\]~<u>$1</u>~isg;
	$message =~ s~\[s\](.*?)\[/s\]~<s>$1</s>~isg;
	$message =~ s~\[glb\](.*?)\[/glb\]~<span style\=\"font-weight: bold\;\">$1</span>~isg;
	$message =~ s~\[move\](.*?)\[/move\]~<marquee>$1</marquee>~isg;

	$hardspace = q~&nbsp;~;
	$char_160  = chr(160);

	while ($message =~ s~(.*)\[quote(\s+author=(.*?)\s(?:\s|$hardspace)*link=(.*?)\s+date=(.*?)\s*)?\]\s*(.*?)\s*\[/quote\]~&quotemsg($1,$3,$4,$5,$6)~eisg) { };

	$message =~ s~\[img\](?:\s|\t|\n|$hardspace|$char_160)*(http\:\/\/)*(.+?)(?:\s|\t|\n|$hardspace|$char_160)*\[/img\]~<img src="http\:\/\/$2" alt="" border="0" />~isg;
	$message =~ s~\[img width=(\d+) height=(\d+)\](?:\s|\t|\n|$hardspace|$char_160)*(http\:\/\/)*(.+?)(?:\s|\t|\n|$hardspace|$char_160)*\[/img\]~restrictimage($1,$2,'http://'.$4)~eisg;

	$message =~ s~\[color=([0-9#a-z -]+?)\](.+?)\[/color\]~<span style="color:$1;">$2</span>~isg;
	$message =~ s~\[black\](.*?)\[/black\]~<span style="color:#000;">$1</span>~isg;
	$message =~ s~\[white\](.*?)\[/white\]~<span style="color:#FFF;">$1</span>~isg;
	$message =~ s~\[red\](.*?)\[/red\]~<span style="color:#FF0000;">$1</span>~isg;
	$message =~ s~\[green\](.*?)\[/green\]~<span style="color:#0F0;">$1</span>~isg;
	$message =~ s~\[blue\](.*?)\[/blue\]~<span style="color:#00F;">$1</span>~isg;

	while ($message =~ s~\[hide?\](.*?)\[/hide?\]~<span class="showover">$1</span>~isg) {};
	while ($message =~ s~\[flood\](.*?)\[/flood\]~<b>$cyabbc_txt{'flood'}: </b><br /><div class="floodbg">$1</div>~isg) {};
	while ($message =~ s~\[flame\](.*?)\[/flame\]~<b>$cyabbc_txt{'flame'}: </b><br /><div class="flamebg">$1</div>~isg) {};
	while ($message =~ s~\[off(top(ic)?)?\](.*?)\[/off(top(ic)?)?\]~<b>$cyabbc_txt{'offtop'}: </b><br /><div class="offtopbg">$3</div>~isg) {};

	$message =~ s~\[edit\](.*?)\[/edit\]~<b>$post_txt{'603'}: </b><br /><div class="editbg" style="overflow: auto;">$1</div>~isg;
	$message =~ s~\[timestamp\=([\d]{9,10})\]~&timeformat($1)~eisg;
	$message =~ s~\[moved\]~$maintxt{'160'}~;
	$message =~ s~\[move by\]~$maintxt{'525'}~;
	$message =~ s~\[font=([0-9a-z _-]+?)\](.+?)\[/font\]~<span style="font-family:$1;">$2</span>~isg;
	while ($message =~ s~\[size=(\d+?)\](.+?)\[/size\]~&sizefont($1,$2)~eisg) { }

	$message =~ s~\[tt\](.*?)\[/tt\]~<tt>$1</tt>~isg;
	$message =~ s~\[left\](.*?)\[/left\]~<div style="text-align: left;">$1</div>~isg;
	$message =~ s~\[center\](.*?)\[/center\]~<center>$1</center>~isg;
	$message =~ s~\[right\](.*?)\[/right\]~<div style="text-align: right;">$1</div>~isg;
	$message =~ s~\[justify\](.*?)\[/justify\]~<div style="text-align: justify">$1</div>~isg;
	$message =~ s~\[sub\](.*?)\[/sub\]~<sub>$1</sub>~isg;
	$message =~ s~\[sup\](.*?)\[/sup\]~<sup>$1</sup>~isg;
	$message =~ s~\[fixed\](.*?)\[/fixed\]~<span style="font-family: Courier New;">$1</span>~isg;

	$message =~ s~\[hr\]\n~<hr width="40%" align="left" size="1" class="hr" />~g;
	$message =~ s~\[hr\]~<hr width="40%" align="left" size="1" class="hr" />~g;
	$message =~ s~\[br\]~\n~ig;
	$message =~ s~\s$YaBBversion\s~ \<a style\=\"font-weight: bold;\" href\=\"http\:\/\/www\.yabbforum\.com\/downloads\.php\"\>$YaBBversion Forum Software\<\/a\> ~g;

	if ($parseflash == 1) {
		if ($message =~ /\[flash\=(\d+?),(\d+?)\](\S+?)\[\/flash\]/) {
			$width  = $1;
			$height = $2;
			if ($3 =~ /^http:\/\//) {
				if ($width > 500)  { $width  = 500; }
				if ($height > 500) { $height = 500; }
				$message =~ s~\[flash\=(\S+?),(\S+?)](\S+?)\[\/flash\]~<object classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" width="$width" height="$height"><param name="movie" value="$3" /><param name="play" value="true" /><param name="loop" value="true" /><param name="quality" value="high" /><embed src="$3" width="$width" height="$height" play="true" loop="true" quality="high"></embed></object>~g;
			}
		}
	} else {

		if ($message =~ /\[flash\=(\S+?),(\S+?)](\S+?)\[\/flash\]/) {
			if ($3 =~ /http:\/\/(\S+?).swf/) {
				if ($stealthurl) {
					$message =~ s~\[flash\=(\S+?),(\S+?)](\S+?)\[\/flash\]~<b>$display_txt{'769'} ($1 x $2):</b> <a href="$boardurl/YaBB.$yyext?action=dereferer;url=$3" target="_blank" onclick="window.open('$3', 'flash', 'resizable,width=$1,height=$2'); return false;">$3</a>~;
				} else {
					$message =~ s~\[flash\=(\S+?),(\S+?)](\S+?)\[\/flash\]~<b>$display_txt{'769'} ($1 x $2):</b> <a href="$3" target="_blank" onclick="window.open('$3', 'flash', 'resizable,width=$1,height=$2'); return false;">$3</a>~;

				}
			}
		}
	}

	if ($autolinkurls) {
		$message =~ s~&quot;&gt;~">~g;
		$message =~ s~\[url\](.+?)\[\/url\]~$1 ~g;
		$message =~ s~([^\w\"\=\[\]]|^|\b|\[quote.*?\]|\[highlight\]|\[\*\]|\[td\]|\A)\\*(\w+?\:\/\/(?:[\w\~\;\:\,\$\-\+\!\*\?/\=\&\@\#\%\(\)]+?)\.(?:[\w\~\.\;\:\,\$\-\+\!\*\?/\=\&\@\#\%\(\)\x80-\xFF]{1,})+?)(\.\)\s|\)\.\s|\&quot\;\)\s|\<\/|\[\/|\[\*)~$1\[url\=$2\]$2\[\/url\]$3~ismg;
		$message =~ s~([^\w\"\=\[\]]|^|\b|\[quote.*?\]|\[highlight\]|\[\*\]|\[td\]|\A)\\*(\w+?\:\/\/(?:[\w\~\;\:\,\$\-\+\!\*\?/\=\&\@\#\%\(\)]+?)\.(?:[\w\~\.\;\:\,\$\-\+\!\*\?/\=\&\@\#\%\(\)\x80-\xFF]{1,})+?)(\.\s|\)\s|\&quot\;\s)~$1\[url\=$2\]$2\[\/url\]$3~ismg;
		$message =~ s~([^\w\"\=\[\]]|^|\b|\[quote.*?\]|\[highlight\]|\[\*\]|\[td\]|\A)\\*(\w+?\:\/\/(?:[\w\~\;\:\,\$\-\+\!\*\?/\=\&\@\#\%\(\)]+?)\.(?:[\w\~\.\;\:\,\$\-\+\!\*\?/\=\&\@\#\%\(\)\x80-\xFF]{1,})+?)(\s)~$1\[url\=$2\]$2\[\/url\]$3~ismg;
		$message =~ s~([^\"\=\[\]/\:\.(\://\w+)]|[\n\b]|\[quote.*?\]|\[highlight\]|\[\*\]|\[td\]|\A|\()\\*(www\.[^\.](?:[\w\~\;\:\,\$\-\+\!\*\?/\=\&\@\#\%\(\)]+?)\.(?:[\w\~\.\;\:\,\$\-\+\!\*\?/\=\&\@\#\%\(\)\x80-\xFF]{1,})+?)(\.\)\s|\)\.\s|\&quot\;\)\s|\<\/|\[\/|\[\*)~$1\[url\=$2\]$2\[\/url\]$3~isg; 
		$message =~ s~([^\"\=\[\]/\:\.(\://\w+)]|[\n\b]|\[quote.*?\]|\[highlight\]|\[\*\]|\[td\]|\A|\()\\*(www\.[^\.](?:[\w\~\;\:\,\$\-\+\!\*\?/\=\&\@\#\%\(\)]+?)\.(?:[\w\~\.\;\:\,\$\-\+\!\*\?/\=\&\@\#\%\(\)\x80-\xFF]{1,})+?)(\.\s|\)\s|\&quot\;\s)~$1\[url\=$2\]$2\[\/url\]$3~isg; 
		$message =~ s~([^\"\=\[\]/\:\.(\://\w+)]|[\n\b]|\[quote.*?\]|\[highlight\]|\[\*\]|\[td\]|\A|\()\\*(www\.[^\.](?:[\w\~\;\:\,\$\-\+\!\*\?/\=\&\@\#\%\(\)]+?)\.(?:[\w\~\.\;\:\,\$\-\+\!\*\?/\=\&\@\#\%\(\)\x80-\xFF]{1,})+?)(\s)~$1\[url\=$2\]$2\[\/url\]$3~isg;
	}

	if ($action eq "search2") {
		$message =~ s~\[(url|link|email)\](.*?)\[/\1\]~\[$1=$2\]$2\[/$1\]~ig;
		$message =~ s~\[(news|gopher|ftp|flash|img)(.*?)\](.*?)\[/\1\]~\[$1$2 tmp=$3\](.*?)\[/$1\]~ig;
		foreach $tmp (@search) {
			if ($searchtype == 4) { $message =~ s~(\Q$tmp\E)~\[shighlight\]$1\[/shighlight\]~ig; }
			else { $message =~ s~(^|\W|_)(\Q$tmp\E)(?=$|\W|_)~$1\[shighlight\]$2\[/shighlight\]$3~ig; }
		}
		$tmp = 1;
		while ($tmp) {
			$message =~ s~\[([^\]]*?)\[/?shighlight(.*?)\]~\[$1~ig;
			if ($message !~ m~\[([^\]]*?)\[/?shighlight(.*?)\]~i) { $tmp = 0; }
		}
		$message =~ s~\[(news|gopher|ftp|flash|img)(.*?) tmp=(.*?)\](.*?)\[/\1\]~\[$1$2\]$3\[/$1\]~ig;
	}
	if ($stealthurl) {
		$message =~ s~\[url\]www\.\s*(.+?)\s*\[/url\]~<a href="$boardurl/YaBB.$yyext?action=dereferer;url=http://www.$1" target="_blank">www.$1</a>~isg;
		$message =~ s~\[url=\s*(\w+\://.+?)\](.+?)\s*\[/url\]~<a href="$boardurl/YaBB.$yyext?action=dereferer;url=$1" target="_blank">$2</a>~isg;
		$message =~ s~\[url=\s*(.+?)\]\s*(.+?)\s*\[/url\]~<a href="$boardurl/YaBB.$yyext?action=dereferer;url=http://$1" target="_blank">$2</a>~isg;
		$message =~ s~\[url\]\s*(.+?)\s*\[/url\]~<a href="$boardurl/YaBB.$yyext?action=dereferer;url=$1" target="_blank">$1</a>~isg;

		$message =~ s~\[link\]www\.\s*(.+?)\s*\[/link\]~<a href="$boardurl/YaBB.$yyext?action=dereferer;url=http://www.$1">www.$1</a>~isg;
		$message =~ s~\[link=\s*(\w+\://.+?)\](.+?)\s*\[/link\]~<a href="$boardurl/YaBB.$yyext?action=dereferer;url=$1">$2</a>~isg;
		$message =~ s~\[link=\s*(.+?)\]\s*(.+?)\s*\[/link\]~<a href="$boardurl/YaBB.$yyext?action=dereferer;url=http://$1">$2</a>~isg;
		$message =~ s~\[link\]\s*(.+?)\s*\[/link\]~<a href="$boardurl/YaBB.$yyext?action=dereferer;url=$1">$1</a>~isg;
		$message =~ s~\[ftp\]\s*(.+?)\s*\[/ftp\]~<a href="$boardurl/YaBB.$yyext?action=dereferer;url=$1" target="_blank">$1</a>~isg;
	} else {
		$message =~ s~\[url\]\s*www\.(\S+?)\s*\[/url\]~<a href="http://www.$1" target="_blank">www.$1</a>~isg;
		$message =~ s~\[url=\s*(\S\w+\://\S+?)\s*\](.+?)\[/url\]~<a href="$1" target="_blank">$2</a>~isg;
		$message =~ s~\[url=\s*(\S+?)\](.+?)\s*\[/url\]~<a href="http://$1" target="_blank">$2</a>~isg;
		$message =~ s~\[url\]\s*(http://)?(\S+?)\s*\[/url\]~<a href="http://$2" target="_blank">$1$2</a>~isg;

		$message =~ s~\[link\]\s*www\.(\S+?)\s*\[/link\]~<a href="http://www.$1">www.$1</a>~isg;
		$message =~ s~\[link=\s*(\S\w+\://\S+?)\s*\](.+?)\[/link\]~<a href="$1">$2</a>~isg;
		$message =~ s~\[link=\s*(\S+?)\](.+?)\s*\[/link\]~<a href="http://$1">$2</a>~isg;
		$message =~ s~\[link\]\s*(\S+?)\s*\[/link\]~<a href="$1">$1</a>~isg;
		$message =~ s~\[ftp\]\s*(ftp://)?(.+?)\s*\[/ftp\]~<a href="ftp://$2">$1$2</a>~isg;
	}

	$message =~ s~(dereferer\;url\=http\:\/\/.*?)#(\S+?\")~$1;anch=$2~isg;
	$message =~ s~\[email\]\s*(\S+?\@\S+?)\s*\[/email\]~<a href="mailto:$1">$1</a>~isg;
	$message =~ s~\[email=\s*(\S+?\@\S+?)\](.*?)\[/email\]~<a href="mailto:$1">$2</a>~isg;

	$message =~ s~\[news\](\S+?)\[/news\]~<a href="$1">$1</a>~isg;
	$message =~ s~\[gopher\](\S+?)\[/gopher\]~<a href="$1">$1</a>~isg;

	$message =~ s~\[highlight\](.*?)\[/highlight\]~<span class="highlight">$1</span>~isg;
	$message =~ s~\[shighlight\](.*?)\[/shighlight\]~<span class="highlight">$1</span>~isg;

	$message =~ s~\/me\s+(.*)~<span style="font-style: italic; color: #005577;">* $displayname $1</span>~ig;

	$message =~ s~\[\*\]~</li><li>~isg;
	$message =~ s~\[olist\]~<ol>~isg;
	$message =~ s~\[/olist\]~</li></ol>~isg;
	$message =~ s~</li><ol>~<ol>~isg;
	$message =~ s~<ol></li>~<ol>~isg;
#	$message =~ s~\[\*\]~</li><li>~isg;
	$message =~ s~\[list\]~<ul>~isg;
	$message =~ s~\[/list\]~</li></ul>~isg;
	$message =~ s~</li><ul>~<ul>~isg;
	$message =~ s~<ul></li>~<ul>~isg;

	$message =~ s~\[pre\](.+?)\[/pre\]~'<pre>' . dopre($1) . '</pre>'~iseg;


	if ($message =~ m~\[table\](?:.*?)\[/table\]~is) {
		while ($message =~ s~<marquee>(.*?)\[table\](.*?)\[/table\](.*?)</marquee>~<marquee>$1<table>$2</table>$3</marquee>~s)        { }
		while ($message =~ s~<marquee>(.*?)\[table\](.*?)</marquee>(.*?)\[/table\]~<marquee>$1\[//table\]$2</marquee>$3\[//table\]~s) { }
		while ($message =~ s~\[table\](.*?)<marquee>(.*?)\[/table\](.*?)</marquee>~\[//table\]$1<marquee>$2\[//table\]$3</marquee>~s) { }
		$message =~ s~\n{0,1}\[table\]\n*(.+?)\n*\[/table\]\n{0,1}~<table>$1</table>~isg;
		while ($message =~ s~\<table\>(.*?)\n*\[tr\]\n*(.*?)\n*\[/tr\]\n*(.*?)\</table\>~<table>$1<tr>$2</tr>$3</table>~is) { }
		while ($message =~ s~\<tr\>(.*?)\n*\[td\]\n{0,1}(.*?)\n{0,1}\[/td\]\n*(.*?)\</tr\>~<tr>$1<td>$2</td>$3</tr>~is)     { }
		$message =~ s~<table>((?:(?!<tr>|</tr>|<td>|</td>|<table>|</table>).)*)<tr>~<table><tr>~isg;
		$message =~ s~<tr>((?:(?!<tr>|</tr>|<td>|</td>|<table>|</table>).)*)<td>~<tr><td>~isg;
		$message =~ s~</td>((?:(?!<tr>|</tr>|<td>|</td>|<table>|</table>).)*)<td>~</td><td>~isg;
		$message =~ s~</td>((?:(?!<tr>|</tr>|<td>|</td>|<table>|</table>).)*)</tr>~</td></tr>~isg;
		$message =~ s~</td>((?!<tr>|</tr>|<td>|</td>|<table>|</table>).*?)<td>~</td><td>~isg;
		$message =~ s~</td>((?!<tr>|</tr>|<td>|</td>|<table>|</table>).*?)</tr>~</td></tr>~isg;
		$message =~ s~</tr>((?:(?!<tr>|</tr>|<td>|</td>|<table>|</table>).)*)<tr>~</tr><tr>~isg;
		$message =~ s~</tr>((?:(?!<tr>|</tr>|<td>|</td>|<table>|</table>).)*)</table>~</tr></table>~isg;
	}

	while ($message =~ s~<a([^>]*?)\n([^>]*)>~<a$1$2>~)                  { }
	while ($message =~ s~<a([^>]*)>([^<]*?)\n([^<]*)</a>~<a$1>$2$3</a>~) { }
	while ($message =~ s~<a([^>]*?)&amp;([^>]*)>~<a$1&$2>~)              { }
	while ($message =~ s~<img([^>]*?)\n([^>]*)>~<img$1$2>~)              { }
	while ($message =~ s~<img([^>]*?)&amp;([^>]*)>~<img$1&$2>~)          { }

	$message =~ s~\[\&table(.*?)\]~<table$1>~g;
	$message =~ s~\[/\&table\]~</table>~g;
	$message =~ s~\n~<br />~ig;
	$message =~ s~\[code_br\]~\n~ig;
}

sub DoUBBCTo {
	# Does UBBC to $_[0] using &DoUBBC and keeps $message the same
	my($messagecopy, $returnthis);
	$messagecopy = $message;
	$message = $_[0];
	&DoUBBC;
	$returnthis = $message;
	$message = $messagecopy;
	return $returnthis;
}

1;
