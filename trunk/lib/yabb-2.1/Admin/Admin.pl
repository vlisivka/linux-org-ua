###############################################################################
# Admin.pl                                                                    #
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

$YaBBversion = 'YaBB 2.1';
$adminplver  = 'YaBB 2.1 $Revision: 1.6 $';
$adminplver =~ s/\$Revision\: (.*?) \$/Build $1/ig;

sub Admin {
	&is_admin_or_gmod;
	$yymain .= qq~
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg" colspan="2">
		 <b>$admintxt{'1'}</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">
		<img alt="Admin Centre Logo" src="$defaultimagesdir/aarea.jpg" />
	   </td>
       <td align="left" class="windowbg2">
		 $admintxt{'2'}
	   </td>
     </tr>
   </table>
 </div>

<br />

<div style="float: left; width: 49%; text-align: left;">

 <div class="bordercolor" style="padding: 0px; width: 95%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg">
		 <b>Credits</b>
	   </td>
     </tr>
     <tr align="center" valign="middle">
       <td align="left" class="catbg"><span class="small">YaBB 2</span>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
Ron Hartendorp, Andrew Aitken, Carsten Dalgaard, Ryan Farrington, Zoltan Kovacs, Tim Ceuppens, Shoeb Omar, Torsten Mrotz, Brian Schaefer, Juvenall Wilson, Corey Chapman, Christer Jenson, and all of our beta testers.<br /><br />
	   </td>
     </tr>
     <tr align="center" valign="middle">
       <td align="left" class="catbg"><span class="small">Special thanks to</span>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
Dave Baughman, Bjoern Berg, Corey Chapman, Peter Crouch, ejdmoo, Dave G, Christian Land, Jeff Lewis, Gunther Meyer, Darya Misse, Parham Mofidi, Torsten Mrotz, Carey P, Popeye, Michael Prager, Matt Siegman, Jay Silverman, StarSaber, Marco van Veelen, the support team, our fearless founder: Zef Hemel and everyone who contributed to YaBB in the course of these last 3 years!<br /><br />
No bits or bytes were harmed during the creation of YaBB!<br /><br />
	   </td>
     </tr>
   </table>
 </div>

<br />

 <div class="bordercolor" style="padding: 0px; width: 95%; margin-left: 0px; margin-right: auto;">
  <script language="JavaScript" type="text/javascript">
  <!-- //hide from dinosaurs
	var STABLE;
  // -->
  </script>

  <script language="javascript" src="http://www.yabbforum.com/update/versioncheck.js" type="text/javascript"></script>

  <script language="JavaScript" type="text/javascript">
  <!-- //hide from dinosaurs
	document.write("<table width='100%' cellspacing='1' cellpadding='4'>");		
	document.write("<tr><td colspan='2' class='titlebg'><b>$admintxt{'3'}</b><\/td><\/tr>");
	document.write("<tr><td class='windowbg2'>$versiontxt{'4'}<\/td><td class='windowbg2'><b>$YaBBversion</b><\/td><\/tr>");
	if( !STABLE ) {
		document.write("<tr><td colspan='2' class='titlebg'>Remote Server not available!</b></td></tr>");
	} else {
		document.write("<tr><td class='windowbg2'>$versiontxt{'5'}<\/td><td class='windowbg2'><b>"+STABLE+"</b><\/td><\/tr>");
		document.write("<tr><td class='windowbg2'>$versiontxt{'7'}<\/td><td class='windowbg2'><b>"+BETA+"</b><\/td><\/tr>");
		document.write("<tr><td class='windowbg2'>$versiontxt{'8'}<\/td><td class='windowbg2'><b>"+ALPHA+"</b><\/td><\/tr>");
		if(STABLE == '$YaBBversion') {
			document.write("<tr><td colspan='2' valign='middle' class='windowbg2'><br \/>$versiontxt{'6'}<br \/><br \/><\/td><\/tr>");
		} else {
			document.write("<tr><td colspan='2' valign='middle' class='windowbg2'><br \/>$versiontxt{'2'}"+STABLE+"$versiontxt{'3'}<br \/><br \/><\/td><\/tr>");
		}
	}
	document.write("<\/table>");

  // -->
  </script>
  <noscript>$versiontxt{'1'}</noscript>
 </div>

</div>
<div style="float: left; width: 50%; text-align: right;">

 <div class="bordercolor" style="padding: 0px; width: 100%; margin-left: auto; margin-right: 0px;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg">
		 <b>$admintxt{'4'}</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">
		 <iframe src="http://www.yabbforum.com/update/" frameborder="0" width="100%" height="293">Sorry, to see the latest news, you must use a browser that supports iframes
		 </iframe>
	   </td>
     </tr>
   </table>
 </div>

<br />

 <div class="bordercolor" style="padding: 0px; width: 100%; margin-left: auto; margin-right: 0px;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg">
		 <b>$admintxt{'5'}</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">~;
	&GetLastLogins;
	$yymain .= qq~
	   </td>
     </tr>
   </table>
 </div>
~;

	if (-d "./Convert") {

		$yymain .= qq~
<br />
<div class="bordercolor" style="padding: 0px; width: 100%; margin-left: auto; margin-right: 0px;">
<form name="backdelete" action="$adminurl?action=convdelete" method="post">
<table width="100%" cellspacing="1" cellpadding="4">
	<tr valign="middle">
	<td align="left" class="titlebg">
		<b>$admintxt{'7'}</b>
	</td>
	</tr>
	<tr valign="middle">
	<td align="left" class="windowbg2"><br />
		$admintxt{'8'}<br /><br />
	</td>
	</tr>
	<tr valign="middle">
	<td align="center" class="catbg">
		<input type="submit" value="$admintxt{'9'}" />
	</td>
	</tr>
</table>
</form>
</div>
~;

	}

	$yymain .= qq~
<div style="height: 130px;">&nbsp;</div>
</div>
~;

	$yytitle = "$admin_txt{'208'}";
	&AdminTemplate;
}

sub DeleteConverterFiles {

	my @convertdir = qw~Boards Members Messages Variables~;

	foreach $cnvdir (@convertdir) {
		$convdir = "./Convert/$cnvdir";
		if (-d "$convdir") {
			opendir("CNVDIR", $convdir) || &admin_fatal_error("$admin_txt{'23'} $convdir");
			@convlist = readdir("CNVDIR");
			closedir("CNVDIR");
			foreach $file (@convlist) {
				unlink "$convdir/$file" || &admin_fatal_error("$admin_txt{'23'} $convdir/$file");
			}
			rmdir("$convdir");
		}
	}
	$convdir = "./Convert";
	if (-d "$convdir") {
		opendir("CNVDIR", $convdir) || &admin_fatal_error("$admin_txt{'23'} $convdir");
		@convlist = readdir("CNVDIR");
		closedir("CNVDIR");
		foreach $file (@convlist) {
			unlink "$convdir/$file";
		}
		rmdir("$convdir");
	}
	if (-e "./Setup.pl") { unlink("./Setup.pl"); }

	$yymain .= qq~<b>$admintxt{'10'}</b>~;
	$yytitle = "$admintxt{'10'}";
	&AdminTemplate;
	exit;
}

sub GetLastLogins {
	fopen(ADMINLOG, "$vardir/adminlog.txt");
	@adminlog = <ADMINLOG>;
	fclose(ADMINLOG);

	foreach $line (@adminlog) {
		chomp $line;
		@element = split(/\|/, $line);
		if (!${$uid.$element[0]}{'realname'}) { &LoadUser($element[0]); }    # If user is not in memory, s/he must be loaded.
		$element[2] = &timeformat($element[2]);
		$yymain .= qq~
		<a href="$scripturl?action=viewprofile;username=$element[0]">${$uid.$element[0]}{'realname'}</a> <span class="small">($element[1]) - $element[2]</span><br />
		~;
	}
}

sub FullStats {
	&is_admin_or_gmod;
	my ($numcats, $numboards, $threadcount, $messagecount, $maxdays, $totalt, $totalm, $avgt, $avgm);
	my ($memcount, $latestmember) = &MembershipGet;
	&LoadUser($latestmember);
	$thelatestmember = qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$latestmember}">${$uid.$latestmember}{'realname'}</a>~;
	$memcount ||= 1;

	$numcats = 0;

	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }
	foreach $catid (@categoryorder) {
		$boardlist = $cat{$catid};
		$numcats++;
		(@bdlist) = split(/\,/, $boardlist);
		($catname, $catperms, $catallowcol) = split(/\|/, $catinfo{"$catid"});

		foreach $curboard (@bdlist) {
			chomp $curboard;
			$numboards++;
			push(@loadboards, $curboard);

		}
	}

	&BoardTotals("load", @loadboards);
	foreach $curboard (@loadboards) {

		$totalm += ${$uid.$curboard}{'messagecount'};
		$totalt += ${$uid.$curboard}{'threadcount'};

	}

	$avgm = int($totalm / $memcount);
	&LoadAdmins;

	if ($enableclicklog) {
		my (@log);
		fopen(LOG, "$vardir/clicklog.txt");
		@log = <LOG>;
		fclose(LOG);
		$yyclicks    = @log;
		$yyclicktext = $admin_txt{'692'};
		$yyclicklink = qq~$yyclicks&nbsp;(<a href="$adminurl?action=showclicks">$admin_txt{'693'}</a>)~;

	} else {
		$yyclicktext = $admin_txt{'692a'};
		$yyclicklink = "";
	}
	my (@elog);
	fopen(ELOG, "$vardir/errorlog.txt");
	@elog = <ELOG>;
	fclose(ELOG);
	$errorslog = @elog;

	$yymain .= qq~

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg">
<img src="$imagesdir/info.gif" alt="" border="0" /> <b>$admintxt{'28'}</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="catbg">
		 <i>$admin_txt{'94'}</i>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
		 <div style="float: left; width: 35%; text-align: left; font-size: 12px; padding-top: 2px; padding-bottom: 2px;">
		   $admin_txt{'488'}
		 </div>
		 <div style="float: left; width: 65%; text-align: left; font-size: 12px; padding-top: 2px; padding-bottom: 2px;">
		   $memcount
		 </div>
		<br />
		 <div style="float: left; width: 35%; text-align: left; font-size: 12px; padding-top: 2px; padding-bottom: 2px;">
		   $admin_txt{'490'}
		 </div>
		 <div style="float: left; width: 65%; text-align: left; font-size: 12px; padding-top: 2px; padding-bottom: 2px;">
		   $totalt
		 </div>
		<br />
		 <div style="float: left; width: 35%; text-align: left; font-size: 12px; padding-top: 2px; padding-bottom: 2px;">
		   $admin_txt{'489'}
		 </div>
		 <div style="float: left; width: 65%; text-align: left; font-size: 12px; padding-top: 2px; padding-bottom: 2px;">
		   $totalm
		 </div>
		<br />
		 <div style="float: left; width: 35%; text-align: left; font-size: 12px; padding-top: 2px; padding-bottom: 2px;">
		   $admintxt{'39'}
		 </div>
		 <div style="float: left; width: 65%; text-align: left; font-size: 12px; padding-top: 2px; padding-bottom: 2px;">
		   $avgm
		 </div>
		<br />
		 <div style="float: left; width: 35%; text-align: left; font-size: 12px; padding-top: 2px; padding-bottom: 2px;">
		   $admin_txt{'658'}
		 </div>
		 <div style="float: left; width: 65%; text-align: left; font-size: 12px; padding-top: 2px; padding-bottom: 2px;">
		   $numcats
		 </div>
		<br />
		 <div style="float: left; width: 35%; text-align: left; font-size: 12px; padding-top: 2px; padding-bottom: 2px;">
		   $admin_txt{'665'}
		 </div>
		 <div style="float: left; width: 65%; text-align: left; font-size: 12px; padding-top: 2px; padding-bottom: 2px;">
		   $numboards
		 </div>
		<br />
		 <div style="float: left; width: 35%; text-align: left; font-size: 12px; padding-top: 2px; padding-bottom: 2px;">
		   $errorlog{'3'}
		 </div>
		 <div style="float: left; width: 65%; text-align: left; font-size: 12px; padding-top: 2px; padding-bottom: 2px;">
		   $errorslog
		 </div>
		<br />
		 <div style="float: left; width: 35%; text-align: left; font-size: 12px; padding-top: 2px; padding-bottom: 2px;">
		   $admin_txt{'691'}&nbsp;<span class="small">($yyclicktext)</span>
		 </div>
		 <div style="float: left; width: 65%; text-align: left; font-size: 12px; padding-top: 2px; padding-bottom: 2px;">
		   $yyclicklink
		 </div>
		<br />&nbsp;<br />
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="catbg">
		 <i>$admin_txt{'657'}</i>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
		 <div style="float: left; width: 35%; text-align: left; font-size: 12px; padding-top: 2px; padding-bottom: 2px;">
		   $admin_txt{'656'}
		 </div>
		 <div style="float: left; width: 65%; text-align: left; font-size: 12px; padding-top: 2px; padding-bottom: 2px;">
		   $thelatestmember
		 </div>
		<br />
		 <div style="float: left; width: 35%; text-align: left; font-size: 12px; padding-top: 2px; padding-bottom: 2px;">
		   $admin_txt{'659'}
		 </div>
		 <div style="float: left; width: 65%; text-align: left; font-size: 12px; padding-top: 2px; padding-bottom: 2px;">

~;

	# Sorts the threads to find the most recent post
	# No need to check for board access here because only admins have access to this page
	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }
	foreach $catid (@categoryorder) {
		$boardlist = $cat{$catid};
		(@bdlist) = split(/\,/, $boardlist);
		foreach $curboard (@bdlist) {
			push(@goodboards, $curboard);
		}
	}

	&BoardTotals("load", @goodboards);
	&getlog(@goodboards);
	foreach $curboard (@goodboards) {
		chomp $curboard;
		$lastposttime = ${$uid.$curboard}{'lastposttime'};
		$lastposttime{$curboard} = &timeformat(${$uid.$curboard}{'lastposttime'});
		${$uid.$curboard}{'lastposttime'} = ${$uid.$curboard}{'lastposttime'} eq 'N/A' || !${$uid.$curboard}{'lastposttime'} ? $boardindex_txt{'470'} : ${$uid.$curboard}{'lastposttime'};
		$lastpostrealtime{$curboard} = ${$uid.$curboard}{'lastposttime'} eq 'N/A' || !${$uid.$curboard}{'lastposttime'} ? '' : ${$uid.$curboard}{'lastposttime'};
		if (${$uid.$curboard}{'lastposter'} =~ m~\AGuest-(.*)~) {
			${$uid.$curboard}{'lastposter'} = $1;
			$lastposterguest{$curboard} = 1;
		}
		${$uid.$curboard}{'lastposter'}   = ${$uid.$curboard}{'lastposter'} eq 'N/A' || !${$uid.$curboard}{'lastposter'} ? $boardindex_txt{'470'} : ${$uid.$curboard}{'lastposter'};
		${$uid.$curboard}{'messagecount'} = ${$uid.$curboard}{'messagecount'}        || 0;
		${$uid.$curboard}{'threadcount'}  = ${$uid.$curboard}{'threadcount'}         || 0;
		$totalm += ${$uid.$curboard}{'messagecount'};
		$totalt += ${$uid.$curboard}{'threadcount'};

		# determine the true last post on all the boards a user has access to
		if ($lastposttime > $lastthreadtime) {
			$lsdatetime     = &timeformat($lastposttime);
			$lsposter       = ${$uid.$curboard}{'lastposter'};
			$lssub          = ${$uid.$curboard}{'lastsubject'};
			$lspostid       = ${$uid.$curboard}{'lastpostid'};
			$lsreply        = ${$uid.$curboard}{'lastreply'};
			$lastthreadtime = $lastposttime;
		}
	}
	$yymain .= qq~
			<a href="$scripturl?num=$lspostid/$lsreply#$lsreply">$lssub</a> ($lsdatetime)
		 </div>
		<br />
		 <div style="float: left; width: 35%; text-align: left; font-size: 12px; padding-top: 2px; padding-bottom: 2px;">
		   $admin_txt{'684'}
		 </div>
		 <div style="float: left; width: 65%; text-align: left; font-size: 12px; padding-top: 2px; padding-bottom: 2px;">
		   $administrators
		 </div>
		<br />
		 <div style="float: left; width: 35%; text-align: left; font-size: 12px; padding-top: 2px; padding-bottom: 2px;">
		   $admin_txt{'684a'}
		 </div>
		 <div style="float: left; width: 65%; text-align: left; font-size: 12px; padding-top: 2px; padding-bottom: 2px;">
		   $gmods
		 </div>
		<br />
		 <div style="float: left; width: 35%; text-align: left; font-size: 12px; padding-top: 2px; padding-bottom: 2px;">
		   $admin_txt{'425'}
		 </div>
		 <div style="float: left; width: 65%; text-align: left; font-size: 12px; padding-top: 2px; padding-bottom: 2px;">
		 <script language="javascript" src="http://www.yabbforum.com/update/versioncheck.js" type="text/javascript"></script>
		<script language="JavaScript" type="text/javascript">  
			<!-- //hide from dinosaurs  
     
				document.write("$versiontxt{'4'} <b>$YaBBversion</b> - $versiontxt{'5'} <b>"+STABLE+"</b> <p>");  
 
			// -->
		</script>
		<noscript>$versiontxt{'1'} <img src="http://www.yabbforum.com/images/version/versioncheck.gif" alt="" /></noscript> 
		 
		 </div>
		<br />&nbsp;<br />
	   </td>
     </tr>
   </table>
 </div>
~;
	$yytitle     = "$admin_txt{'208'}";
	$action_area = "stats";
	&AdminTemplate;
	exit;
}

sub LoadAdmins {
	&is_admin_or_gmod;
	my (@members, $curentry, $memdata);
	$administrators = "";
	$gmods          = "";
	&ManageMemberinfo("load");
	while (($membername, $value) = each(%memberinf)) {
		($memberrealname, undef, $memposition, $memposts) = split(/\|/, $value);
		if ($memposition eq "Administrator") {
			$administrators .= qq~ <a href="$scripturl?action=viewprofile;username=$membername">$memberrealname</a><span class="small">,</span> \n~;
		}
		if ($memposition eq "Global Moderator") {
			$gmods .= qq~ <a href="$scripturl?action=viewprofile;username=$membername">$memberrealname</a><span class="small">,</span> \n~;
		}
	}
	$administrators =~ s~<span class="small">,</span> \n\Z~~;
	$gmods          =~ s~<span class="small">,</span> \n\Z~~;
	if ($gmods eq "") { $gmods = qq~&nbsp;~; }
	undef %memberinf;
}

sub ShowClickLog {
	&is_admin_or_gmod;

	if ($enableclicklog) { $logtimetext = $admin_txt{'698'}; }
	else { $logtimetext = $admin_txt{'698a'}; }

	my ($totalip, $totalclick, $totalbrow, $totalos, @log, @iplist, $date, @to, @from, @info, @os, @browser, @newiplist, @newbrowser, @newoslist, @newtolist, @newfromlist, $i, $curentry);
	fopen(LOG, "$vardir/clicklog.txt");
	@log = <LOG>;
	fclose(LOG);

	$i = 0;
	foreach $curentry (@log) {
		($iplist[$i], $date, $to[$i], $from[$i], $info[$i]) = split(/\|/, $curentry);
		$i++;
	}
	$i = 0;
	foreach $curentry (@info) {
		if ($curentry !~ /\s\(Win/i || $curentry !~ /\s\(mac/) { $curentry =~ s/\s\((compatible;\s)*/ - /ig; }
		else { $curentry =~ s/(\S)*\(/; /g; }
		if ($curentry =~ /\s-\sWin/i) { $curentry =~ s/\s-\sWin/; win/ig; }
		if ($curentry =~ /\s-\sMac/i) { $curentry =~ s/\s-\sMac/; mac/ig; }
		($browser[$i], $os[$i]) = split(/\;\s/, $curentry);
		if ($os[$i] =~ /\)\s\S/) { ($os[$i], $browser[$i]) = split(/\)\s/, $os[$i]); }
		$os[$i] =~ s/\)//g;
		$i++;
	}

	for ($i = 0; $i < @iplist; $i++) { $iplist{ $iplist[$i] }++; }
	$i = 0;
	while (($key, $val) = each(%iplist)) {
		$newiplist[$i] = [$key, $val];
		$i++;
	}
	$totalclick = @iplist;
	$totalip    = @newiplist;
	for ($i = 0; $i < @newiplist; $i++) {

		if ($newiplist[$i]->[0] =~ /\S+/ && $newiplist[$i]->[0] =~ /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/) {
			$guestiplist .= qq~$newiplist[$i]->[0]&nbsp;<span style="color: #FF0000;">(<i>$newiplist[$i]->[1]</i>)</span><br />~;
		} else {
			$useriplist .= qq~<a href="$scripturl?action=viewprofile;username=$newiplist[$i]->[0]">$newiplist[$i]->[0]</a>&nbsp;<span style="color: #FF0000;">(<i>$newiplist[$i]->[1]</i>)</span><br />~;
		}
	}

	for ($i = 0; $i < @browser; $i++) { $browser{ $browser[$i] }++; }
	$i = 0;
	while (($key, $val) = each(%browser)) {
		$newbrowser[$i] = [$key, $val];
		$i++;
	}
	$totalbrow = @newbrowser;
	for ($i = 0; $i < @newbrowser; $i++) {
		if ($newbrowser[$i]->[0] =~ /\S+/) {
			$browserlist .= qq~$newbrowser[$i]->[0] &nbsp;<span style="color: #FF0000;">(<i>$newbrowser[$i]->[1]</i>)</span><br />~;
		}
	}

	for ($i = 0; $i < @os; $i++) { $os{ $os[$i] }++; }
	$i = 0;
	while (($key, $val) = each(%os)) {
		$newoslist[$i] = [$key, $val];
		$i++;
	}
	$totalos = @newoslist;
	for ($i = 0; $i < @newoslist; $i++) {
		if ($newoslist[$i]->[0] =~ /\S+/) {
			$oslist .= qq~$newoslist[$i]->[0] &nbsp;<span style="color: #FF0000;">(<i>$newoslist[$i]->[1]</i>)</span><br />~;
		}
	}

	for ($i = 0; $i < @to; $i++) { $to{ $to[$i] }++; }
	$i = 0;
	while (($key, $val) = each(%to)) {
		$newtolist[$i] = [$key, $val];
		$i++;
	}
	for ($i = 0; $i < @newtolist; $i++) {
		if ($newtolist[$i]->[0] =~ /\S+/) {
			$scriptcalls .= qq~<a href=$newtolist[$i]->[0] target=_blank>$newtolist[$i]->[0]</a>&nbsp;<span style="color: #FF0000;">(<i>$newtolist[$i]->[1]</i>)</span><br />~;
		}
	}

	for ($i = 0; $i < @from; $i++) { $from{ $from[$i] }++; }
	$i = 0;
	while (($key, $val) = each(%from)) {
		$newfromlist[$i] = [$key, $val];
		$i++;
	}
	for ($i = 0; $i < @newfromlist; $i++) {
		if ($newfromlist[$i]->[0] =~ /\S+/ && $newfromlist[$i]->[0] !~ m~$boardurl~i) {
			$referlist .= qq~<a href=$newfromlist[$i]->[0] target=_blank>$newfromlist[$i]->[0]</a>&nbsp;<span style="color: #FF0000;">(<i>$newfromlist[$i]->[1]</i>)</span><br />~;
		}
	}

	$yymain .= qq~

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg">
<img src="$imagesdir/info.gif" alt="" border="0" /> <b>$admin_txt{'693'}</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
		 $admin_txt{'697'}$logtimetext<br /><br />
	   </td>
     </tr>
   </table>
 </div>

~;
	if ($enableclicklog) {
		$yymain .= qq~

<br />

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg" colspan="2">
<img src="$imagesdir/cat.gif" alt="" border="0" /> <b>$admin_txt{'694'}</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2" colspan="2"><br />
		 $admin_txt{'691'}: $totalclick<br />
		 $admin_txt{'743'}: $totalip<br /><br />
	   </td>
     </tr>
     <tr valign="middle">
       <td align="center" class="catbg" width="50%">
		 <b>Users</b>
	   </td>
       <td align="center" class="catbg" width="50%">
		 <b>Guests</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2" valign="top" width="50%"><br />
		 $useriplist<br />
	   </td>
       <td align="left" class="windowbg2" valign="top" width="50%"><br />
		 $guestiplist<br />
	   </td>
     </tr>
   </table>
 </div>

<br />

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg">
<img src="$imagesdir/cat.gif" alt="" border="0" /> <b>$admin_txt{'695'}</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="catbg">
		 <i>$admin_txt{'744'}: $totalbrow</i>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
		 $browserlist<br />
	   </td>
     </tr>
   </table>
 </div>

<br />

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg">
<img src="$imagesdir/cat.gif" alt="" border="0" /> <b>$admin_txt{'696'}</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="catbg">
		 <i>$admin_txt{'745'}: $totalos</i>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
		 $oslist<br />
	   </td>
     </tr>
   </table>
 </div>

<br />

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg">
<img src="$imagesdir/cat.gif" alt="" border="0" /> <b>$admin_txt{'696a'}</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
		 $scriptcalls<br />
	   </td>
     </tr>
   </table>
 </div>

<br />

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg">
<img src="$imagesdir/cat.gif" alt="" border="0" /> <b>$admin_txt{'838'}</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
		 $referlist<br />
	   </td>
     </tr>
   </table>
 </div>
~;
	}
	$yytitle     = $admin_txt{'693'};
	$action_area = "showclicks";
	&AdminTemplate;
	exit;
}

sub AdminMembershipRecount {
	&is_admin_or_gmod;
	&MembershipCountTotal;
	$yymain .= qq~<b>$admin_txt{'505'}</b>~;
	$yytitle     = $admin_txt{'504'};
	$action_area = "membershiprecount";
	&AdminTemplate;
	exit;
}

sub AdminBoardRecount {
	&is_admin_or_gmod;
	&ThreadRecount;
	require "$boardsdir/forum.master";
	foreach (keys %board) {
		&BoardCountTotals($_);
	}

	$yymain .= qq~<b>$admin_txt{'503'}</b>~;
	$yytitle     = $admin_txt{'502'};
	$action_area = "boardrecount";
	&AdminTemplate;
	exit;
}

sub ThreadRecount {
	opendir(DIRECTORY, "$datadir");
	while ($file = readdir(DIRECTORY)) {
		next unless grep { /\.txt$/ } $file;
		($filename, $fileext) = split(/\./, $file);
		fopen(MSG, "$datadir/$filename.txt");
		@messages = <MSG>;
		fclose(MSG);
		@lastmessage = split(/\|/, $messages[$#messages]);
		&MessageTotals("load", $filename);
		${$filename}{'replies'} = $#messages;
		${$filename}{'lastposter'} = $lastmessage[4] eq "Guest" ? qq~Guest-$lastmessage[1]~ : $lastmessage[4];
		&MessageTotals("update", $filename);
	}
	closedir(DIRECTORY);
}

sub RebuildMessageIndex {
	opendir(CTB, $datadir);
	@threadlist = grep { /\.ctb$/ } readdir(CTB);
	closedir(CTB);
	$i = 0;
	foreach my $thread (@threadlist) {
		chomp $thread;
		$thread =~ s/\.ctb$//g;
		if (!-e "$datadir/$thread.txt") {
			unlink("$datadir/$thread.ctb");
			next;
		}
		fopen(FILECTB, "$datadir/$thread.ctb");
		@boarddata = <FILECTB>;
		fclose(FILECTB);
		$theboard = $boarddata[0];
		chomp $theboard;
		$thestatus = $boarddata[5];
		chomp $thestatus;
		fopen(FILETXT, "$datadir/$thread.txt");
		@threaddata = <FILETXT>;
		fclose(FILETXT);
		(@firstinfo) = split(/\|/, $threaddata[0]);
		(@lastinfo)  = split(/\|/, $threaddata[$#threaddata]);
		$thelastinfo = sprintf("%010d", $lastinfo[3]);
		$threadinfo[$i] = qq~$theboard|$thelastinfo|$thread|$firstinfo[0]|$firstinfo[1]|$firstinfo[2]|$lastinfo[3]|$#threaddata|$firstinfo[4]|$firstinfo[5]|$thestatus\n~;
		$i++;
	}
	@SortBoards = sort { lc($b) cmp lc($a) } (@threadinfo);
	$openfile = "";
	(@firsthread) = split(/\|/, $SortBoards[0]);
	$closefile = $firsthread[0];
	for ($i = 0; $i < @SortBoards; $i++) {
		@thisthread = ();
		(@thisthread) = split(/\|/, $SortBoards[$i]);
		my $thisboard = $thisthread[0];
		if ($thisboard ne $closefile) {
			fclose(REBUILDMESSAGE);
			$closefile = $thisboard;
		}
		if ($thisboard ne $openfile) {
			fopen(REBUILDMESSAGE, ">$boardsdir/$thisboard.txt");
			$openfile = $thisboard;
		}
		print REBUILDMESSAGE qq~$thisthread[2]|$thisthread[3]|$thisthread[4]|$thisthread[5]|$thisthread[6]|$thisthread[7]|$thisthread[8]|$thisthread[9]|$thisthread[10]~;
	}
	fclose(REBUILDMESSAGE);
	$yymain .= qq~<b>$admin_txt{'507'}</b>~;
	$yytitle     = $admin_txt{'506'};
	$action_area = "rebuildmesindex";
	&AdminTemplate;
	exit;
}

sub case_insensitive {
	uc($::a) cmp uc($::b);
}

sub DeleteOldMessages {
	&is_admin_or_gmod;
	fopen(DELETEOLDMESSAGE, "$vardir/oldestmes.txt");
	$maxdays = <DELETEOLDMESSAGE>;
	fclose(DELETEOLDMESSAGE);
	$yytitle = "$aduptxt{'04'}";
	$yymain .= qq~
<form action="$adminurl?action=removeoldthreads" method="POST">
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg">
<img src="$imagesdir/ban.gif" alt="" border="0" /> <b>$aduptxt{'04'}</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
		 $aduptxt{'05'}<br /><br />
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
		 $admin_txt{'4'}: <input type="checkbox" name="keep_them" value="1" /><br />
		 $admin_txt{'124'} <input type=text name="maxdays" size="2" value="$maxdays" /> $admin_txt{'579'} $admin_txt{'2'}:<br /><br />
		 <div align="left" style="margin-left: 25px; margin-right: auto;">
~;

	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }

	foreach $catid (@categoryorder) {
		$boardlist = $cat{$catid};
		(@bdlist) = split(/\,/, $boardlist);
		($catname, $catperms) = split(/\|/, $catinfo{"$catid"});

		foreach $curboard (@bdlist) {
			($boardname, $boardperms, $boardview) = split(/\|/, $board{"$curboard"});

			$selectname = $curboard . 'check';
			$yymain .= qq~
		   <input type="checkbox" name="$selectname" value="1" />&nbsp;$boardname<br />
~;
		}
	}
	$yymain .= qq~
		 </div><br />
	   </td>
     </tr>
     <tr valign="middle">
       <td align="center" class="catbg">
		 <input type=submit value="$admin_txt{'31'}" />
	   </td>
     </tr>
   </table>
 </div>
</form>
~;
	$action_area = "deleteoldthreads";
	&AdminTemplate;
	exit;
}

sub RebuildMemHistory {
	&is_admin_or_gmod;
	opendir("MEMBSDIR", $memberdir);
	@memlogs = grep { /\.rlog$/ } readdir(MEMBSDIR);
	closedir("MEMBSDIR");
	foreach $recfile (@memlogs) {
		chomp $recfile;
		unlink "$memberdir/$recfile";
	}

	opendir("BOARDSDIR", $boardsdir);
	@messages = grep { /\.txt$/ } readdir(BOARDSDIR);
	closedir("BOARDSDIR");

	foreach $file (@messages) {
		chomp $file;
		($foundfile, $ext) = split(/\./, $file);
		fopen("BRDFILE", "$boardsdir/$foundfile.txt");
		@messagefile = <BRDFILE>;
		fclose("BRDFILE");
		foreach my $line (@messagefile) {
			chomp $line;
			my ($thread, undef) = split(/\|/, $line, 2);
			if (-e "$datadir/$thread.txt") {
				fopen("MSGFILE", "$datadir/$thread.txt");
				@messagelines = <MSGFILE>;
				fclose("MSGFILE");
				foreach my $msgline (@messagelines) {
					chomp $msgline;
					my (undef, undef, undef, undef, $recuser, undef) = split(/\|/, $msgline, 6);
					if($username ne "Guest") { &writereclog($thread, $recuser); }
				}
			}
		}
	}

	$yymain .= qq~<b>$admin_txt{'598'}</b>~;
	$yytitle     = "$admin_txt{'597'}";
	$action_area = "rebuildmemhist";
	&AdminTemplate;
	exit;
}

sub writereclog {
	my ($thread, $receuser) = @_;
	if (-e "$memberdir/$receuser.wlog") {
		unlink "$memberdir/$receuser.wlog";
	}
	if (-e "$memberdir/$receuser.rlog") {
		fopen(RLOG, "$memberdir/$receuser.rlog");
		%recent = map /(.*)\t(.*)/, <RLOG>;
		fclose(RLOG);
	}
	unless (exists($recent{$thread})) {
		$recent{$thread} = 0;
	}
	$recent{$thread}++;
	fopen(RLOG, ">$memberdir/$receuser.rlog");
	print RLOG map "$_\t$recent{$_}\n", keys %recent;
	fclose(RLOG);
	undef %recent;
}

sub RebuildMemList {
	&is_admin_or_gmod;
	&MemberIndex("rebuild");
	$yymain .= qq~<b>$admin_txt{'594'} $regcounter $admin_txt{'594a'}</b>~;
	$yytitle     = "$admin_txt{'593'}";
	$action_area = "rebuildmemlist";
	&AdminTemplate;
	exit;
}

sub UpdateNotify {
	&is_admin_or_gmod;
	$numbfiles = 0;
	$numtfiles = 0;
	&getMailFiles;
	my ($boardfile, $threadfile, @allboards, @allthreads);
	foreach $boardfile (@bmaildir) {
		chomp $boardfile;
		fopen(FILE, "$boardsdir/$boardfile");
		@allboardnot = <FILE>;
		fclose(FILE);
		fopen(FILE, ">$boardsdir/$boardfile", 1);
		foreach $bline (@allboardnot) {
			chomp $bline;
			if ($bline !~ /\t/) {
				($bheuser, undef, $bhelang, $bhetype) = split(/\|/, $bline, 4);
				print FILE "$bheuser\t$bhelang|$bhetype|1\n";
				$numbfiles++;
			} else {
				print FILE "$bline\n";
			}
		}
		fclose(FILE);
		if (!-s "$boardsdir/$boardfile") { unlink("$boardsdir/$boardfile"); }
	}
	foreach $threadfile (@tmaildir) {
		chomp $threadfile;
		fopen(FILE, "$datadir/$threadfile");
		@allthreadsnot = <FILE>;
		fclose(FILE);
		fopen(FILE, ">$datadir/$threadfile", 1);
		foreach $tline (@allthreadsnot) {
			chomp $tline;
			if ($tline !~ /\t/) {
				($theuser, undef, $thelang, $thetype) = split(/\|/, $tline, 4);
				print FILE "$theuser\t$thelang|1|1\n";
				$numtfiles++;
			} else {
				print FILE "$tline\n";
			}
		}
		fclose(FILE);
		if (!-s "$datadir/$threadfile") { unlink("$datadir/$threadfile"); }
	}
	$yymain .= qq~<b>Notification updated!</b><br />Board notification: $numbfiles<br />Topic notification: $numtfiles~;
	$yytitle     = "Notification update";
	$action_area = "updatenotify";
	&AdminTemplate;
	exit;
}

sub DeleteMultiMembers {
	&is_admin_or_gmod;
	my ($count, $currentmem, $start, $sortmode, $sortorder);
	chomp $FORM{"button"};
	chomp $FORM{"emailsubject"};
	chomp $FORM{"emailtext"};
	$tmpemailsubject = $FORM{"emailsubject"};
	$tmpemailtext    = $FORM{"emailtext"};
	if ($FORM{"button"} ne "1" && $FORM{"button"} ne "2") { &admin_fatal_error($admin_txt{'1'}); }

	fopen(FILE, "$memberdir/memberlist.txt");
	@memnum = <FILE>;
	fclose(FILE);
	$count = 0;

	if ($FORM{'button'} eq "1" && $FORM{"emailtext"} ne "") {
		$tmpemailsubject =~ s~\|~&#124~g;
		$tmpemailtext    =~ s~\|~&#124~g;
		$mailline = qq~$date|$tmpemailsubject|$tmpemailtext|$username~;
		&MailList($mailline);
	}

	&getMailFiles;

	while (@memnum >= $count) {
		$currentmem = $FORM{"member$count"};
		if (exists $FORM{"member$count"}) {
			&UserCheck($currentmem, "realname+email");

			push(@deademails, $usercheck{'email'});

			$emailsubject = $FORM{"emailsubject"};
			$emailtext    = $FORM{"emailtext"};

			if ($FORM{"del_mail"}) { $emailsubject = $amv_txt{'43'}; $emailtext = $amv_txt{'44'}; }

			$emailsubject =~ s~\[name\]~$usercheck{'realname'}~ig;
			$emailsubject =~ s~\[username\]~$currentmem~ig;

			$emailtext =~ s~\[name\]~$usercheck{'realname'}~ig;
			$emailtext =~ s~\[username\]~$currentmem~ig;

			if ($emailtext ne "") { &sendmail($usercheck{'email'}, $emailsubject, $emailtext); }

			if ($FORM{'button'} eq "2") {

				unlink("$memberdir/$currentmem.dat");
				unlink("$memberdir/$currentmem.vars");
				unlink("$memberdir/$currentmem.msg");
				unlink("$memberdir/$currentmem.log");
				unlink("$memberdir/$currentmem.rlog");
				unlink("$memberdir/$currentmem.outbox");
				unlink("$memberdir/$currentmem.storage");

				&MemberIndex("remove", $currentmem);

				# For security, remove username from mod position
				&KillModerator($currentmem);
			}
		}
		$count++;
	}

	if ($INFO{'start'} ne "") { $startmode = $INFO{'start'}; }
	if ($INFO{'sort'}  ne "") { $sortmode  = ";sort=" . $INFO{'sort'}; }
	if ($INFO{'order'}) { $sortorder = ";reversed=" . $INFO{'order'}; }

	if ($FORM{'button'} eq "1") {
		$yySetLocation = qq~$adminurl?action=mailing;$sortmode~;
	} else {
		$yySetLocation = qq~$adminurl?action=viewmembers;start=$startmode$sortmode$sortorder~;
	}
	&redirectexit;
}

sub ml {
	&is_admin_or_gmod;
	$FORM{'emails'} = "; " . $FORM{'emails'};
	$FORM{'emails'} =~ s/[\n\r]//g;
	@emails = split(/;\s*/, $FORM{'emails'});
	foreach $curmem (@emails) {
		&sendmail($curmem, "$mbname: $FORM{'subject'}", "$FORM{'message'}\n\n$admin_txt{'130'}\n\n$scripturl");
	}
	$yySetLocation = qq~$adminurl~;
	&redirectexit;
}

sub clean_log {
	&is_admin_or_gmod;

	# Overwrite with a blank file
	fopen(FILE, ">$vardir/log.txt");
	print FILE '';
	fclose(FILE);
	$yymain .= qq~<b>$admin_txt{'596'}</b>~;
	$yytitle     = "$admin_txt{'595'}";
	$action_area = "clean_log";
	&AdminTemplate;
	exit;
}

sub ipban {
	&is_admin_or_gmod;
	my (@banlist, $line, $tmp, @ipban, @emailban, @userban, $dummy, $eban, $iban, $uban);
	fopen(FILE, "$vardir/ban.txt");
	@banlist = <FILE>;
	fclose(FILE);
	foreach $line (@banlist) {
		chomp $line;
		($dummy, $tmp) = split(/\|/, $line);
		if ($dummy eq "I") { $iban = $tmp; }
		if ($dummy eq "E") { $eban = $tmp; }
		if ($dummy eq "U") { $uban = $tmp; }
	}
	$iban =~ s/\,/\n/g;
	$eban =~ s/\,/\n/g;
	$uban =~ s/\,/\n/g;
	$yymain .= qq~
<form action="$adminurl?action=ipban2" method="post">
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg">
<img src="$imagesdir/ban.gif" alt="" border="0" /><b>$admin_txt{'340'}</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="catbg"><span class="small">
			$admin_txt{'724'}
		 </span>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="center" class="windowbg2"><br />
		<textarea cols="60" rows="10" name="ban" style="width: 95%">$iban</textarea><br /><br />
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="catbg"><span class="small">
			$admin_txt{'725'}
		 </span>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="center" class="windowbg2"><br />
		<textarea cols="60" rows="10" name="ban_email" style="width: 95%">$eban</textarea><br /><br />
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="catbg"><span class="small">
			$admin_txt{'725a'}
		 </span>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="center" class="windowbg2"><br />
		<textarea cols="60" rows="10" name="ban_memname" style="width: 95%">$uban</textarea><br /><br />
	   </td>
     </tr>
     <tr valign="middle">
       <td align="center" class="catbg">
		 <input type="submit" value="$admin_txt{'10'}" />
	   </td>
     </tr>
   </table>
 </div>
</form>
~;
	$yytitle     = "$admin_txt{'340'}";
	$action_area = "ipban";
	&AdminTemplate;
	exit;
}

sub ipban2 {
	&is_admin_or_gmod;
	$FORM{'ban'}         =~ tr/\r//d;
	$FORM{'ban'}         =~ s/ //g;
	$FORM{'ban'}         =~ s~\A[\s\n]+~~;
	$FORM{'ban'}         =~ s~[\s\n]+\Z~~;
	$FORM{'ban'}         =~ s~\n\s*\n~\n~g;
	$FORM{'ban'}         =~ s/\n/\,/g;
	$FORM{'ban_email'}   =~ s/ //g;
	$FORM{'ban_email'}   =~ tr/\r//d;
	$FORM{'ban_email'}   =~ s~\A[\s\n]+~~;
	$FORM{'ban_email'}   =~ s~[\s\n]+\Z~~;
	$FORM{'ban_email'}   =~ s~\n\s*\n~\n~g;
	$FORM{'ban_email'}   =~ s/\n/\,/g;
	$FORM{'ban_memname'} =~ s/ //g;
	$FORM{'ban_memname'} =~ tr/\r//d;
	$FORM{'ban_memname'} =~ s~\A[\s\n]+~~;
	$FORM{'ban_memname'} =~ s~[\s\n]+\Z~~;
	$FORM{'ban_memname'} =~ s~\n\s*\n~\n~g;
	$FORM{'ban_memname'} =~ s/\n/\,/g;

	fopen(FILE, ">$vardir/ban.txt", 1);
	print FILE "I|$FORM{'ban'}\n";
	print FILE "E|$FORM{'ban_email'}\n";
	print FILE "U|$FORM{'ban_memname'}\n";
	fclose(FILE);
	$yySetLocation = qq~$adminurl~;
	&redirectexit;
}

sub ver_detail {
	&is_admin_or_gmod;

	opendir(LNGDIR, $langdir);
	my @lfilesanddirs = readdir(LNGDIR);
	close(LNGDIR);
	my $langs   = "";
	my $rowspan = 55;
	foreach $fld (@lfilesanddirs) {
		if (-d "$langdir/$fld" && $fld =~ m^\A[0-9a-zA-Z_\#\%\-\:\+\?\$\&\~\,\@/]+\Z^ && -e "$langdir/$fld/Main.lng") {
			fopen(FILE, "$langdir/$fld/version.txt");
			my @ver = <FILE>;
			fclose(FILE);

			$langs .= qq~		<tr>
			<td width="30%" class="windowbg2" align="left">$fld Language Pack</td>
			<td width="35%" class="windowbg2" align="left"><i>$ver[0]</i></td>
		</tr>~;
			$rowspan++;
		}
	}
	require "$admindir/Attachments.pl";
	require "$sourcedir/BoardIndex.pl";
	require "$sourcedir/Decoder.pl";
	require "$sourcedir/Display.pl";
	require "$sourcedir/DoSmilies.pl";
	require "$sourcedir/Favorites.pl";
	require "$admindir/GuardianAdmin.pl";
	require "$sourcedir/Guardian.pl";
	require "$sourcedir/HelpCentre.pl";
	require "$admindir/EditHelpCentre.pl";
	require "$sourcedir/InstantMessage.pl";
	require "$admindir/AdminEdit.pl";
	require "$sourcedir/LogInOut.pl";
	require "$admindir/MailMembers.pl";
	require "$sourcedir/Maintenance.pl";
	require "$admindir/ManageBoards.pl";
	require "$admindir/ManageCats.pl";
	require "$admindir/ManageTemplates.pl";
	require "$admindir/MemberGroups.pl";
	require "$sourcedir/Memberlist.pl";
	require "$sourcedir/MessageIndex.pl";
	require "$sourcedir/ModifyMessage.pl";
	require "$admindir/ModList.pl";
	require "$admindir/AdvSettings.pl";
	require "$sourcedir/MoveTopic.pl";
	require "$sourcedir/Notify.pl";
	require "$sourcedir/Post.pl";
	require "$sourcedir/Poll.pl";
	require "$sourcedir/Printpage.pl";
	require "$sourcedir/Profile.pl";
	require "$sourcedir/Recent.pl";
	require "$sourcedir/Register.pl";
	require "$admindir/RegistrationLog.pl";
	require "$admindir/RemoveOldTopics.pl";
	require "$sourcedir/RemoveTopic.pl";
	require "$sourcedir/Search.pl";
	require "$sourcedir/SendTopic.pl";
	require "$sourcedir/SetStatus.pl";
	require "$sourcedir/Sessions.pl";
	require "$admindir/Smilies.pl";
	require "$sourcedir/SplitSplice.pl";
	require "$sourcedir/SubList.pl";
	require "$admindir/ViewMembers.pl";
	require "$sourcedir/YaBBC.pl";
	require "YaBB.$yyext";

	$YaBBplver             =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$advsettingsplver      =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$attachmentsplver      =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$boardindexplver       =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$decoderplver          =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$datetimeplver         =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$displayplver          =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$dosmiliesplver        =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$favoritesplver        =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$guardianadminplver    =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$guardianplver         =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$helpcentreplver       =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$edithelpcentreplver   =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$instantmessageplver   =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$loadplver             =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$lockthreadplver       =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$subsplver             =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$admineditplver        =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$manageboardsplver     =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$managecatsplver       =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$membergroupsplver     =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$managetemplatesplver  =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$removeoldthreadsplver =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$smiliesplver          =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$yabbcplver            =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$subsplver             =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$loginoutplver         =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$maintenanceplver      =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$mailmembersplver      =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$memberlistplver       =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$messageindexplver     =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$modifymessageplver    =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$modlistplver          =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$movethreadplver       =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$notifyplver           =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$pollplver             =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$printplver            =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$postplver             =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$profileplver          =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$recentplver           =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$registerplver         =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$registrationlogplver  =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$removethreadplver     =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$searchplver           =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$securityplver         =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$sendtopicplver        =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$setstatusplver        =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$splitspliceplver      =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$smiliesplver          =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$sublistplver          =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$adminsublistplver     =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$sessionsplver         =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$viewmembersplver      =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$yymain .= qq~

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
		 <script language="javascript" src="http://www.yabbforum.com/update/versioncheck.js" type="text/javascript"></script>
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg" colspan="3">
<img src="$imagesdir/info.gif" alt="" border="0" /><b>$admin_txt{'429'}</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="center" class="catbg" width="30%">
		  <b>$admin_txt{'495'}</b><br /></td>
       <td align="center" class="catbg" width="35%">
		  <b>$admin_txt{'494'}</b><br /></td>
       <td align="center" class="catbg" width="35%">
		  <b>$admin_txt{'493'}</b><br /></td>
	   </td>
	  </tr>
	  <tr>
			<td width="30%" class="windowbg2" align="left">$admin_txt{'496'}</td>
			<td width="35%" class="windowbg2" align="left"><i>$YaBBversion</i></td>
			<td width="35%" class="windowbg2" rowspan="$rowspan" align="left" valign="top">
			<script language="JavaScript" type="text/javascript">  
			<!-- //hide from dinosaurs  
     
				document.write("$versiontxt{'5'}<br /><b>"+STABLE+"</b><br />$versiontxt{'7'}<br /><b>"+BETA+"</b>");  
 
			// -->
			</script>
			<noscript>$versiontxt{'1'} <img src="http://www.yabbforum.com/images/version/versioncheck.gif" alt="" /></noscript> 
			 </td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">YaBB.$yyext</td>
			<td width="35%" class="windowbg2" align="left"><i>$YaBBplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">AdminIndex.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$indexplver</i></td>	
		</tr>$langs<tr>
			<td width="30%" class="windowbg2" align="left">Admin.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$adminplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">AdminEdit.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$admineditplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">Attachments.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$attachmentsplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">BoardIndex.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$boardindexplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">DateTime.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$datetimeplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">Decoder.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$decoderplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">Display.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$displayplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">DoSmilies.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$dosmiliesplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">EditHelpCentre.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$edithelpcentreplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">Favorites.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$favoritesplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">Guardian.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$guardianplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">GuardianAdmin.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$guardianadminplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">HelpCentre.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$helpcentreplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">InstantMessage.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$instantmessageplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">Load.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$loadplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">LogInOut.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$loginoutplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">Maintenance.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$maintenanceplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">MailMembers.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$mailmembersplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">ManageBoards.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$manageboardsplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">ManageCats.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$managecatsplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">ManageTemplates.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$managetemplatesplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">MemberGroups.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$membergroupsplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">Memberlist.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$memberlistplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">MessageIndex.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$messageindexplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">ModifyMessage.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$modifymessageplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">ModList.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$modlistplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">AdvSettings.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$advsettingsplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">MoveTopic.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$movethreadplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">Notify.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$notifyplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">Poll.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$pollplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">Post.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$postplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">Printpage.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$printplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">Profile.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$profileplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">Recent.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$recentplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">Register.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$registerplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">RegistrationLog.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$registrationlogplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">RemoveOldTopics.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$removeoldthreadsplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">RemoveTopic.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$removethreadplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">Search.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$searchplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">SendTopic.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$sendtopicplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">Security.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$securityplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">SetStatus.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$setstatusplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">Smilies.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$smiliesplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">SubList.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$sublistplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">AdminSublist.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$adminsublistplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">Sessions.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$sessionsplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">SplitSplice.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$splitspliceplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">Subs.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$subsplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">ViewMembers.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$viewmembersplver</i></td>
		</tr><tr>
			<td width="30%" class="windowbg2" align="left">YaBBC.pl</td>
			<td width="35%" class="windowbg2" align="left"><i>$yabbcplver</i></td>
     </tr>
   </table>
 </div>
~;
	$yytitle     = $admin_txt{'429'};
	$action_area = "detailedversion";
	&AdminTemplate;
	exit;
}

sub Refcontrol {
	LoadLanguage("RefControl");
	fopen(FILE, "$sourcedir/SubList.pl");
	@scriptlines = <FILE>;
	fclose(FILE);
	fopen(FILE, "$vardir/allowed.txt");
	@allowed = <FILE>;
	fclose(FILE);
	$startread = 0;
	$counter   = 0;

	foreach $scriptline (@scriptlines) {
		chomp $scriptline;
		if (substr($scriptline, 0, 1) eq "'") {
			$scriptline =~ /\'(.*?)\'/;
			$actionfound = $1;
			push(@actfound, $actionfound);
			$counter++;
		}
	}
	$column  = int($counter / 3);
	$counter = 0;
	foreach $actfound (@actfound) {
		$selected = "";
		foreach $allow (@allowed) {
			chomp $allow;
			if ($actfound eq $allow) { $selected = " checked"; last; }
		}
		$dismenu .= qq~<input type="checkbox" name="$actfound"$selected /><img src="$imagesdir/question.gif" align="middle" alt="$reftxt{'1a'} $refexpl_txt{$actfound}" title="$reftxt{'1a'} $refexpl_txt{$actfound}" border="0" /> $actfound<br />\n~;
		$counter++;
		if ($counter > $column + 1) {
			$dismenu .= qq~</td><td align="left" class="windowbg2" valign="top" width="33%">~;
			$counter = 0;
		}
	}
	$dismenu .= qq~</td>~;
	$yymain  .= qq~
<form action="$adminurl?action=referer_control2" method="POST">
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg" colspan="3">
<img src="$imagesdir/preferences.gif" alt="" border="0" /><b>$reftxt{'1'}</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2" colspan="3"><br />
		$reftxt{'2'}<br />
	  <span class="small">
		<i>$reftxt{'3'}</i><br /><br />
	  </span>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2" valign="top" width="33%">
		$dismenu
	   </td>
     </tr>
     <tr valign="middle">
       <td align="center" class="catbg" colspan="3">
		<input type="submit" value="$reftxt{'4'}" />
	   </td>
     </tr>
   </table>
 </div>
</form>
~;
	$yytitle     = "$reftxt{'1'}";
	$action_area = "referer_control";
	&AdminTemplate;
	exit;
}

sub Refcontrol2 {
	&is_admin_or_gmod;
	fopen(FILE, "$sourcedir/SubList.pl");
	@scriptlines = <FILE>;
	fclose(FILE);
	$startread = 0;
	$counter   = 0;
	foreach $scriptline (@scriptlines) {
		chomp $scriptline;
		if (substr($scriptline, 0, 1) eq "'") {
			$scriptline =~ /\'(.*?)\'/;
			$actionfound = $1;
			push(@actfound, $actionfound);
			$counter++;
		}
	}
	foreach $actfound (@actfound) {
		if ($FORM{$actfound}) { push(@outfile, "$actfound\n"); }
	}

	fopen(FILE, ">$vardir/allowed.txt");
	print FILE @outfile;
	fclose(FILE);
	$yySetLocation = qq~$adminurl~;
	&redirectexit;
}

sub AddMember {
	&is_admin_or_gmod;
	LoadLanguage("Register");
	$yymain .= qq~
<form action="$adminurl?action=addmember2" method="post" name="creator"> 
<table align="center" border="0" cellspacing="1" cellpadding="3" class="bordercolor">
  <tr>
	<td colspan="2" width="100%" valign="middle" class="titlebg">
	<img src="$imagesdir/register.gif" alt="" border="0" style="vertical-align: middle;" /><b> $admintxt{'17a'}</b>
	</td>
  </tr><tr>
	<td width="30%" class="windowbg"><b>$register_txt{'98'}:</b></td>
	<td width="70%" class="windowbg"><input type="text" name="username" size="30" maxlength="18" /><input type="hidden" name="_session_id_" id="_session_id_" value="$sessionid" /><input type="hidden" name="regdate" id="regdate" value="$regdate" /></td>
  </tr><tr>
	<td width="30%" class="windowbg"><b>$register_txt{'69'}:</b></td>
	<td width="70%" class="windowbg"><input type="text" maxlength="40" name="email" size="50" /></td>
  </tr>~;
	if ($allow_hide_email == 1) {
		$yymain .= qq~
  <tr>
	<td width="30%" class="windowbg"><b>$register_txt{'721'}</b></td>
	<td width="70%" class="windowbg"><input type="checkbox" name="hideemail" value="checked" /></td>
  </tr>
~;
	}
	$yymain .= qq~
	</tr>
~;
	unless ($emailpassword) {
		$yymain .= qq~
	<tr>
		<td width="30%" class="windowbg"><b>$register_txt{'81'}:</b></td>
		<td width="70%" class="windowbg"><input type="password" maxlength="30" name="passwrd1" size="30" /></td>
	</tr><tr>
		<td width="30%" class="windowbg"><b>$register_txt{'82'}:</b></td>
		<td width="70%" class="windowbg"><input type="password" maxlength="30" name="passwrd2" size="30" /></td>
	</tr>
~;
	}

	$yymain .= qq~
  <tr>
	<td colspan="2" align="center" class="catbg">
		<input type="submit" value="$register_txt{'97'}" />
	</td>
</tr>
</table>
</form>
~;

	$yymain .= qq~


<script type="text/javascript" language="JavaScript"> <!--
	document.creator.username.focus();
//--> </script>
~;
	$yytitle     = "$register_txt{'97'}";
	$action_area = "addmember";
	&AdminTemplate;
	exit;
}

sub AddMember2 {
	&is_admin_or_gmod;
	LoadLanguage("Register");
	LoadLanguage("Main");
	my %member;
	while (($key, $value) = each(%FORM)) {
		$value =~ s~\A\s+~~;
		$value =~ s~\s+\Z~~;
		$value =~ s~[\n\r]~~g;
		$member{$key} = $value;
	}
	$member{'username'} =~ s/\s/_/g;

	# check if there is a system hash named like this by checking existence through size
	my $hsize = keys(%{ $member{'username'} });
	if ($hsize > 0) { &admin_fatal_error("Username prohibited by system"); }
	if (length($member{'username'}) > 25) { $member{'username'} = substr($member{'username'}, 0, 25); }
	&admin_fatal_error("($member{'username'}) $register_txt{'37'}") if ($member{'username'} eq '');
	&admin_fatal_error("($member{'username'}) $register_txt{'99'}") if ($member{'username'} eq '_' || $member{'username'} eq '|');
	&admin_fatal_error("$register_txt{'244'} $member{'username'}") if ($member{'username'} =~ /guest/i);
	&admin_fatal_error("$register_txt{'240'} $register_txt{'35'} $register_txt{'241'}") if ($member{'username'} !~ /\A[0-9A-Za-z#%+-\.@^_]+\Z/);
	&admin_fatal_error("$register_txt{'240'}")                                          if ($member{'username'} =~ /,/);
	&admin_fatal_error("($member{'username'}) $register_txt{'76'}")                     if ($member{'email'} eq "");
	&admin_fatal_error("($member{'username'}) $register_txt{'100'}")                    if (-e ("$memberdir/$member{'username'}.vars"));
	&admin_fatal_error("$register_txt{'1'}")                                            if ($member{'username'} eq $member{'passwrd1'});

	if ($emailpassword) {
		srand();
		$member{'passwrd1'} = int(rand(100));
		$member{'passwrd1'} =~ tr/0123456789/ymifxupbck/;
		$_ = int(rand(77));
		$_ =~ tr/0123456789/q8dv7w4jm3/;
		$member{'passwrd1'} .= $_;
		$_ = int(rand(89));
		$_ =~ tr/0123456789/y6uivpkcxw/;
		$member{'passwrd1'} .= $_;
		$_ = int(rand(188));
		$_ =~ tr/0123456789/poiuytrewq/;
		$member{'passwrd1'} .= $_;
		$_ = int(rand(65));
		$_ =~ tr/0123456789/lkjhgfdaut/;
		$member{'passwrd1'} .= $_;
	} else {
		&admin_fatal_error("($member{'username'}) $register_txt{'213'}") if ($member{'passwrd1'} ne $member{'passwrd2'});
		&admin_fatal_error("($member{'username'}) $register_txt{'91'}") if ($member{'passwrd1'} eq '');
		&admin_fatal_error("$register_txt{'240'} $register_txt{'36'} $register_txt{'241'}") if ($member{'passwrd1'} !~ /\A[\s0-9A-Za-z!@#$%\^&*\(\)_\+|`~\-=\\:;'",\.\/?\[\]\{\}]+\Z/);
	}
	&admin_fatal_error("$register_txt{'240'} $register_txt{'69'} $register_txt{'241'}") if ($member{'email'} !~ /[\w\-\.\+]+\@[\w\-\.\+]+\.(\w{2,4}$)/);
	&admin_fatal_error("$register_txt{'500'}") if (($member{'email'} =~ /(@.*@)|(\.\.)|(@\.)|(\.@)|(^\.)|(\.$)/) || ($member{'email'} !~ /\A.+@\[?(\w|[-.])+\.[a-zA-Z]{2,4}|[0-9]{1,4}\]?\Z/));
	fopen(FILE, "$vardir/ban_email.txt");
	@banned = <FILE>;
	fclose(FILE);
	foreach $curban (@banned) {
		if ($member{'email'} eq "$curban") { &admin_fatal_error("$register_txt{'678'}$register_txt{'430'}!"); }
	}

	$testname    = $member{'username'};
	$testemail   = lc $member{'email'};
	$is_existing = &MemberIndex("check_exist", $testname);
	if ($is_existing eq $testname) { &admin_fatal_error("($member{'username'}) $register_txt{'473'}"); }
	$is_existing = &MemberIndex("check_exist", $testemail);
	if ($is_existing eq $testemail) { &admin_fatal_error("$register_txt{'730'} ($member{'email'}) $register_txt{'731'}"); }

	&ToHTML($member{'email'});

	fopen(RESERVE, "$vardir/reserve.txt") || &admin_fatal_error("$register_txt{'23'} reserve.txt", 1);
	@reserve = <RESERVE>;
	fclose(RESERVE);
	fopen(RESERVECFG, "$vardir/reservecfg.txt") || &admin_fatal_error("$register_txt{'23'} reservecfg.txt", 1);
	@reservecfg = <RESERVECFG>;
	fclose(RESERVECFG);
	for ($a = 0; $a < @reservecfg; $a++) {
		chomp $reservecfg[$a];
	}
	$matchword = $reservecfg[0] eq 'checked';
	$matchcase = $reservecfg[1] eq 'checked';
	$matchuser = $reservecfg[2] eq 'checked';
	$matchname = $reservecfg[3] eq 'checked';
	$namecheck = $matchcase eq 'checked' ? $member{'username'} : lc $member{'username'};

	foreach $reserved (@reserve) {
		chomp $reserved;
		$reservecheck = $matchcase ? $reserved : lc $reserved;
		if ($matchuser) {
			if ($matchword) {
				if ($namecheck eq $reservecheck) { &admin_fatal_error("$register_txt{'244'} $reserved"); }
			} else {
				if ($namecheck =~ $reservecheck) { &admin_fatal_error("$register_txt{'244'} $reserved"); }
			}
		}
	}

	&admin_fatal_error("$register_txt{'100'})") if (-e ("$memberdir/$member{'username'}.vars"));
	if ($send_welcomeim == 1) {
		$messageid = $^T . $$;
		fopen(IM, ">$memberdir/$member{'username'}.msg", 1);
		print IM "$sendname|$imsubject|$date|$imtext|$messageid|$ENV{'REMOTE_ADDR'}|1\n";
		fclose(IM);
	}
	$encryptopass = &encode_password($member{'passwrd1'});
	$reguser      = $member{'username'};
	$registerdate = timetostring($date);

	if ($default_template) { $new_template = $default_template; }
	else { $new_template = "default"; }

	${$uid.$reguser}{'password'}      = $encryptopass;
	${$uid.$reguser}{'realname'}      = $reguser;
	${$uid.$reguser}{'email'}         = lc($member{'email'});
	${$uid.$reguser}{'postcount'}     = 0;
	${$uid.$reguser}{'usertext'}      = $defaultusertxt;
	${$uid.$reguser}{'userpic'}       = "blank.gif";
	${$uid.$reguser}{'regdate'}       = $registerdate;
	${$uid.$reguser}{'regtime'}       = int(time);
	${$uid.$reguser}{'timeselect'}    = $timeselected;
	${$uid.$reguser}{'timeoffset'}    = $timeoffset;
	${$uid.$reguser}{'dsttimeoffset'} = $dstoffset;
	${$uid.$reguser}{'hidemail'}      = $FORM{'hideemail'};
	${$uid.$reguser}{'timeformat'}    = qq~MM D+ YYYY @ HH:mm:ss*~;
	${$uid.$reguser}{'template'}      = $new_template;
	${$uid.$reguser}{'language'}      = $language;
	${$uid.$reguser}{'pageindex'}     = qq~1|1|1~;

	&UserAccount($reguser, "register") & MemberIndex("add", $reguser) & FormatUserName($reguser);

	if ($emailpassword) {
		&sendmail($member{'email'}, "$register_txt{'700'} $mbname", "$register_txt{'248'} $member{'username'}!\n\n$register_txt{'719'} $member{'username'}, $register_txt{'492'} $member{'passwrd1'}\n\n$register_txt{'701'}\n$scripturl?action=profile;username=$useraccount{$member{'username'}}\n\n$register_txt{'130'}");
	} else {
		if ($emailwelcome) {
			&sendmail($member{'email'}, "$register_txt{'700'} $mbname", "$register_txt{'248'} $member{'username'}!\n\n$register_txt{'719'} $member{'username'}, $register_txt{'492'} $member{'passwrd1'}\n\n$register_txt{'701'}\n$scripturl?action=profile;username=$useraccount{$member{'username'}}\n\n$register_txt{'130'}");
		}

	}

	$yytitle       = "$register_txt{'245'}";
	$yymain        = "$register_txt{'245'}";
	$yySetLocation = qq~$adminurl?action=viewmembers;sort=regdate;reversed=on;start=0~;
	&redirectexit;
	$action_area = "addmember";
	&AdminTemplate;
}

sub FloodControl {

	LoadLanguage("Sessions");

	if (-e "$vardir/secsettings.txt") {
		require "$vardir/secsettings.txt";
	} else {
		fopen(FILE, ">$vardir/secsettings.txt");
		print FILE qq~1;~;
		fclose(FILE);
	}

	if ($regcheck)             { $regcheck         = ' checked="checked" ' }
	if ($translayer)           { $transcheck       = ' checked="checked" ' }
	if ($stealthurl)           { $stluchecked      = ' checked="checked" ' }
	if ($sessions)             { $sessionschecked  = ' checked="checked" ' }
	if ($referersecurity)      { $refsecchecked    = ' checked="checked" ' }
	if ($show_online_ip_admin) { $ol_admin_checked = ' checked="checked"'; }
	if ($show_online_ip_gmod)  { $ol_gmod_checked  = ' checked="checked"'; }

	$yymain .= qq~

<form action="$adminurl?action=flood_control2" method="post">
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg">
		 <img src="$imagesdir/preferences.gif" alt="" border="0" /><b>$floodtxt{'1'}</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
		 <div class="setting_cell">
			$floodtxt{'2'}
		 </div>
		 <div class="setting_cell2">
			<input type="checkbox" name="regcheck"$regcheck />
		 </div>
		 <br />
		 <div class="setting_cell">
			$floodtxt{'7'}
		 </div>
		 <div class="setting_cell2">
			<input type="text" name="codemaxchars" size="5" value="$codemaxchars" />
		 </div>
		 <br />
		 <div class="setting_cell">
			$floodtxt{'9'}
		 </div>
		 <div class="setting_cell2">
			<input type="checkbox" name="translayer"$transcheck />
		 </div>
		 <br />
		 <div class="setting_cell">
			$dereftxt{'2'}<br /><span class="small">$dereftxt{'4'}</span>
		 </div>
		 <div class="setting_cell2">
			<input type="checkbox" name="stealthurl"$stluchecked />
		 </div>
		 <br />
		 <div class="setting_cell">
			$session_txt{'1'}<br /><span class="small">$session_txt{'2'}</span>
		 </div>
		 <div class="setting_cell2">
			<input type="checkbox" name="sessions"$sessionschecked />
		 </div>
		 <br />
		 <div class="setting_cell">
			$reftxt{'8'}
		 </div>
		 <div class="setting_cell2">
			<input type="checkbox" name="referersecurity"$refsecchecked /><br /><br />
		 </div>
		 <div class="setting_cell">
			$admin_txt{'show_ip_admin'}
		 </div>
		 <div class="setting_cell2">
			<input type="checkbox" name="show_online_ip_admin"$ol_admin_checked /><br /><br />
		 </div>
		 <div class="setting_cell">
			$admin_txt{'show_ip_gmod'}
		 </div>
		 <div class="setting_cell2">
			<input type="checkbox" name="show_online_ip_gmod"$ol_gmod_checked /><br /><br />
		 </div>
	   </td>
     </tr>
   </table>
 </div>

<br />

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="center" class="catbg">
		 <input type="submit" value="$admin_txt{'10'}" />
	   </td>
     </tr>
   </table>
 </div>
</form>


~;
	$action_area = "flood_control";
	&AdminTemplate;

}

sub FloodControl2 {
	&is_admin_or_gmod;

	my @onoff = qw/show_online_ip_admin show_online_ip_gmod sessions translayer referersecurity stealthurl regcheck/;

	# Set as 0 or 1 if box was checked or not
	my $fi;
	map { $fi = lc $_; ${$_} = $FORM{$fi} eq 'on' ? 1 : 0; } @onoff;

	$codemaxchars = $FORM{'codemaxchars'} || "6";
	if ($codemaxchars > 15) { $codemaxchars = 15; }

	my $filler  = q~                                                                               ~;
	my $setfile = << "EOF";
###############################################################################
# SecSettings.txt                                                             #
###############################################################################

use utf8;

\$regcheck = $regcheck;					# Set to 1 if you want to enable automatic flood protection enabled
\$codemaxchars = $codemaxchars;				# Set max length of validation code (15 is max)
\$translayer = $translayer;				# Set to 1 background for validation image should be transparent
\$stealthurl = $stealthurl;				# Set to 1 to mask referer url to hosts if a hyperlink is clicked.
\$referersecurity = $referersecurity;			# Set to 1 to activate referer security checking.
\$sessions = $sessions;					# Set to 1 to activate session id protection.
\$show_online_ip_admin = $show_online_ip_admin;		# Set to 1 to show online IP's to admins.
\$show_online_ip_gmod = $show_online_ip_gmod;		# Set to 1 to show online IP's to global moderators.


1;
EOF

	$setfile =~ s~(.+\;)\s+(\#.+$)~$1 . substr( $filler, 0, (70-(length $1)) ) . $2 ~gem;
	$setfile =~ s~(.{64,}\;)\s+(\#.+$)~$1 . "\n   " . $2~gem;
	$setfile =~ s~^\s\s\s+(\#.+$)~substr( $filler, 0, 70 ) . $1~gem;

	fopen(FILE, ">$vardir/secsettings.txt");
	print FILE $setfile;
	fclose(FILE);

	$yySetLocation = qq~$adminurl~;
	&redirectexit;

}

1;
