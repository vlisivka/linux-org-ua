###############################################################################
# Subs.pl                                                                     #
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

# BEGIN {} block to pass "perl -c" (at least from the directory above Sources)
BEGIN {
	push(@INC, "./Modules");
	push(@INC, "./Modules/Upload");
	push(@INC, "./Modules/Digest");
}

$subsplver = 'YaBB 2.1 $Revision: 1.15 $';

use subs 'exit';
$yymain = "";
$CGITempFile::TMPDIRECTORY = "$uploaddir";

# set line wrap limit in Display.
$linewrap = 80;

# get the current date/time
$date = int(time + $timecorrection);

# parse the query string
&readform;                                   

$uid = substr($date, length($date) - 3, 3);
$session_id = $cookiesession_name;

$user_ip = $ENV{'REMOTE_ADDR'};

if ($user_ip eq "127.0.0.1") {
	if    ($ENV{'HTTP_CLIENT_IP'}       && $ENV{'HTTP_CLIENT_IP'}       ne "127.0.0.1") { $user_ip = $ENV{'HTTP_CLIENT_IP'}; }
	elsif ($ENV{'X_CLIENT_IP'}          && $ENV{'X_CLIENT_IP'}          ne "127.0.0.1") { $user_ip = $ENV{'X_CLIENT_IP'}; }
	elsif ($ENV{'HTTP_X_FORWARDED_FOR'} && $ENV{'HTTP_X_FORWARDED_FOR'} ne "127.0.0.1") { $user_ip = $ENV{'HTTP_X_FORWARDED_FOR'}; }
}

$masterseed = substr($date, length($date) - 4, length($date));
$formsession = &encode_session($mbname, $masterseed);
$formsession .= $masterseed;

if (-e ("YaBB.cgi")) { $yyext = "cgi"; }
else { $yyext = "pl"; }
if (-e ("AdminIndex.cgi")) { $yyaext = "cgi"; }
else { $yyaext = "pl"; }

# data files state indication. U can use fullnames here.
our %loaded = (
	online_users => 0, # $vardir/log.txt - %online_users
	                   # *.log (mainly $username.log) - %yyuserlog
);

# login/ip => other log.txt info
our %online_users;

sub getnewid {
	my $newid = int(time);
	while (-e "$datadir/$newid.txt") { ++$newid; }
	return $newid;
}

sub undupe {
	@in  = @_;
	@out = ();
	foreach $check (@in) {
		$duped = 0;
		foreach $checkout (@out) {
			if ($checkout eq $check) { $duped = 1; }
		}
		if ($duped == 0) {
			push(@out, $check);
		}
	}
	return @out;
}

sub exit {
	local $| = 1;
	local $\ = '';
	print '';
	CORE::exit($_[0] || 0);
}

sub header {
	my %params = @_;
	my $ret    = "";
	if ($params{'-status'}) {
		if ($yyIIS) {
			$ret .= "HTTP/1.0 $params{'-status'}\n";
		} else {
			$ret .= "Status: $params{'-status'}\n";
		}
	}
	if (!$cachebehaviour || $cachebehaviour == 0) {
		$ret .= qq~Cache-Control: no-cache, must-revalidate\n~;
		$ret .= qq~Pragma: no-cache\n~;
	}
	if ($params{'-cookie'}) {
		my (@cookie) = ref($params{'-cookie'}) && ref($params{'-cookie'}) eq 'ARRAY' ? @{ $params{'-cookie'} } : $params{'-cookie'};
		foreach (@cookie) {
			$ret .= "Set-Cookie: $_\n";
		}
	}
	if ($params{'-location'}) {
		$ret .= "Location: $params{'-location'}\n";
	}
	$params{'-charset'} = "; charset=$params{'-charset'}" if $params{'-charset'};
	$params{'Content-Encoding'} = "Content-Encoding: $params{'Content-Encoding'}\n" if $params{'Content-Encoding'};
	$ret .= "$params{'Content-Encoding'}Content-Type: text/html$params{'-charset'}\r\n\r\n";
	return $ret;
}

sub cookie {
	my %params = @_;

	if ($params{'-expires'} =~ /\+(\d+)m/) {
		my ($sec, $min, $hour, $mday, $mon, $year, $wday) = gmtime(time + $1 * 60);

		$year += 1900;
		my @mos = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec");
		my @dys = ("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat");
		$mon  = $mos[$mon];
		$wday = $dys[$wday];

		$params{'-expires'} = sprintf("%s, %02i-%s-%04i %02i:%02i:%02i GMT", $wday, $mday, $mon, $year, $hour, $min, $sec);
	}

	$params{'-path'}    = " path=$params{'-path'};"       if $params{'-path'};
	$params{'-expires'} = " expires=$params{'-expires'};" if $params{'-expires'};

	return "$params{'-name'}=$params{'-value'};$params{'-path'}$params{'-expires'}";
}

sub redirectexit {
	if ($gzcomp && $gzaccept) {
		if ($yySetCookies1 || $yySetCookies2 || $yySetCookies3) {
			print header(-status            => '302 Moved Temporarily',
				'Content-Encoding' => 'gzip',
				-cookie   => [$yySetCookies1, $yySetCookies2, $yySetCookies3],
				-location => $yySetLocation);
		} else {
			print header(-status            => '302 Moved Temporarily',
				'Content-Encoding' => 'gzip',
				-location          => $yySetLocation);
		}
	} else {
		if ($yySetCookies1 || $yySetCookies2 || $yySetCookies3) {
			$cookiewritten = "Cookie Set";
			print header(-status => '302 Moved Temporarily',
				-cookie   => [$yySetCookies1, $yySetCookies2, $yySetCookies3],
				-location => $yySetLocation);
		} else {
			print header(-status   => '302 Moved Temporarily',
				-location => $yySetLocation);
		}
	}
	exit;
}

sub redirectinternal {
	if ($currentboard) {
		if ($INFO{'num'}) { require "$sourcedir/Display.pl"; &Display; }
		else { require "$sourcedir/MessageIndex.pl"; &MessageIndex; }
	} else {
		require "$sourcedir/BoardIndex.pl";
		&BoardIndex;
	}
	exit;
}

sub ImgLoc {
	if (!-e "$forumstylesdir/$useimages/$_[0]") { $thisimgloc = qq~img src="$forumstylesurl/default/$_[0]"~; }
	else { $thisimgloc = qq~img src="$imagesdir/$_[0]"~; }
	return $thisimgloc;
}

sub template {
	my $gzaccept = $ENV{'HTTP_ACCEPT_ENCODING'} =~ /\bgzip\b/ || $gzforce;

	#print header
	if ($gzcomp && $gzaccept) {
		if ($yySetCookies1 || $yySetCookies2 || $yySetCookies3) {
			$cookiewritten = "Cookie Set";
			print header(-status            => '200 OK',
				'Content-Encoding' => 'gzip',
				-cookie  => [$yySetCookies1, $yySetCookies2, $yySetCookies3],
				-charset => $yycharset);
		} else {
			print header(-status            => '200 OK',
				'Content-Encoding' => 'gzip',
				-charset           => $yycharset);
		}
	} else {
		if ($yySetCookies1 || $yySetCookies2 || $yySetCookies3) {
			$cookiewritten = "Cookie Set";
			print header(-status => '200 OK',
				-cookie  => [$yySetCookies1, $yySetCookies2, $yySetCookies3],
				-charset => $yycharset);
		} else {
			print header(-status  => '200 OK',
				-charset => $yycharset);
		}
	}

	$yyposition = $yytitle;
	$yytitle    = "$mbname - $yytitle";

	# remove search from menu if disabled by the admin 
	$yymenu = qq~<a href="$scripturl">$img{'home'}</a>$menusep$img{'rules'}$menusep<a href="$scripturl?action=help" style="cursor:help;">$img{'help'}</a>~;
	if ($maxsearchdisplay > -1) {
		$yymenu .= qq~$menusep<a href="$scripturl?action=search">$img{'search'}</a>~;
	}
	if (!$iamguest) {
		$yymenu .= qq~$menusep<a href="$scripturl?action=ml">$img{'memberlist'}</a>~;
		if (${$uid.$username}{'favorites'}) {
			$yymenu .= qq~$menusep<a href="$scripturl?action=favorites">$img{'favorites'}</a>~;
		}
	}

	if ($iamadmin) { $yymenu .= qq~$menusep<a href="$boardurl/AdminIndex.$yyaext">$img{'admin'}</a>~; }
	if ($iamgmod) {
		if (-e ("$vardir/gmodsettings.txt")) {
			require "$vardir/gmodsettings.txt";
		}
		if ($allow_gmod_admin) { $yymenu .= qq~$menusep<a href="$boardurl/AdminIndex.$yyaext">$img{'admin'}</a>~; }
	}
	if ($sessionvalid == 0 && !$iamguest) { $yymenu .= qq~$menusep<a href="$scripturl?action=revalidatesession">$img{'sessreval'}</a>~; }
	if ($iamguest) {
		$yymenu .= qq~$menusep<a href="$scripturl?action=login">$img{'login'}</a>~;
		if (!$regdisable) { $yymenu .= qq~$menusep<a href="$scripturl?action=register">$img{'register'}</a>~; }
	} else {
		$yymenu .= qq~$menusep<a href="$scripturl?action=viewprofile;username=$username">$img{'profile'}</a>~;
		if ($enable_notification) { $yymenu .= qq~$menusep<a href="$scripturl?action=shownotify">$img{'notification'}</a>~; }
		$yymenu .= qq~$menusep<a href="$scripturl?action=logout">$img{'logout'}</a>~;
	}

	### SAFETY LOCK ###
	if ( $iamadmin or $iamgmod or $iammod ) {
		$yymenu .= qq~$menusep<a href="$scripturl?action=nbwg">$img{'bwgmessage'}</a>$menusep<a href="$scripturl?action=safetylock">$img{'safetylock'}</a>~;
	} elsif ( ${$uid.$username}{'addgroups'} ) {
		require "$sourcedir/BanWithGroup.pl"
			if not $loaded{'BanWithGroup.pl'};
		my $lockgid = group_gid ( 'Safety Lock' );
		if ( defined $lockgid and ${$uid.$username}{'addgroups'} =~ /(^|,)$lockgid(,|$)/ ) {
			$yymenu .= qq~$menusep<a href="$scripturl?action=bwglog">$img{'bwglog'}</a>$menusep<a href="$scripturl?action=safetyunlock">$img{'safetyunlock'}</a>~;
		}
	}
	### SAFETY LOCK ###

	$yyimages        = $imagesdir;
	$yydefaultimages = $defaultimagesdir;
	$yystyle         = qq~<link rel="stylesheet" href="$forumstylesurl/$usestyle.css" type="text/css" />~;
	$yystylesheet    = qq~<link rel="stylesheet" href="$forumstylesurl/$usestyle.css" type="text/css" />~;
	$yystyle      =~ s~$usestyle\/~~g;
	$yystylesheet =~ s~$usestyle\/~~g;

	# This is for the Help Center and anywhere else that wants to add inline CSS.
	$yystyle      .= $yyinlinestyle;
	$yystylesheet .= $yyinlinestyle;

	if (!$usehead) { $usehead = qq~default~; }
	$yytemplate = "$templatesdir/$usehead/$usehead.html";
	fopen(TEMPLATE, "$yytemplate") || die("$maintxt{'23'}: $testfile");
	@yytemplate = <TEMPLATE>;
	fclose(TEMPLATE);
	$newsloaded = 0;

	my $output = '';
	$yyboardname = "$mbname";
	$yytime      = &timeformat($date, 1);

#	if ( $snark_enable ) {
#
#		require "$sourcedir/Snark.pl" if not $loaded{'Snark.pl'};
#		$yyuname = snark_header ( $username );
#	} els
	if ( $regdisable ) {
		$yyuname = $iamguest ? qq~$maintxt{'248'} $maintxt{'28'}. $maintxt{'249'} <a href="$scripturl?action=login">$maintxt{'34'}</a>.~ : qq~$maintxt{'247'} $realname, ~;
	} else {
		$yyuname = $iamguest ? qq~$maintxt{'248'} $maintxt{'28'}. $maintxt{'249'} <a href="$scripturl?action=login">$maintxt{'34'}</a> $maintxt{'377'} <a href="$scripturl?action=register">$maintxt{'97'}</a>.~ : qq~$maintxt{'247'} $realname, ~;
	}
	if ($enable_news) {
		fopen(NEWS, "$vardir/news.txt");
		@newsmessages = <NEWS>;
		fclose(NEWS);
	}
	if ($debug == 1) {
		$time_running = time - $START_TIME;
		if ($START_TIME = 0 || $time_running > 1000) {
			$yytimeclock = "Your server probably does not have Time::Hires installed or does not support the local module for it";
		} else {
			$time_running = sprintf("%.4f", $time_running);
			$yytimeclock = "Page completed in $time_running seconds, Loaded $loadedboards Boards";
		}
		$yyfileactions = "Opened $file_open files and Closed $file_close files. (should be equal numbers)";
		$openfiles =~ s~\+\<~~g;
		$yyfilenames = $openfiles;
		$yydebug     = qq~<br /><u>Debugging Information</u><br /><br /><u>benchmarking</u><br />$yytimeclock<br /><br /><u>Your IP address is</u><br />$user_ip<br /><br /><u>Your Browser Agent:</u><br />$ENV{'HTTP_USER_AGENT'}<br /><br /><u>File Check on Open/Close</u><br />$yyfileactions<br /><br /><u>Filehandle/Files Opened:</u><br />$openfiles~;
	}
	for (my $i = 0; $i <= $#yytemplate; $i++) {
		$curline = $yytemplate[$i];
		if (!$yycopyin && $curline =~ m~<yabb copyright>~) { $yycopyin = 1; }
		$yysearchbox = "";
		unless ($iamguest && $guestaccess == 0) {
			if ($curline =~ m~<yabb searchbox>~ && $maxsearchdisplay > -1) {
				$checklist = "";
				unless ($mloaded == 1) { require "$boardsdir/forum.master"; }
				foreach $catid (@categoryorder) {
					if ($INFO{'catselect'} ne $catid && $INFO{'catselect'}) { next; }
					$boardlist = $cat{$catid};
					(@bdlist) = split(/\,/, $boardlist);
					my ($catname, $catperms, $catallowcol) = split(/\|/, $catinfo{"$catid"});
					# On early errors this may be called before Security.pl was loaded.
					# Hack to not bail out with error.
					if (defined &CatAccess) {
						my $access = &CatAccess($catperms);
						if (!$access) { next; }
						foreach $curboard (@bdlist) {
							chomp $curboard;
							$cat_boardcnt{$catid}++;
							my ($boardname, $boardperms, $boardview) = split(/\|/, $board{"$curboard"});
							my $access = &AccessCheck($curboard, '', $boardperms);
							if (!$iamadmin && $access ne "granted") { next; }
							$checklist .= qq~$curboard, ~;
						}
					}
				}
				$checklist =~ s/, \Z//;
				$yysearchbox = qq~
			<script language="JavaScript1.2" src="$ubbcjspath" type="text/javascript"></script>
			<form action="$scripturl?action=search2" method="post" onsubmit="return submitproc()">
			<input type="hidden" name="searchtype" value="allwords" />
			<input type="hidden" name="userkind" value="any" />
			<input type="hidden" name="subfield" value="on" />
			<input type="hidden" name="msgfield" value="on" />
			<input type="hidden" name="age" value="31" />
			<input type="hidden" name="numberreturned" value="$maxsearchdisplay" />
			<input type="hidden" name="oneperthread" value="1" />
			<input type="hidden" name="action" value="dosearch" />
			<input type="hidden" name="searchboards" value="$checklist" />
			<input type="text" name="search" size="16" style="font-size: 11px; vertical-align: middle;" />
			<input type="image" src="$imagesdir/search.gif" style="border: 0; background-color: transparent; margin-right: 5px; vertical-align: middle;" />
			</form>
			~;
			}
		}
		if ($curline =~ m~<yabb newstitle>~ && $enable_news) {
			$yynewstitle = qq~<b>$maintxt{'102'}:</b> ~;
		}
		if ($curline =~ m~<yabb news>~ && $enable_news && $newsloaded == 0) {
			srand;
			if ($shownewsfader == 1) {
				$fadedelay = ($maxsteps * $stepdelay);
				$yynews .= qq~
				<script language="JavaScript1.2" type="text/javascript">
					<!--
						var maxsteps = "$maxsteps";
						var stepdelay = "$stepdelay";
						var fadelinks = $fadelinks;
						var delay = "$fadedelay";
						var bcolor = "$color{'faderbg'}";
						var tcolor = "$color{'fadertext'}";
						var fcontent = new Array();
						var begintag = "";~;
				fopen(NEWS, "$vardir/news.txt");
				@newsmessages = <NEWS>;
				fclose(NEWS);
				$newsloaded = 1;
				for (my $j = 0; $j < @newsmessages; $j++) {
					$newsmessages[$j] =~ s/\n|\r//g;
					if ($newsmessages[$j] eq '') { next; }
					if ($i != 0) { $yymain .= qq~\n~; }
					$message = $newsmessages[$j];
					if ($enable_ubbc) {
						if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; }
						&DoUBBC;
					}
					$message =~ s/\"/\\\"/g;    # "
					$yynews .= qq~
						fcontent[$j] = "$message";\n~;
				}
				$yynews .= qq~
						var closetag = '';
						//window.onload = fade;
					// -->
				</script>
				<script language="JavaScript1.2" type="text/javascript" src="$faderpath"></script>
				~;
			} else {
				$message = $newsmessages[int rand(@newsmessages)];
				if ($enable_ubbc) {
					if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; }
					&DoUBBC;
				}
				$ubbcnews = $message;
				$yynews   = qq~$ubbcnews~;
			}
		}
		$yyurl      = $scripturl;
		$addsession = qq~<input type="hidden" name="formsession" value="$formsession" /></form>~;
		$curline =~ s~<yabb\s+(\w+)>~${"yy$1"}~g;
		$curline =~ s~<includefile="(\S+)">~${\(IncludeFile($1))}~g;
		$curline =~ s~(a href\=\S+?action\=viewprofile\;username\=.+?)(\>)~$1 rel=\"nofollow\"$2~isg;
		$curline =~ s~img src\=\"$imagesdir\/(.+?)\"~&ImgLoc($1)~eisg;
		$curline =~ s~(img src\=\"$imagesdir\/.+?)title\=\"(.*?)\"(.*? \/\>)~$1$3~ig;
		$curline =~ s~alt\=\"(.*?)\"~alt\=\"$1\" title\=\"$1\"~ig;
		$curline =~ s~</form>~$addsession~g;
		$output .= $curline;
	}
	if ($yycopyin == 0) {
		$output = q~<center><h1><b>Sorry, the copyright tag <yabb copyright> must be in the template.<br />Please notify this forum's administrator that this site is using an ILLEGAL copy of YaBB!</b></h1></center>~;
	}

	# do output
	if ($gzcomp && $gzaccept) {
		if ($gzcomp == 1) {
			$| = 1;
			open(GZIP, "| gzip -f");
			print GZIP $output;
			close(GZIP);
		} else {
			require Compress::Zlib;
			binmode STDOUT;
			print Compress::Zlib::memGzip($output);
		}
	} else {
		print $output;
	}
}

# One should never criticize his own work except in a fresh and hopeful mood.
# The self-criticism of a tired mind is suicide.
# - Charles Horton Cooley

sub IncludeFile {
	my $fname = shift;
	my $file;
	$fname =~ s/([\&;\`'\|\"*\?\~\^\(\)\[\]\{\}\$\n\r])//g;
	fopen(INCLUDE, $fname) || return '[an error occured while processing this directive]';
	my @file = <INCLUDE>;
	fclose(INCLUDE);
	$file = join('', @file);
	return $file;
}

sub fatal_error_logging {
	my $tmperror = $_[0];
	$tmperror =~ s/\n//ig;
	fopen(ERRORLOG, "+<$vardir/errorlog.txt");
	seek ERRORLOG, 0, 0;
	my @errorlog = <ERRORLOG>;
	truncate ERRORLOG, 0;
	seek ERRORLOG, 0, 0;
	chomp @errorlog;
	$errorcount = $#errorlog + 1;

	if ($elrotate) {
		while ($errorcount >= $elmax) {
			my $void = shift @errorlog;
			$errorcount = $#errorlog + 1;
		}
	}
	if ($iamguest) {
		push @errorlog, time() . "\|$date\|$user_ip\|$tmperror\|$action\|$INFO{'num'}\|$currentboard\|$FORM{'username'}\|$FORM{'passwrd'}";
	} else {
		push @errorlog, time() . "\|$date\|$user_ip\|$tmperror\|$action\|$INFO{'num'}\|$currentboard\|$username\|$FORM{'passwrd'}";
	}
	foreach (@errorlog) {
		chomp;
		if ($_ ne "") {
			print ERRORLOG $_ . "\n";
		}
	}
	fclose(ERRORLOG);

	undef($tmperror);
}

# The error message is the Truth.  The error message is God.
# - File Of Good Advice.

sub fatal_error {
	my $e = $_[0];
	my $v = $_[1];    # Verbose puts . $! with the error message
	$e .= "\n";
	if ($v) { $e .= $! . "\n"; }

	if ($elenable) {
		&fatal_error_logging($e);
	}
	&LoadIMs;
	$yymain .= qq~
<table border="0" width="80%" cellspacing="1" class="bordercolor" align="center" cellpadding="4">
  <tr>
    <td class="titlebg"><span class="text1"><b>$maintxt{'106'}</b></span></td>
  </tr><tr>
    <td class="windowbg"><br /><span class="text1">$e</span><br /><br /></td>
  </tr>
</table>
<center><br /><a href="javascript:history.go(-1)">$maintxt{'193'}</a></center>
~;
	$yytitle = "$maintxt{'106'}";
	&template;
	exit;

}

sub admin_fatal_error {
	my $e = $_[0];
	my $v = $_[1];    #verbose puts . $! with the error message
	$e .= "\n";
	if ($v) { $e .= $! . "\n"; }

	if ($elenable) {
		&fatal_error_logging($e);
	}
	$yymain .= qq~
<table border="0" width="80%" cellspacing="1" class="bordercolor" align="center" cellpadding="4">
  <tr>
    <td class="titlebg"><span class="text1"><b>$admin_txt{'106'}</b></span></td>
  </tr><tr>
    <td class="windowbg"><br /><span class="text1">$e</span><br /><br /></td>
  </tr>
</table>
<center><br /><a href="javascript:history.go(-1)">$admin_txt{'193'}</a></center>
~;
	$yytitle = "$maintxt{'106'}";
	&AdminTemplate;
	exit;
}

sub readform {
	my (@pairs, $pair, $name, $value);
	if ($ENV{QUERY_STRING} =~ m/action\=dereferer/) {
		$INFO{'action'} = "dereferer";
		$urlstart = index($ENV{QUERY_STRING}, "url=");
		$INFO{'url'} = substr($ENV{QUERY_STRING}, $urlstart + 4, length($ENV{QUERY_STRING}) - $urlstart + 3);
		$INFO{'url'} =~ s/\;anch\=/#/g;
		$testenv = "";
	} else {
		$testenv = $ENV{QUERY_STRING};
		$testenv =~ s/\&/\;/g;
	}

	# URL encoding for web.de http://www.blooberry.com/indexdot/html/topics/urlencoding.htm
	$testenv =~ s/\%3B/;/g;
	$testenv =~ s/\%26/&/g;

	sub split_string {
		my ($string, $hash, $altdelim) = @_;

		if ($altdelim && $$string =~ m~;~) { @pairs = split(/;/, $$string); }
		else { @pairs = split(/&/, $$string); }
		foreach $pair (@pairs) {
			($name, $value) = split(/=/, $pair);
			$name  =~ tr/+/ /;
			$name  =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
			$value =~ tr/+/ /;
			$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;

			if (exists($hash->{$name})) {
				$hash->{$name} .= ", $value";
			} else {
				$hash->{$name} = $value;
			}
		}
	}

	split_string(\$testenv, \%INFO, 1);
	if ($ENV{REQUEST_METHOD} eq 'POST') {
		if ($ENV{CONTENT_TYPE} =~ /multipart\/form-data/) {
			use Upload::CGI;
			import Upload::CGI qw(:standard);
			my $query = new CGI;
			my (@keylist) = sort($query->param());
			foreach $key (@keylist) {
				# may be dealing with multiple values; need to join with comma
				$value = join(', ', $query->param($key));
				$FORM{$key} = $value;
				$postsize += length($value);
				$postsize += length($key) + 1;
			}
			if ($query->param('file')) {
				$filename = $query->param('file');
				$tmpfile  = $query->tmpFileName($filename);
				$postsize -= length('file') + 1;
			}
		} else {
			read(STDIN, my $input, $ENV{CONTENT_LENGTH});
			split_string(\$input, \%FORM);
		}
	}
	$action = $INFO{'action'} || $FORM{'action'};

	if ($action eq 'search2') { &FromHTML($FORM{'search'}); }
	&ToHTML($INFO{'title'});
	&ToHTML($FORM{'title'});
	&ToHTML($INFO{'subject'});
	&ToHTML($FORM{'subject'});
}

# tid	      - time of last visit to thread
# tid--unread - time of last use of 'unread',
# 		can appear together with just tid!
# bid	      - time of last view of threadlist of board 
# 		(nothing to do with 'read' status)
# bid--mark   - time of last use of 'markread'
#		'markallread' is implemented also usig this

sub getlog {

	if ( $loaded{"$username.log"} or $iamguest or
	     $max_log_days_old == 0 or not -e "$memberdir/$username.log" ) {
		return 1
	}

	our %yyuserlog = ();

	my $mintime = $date - ($max_log_days_old * 86400);

	fopen ( GETLOG, "< $memberdir/$username.log" );

	foreach my $row ( <GETLOG> ) {

		chomp $row;
		my ($name, $value, $thistime) = split /\|/, $row;

		next if not $name; # FIXME: strange enough.
				   # maybe, check if exists?

		$yyuserlog{$name} = $value || $thistime;
	}

	fclose ( GETLOG );

	$loaded{"$username.log"} = 1;
}

sub modlog {

	if ( $iamguest or $max_log_days_old == 0 ) {
		return
	}

	getlog;

	my ( $entry, $dumbtime, $thistime ) = @_;
	
	$yyuserlog{$entry} = $dumbtime || $thistime || $date;
}

sub dumplog {

	if ( $iamguest or $max_log_days_old == 0 ) {
		return
	}

	modlog ( @_ ) if @_;

	return if not defined %yyuserlog;

	fopen ( DUMPLOG, "> $memberdir/$username.log" );

	foreach my $entry ( keys %yyuserlog ) {

		next if not $entry; # very strange...

		print DUMPLOG qq($entry||$yyuserlog{$entry}\n);
	}

	fclose ( DUMPLOG );
}

sub jumpto {
	my (@masterdata, $category, @data, $found, $tmp, @memgroups, @newcatdata, $boardname);
	$selecthtml = qq~
<form method="post" action="$scripturl" name="jump" style="display: inline;">
<select name="values" onchange="if(this.options[this.selectedIndex].value) window.location.href='$scripturl' + this.options[this.selectedIndex].value;">
    <option value="">$maintxt{'251'}:</option>
~;
	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }
	foreach $catid (@categoryorder) {
		$boardlist = $cat{$catid};
		(@bdlist) = split(/\,/, $boardlist);
		($catname, $catperms) = split(/\|/, $catinfo{"$catid"});

		$cataccess = &CatAccess($catperms);
		if (!$cataccess) { next; }

		$selecthtml .= qq~    <option value="">-----------------------------</option>
    <option value="?catselect=$catid">$catname</option>
    <option value="">-----------------------------</option>~;
		foreach $board (@bdlist) {
			($boardname, $boardperms, $boardview) = split(/\|/, $board{"$board"});
			&ToChars($boardname);
			my $access = &AccessCheck($board, '', $boardperms);
			if (!$iamadmin && $access ne "granted" && $boardview != 1) { next; }

			if ($board eq $currentboard) { $selecthtml .= "<option selected=\"selected\" value=\"?board=$board\">=> $boardname</option>\n"; }
			else { $selecthtml .= "<option value=\"?board=$board\">&nbsp; - $boardname</option>\n"; }
		}
	}
	$selecthtml .= qq~</select>
    <input type="button" value="$maintxt{'32'}" onclick="if (values.options[values.selectedIndex].value) window.location.href='$scripturl' + values.options[values.selectedIndex].value;" />
</form>~;
}

sub moveto {
	my ($category, $boardname);
	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }
	foreach $catid (@categoryorder) {
		$brdlist = $cat{$catid};
		if(!$brdlist) { next; }
		(@bdlist) = split(/\,/, $brdlist);
		($catname, $catperms) = split(/\|/, $catinfo{"$catid"});

		$cataccess = &CatAccess($catperms);
		if (!$cataccess) { next; }

		$boardlist .= qq~<optgroup label="$catname">~;
		foreach $board (@bdlist) {
			($boardname, $boardperms, $boardview) = split(/\|/, $board{"$board"});
			&ToChars($boardname);
			my $access = &AccessCheck($board, '', $boardperms);
			if (!$iamadmin && $access ne "granted") { next; }
			if ($board ne $currentboard) {
				$boardlist .= qq~<option value="$board">$boardname</option>\n~;
			}
		}
		$boardlist .= qq~</optgroup>~;
	}
}


sub sendmail {
	&LoadLanguage("Smtp");
	($to, $subject, $message, $from) = @_;

	# Do a FromHTML here for $to, and for $mbname
	# Just in case has special chars like & in addresses
	&FromHTML($to);
	&FromHTML($mbname);

	# Change commas to HTML entity - ToHTML doesn't catch this
	# It's only a problem when sending emails, so no change to ToHTML.
	$mbname =~ s/,/&#44;/ig;

	$smtp_charset = $yycharset;
	$fromheader = $from ? "$from" : "$mbname <$webmaster_email>";
	$toheader   = $to   ? "$to"   : "$mbname $smtp_txt{'555'} <$webmaster_email>";
	unless ($from) { $from = $webmaster_email; }
	if ($mailtype == 1) { use Socket; }
	$to              =~ s/[ \t]+/, /g;
	$webmaster_email =~ s/.*<([^\s]*?)>/$1/;
	$message         =~ s/^\./\.\./gm;
	$message         =~ s/\r\n/\n/g;
	$message         =~ s/\n/\r\n/g;
	$message         =~ s/<\/*b>//g;
	$smtp_server     =~ s/^\s+//g;
	$smtp_server     =~ s/\s+$//g;
	if (!$to) { return; }

	# Encode subject into base64 with directly specified encoding
	eval q^
		use MIME::Base64 qw(encode_base64);
		$subject = '=?' . uc ( $smtp_charset ) . '?B?' . encode_base64 ( $subject, '' ) . '?=';
	^;

	# Thanks to Graham J for your contribution to this routine
	if ($mailtype == 1) {
		require "$sourcedir/Smtp.pl";
		&use_smtp;
	}
	if ($mailtype == 2) {
		eval q^
			use Net::SMTP;
			my $smtp = Net::SMTP->new($smtp_server, Debug => 0) || die "unable to create Net::SMTP object $smtp_server.";
			$smtp->mail($from); 
			foreach (split(/, /, $to)) {
				$smtp->to($_);
			}
			$smtp->data(); 
			$smtp->datasend("To: $toheader\r\n"); 
			$smtp->datasend("From: $fromheader\r\n"); 
			$smtp->datasend("X-Mailer: YaBB Net::SMTP\r\n"); 
			$smtp->datasend("Subject: $subject\r\n");
			$smtp->datasend("Content-Type: text/plain; charset=$smtp_charset\r\n");
			$smtp->datasend("\r\n");
			$smtp->datasend($message);
			$smtp->dataend();
			$smtp->quit();
		^;
		if ($@) {
			&fatal_error("\n<br />Net::SMTP fatal error: $@\n<br />");
			return -77;
		}
		return 1;
	}
	if ($mailtype == 0) {
		$to =~ s/,//g;
		open(MAIL, "| $mailprog  $to");
		print MAIL "To: $toheader\n";
		print MAIL "From: $fromheader\n";
		print MAIL "X-Mailer: YaBB Sendmail\n";
		print MAIL "Subject: $subject\n";
		print MAIL "Content-type: text/plain; charset=$smtp_charset\n";
		$message =~ s/\r\n/\n/g;
		print MAIL "$message\n";
		close(MAIL);
		return (1);
	}
}

sub spam_protection {

	# Always look on the bright side of life
	# - Monty Python

	unless ($timeout) { return; }
	my ($time, $flood_ip, $flood_time, $flood, @floodcontrol);

	if (-e "$vardir/flood.txt") {
		fopen(FLOOD, "$vardir/flood.txt");
		push(@floodcontrol, "$user_ip|$date\n");
		while (<FLOOD>) {
			chomp($_);
			($flood_ip, $flood_time) = split(/\|/, $_);
			if ($user_ip eq $flood_ip && $date - $flood_time <= $timeout) { $flood = 1; }
			elsif ($date - $flood_time < $timeout) { push(@floodcontrol, "$_\n"); }
		}
		fclose(FLOOD);
	}
	if ($flood && !$iamadmin && $action eq 'post2') { &Preview("$maintxt{'409'} $timeout $maintxt{'410'}"); }
	if ($flood) {
		&fatal_error("$maintxt{'409'} $timeout $maintxt{'410'}");
	}
	fopen(FLOOD, ">$vardir/flood.txt", 1);
	print FLOOD @floodcontrol;
	fclose(FLOOD);
}

sub CountChars {
	our ( $convertstr, $convertcut );
	our $cliped = 0;

	$convertstr =~ m/\A(([^&\[<]|&(\w+|#\d+);|\[ch\d{3,}\]|<[^>]+>|.){0,$convertcut})(.?)/s;
	$cliped     =  1 if length $4;
	$convertstr =  $1;
	$convertstr =~ s/\s*\Z//;
}

sub WrapChars {
	$wrapstr       =~ s/(&#\d{3,}?;)/ $1/ig;
	$wrapstr       =~ s/(\S{$wrapcut})/$1 /gi;
	my $tmpwrapcut =  $wrapcut;
	my @wwords     =  split /\s/, $wrapstr;
	my $tmpwrapstr =  "";
	$wrapstr       =  "";
	foreach my $curword ( @wwords ) {

		if ($curword =~ m/&#\d{3,}?;/) {
			$tmpwrapcut += length($curword);
		}
		if ((length($tmpwrapstr) + length($curword)) > $tmpwrapcut) {
			$wrapstr .= qq($tmpwrapstr<br />);
			$tmpwrapstr = "$curword ";
			$tmpwrapcut = $wrapcut;
		} else {
			$tmpwrapstr .= "$curword ";
		}
	}
	$wrapstr .= $tmpwrapstr;
	$wrapstr =~ s/ (&#\d{3,}?;)/$1/ig;
	$wrapstr =~ s/ \Z//;
}

sub FromChars {
	$_[0] =~ s/&#(\d{3,});/ $1>127 ? "[ch$1]" : "&#$1;" /seg;
}

sub ToChars {
	$_[0] =~ s/\[ch(\d{3,})\]/ $1>127 ? "&#$1;" : '' /sieg;
}

sub ToHTML {
	$_[0] =~ s/&/&amp;/g;
	$_[0] =~ s/"/&quot;/g;
	$_[0] =~ s/  / &nbsp;/g;
	$_[0] =~ s/</&lt;/g;
	$_[0] =~ s/>/&gt;/g;
	$_[0] =~ s/\|/\&#124;/g;
}

sub FromHTML {
	$_[0] =~ s/&quot;/"/g;
	$_[0] =~ s/&nbsp;/ /g;
	$_[0] =~ s/&lt;/</g;
	$_[0] =~ s/&gt;/>/g;
	$_[0] =~ s/&#124;/\|/g;
	$_[0] =~ s/&amp;/&/g;
}

sub dopre {
	local $_ = $_[0];
	s~<br \/>~\n~ig;
	s~<br>~\n~ig;
	return $_;
}

sub elimnests {
	local $_ = $_[0];
	s~\[/*shadow([^\]]*)\]~~ig;
	s~\[/*glow([^\]]*)\]~~ig;
	return $_;
}

sub unwrap {
	$unwrapped = $_[0];
	$unwrapped =~ s~<yabbwrap>~~g;
	$unwrapped = qq~\[code\]$unwrapped\[\/code\]~;
	return $unwrapped;
}

sub wrap {
#	$message =~ s~ &nbsp; &nbsp; &nbsp;~[tab]~ig;
	$message =~ s~<br \/>~\n~ig;
	$message =~ s~<br>~\n~ig;
#	$message =~ s/((\[ch\d{3,}?\]|&\S+?;|\S){$linewrap})/$1\n/ig;

	&FromHTML($message);
	$message =~ s~[\n\r]~ <yabbbr> ~g;
	my @words = split /\s/, $message;
	$message = "";
	foreach my $cur ( @words ) {
		if ($cur !~ m~www\.(.+?)\.~ && $cur !~ m~(ht|f)tp://~ && $cur !~ m~\[.+?\]~) {
			$cur =~ s~(.{$linewrap})~$1<yabbwrap>~g;
		} elsif ($cur !~ m~\[table\](.*?)\[\/table\]~ && $cur !~ m~\[url(.*?)\](.*?)\[\/url\]~ && $cur !~ m~\[flash(.*?)\](.*?)\[\/flash\]~ && $cur !~ m~\[img(.*?)\](.*?)\[\/img\]~) {
			$cur =~ s~(\[.*?\])~ $1 ~g;
			@splitword = split /\s/, $cur;
			$cur = "";
			foreach $splitcur (@splitword) {
				if ($splitcur !~ m~www\.(.+?)\.~ && $splitcur !~ m~(ht|f)tp://~ && $splitcur !~ m~\[.+?\]~) {
					$splitcur =~ s~(.{$linewrap})~$1<yabbwrap>~g;
				}
				$cur .= $splitcur;
			}
		}
		$message .= "$cur ";
	}
	$message =~ s~\[code\](.*?)\[\/code\]~&unwrap($1)~eisg;
	$message =~ s/ <yabbbr> /\n/g;
	$message =~ s/<yabbwrap>/\n/g;

	&ToHTML($message);
#	$message =~ s~\[tab\]~ &nbsp; &nbsp; &nbsp;~ig;
	$message =~ s^\n^<br />^g;
}

sub wrap2 {
	$message =~ s#<a href=(\S*?)(\s[^>]*)?>(\S{$linewrap,}?)</a># my $mess=$3; { $mess =~ s/\A((&.+?;|<.+?>|\[ch\d{3,}\]|.){$linewrap}).*\Z/$1.../s; } "<a href=$1$2>$mess</a>" #sieg;
}

sub BoardCountTotals {
	my $cntboard = $_[0];
	unless ($cntboard) { return undef; }
	my (@threads, $threadcount, $messagecount);

	fopen(BOARD, "$boardsdir/$cntboard.txt");
	@threads = <BOARD>;
	fclose(BOARD);
	$threadcount  = @threads;
	$messagecount = $threadcount;
	foreach my $row ( @threads ) {
		$messagecount += ( split /\|/, $row )[5];
	}
	&BoardTotals("load", $cntboard);
	${$uid.$cntboard}{'threadcount'}  = $threadcount;
	${$uid.$cntboard}{'messagecount'} = $messagecount;
	&BoardTotals("update", $cntboard);
	&BoardSetLastInfo($cntboard);
}

sub BoardSetLastInfo {
	my $setboard = $_[0];
	unless ($setboard) { return undef; }
	my ($lastthread, $lastthreadid, @lastthreadmessages, @lastmessage, $lastmessage);

	fopen(BOARD, "$boardsdir/$setboard.txt");
	$lastthread = <BOARD>;
	fclose(BOARD);
	chomp $lastthread;
	if ($lastthread) {
		($lastthreadid, $dummy) = split(/\|/, $lastthread);
		fopen(FILE, "$datadir/$lastthreadid.txt") || &fatal_error("$maintxt{'23'} $lastthreadid.txt", 1);
		@lastthreadmessages = <FILE>;
		fclose(FILE);
		@lastmessage = split(/\|/, $lastthreadmessages[$#lastthreadmessages]);
		&MessageTotals("load", $lastthreadid);
	}
	&BoardTotals("load", $setboard);
	${$uid.$setboard}{'lastposttime'} = $lastthread ? $lastmessage[3]                : 'N/A';
	${$uid.$setboard}{'lastposter'}   = $lastthread ? ${$lastthreadid}{'lastposter'} : 'N/A';
	${$uid.$setboard}{'lastpostid'}   = $lastthread ? $lastthreadid                  : '';
	${$uid.$setboard}{'lastreply'}    = $lastthread ? ${$lastthreadid}{'replies'}    : '';
	${$uid.$setboard}{'lastsubject'}  = $lastthread ? $lastmessage[0]                : '';
	${$uid.$setboard}{'lasticon'}     = $lastthread ? $lastmessage[5]                : '';
	&BoardTotals("update", $setboard);
}

sub RemoveThreadFiles {
	my $removethread = $_[0];
	if ($removethread) {
		unlink("$datadir/$removethread.txt");
		unlink("$datadir/$removethread.ctb");
		unlink("$datadir/$removethread.mail");
		unlink("$datadir/$removethread.poll");
		unlink("$datadir/$removethread.polled");
	}
}

sub MembershipGet {
	if (fopen(FILEMEMGET, "$memberdir/members.ttl")) {
		$_ = <FILEMEMGET>;
		chomp;
		fclose(FILEMEMGET);
		return split(/\|/, $_);
	} else {
		my @ttlatest = &MembershipCountTotal;
		return @ttlatest;
	}
}

use Fcntl qw/:DEFAULT/;
unless (defined $LOCK_SH) { $LOCK_SH = 1; }

{
	my %yyOpenMode = (
		'+>>' => 5,
		'+>'  => 4,
		'+<'  => 3,
		'>>'  => 2,
		'>'   => 1,
		'<'   => 0,
		''    => 0);

	# fopen: opens a file. Allows for file locking and better error-handling.
	sub fopen ($$;$) {
		$file_open++;
		my ($filehandle, $filename, $usetmp) = @_;
		if ($debug) { $openfiles .= qq~$filehandle -> $filename<br />~; }
		my ($flockCorrected, $cmdResult, $openMode, $openSig);

		$serveros = "$^O";
		if ($serveros =~ m/Win/ && substr($filename, 1, 1) eq ":") {
			$filename =~ s~\\~\\\\~g;    # Translate windows-style \ slashes to windows-style \\ escaped slashes.
			$filename =~ s~/~\\\\~g;     # Translate unix-style / slashes to windows-style \\ escaped slashes.
		} else {
			$filename =~ tr~\\~/~;       # Translate windows-style \ slashes to unix-style / slashes.
		}
		$LOCK_EX     = 2;                # You can probably keep this as it is set now.
		$LOCK_UN     = 8;                # You can probably keep this as it is set now.
		$LOCK_SH     = 1;                # You can probably keep this as it is set now.
		$usetempfile = 0;                # Write to a temporary file when updating large files.

		# Check whether we want write, append, or read.
		$filename =~ m~\A([<>+]*)(.+)~;
		$openSig  = $1                    || '';
		$filename = $2                    || $filename;
		$openMode = $yyOpenMode{$openSig} || 0;

		$filename =~ s~[^/\\0-9A-Za-z#%+\,\-\ \.\:@^_]~~g;    # Remove all inappropriate characters.

		if ($filename =~ m~/\.\./~) { &fatal_error("$maintxt{'23'} $filename. $maintxt{'609'}"); }

		# If the file doesn't exist, but a backup does, rename the backup to the filename
		if (!-e $filename && -e "$filename.bak") { rename("$filename.bak", "$filename"); }
		$testfile = $filename;
		if ($use_flock == 2 && $openMode) {
			my $count;
			while ($count < 15) {
				if (-e $filehandle) { sleep 2; }
				else { last; }
				++$count;
			}
			unlink($filehandle) if ($count == 15);
			local *LFH;
			CORE::open(LFH, ">$filehandle");
			$yyLckFile{$filehandle} = *LFH;
		}

		if ($use_flock && $openMode == 1 && $usetmp && $usetempfile && -e $filename) {
			$yyTmpFile{$filehandle} = $filename;
			$filename .= '.tmp';
		}

		if ($openMode > 2) {
			if ($openMode == 5) { $cmdResult = CORE::open($filehandle, "+>>$filename"); }
			elsif ($use_flock == 1) {
				if ($openMode == 4) {
					if (-e $filename) {

						# We are opening for output and file locking is enabled...
						# read-open() the file rather than write-open()ing it.
						# This is to prevent open() from clobbering the file before
						# checking if it is locked.
						$flockCorrected = 1;
						$cmdResult = CORE::open($filehandle, "+<$filename");
					} else {
						$cmdResult = CORE::open($filehandle, "+>$filename");
					}
				} else {
					$cmdResult = CORE::open($filehandle, "+<$filename");
				}
			} elsif ($openMode == 4) {
				$cmdResult = CORE::open($filehandle, "+>$filename");
			} else {
				$cmdResult = CORE::open($filehandle, "+<$filename");
			}
		} elsif ($openMode == 1 && $use_flock == 1) {
			if (-e $filename) {

				# We are opening for output and file locking is enabled...
				# read-open() the file rather than write-open()ing it.
				# This is to prevent open() from clobbering the file before
				# checking if it is locked.
				$flockCorrected = 1;
				$cmdResult = CORE::open($filehandle, "+<$filename");
			} else {
				$cmdResult = CORE::open($filehandle, ">$filename");
			}
		} elsif ($openMode == 1) {
			$cmdResult = CORE::open($filehandle, ">$filename");    # Open the file for writing
		} elsif ($openMode == 2) {
			$cmdResult = CORE::open($filehandle, ">>$filename");    # Open the file for append
		} elsif ($openMode == 0) {
			$cmdResult = CORE::open($filehandle, $filename);        # Open the file for input
		}
		unless ($cmdResult)      { return 0; }
		if     ($flockCorrected) {

			# The file was read-open()ed earlier, and we have now verified an exclusive lock.
			# We shall now clobber it.
			flock($filehandle, $LOCK_EX);
			if ($faketruncation) {
				CORE::open(OFH, ">$filename");
				unless ($cmdResult) { return 0; }
				print OFH '';
				CORE::close(OFH);
			} else {
				truncate(*$filehandle, 0) || &fatal_error("$maintxt{'631'}: $filename");
			}
			seek($filehandle, 0, 0);
		} elsif ($use_flock == 1) {
			if ($openMode) { flock($filehandle, $LOCK_EX); }
			else { flock($filehandle, $LOCK_SH); }
		}
		return 1;
	}

	# fclose: closes a file, using Windows 95/98/ME-style file locking if necessary.
	sub fclose ($) {
		$file_close++;
		my $filehandle = $_[0];
		CORE::close($filehandle);
		if ($use_flock == 2) {
			if (exists $yyLckFile{$filehandle} && -e $filehandle) {
				CORE::close($yyLckFile{$filehandle});
				unlink($filehandle);
				delete $yyLckFile{$filehandle};
			}
		}
		if ($yyTmpFile{$filehandle}) {
			my $bakfile = $yyTmpFile{$filehandle};
			if ($use_flock == 1) {

				# Obtain an exclusive lock on the file.
				# ie: wait for other processes to finish...
				local *FH;
				CORE::open(FH, $bakfile);
				flock(FH, $LOCK_EX);
				CORE::close(FH);
			}

			# Switch the temporary file with the original.
			unlink("$bakfile.bak") if (-e "$bakfile.bak");
			rename($bakfile, "$bakfile.bak");
			rename("$bakfile.tmp", $bakfile);
			delete $yyTmpFile{$filehandle};
			if (-e $bakfile) {
				unlink("$bakfile.bak");    # Delete the original file to save space.
			}
		}
		return 1;
	}

}    #/ my %yyOpenMode

sub KickGuest {
	require "$sourcedir/LogInOut.pl";
	$sharedLogin_title = "$maintxt{'633'}";
	$sharedLogin_text  = qq~<br />$maintxt{'634'}<br />$maintxt{'635'} <a href="$scripturl?action=register">$maintxt{'636'}</a> $maintxt{'637'}<br /><br />~;
	$yymain .= qq~<div class="bordercolor" style="width: 400px; margin-bottom: 8px; margin-left: auto; margin-right: auto;">~;
	$yymain .= &sharedLogin;
	$yymain .= qq~</div>~;
	$yytitle = "$maintxt{'34'}";
	&template;
	exit;
}

sub WriteLog {
	my ($curentry, $name);
	my $field = $username;
	if ($field eq "Guest") { $field = "$user_ip"; }

	fopen(LOG, "+<$vardir/log.txt");
	seek LOG, 0, 0;
	my @online = <LOG>;
	truncate LOG, 0;
	seek LOG, 0, 0;
	print LOG "$field|$date|$user_ip\n";
	foreach $curentry (@online) {
		$curentry =~ s/\n//g;
		($name, $date1, $orig_ip) = split(/\|/, $curentry);

		# Case insensitive name-checking, so that you can't be listed twice online
		if (lc($field) eq lc($name)) { next; }
		$date2 = $date;
		chomp $date1;
		chomp $date2;
		&calctime;
		if ($name ne $field && $user_ip ne $name && $result <= ($OnlineLogTime * 60) && $result >= 0) {
			print LOG "$curentry\n";
		}

		# This check needs to be present to prevent thrashing of the user.vars file
		if ($result > ($OnlineLogTime * 60)) {
			if (!${$uid.$name}{'password'}) { &LoadUser($name); }
			&UserAccount($name, "update", "lastonline");
		}
	}
	fclose(LOG);

	if ($action eq '' && $enableclicklog == 1) {
		fopen(LOG, "+<$vardir/clicklog.txt", 1);
		my @entries = <LOG>;
		seek LOG, 0, 0;
		truncate LOG, 0;
		if ($ENV{'HTTP_REFERER'} =~ m~$boardurl~i) { $thereferer = ""; }
		else { $thereferer = $ENV{'HTTP_REFERER'}; }
		print LOG "$field|$date|$ENV{'REQUEST_URI'}|$thereferer|$ENV{'HTTP_USER_AGENT'}\n";
		foreach $curentry (@entries) {
			$curentry =~ s/\n//g;
			chomp $curentry;
			($name, $date1, $dummy, $dummy, $dummy) = split(/\|/, $curentry);
			$date2 = $date;
			chomp $date1;
			chomp $date2;
			&calctime;
			$ClickAge = int($result / 60);
			if ($ClickAge <= $ClickLogTime && $ClickAge >= 0) { print LOG "$curentry\n"; }
		}
		fclose(LOG);
	}
}

sub encode_session {
	my ($input, $seed) = @_;
	my ($output, $ascii, $key, $hex, $hexkey, $x);
	$key = substr($seed, length($seed) - 2, 2);
	$hexkey = uc(unpack("H2", pack("I", $key)));
	$x = 0;
	for ($n = 0; $n < length $input; $n++) {
		$ascii = substr($input, $n, 1);
		$ascii = ord($ascii) + $key - $n;
		$hex   = uc(unpack("H2", pack("I", $ascii)));
		$output .= $hex;
		$x++;
		if ($x > 32) { $x = 0; }
	}
	$output .= $hexkey;
	return $output;
}

sub encode_password {
	my $eol = "";
	$eol = $_[0];
	chomp $eol;
	if (eval "require Digest::MD5") {
		use Digest::MD5 qw(md5_base64);
	}

	my $mypass = md5_base64 $eol;
	return $mypass;
}

sub encode_smtp64 {
    if ($] >= 5.006) {
	require bytes;
	if (bytes::length($_[0]) > length($_[0]) ||
	    ($] >= 5.008 && $_[0] =~ /[^\0-\xFF]/))
	{
	    require Carp;
	    Carp::croak("The Base64 encoding is only defined for bytes");
	}
    }
    use integer;
    my $eol = $_[1];
    $eol = "\n" unless defined $eol;

    my $res = pack("u", $_[0]);
    # Remove first character of each line, remove newlines
    $res =~ s/^.//mg;
    $res =~ s/\n//g;
    $res =~ tr|` -_|AA-Za-z0-9+/|;               # `# help emacs
    # fix padding at the end
    my $padding = (3 - length($_[0]) % 3) % 3;
    $res =~ s/.{$padding}$/'=' x $padding/e if $padding;
    # break encoded string into lines of no more than 76 characters each
    if (length $eol) {
	$res =~ s/(.{1,76})/$1$eol/g;
    }
    chomp $res;
    return $res;
}

sub decode_smtp64 ($)
{
    local($^W) = 0; # unpack("u",...) gives bogus warning in 5.00[123]
    use integer;

    my $str = shift;
    $str =~ tr|A-Za-z0-9+=/||cd;            # remove non-base64 chars
    if (length($str) % 4) {
	require Carp;
	Carp::carp("Length of base64 data not a multiple of 4")
    }
    $str =~ s/=+$//;                        # remove padding
    $str =~ tr|A-Za-z0-9+/| -_|;            # convert to uuencoded format
    return "" unless length $str;

    ## I guess this could be written as
    #return unpack("u", join('', map( chr(32 + length($_)*3/4) . $_,
    #			$str =~ /(.{1,60})/gs) ) );
    ## but I do not like that...
    my $uustr = '';
    my ($i, $l);
    $l = length($str) - 60;
    for ($i = 0; $i <= $l; $i += 60) {
	$uustr .= "M" . substr($str, $i, 60);
    }
    $str = substr($str, $i);
    # and any leftover chars
    if ($str ne "") {
	$uustr .= chr(32 + length($str)*3/4) . $str;
    }
    return unpack ("u", $uustr);
}

sub Censor {
	my $string = $_[0];
	foreach $censor (@censored) {
		my ($tmpa, $tmpb, $tmpc) = @{$censor};
		if ($tmpc) {
			$string =~ s~(^|\W|_)\Q$tmpa\E(?=$|\W|_)~$1$tmpb~gi;
		} else {
			$string =~ s~\Q$tmpa\E~$tmpb~gi;
		}
	}
	return $string;
}

sub CheckCensor {
	my $string = $_[0];
	foreach $censor (@censored) {
		my ($tmpa, $tmpb, $tmpc) = @{$censor};
		if ($string =~ m/(\Q$tmpa\E)/i) {
			$found_word .= "$1 ";
		}
	}
	return $found_word;
}

sub YaBBsort {
	my $field = (shift || 0) + 1;    # 0-based field
	my $type = shift || 0;           # 0=numeric; 1=text
	my $case = shift || 0;           # 0=case sensitive; 1=ignore case
	my $dir  = shift || 0;           # 0=increasing; 1=decreasing

	if ($type == 0) {
		if ($dir == 0) {
			$a->[$field] <=> $b->[$field];
		} else {
			$b->[$field] <=> $a->[$field];
		}
	} else {
		if ($case == 0) {
			if ($dir == 0) {
				$a->[$field] cmp $b->[$field];
			} else {
				$b->[$field] cmp $a->[$field];
			}
		} else {
			if ($dir == 0) {
				uc $a->[$field] cmp uc $b->[$field];
			} else {
				uc $b->[$field] cmp uc $a->[$field];
			}
		}
	}
}

sub referer_check {
	$referencedomain = substr($boardurl, 7, (index($boardurl, "/", 7)) - 7);
	$refererdomain = substr($ENV{HTTP_REFERER}, 7, (index($ENV{HTTP_REFERER}, "/", 7)) - 7);
	if ($refererdomain !~ /$referencedomain/ && $ENV{QUERY_STRING} ne "" && length($refererdomain) > 0) {
		$goodaction = 0;
		fopen(ALLOWED, "$vardir/allowed.txt");
		@allowed = <ALLOWED>;
		fclose(ALLOWED);
		foreach $allow (@allowed) {
			chomp $allow;
			if ($action ne "" && $action eq $allow) { $goodaction = 1; last; }
		}
		if ($goodaction == 0 && $action ne "") { &fatal_error("$reftxt{'5'} $action<br />$reftxt{'7'} $referencedomain<br />$reftxt{'6'} $refererdomain"); }
	}
}

sub Dereferer {
	print "Content-Type: text/html\n\n";
	$refresh = qq~<html>\n<head>\n</head>\n<body Onload = document.location="$INFO{'url'}" target="_top">\n<font face="Arial" size="2">$dereftxt{'1'}</font>\n</body></html>\n~;
	print $refresh;
	exit;
}

sub MailTo {
	if ($iamguest) { &fatal_error("$ml_txt{'223'}"); }
	my $mailusername = $INFO{'user'};
	my $mailcrypted  = $INFO{'mail_id'};
	&LoadUser($mailusername);    # If user is not in memory, s/he must be loaded.
	if (${$uid.$mailusername}{'email'} && (${$uid.$mailusername}{'hidemail'} ne "checked" || $iamadmin) && $mailusername ne "Guest") {
		$truemail = ${$uid.$mailusername}{'email'};
	} elsif ($mailusername eq "Guest") {
		$truemail = &descramble($mailcrypted, $mailusername);
	} else {
		fatal_error("$ml_txt{'801'}");
	}
	print "Content-Type: text/html\n\n";
	$refresh = qq~<html>\n<head>\n
	<script>
		var tik=0
		function timer() {
		  	window.setTimeout("timer()", 2000)
			tik=tik+1
			if(tik==2){
				window.close()
			}
		}
	</script>
	</head>\n
	<body Onload = document.location="mailto:$truemail">\n
	<font face="Arial" size="2">$dereftxt{'3'}</font>\n
	<script language="JavaScript1.2" type="text/javascript">\n
	timer();
	</script>
	</body></html>\n~;
	print $refresh;
}

sub LoadLanguage {
	my $what_to_load = $_[0];
	my $use_lang     = $language ? $language : $lang;

#### FIXME: Avoiding vulnerability
	if ($use_lang !~ m^\A[0-9a-zA-Z_\#\%\-\:\+\?\$\&\~\,\@]+\Z^) {
		$use_lang = 'English';
	}
	if (-e "$langdir/$use_lang/$what_to_load.lng") {
		require "$langdir/$use_lang/$what_to_load.lng";
	} elsif (-e "$langdir/$lang/$what_to_load.lng") {
		require "$langdir/$lang/$what_to_load.lng";
	} elsif (-e "$langdir/English/$what_to_load.lng") {
		require "$langdir/English/$what_to_load.lng";
	} else {
		&fatal_error("$use_lang/$what_to_load.lng - $maintxt{'775'}");
	}
}

sub Recent_Load {
	my $who_to_load = $_[0];
	if (-e "$memberdir/$who_to_load.wlog") {
		require "$memberdir/$who_to_load.wlog";
		&Recent_Save($who_to_load);
		unlink "$memberdir/$who_to_load.wlog";
	}
	if (-e "$memberdir/$who_to_load.rlog") {
		fopen(RLOG, "$memberdir/$who_to_load.rlog");
		%recent = map /(.*)\t(.*)/, <RLOG>;
		fclose(RLOG);
	}
}

sub Recent_Write {
	my ($todo, $recentthread, $recentuser) = @_;
	&Recent_Load($recentuser);
	if($todo eq "incr") {
		unless (exists($recent{$recentthread})) { $recent{$recentthread} = 0; }
		$recent{$recentthread}++;
	}
	if($todo eq "decr") {
		$recent{$recentthread}--;
		if ($recent{$recentthread} < 1) { delete $recent{$recentthread}; }
	}
	&Recent_Save($recentuser);
}

sub Recent_Save {
	my $who_to_save = $_[0];
	fopen(RLOG, ">$memberdir/$who_to_save.rlog");
	print RLOG map "$_\t$recent{$_}\n", keys %recent;
	fclose(RLOG);
	undef %recent;
	if (!-s "$memberdir/$who_to_save.rlog") { unlink("$memberdir/$who_to_save.rlog"); }
}

sub Write_ForumMaster {
	fopen(FORUMMASTER, ">$boardsdir/forum.master", 1);
	print FORUMMASTER qq~\$mloaded = 1;\n~;
	@catorder = &undupe(@categoryorder);
	print FORUMMASTER qq~\@categoryorder = qw(@catorder);\n~;
	while (($key, $value) = each(%cat)) {

		# Escape membergroups with a $ in them
		$value =~ s~\$~\\\$~g;
		# Strip membergroups with a ~ from them
		$value =~ s/\~//g;
		print FORUMMASTER qq~\$cat{'$key'} = qq\~$value\~;\n~;
	}
	while (($key, $value) = each(%catinfo)) {

		# Escape membergroups with a $ in them
		$value =~ s~\$~\\\$~g;
		# Strip membergroups with a ~ from them
		$value =~ s/\~//g;
		print FORUMMASTER qq~\$catinfo{'$key'} = qq\~$value\~;\n~;
	}
	while (($key, $value) = each(%board)) {

		# Escape membergroups with a $ in them
		$value =~ s~\$~\\\$~g;
		# Strip membergroups with a ~ from them
		$value =~ s/\~//g;
		print FORUMMASTER qq~\$board{'$key'} = qq\~$value\~;\n~;
	}
	print FORUMMASTER qq~\n1;~;
	fclose(FORUMMASTER);
}

sub memparse {
	foreach $line (@_) {
		$line =~ s~(.*?)\t(.*?)~$1~isg;
	}
	return @_;
}

sub scramble {
	my ($input, $user) = @_;

	# creating a codekey based on userid
	$carrier = "";
	for ($n = 0; $n < length $user; $n++) {
		$ascii = substr($user, $n, 1);
		$ascii = ord($ascii);
		$carrier .= $ascii;
	}
	while (length($carrier) < length($input)) { $carrier .= $carrier; }
	$carrier = substr($carrier, 0, length($input));
	my $scramble = &encode_password($user);
	for ($n = 0; $n < 9; $n++) {
		$scramble .= &encode_password($scramble);
	}
	$scramble =~ s/\//y/g;
	$scramble =~ s/\+/x/g;
	$scramble =~ s/\-/Z/g;
	$scramble =~ s/\:/Q/g;

	# making a mess of the input
	$lastvalue = 3;
	for ($n = 0; $n < length $input; $n++) {
		$letter = substr($input, $n, 1);
		$value = (substr($carrier, $n, 1)) + $lastvalue + 1;
		$lastvalue = $value;
		substr($scramble, $value, 1) = $letter;
	}

	# adding code length to code
	my $len = length($input) + 65;
	$scramble .= chr($len);
	return $scramble;
}

sub descramble {
	my ($input, $user) = @_;

	# creating a codekey based on userid
	$carrier = "";
	for ($n = 0; $n < length($user); $n++) {
		$ascii = substr($user, $n, 1);
		$ascii = ord($ascii);
		$carrier .= $ascii;
	}
	my $orgcode   = substr($input, length($input) - 1, 1);
	my $orglength = ord($orgcode);

	while (length($carrier) < $orglength - 65) { $carrier .= $carrier; }
	$carrier = substr($carrier, 0, length($input));

	$lastvalue  = 3;
	$descramble = "";

	# getting code length from encrypted input
	for ($n = 0; $n < $orglength - 65; $n++) {
		$value = (substr($carrier, $n, 1)) + $lastvalue + 1;
		$letter = substr($input, $value, 1);
		$lastvalue = $value;
		$descramble .= qq~$letter~;
	}
	return $descramble;
}

sub dirstats {
	use File::Find;
	my ($size, $used_space, $free_space) = 0;
	&find(sub { $dirsize += -s }, $uploaddir);
	$used_space  = int($dirsize / 1024);
	$spaceleft   = ($mydirlimit - $dirsize);
	$kbspaceleft = ($dirlimit - $used_space);
}

sub clear_temp {
	if ($filename) {
		close($filename);
	}
	if (-e $tmpfile && $tmpfile ne '') {
		close($tmpfile);
		unlink $tmpfile || &fatal_error("Error deleting tempfile '$tmpfile': $!\n");
	}
}

sub write_error {
	my $e = $_[0];
	&clear_temp;
	&LoadIMs;    # Load IM's
	$yymain .= qq~
<table border="0" width="80%" cellspacing="1" bgcolor="$color{'bordercolor'}" class="bordercolor" align="center" cellpadding="4">
  <tr>
    <td class="titlebg" bgcolor="$color{'titlebg'}"><font size="2" class="text1" color="$color{'titletext'}"><b>$maintxt{'106'}</b></font></td>
  </tr><tr>
    <td class="windowbg" bgcolor="$color{'windowbg'}"><br /><font size="2">$e</font><br /><br /></td>
  </tr>
</table>
<center><br /><a href="javascript:history.go(-1)">$txt{'250'}</a></center>
~;
	$yytitle = "$txt{'106'}";
	&template;
	exit;

}

sub MemberPageindex {
	my ($msindx, $trindx, $mbindx);
	($msindx, $trindx, $mbindx) = split(/\|/, ${$uid.$username}{'pageindex'});
	if ($INFO{'action'} eq "memberpagedrop") {
		${$uid.$username}{'pageindex'} = "$msindx|$trindx|0";
	}
	if ($INFO{'action'} eq "memberpagetext") {
		${$uid.$username}{'pageindex'} = "$msindx|$trindx|1";
	}
	&UserAccount($username, "update");
	$yySetLocation = qq($scripturl?action=ml;sort=$INFO{'sort'};letter=$INFO{'letter'};start=$INFO{'start'});
	&redirectexit;
}

sub check_existence {

	my ( $dir, $filename ) = @_;

	my $numdelim = "_";

	my $origname =  $filename;
	$origname    =~ s/(\S+?)(\.\S+$)/$1/i;
	my $filext   =  $2;
	my $filenumb =  0;

	while ( -e "$dir/$filename" ) {
		$filename = $origname . $numdelim .
			    sprintf( "%03d", ++$filenumb ) . $filext;
	}

	return $filename
}

sub ManageMemberlist {
	my $todo    = $_[0];
	my $user    = $_[1];
	my $userreg = $_[2];
	if ($todo eq "load" || $todo eq "update" || $todo eq "delete" || $todo eq "add") {
		fopen(MEMBLIST, "$memberdir/memberlist.txt");
		%memberlist = map /(.*)\t(.*)/, <MEMBLIST>;
		fclose(MEMBLIST);
	}
	if ($todo eq "add") {
		$memberlist{$user} = "$userreg";
	}
	if ($todo eq "update") {
		$memregtime = $memberlist{$user};
		if ($userreg) { $memregtime = qq~$userreg~; }
		$memberlist{$user} = "$memregtime";
	}
	if ($todo eq "delete") {
		delete($memberlist{$user});
	}
	if ($todo eq "save" || $todo eq "update" || $todo eq "delete" || $todo eq "add") {
		fopen(MEMBLIST, ">$memberdir/memberlist.txt");
		print MEMBLIST map "$_\t$memberlist{$_}\n", sort { lc $memberlist{$a} cmp lc $memberlist{$b} } keys %memberlist;
		fclose(MEMBLIST);
		undef %memberlist;
	}
}

sub ManageMemberinfo {
	my $todo       = $_[0];
	my $user       = $_[1];
	my $userdisp   = $_[2];
	my $usermail   = $_[3];
	my $usergrp    = $_[4];
	my $usercnt    = $_[5];
	my $useraddgrp = $_[6];
	if ($todo eq "load" || $todo eq "update" || $todo eq "delete" || $todo eq "add") {
		fopen(MEMBINFO, "$memberdir/memberinfo.txt");
		%memberinf = map /(.*)\t(.*)/, <MEMBINFO>;
		fclose(MEMBINFO);
	}
	if ($todo eq "add") {
		$memberinf{$user} = "$userdisp|$usermail|$usergrp|$usercnt|$useraddgrp";
	}
	if ($todo eq "update") {
		($memrealname, $mememail, $memposition, $memposts, $memaddgrp) = split(/\|/, $memberinf{$user});
		if ($userdisp)   { $memrealname = qq~$userdisp~; }
		if ($usermail)   { $mememail    = qq~$usermail~; }
		if ($usergrp)    { $memposition = qq~$usergrp~; }
		if ($usercnt)    { $memposts    = $usercnt; }
		if ($useraddgrp) { $memaddgrp   = $useraddgrp; }
		$memberinf{$user} = "$memrealname|$mememail|$memposition|$memposts|$memaddgrp";
	}
	if ($todo eq "delete") {
		delete($memberinf{$user});
	}
	if ($todo eq "save" || $todo eq "update" || $todo eq "delete" || $todo eq "add") {
		fopen(MEMBINFO, ">$memberdir/memberinfo.txt");
		print MEMBINFO map "$_\t$memberinf{$_}\n", keys %memberinf;
		fclose(MEMBINFO);
		undef %memberinf;
	}
}

# loads online users info from log.txt
# TODO: Fix other places to use this, add log saving routine?
sub load_online_users {
	if ( $loaded{online_users} ) {
		return 1
	}

	if ( not open ONLINELOG, "< $vardir/log.txt" ) {
		return 0
	}

	%online_users = map {
			chomp;
			m/^([^\|]+)\|(.*)$/;
			$1 => $2
		} <ONLINELOG>;
#		} grep m/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\|/, <ONLINELOG>;

	close ONLINELOG;

#	$snark_state{online_users} = 1;

	return 1
}

# returns true (1) if user is online.
# Intended for use with user logins. Or u should specify IP.
# TODO: Add check for $username, Guest and Guest-xxx checking to not
#       load log when it is not necessary?
sub is_online {
	load_online_users;

	return exists $online_users{$_[0]}
}

sub Collapse_Load {
	my (@userhide, $hidden);
	$colbutton = 1;
	my $i = 0;
	@userhide = split(/\,/, ${$uid.$username}{'cathide'});
	foreach my $key (@categoryorder) {
		my ($catname, $catperms, $catallowcol) = split(/\|/, $catinfo{$key});
		$access = &CatAccess($catperms);
		if ($catallowcol == 1 && $access) { $i++; }
		$catcol{$key} = 1;
		foreach $hidden (@userhide) {
			chomp $hidden;
			if ($catallowcol == 1 && $key eq $hidden) { $catcol{$key} = 0; }
		}
	}
	if ($i == @userhide) { $colbutton = 0; }
	$colloaded = 1;
}

sub getMailFiles {
	opendir(BOARDNOT, "$boardsdir");
	@bmaildir = grep { /\.mail$/ } readdir(BOARDNOT);
	closedir(BOARDNOT);
	opendir(THREADNOT, "$datadir");
	@tmaildir = grep { /\.mail$/ } readdir(THREADNOT);
	closedir(THREADNOT);
}

sub MailList {
	&is_admin_or_gmod;
	my ($ntime, $nsubject, $ntext, $nsender, $delmailline);
	if (!$INFO{'delmail'}) {
		$mailline = $_[0];
		$mailline =~ s~\r~~g;
		$mailline =~ s~\n~<br />~g;
		($ntime, $nsubject, $ntext, $nsender) = split(/\|/, $mailline);
	} else {
		$delmailline = $INFO{'delmail'};
	}
	if (-e ("$vardir/maillist.dat")) {
		fopen(FILE, "$vardir/maillist.dat");
		@maillist = <FILE>;
		fclose(FILE);
		fopen(FILE, ">$vardir/maillist.dat");
		if (!$INFO{'delmail'}) {
			print FILE "$mailline\n";
		}
		foreach $curmail (@maillist) {
			chomp $curmail;
			($otime, $osubject, $otext, $osender) = split(/\|/, $curmail);
			if ($FORM{'reused'} != $otime && $otime ne $delmailline) {
				print FILE "$curmail\n";
			}
		}
		fclose(FILE);
	} else {
		fopen(FILE, ">$vardir/maillist.dat");
		print FILE "$mailline\n";
		fclose(FILE);
	}
	if ($INFO{'delmail'}) {
		$yySetLocation = qq~$adminurl?action=mailing~;
		&redirectexit;
	}
}


# Moved here from Register.pl,
# as Post.pl also needs it
# to check guest's credentails
sub reg_banning {

	my $ban_user  = $_[0];
	my $ban_email = $_[1];

	if ($username eq "admin" && $iamadmin) { return 0; }
	my (@banlist, $banned, $ban_time);
	my $bansize = -s "$vardir/ban.txt";
	if ($bansize > 9) {
		fopen(BAN, "$vardir/ban.txt");
		@banlist = <BAN>;
		fclose(BAN);
	} else {
		return 0;
	}
	$ban_time = int(time);

	foreach my $line (@banlist) {
		chomp $line;
		my ($dummy, $bannedlst) = split(/\|/, $line);
		my @banned = split(/\,/, $bannedlst);
		if ($dummy eq "I") {    # IP BANNING
			foreach my $ipbanned (@banned) {
				my $str_len = length($ipbanned);
				my $comp_ip = substr($user_ip, 0, $str_len);
				if ($ipbanned eq $comp_ip) {
					fopen(LOG, ">>$vardir/ban_log.txt");
					print LOG "$ban_time|$user_ip\n";
					fclose(LOG);
					&UpdateCookie("delete", $ban_user);
					$username = "Guest";
					&fatal_error("I: $security_txt{'678'}$security_txt{'430'}!");
					&redirectinternal;
				}
			}
		} elsif ($dummy eq "E") {    # EMAIL BANNING
			foreach my $emailbanned (@banned) {
				if (lc $emailbanned eq lc $ban_email) {
					fopen(LOG, ">>$vardir/ban_log.txt");
					print LOG "$ban_time|$emailbanned ($user_ip)\n";
					fclose(LOG);
					&UpdateCookie("delete", $ban_user);
					$username = "Guest";
					&fatal_error("E: $security_txt{'678'}$security_txt{'430'}!");
					&redirectinternal;
				}
			}
		} elsif ($dummy eq "U") {    # USERNAME BANNING
			foreach my $namebanned (@banned) {
				my $rx = quotemeta $namebanned;
				if ($ban_user =~ m/\b$rx\b/i) {
					fopen(LOG, ">>$vardir/ban_log.txt");
					print LOG "$ban_time|$namebanned ($user_ip)\n";
					fclose(LOG);
					&UpdateCookie("delete", $ban_user);
					$username = "Guest";
					&fatal_error("U: $security_txt{'678'}$security_txt{'430'}!");
					&redirectinternal;
				}
			}
		}
	}
}

1;
