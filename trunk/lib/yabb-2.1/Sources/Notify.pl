###############################################################################
# Notify.pl                                                                   #
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

$notifyplver = 'YaBB 2.1 $Revision: 1.2 $';
if ($action eq 'detailedversion') { return 1; }

LoadLanguage("Notify");

sub ManageBoardNotify {
	my $todo     = $_[0];
	my $theboard = $_[1];
	my $user     = $_[2];
	my $userlang = $_[3];
	my $notetype = $_[4];
	my $noteview = $_[5];
	if ($todo eq "load" || $todo eq "update" || $todo eq "delete" || $todo eq "add") {
		if (-e "$boardsdir/$theboard.mail") {
			fopen(BOARDNOTE, "$boardsdir/$theboard.mail");
			%theboard = map /(.*)\t(.*)/, <BOARDNOTE>;
			fclose(BOARDNOTE);
		}
	}
	if ($todo eq "add") {
		$theboard{$user} = "$userlang|$notetype|$noteview";
	}
	if ($todo eq "update") {
		if (exists $theboard{$user}) {
			($memlang, $memtype, $memview) = split(/\|/, $theboard{$user});
			if ($userlang) { $memlang = qq~$userlang~; }
			if ($notetype) { $memtype = qq~$notetype~; }
			if ($noteview) { $memview = $noteview; }
			$theboard{$user} = "$memlang|$memtype|$memview";
		}
	}
	if ($todo eq "delete") {
		if (exists $theboard{$user}) {
			delete($theboard{$user});
		}
	}
	if ($todo eq "save" || $todo eq "update" || $todo eq "delete" || $todo eq "add") {
		fopen(BOARDNOTE, ">$boardsdir/$theboard.mail");
		print BOARDNOTE map "$_\t$theboard{$_}\n", sort { $theboard{$a} cmp $theboard{$b} } keys %theboard;
		fclose(BOARDNOTE);
		undef %theboard;
		if (!-s "$boardsdir/$theboard.mail") { unlink("$boardsdir/$theboard.mail"); }
	}
}

sub BoardNotify {
	if (!$currentboard) { &fatal_error($maintxt{'1'}); }
	if ($iamguest)      { &fatal_error("$maintxt{'138'}"); }
	my ($curuser, $curlang, $notifytype);
	$selected1 = "";
	$selected2 = "";
	$deloption = "";
	my ($boardname, undef) = split(/\|/, $board{"$currentboard"}, 2);
	&ToChars($boardname);
	&ManageBoardNotify("load", $currentboard);
	$yymain .= qq~
	<form action="$scripturl?action=boardnotify3;board=$currentboard" method="post">
	<table border="0" width="600" cellspacing="1" cellpadding="4" align="center" class="bordercolor">
		<tr>
		<td colspan="2" align="left" class="titlebg">
		<img src="$imagesdir/notify.gif" alt="" /> <span class="text1"><b>$notify_txt{'136'} - $boardname</b></span>
		</td>
		</tr><tr>
		<td class="windowbg" width="70%" align="left" valign="middle"><br />
	~;

	if (exists $theboard{$username}) {
		($memlang, $memtype, $memview) = split(/\|/, $theboard{$username});
		${ selected . $memtype } = qq~ selected="selected"~;
		$deloption = qq~<option value="3">$notify_txt{'134'}</option>~;
		$yymain .= qq~$notify_txt{'137'} &nbsp;~;
	} else {
		$yymain .= qq~$notify_txt{'126'} &nbsp;~;
	}
	$yymain .= qq~
		<br /><br />
		</td><td class="windowbg" width="30%" align="center" valign="middle">
		<select name="$currentboard">
		<option value="1"$selected1>$notify_txt{'132'}</option>
		<option value="2"$selected2>$notify_txt{'133'}</option>
		$deloption
		</select>
		</td></tr>
		<tr>
		<td colspan="2" class="catbg" align="center">
		<input type="submit" value="$notify_txt{'124'}" />
		</td>
		</tr>
	</table>
	</form>
	~;
	undef %theboard;
	$yytitle = "$notify_txt{'125'}";
	&template;
	exit;
}

sub BoardNotify2 {
	if ($iamguest) { &fatal_error("$maintxt{'138'}"); }
	foreach $variable (keys %FORM) {
		$notify_type = $FORM{"$variable"};
		if ($notify_type == 1 || $notify_type == 2) {
			&ManageBoardNotify("add", $variable, $username, ${$uid.$username}{'language'}, $notify_type, "1");
		} elsif ($notify_type == 3) {
			&ManageBoardNotify("delete", $variable, $username);
		}
	}
	if ($action eq "boardnotify3") {
		$yySetLocation = qq~$scripturl?board=$INFO{'board'}~;
	} else {
		$yySetLocation = qq~$scripturl?action=shownotify~;
	}
	&redirectexit;
}

sub ManageThreadNotify {
	my $todo      = $_[0];
	my $thethread = $_[1];
	my $user      = $_[2];
	my $userlang  = $_[3];
	my $notetype  = $_[4];
	my $noteview  = $_[5];

	if ($todo eq "load" || $todo eq "update" || $todo eq "delete" || $todo eq "add") {
		if (-e "$datadir/$thethread.mail") {
			fopen(THREADNOTE, "$datadir/$thethread.mail");
			%thethread = map /(.*)\t(.*)/, <THREADNOTE>;
			fclose(THREADNOTE);
		}
	}
	if ($todo eq "add") {
		$thethread{$user} = "$userlang|$notetype|$noteview";
	}
	if ($todo eq "update") {
		if (exists $thethread{$user}) {
			($memlang, $memtype, $memview) = split(/\|/, $thethread{$user});
			if ($userlang) { $memlang = qq~$userlang~; }
			if ($notetype) { $memtype = qq~$notetype~; }
			if ($noteview) { $memview = $noteview; }
			$thethread{$user} = "$memlang|$memtype|$memview";
		}
	}
	if ($todo eq "delete") {
		if (exists $thethread{$user}) {
			delete($thethread{$user});
		}
	}
	if ($todo eq "save" || $todo eq "update" || $todo eq "delete" || $todo eq "add") {
		fopen(THREADNOTE, ">$datadir/$thethread.mail");
		print THREADNOTE map "$_\t$thethread{$_}\n", sort { $thethread{$a} cmp $thethread{$b} } keys %thethread;
		fclose(THREADNOTE);
		undef %thethread;
		if (!-s "$datadir/$thethread.mail") { unlink("$datadir/$thethread.mail"); }
	}
}

sub Notify {
	if ($iamguest) { &fatal_error("$maintxt{'138'}"); }
	my ($thread, $line, $start, $curuser, $curlang);
	if ($INFO{'thread'} =~ m~/~) {
		($thread, $start) = split('/', $INFO{'thread'});
	} else {
		$thread = $INFO{'thread'};
		$start  = $INFO{'start'};
	}
	&ManageThreadNotify("load", "$thread");
	$yymain .= qq~
	<table border="0" width="600" cellspacing="1" cellpadding="4" align="center" class="bordercolor">
		<tr>
		<td align="left" class="titlebg">
		<img src="$imagesdir/notify.gif" alt="" /> <span class="text1"><b>$notify_txt{'118'}</b></span>
		</td>
		</tr><tr>
		<td class="windowbg" align="center"><br />
	~;
	if (exists $thethread{$username}) {
		$yymain .= qq~$notify_txt{'117'}<br /><br /><b><a href="$scripturl?action=notify3;thread=$thread/$start" style="font-weight: bold;">$notify_txt{'Do not notify'}</a> - <a href="$scripturl?num=$thread/$start" style="font-weight: bold;">$notify_txt{'Notify'}</a></b>~;
	} else {
		$yymain .= qq~$maintxt{'126'}<br /><br /><b><a href="$scripturl?action=notify2;thread=$thread/$start" style="font-weight: bold;">$notify_txt{'Notify'}</a> - <a href="$scripturl?num=$thread/$start" style="font-weight: bold;">$notify_txt{'Do not notify'}</a></b>~;
	}
	$yymain .= qq~
		</td>
		</tr>
	</table>
	~;
	undef %thethread;
	$yytitle = "$notify_txt{'125'}";
	&template;
	exit;
}

sub Notify2 {
	if ($iamguest) { &fatal_error($maintxt{'138'}); }
	my ($thread, $start);
	if ($INFO{'thread'} =~ m~/~) {
		($thread, $start) = split('/', $INFO{'thread'});
	} else {
		$thread = $INFO{'thread'};
		$start  = $INFO{'start'};
	}
	&ManageThreadNotify("add", $thread, $username, ${$uid.$username}{'language'}, "1", "1");
	$yySetLocation = qq~$scripturl?num=$thread/$start~;
	&redirectexit;
}

sub Notify3 {
	if ($iamguest) { &fatal_error("$maintxt{'138'}"); }
	my ($thread, $start);
	if ($INFO{'thread'} =~ m~/~) {
		($thread, $start) = split('/', $INFO{'thread'});
	} else {
		$thread = $INFO{'thread'};
		$start  = $INFO{'start'};
	}
	if (-e "$datadir/$thread.mail") {
		&ManageThreadNotify("delete", $thread, $username);
	}
	$yySetLocation = qq~$scripturl?num=$thread/$start~;
	&redirectexit;
}

sub Notify4 {
	if ($iamguest) { &fatal_error("$maintxt{'138'}"); }
	my ($variable, $notype, $threadno);
	foreach $variable (keys %FORM) {
		($notype, $threadno) = split(/-/, $variable);
		if ($notype eq "thread") {
			&ManageThreadNotify("delete", $threadno, $username);
		}
	}
	&ShowNotifications;
}

sub updateLanguage {
	my $user    = $_[0];
	my $newlang = $_[1];
	my ($threadfile, $boardfile);
	foreach $boardfile (@bmaildir) {
		($myboard, undef) = split(/\./, $boardfile);
		&ManageBoardNotify("update", $myboard, $user, $newlang, "", "");
	}
	foreach $threadfile (@tmaildir) {
		($mythread, undef) = split(/\./, $threadfile);
		&ManageThreadNotify("update", $mythread, $user, $newlang, "", "");
	}
}

sub removeNotifications {
	my $user = $_[0];
	my ($boardfile, $threadfile);
	foreach $boardfile (@bmaildir) {
		($myboard, undef) = split(/\./, $boardfile);
		&ManageBoardNotify("delete", $myboard, $user);
	}
	foreach $threadfile (@tmaildir) {
		($mythread, undef) = split(/\./, $threadfile);
		&ManageThreadNotify("delete", $mythread, $user);
	}
}

sub ShowNotifications {
	if ($iamguest) { &fatal_error("$maintxt{'138'}"); }
	my ($boardfile, $myboard);

	# Show Javascript for 'check all' notifications
	$yymain .= qq~
<script language="JavaScript1.2" type="text/javascript">
	<!-- Begin
		function checkAll(j) {
			for (var i = 0; i < document.threadnotify.elements.length; i++) {
				if (j == 0 ) {document.threadnotify.elements[i].checked = true;}
			}
		}
		function uncheckAll(j) {
			for (var i = 0; i < document.threadnotify.elements.length; i++) {
				if (j == 0 ) {document.threadnotify.elements[i].checked = false;}
			}
		}
	//-->
</script>
	~;

	&getMailFiles;

	$boardnum = 0;

	# Display Board notifications
	$yymain .= qq~
	<form action="$scripturl?action=boardnotify2" method="post" name="boardnotify">
	<table border="0" width="600" align="center" cellspacing="1" cellpadding="4" class="bordercolor">
		<tr><td colspan="2" align="left" class="titlebg">
		<img src="$imagesdir/notify.gif" alt="" /> <span class="text1"><b>$notify_txt{'136'}</b></span>
		</td></tr>
	~;
	foreach $boardfile (@bmaildir) {
		($myboard, undef) = split(/\./, $boardfile);
		&ManageBoardNotify("load", "$myboard");
		if (exists $theboard{$username}) {
			$boardnum++;
			($curlang, $boardnotifytype, $hasviewed) = split(/\|/, $theboard{$username});
			my ($boardname, undef) = split(/\|/, $board{"$myboard"}, 2);
			&ToChars($boardname);
			($selected1, $selected2) = "";
			if ($boardnotifytype eq "1") {
				$selected1 = qq~ selected="selected"~;
			} else {
				$selected2 = qq~ selected="selected"~;
			}
			$boardblock .= qq~
			<tr><td align="left" width="65%" class="windowbg">
			<a href="$scripturl?board=$myboard">$boardname</a>
			</td><td align="center" width="35%" class="windowbg">
			<select name="$myboard">
				<option value="1"$selected1>$notify_txt{'132'}</option>
				<option value="2"$selected2>$notify_txt{'133'}</option>
				<option value="3">$notify_txt{'134'}</option>
			</select>
			</td></tr>
			~;
		}
		undef %theboard;
	}
	if (!$boardnum) {
		$yymain .= qq~
		<tr><td colspan="2" align="left" class="windowbg">
		<br />
		$notify_txt{'139'}<br /><br />
		</td></tr>
		~;
	} else {
		$yymain .= qq~
		<tr><td align="left" class="catbg">
		<b>$notify_txt{'135'}</b>
		</td><td align="center" class="catbg">
		<b>$notify_txt{'138'}</b>
		</td></tr>
		$boardblock
		<tr><td colspan="2" align="center" class="windowbg">
		<input type="submit" value="$notify_txt{'124'}" />&nbsp; <input type="reset" value="$notify_txt{'121'}" />
		</td></tr>
		~;
	}
	$yymain .= qq~
	</table>
	</form>
	<br /><br />
	~;
	&LoadCensorList;
	$threadnum = 0;

	$yymain .= qq~
	<form action="$scripturl?action=notify4" method="post" name="threadnotify">
	<table border="0" width="600" align="center" cellspacing="1" cellpadding="4" class="bordercolor">
	<tr><td align="left" colspan="2" class="titlebg">
		<img src="$imagesdir/notify.gif" alt="" /> <span class="text1"><b>$notify_txt{'118'}</b></span>
	</td></tr>
	~;
	foreach $threadfile (@tmaildir) {
		($mythread, undef) = split(/\./, $threadfile);
		&ManageThreadNotify("load", "$mythread");
		if (exists $thethread{$username}) {
			$threadnum++;
			($curlang, $isboardnotify, $hasviewed) = split(/\|/, $thethread{$username});
			fopen(FILE, "$datadir/$mythread.txt");
			@messages = <FILE>;
			fclose(FILE);
			($msub, $mname, $memail, $mdate, $musername, $micon, $mattach, $mip, $mmessage) = split(/\|/, $messages[0]);
			&ToChars($msub);
			$msub = &Censor($msub);
			&LoadUser($musername);

			if (${$uid.$musername}{'realname'}) {
				$username_link = qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$musername}">${$uid.$musername}{'realname'}</a>~;
			} elsif ($mname) {
				$username_link = $mname;
			} else {
				$username_link = $musername;
			}
			$threadblock .= qq~
			<tr><td align="left" width="85%" class="windowbg">
				<b><a href="$scripturl?num=$mythread">$msub</a></b> $notify_txt{'120'} $username_link
			</td><td align="center" width="15%" class="windowbg">
				<input type="checkbox" name="thread-$mythread" value="1" />
			</td></tr>
			~;
		}
	}
	if (!$threadnum) {
		$yymain .= qq~
		<tr><td colspan="2" align="left" class="windowbg">
		<br />
		$notify_txt{'119'}<br /><br />
		</td></tr>
		~;
	} else {
		$yymain .= qq~
		<tr><td align="left" class="catbg">
		<b>$notify_txt{'140'}</b>
		</td><td align="center" class="catbg">
		<b>$notify_txt{'134'}</b>
		</td></tr>
		$threadblock
		<tr><td align="right" width="85%" class="catbg"><span class="small">$notify_txt{'144'}</span></td>
		<td align="center" width="15%" class="catbg"><input type="checkbox" name="checkall" value="" onclick="if (this.checked) checkAll(0); else uncheckAll(0);" /></td>
		<tr><td colspan="2" align="center" class="windowbg">
		<input type="submit" value="$notify_txt{'124'}" />&nbsp; <input type="reset" value="$notify_txt{'121'}" />
		</td></tr>
		~;
	}
	$yymain .= qq~
	</table>
	</form>
	~;

	$yytitle = "$notify_txt{'124'}";
	&template;
	exit;
}

1;
