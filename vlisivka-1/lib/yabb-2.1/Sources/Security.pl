###############################################################################
# Security.pl                                                                 #
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

$securityplver = 'YaBB 2.1 $Revision: 1.3 $';
if ($action eq 'detailedversion') { return 1; }

# The details of that silly code are irrelevant.
# - Tim Peters, 4 Mar 1992

$scripturl = qq~$boardurl/YaBB.$yyext~;

# BIG board check
if ($INFO{'board'}  =~ m~/~) { ($INFO{'board'},  $INFO{'start'}) = split('/', $INFO{'board'}); }
if ($INFO{'num'}    =~ m~/~) { ($INFO{'num'},    $INFO{'start'}) = split('/', $INFO{'num'}); }
if ($INFO{'letter'} =~ m~/~) { ($INFO{'letter'}, $INFO{'start'}) = split('/', $INFO{'letter'}); }
if ($INFO{'thread'} =~ m~/~) { ($INFO{'thread'}, $INFO{'start'}) = split('/', $INFO{'thread'}); } #'

if (-d "$uploaddir") {
	$fa_ok = 1;
} else {
	$fa_ok = 0;
}

$currentboard = $INFO{'board'};
$curnum       = $INFO{'num'};

# strip off any non numeric values to avoid exploitation
$curnum =~ s/(\D*)//g;

if (!$currentboard) {
	&MessageTotals("load", $curnum);
	$currentboard = ${$curnum}{'board'};
}

if ($curnum != '' && !$action) {

	# Add 1 to the number of views of this thread.
	&MessageTotals ('load', $curnum);
	if (${$curnum}{'threadstatus'} =~ /m/) {
		fopen (MOVED, "<$datadir/$curnum.txt");
		my $mesg = (split /\|/, <MOVED>)[8];
		fclose(MOVED);
		if ($mesg =~ /\[link=[^\]]+num=(\d+)[\/\]]/) {
			$yySetLocation = qq~$scripturl?num=$1~;
			&redirectexit;
		}
	}
	&MessageTotals("incview", $curnum);
	unless ($username eq "Guest") {
		$j           = 0;
		@tmprepliers = ();
		for ($i = 0; $i < @repliers; $i++) {
			chomp $repliers[$i];
			($reptime, $repuser, $isreplying) = split(/\|/, $repliers[$i]);
			$outtime = $date - $reptime;
			if ($outtime > 600) { next; }
			elsif ($repuser eq $username) { $tmprepliers[$j] = qq~$date|$repuser|0~; $isrep = 1; }
			else { $tmprepliers[$j] = qq~$reptime|$repuser|$isreplying~; }
			$j++;
		}
		if (!$isrep) {
			$thisreplier = qq~$date|$username|0~;
			push(@tmprepliers, $thisreplier);
		}
		@repliers = @tmprepliers;
		&MessageTotals("update", $curnum);
	}
} elsif ($curnum != '' && $action) {
	# or load the global hash for this thread.
	&MessageTotals("load", $curnum);
}


if ($currentboard ne '') {
	if ($currentboard ne '' && $currentboard !~ /\A[\s0-9A-Za-z#%+,-\.:=?@^_]+\Z/) { &fatal_error($maintxt{'399'}); }
	if (!-e "$boardsdir/$currentboard.txt") { &fatal_error("300 $maintxt{'106'}: $maintxt{'23'} $currentboard.txt"); }
	($boardname, $boardperms, $boardview) = split(/\|/, $board{"$currentboard"});
	my $access = &AccessCheck($currentboard, '', $boardperms);
	if (!$iamadmin && $access ne "granted" && $boardview != 1) { &fatal_error($maintxt{'1'}); }

	# Determine what category we are in.
	$catid = ${$uid.$currentboard}{'cat'};
	($cat, $catperms) = split(/\|/, $catinfo{"$catid"});
	$cataccess = &CatAccess($catperms);
	unless ($annboard ne "" && $currentboard eq $annboard) {
		if (!$cataccess) { &fatal_error($maintxt{'1'}); }
	}

	$bdescrip = ${$uid.$currentboard}{'description'};

	# Create Hash %moderators and %moderatorgroups with all Moderators of the current board
	${$uid.$currentboard}{'mods'} =~ s/\, /\,/g;
	foreach (split(/\,/, ${$uid.$currentboard}{'mods'})) {
		&LoadUser($_);
		$moderators{$_} = ${$uid.$_}{'realname'};
	}
	${$uid.$currentboard}{'modgroups'} =~ s/\, /\,/g;
	foreach (split(/\,/, ${$uid.$currentboard}{'modgroups'})) {
		chomp $_;
		$moderatorgroups{$_} = $_;
	}

	unless ($iamadmin) {
		my $accesstype = "";
		if ($action eq "post") {
			if ($INFO{'title'} eq 'CreatePoll' || $INFO{'title'} eq 'CreatePoll') {
				$accesstype = 3;    # Post Poll
			} elsif ($INFO{'num'}) {
				$accesstype = 2;    # Post Reply
			} else {
				$accesstype = 1;    # Post Thread
			}
		}
		my $access = &AccessCheck($currentboard, $accesstype);
		if ($access ne "granted") { &fatal_error($maintxt{'1'}); }
	}
} else {
	### BIG category check
	$currentcat = $INFO{'cat'} || $INFO{'catselect'};
	if ($currentcat ne '') {
		if ($currentcat =~ m~/~)  { &fatal_error($maintxt{'399a'}); }
		if ($currentcat =~ m~\\~) { &fatal_error($maintxt{'400a'}); }
		if ($currentcat ne '' && $currentcat !~ /\A[\s0-9A-Za-z#%+,-\.:=?@^_]+\Z/) { &fatal_error($maintxt{'399a'}); }
		if (!$cat{$currentcat}) { &fatal_error("300 $maintxt{'106'}: $maintxt{'23'} $currentcat"); }

		#  and need cataccess check!
		$cataccess = &CatAccess($catperms);
		if (!$cataccess) { &fatal_error($maintxt{'1'}); }
	}
}

# BIG thread check
my $threadid = $INFO{'num'} || $INFO{'thread'} || $FORM{'threadid'};

# strip off any non numeric values to avoid exploitation
$threadid =~ s/(\D*)//g;
if ($threadid ne '' && $INFO{'action'} ne 'imsend' && $INFO{'action'} ne 'imsend2') {
	if ($threadid !~ /\d*(.\d*)?/)    { &fatal_error($maintxt{'337'}); }
	if (!-e "$datadir/$threadid.txt") { &fatal_error("104 $maintxt{'106'}: $maintxt{'23'} $threadid.txt"); }
	if ($currentboard ne '') {
		if ($threadid ne '' && !$FORM{'caller'} && $action ne 'imsend') {
			$yyThreadPosition = -1;
			my $found;
			fopen(BOARDFILE, "$boardsdir/$currentboard.txt") || &fatal_error("401 $maintxt{'106'}: $maintxt{'23'} $currentboard.txt", 1);
			while ($yyThreadLine = <BOARDFILE>) {
				++$yyThreadPosition;
				if ($yyThreadLine =~ m~\A$threadid\|~o) { $found = 1; last; }
			}
			fclose(BOARDFILE);

			chomp $yyThreadLine;
		}
	}
}

sub is_admin { if (!$iamadmin) { &fatal_error($security_txt{'1'}); } }
sub is_admin2 { if (!$iamadmin) { &fatal_error($security_txt{'134'}); } }
sub is_global { if (!$iamgmod || $allow_mod != 1) { &fatal_error($security_txt{'1'}); } }

sub is_admin_or_gmod {
	if (!$iamadmin && !$iamgmod) { &fatal_error($security_txt{'1'}); }

	if ($iamgmod && $action ne "") {
		require "$vardir/gmodsettings.txt";

		if ($gmod_access{"$action"} ne "on" && $gmod_access2{"$action"} ne "on") {
			&fatal_error($security_txt{'1'});
		}
	}
}

sub banning {
	if ($username eq "admin" && $iamadmin) { return 0; }
	my (@banlist, $banned, $ban_time, $dummy, $line);
	my $bansize = -s "$vardir/ban.txt";
	if ($bansize > 9) {
		fopen(BAN, "$vardir/ban.txt");
		@banlist = <BAN>;
		fclose(BAN);
	} else {
		return 0;
	}
	$ban_time = int(time);

	foreach $line (@banlist) {
		@banned = ();
		chomp $line;
		($dummy, $bannedlst) = split(/\|/, $line);
		@banned = split(/\,/, $bannedlst);
		if ($dummy eq "I") {    # IP BANNING
			foreach $ipbanned (@banned) {
				$str_len = length($ipbanned);
				$comp_ip = substr($user_ip, 0, $str_len);
				if ($ipbanned eq $comp_ip) {
					fopen(LOG, ">>$vardir/ban_log.txt");
					print LOG "$ban_time|$user_ip\n";
					fclose(LOG);
					&UpdateCookie("delete", $username);
					$username = "Guest";
					&fatal_error("I: $security_txt{'678'}$security_txt{'430'}!");
					&redirectinternal;
				}
			}
		} elsif (!$iamguest && $dummy eq "E") {    # EMAIL BANNING
			foreach $emailbanned (@banned) {
				if (lc $emailbanned eq lc ${$uid.$username}{'email'}) {
					fopen(LOG, ">>$vardir/ban_log.txt");
					print LOG "$ban_time|$emailbanned ($user_ip)\n";
					fclose(LOG);
					&UpdateCookie("delete", $username);
					$username = "Guest";
					&fatal_error("E: $security_txt{'678'}$security_txt{'430'}!");
					&redirectinternal;
				}
			}
		} elsif (!$iamguest && $dummy eq "U") {    # USERNAME BANNING
			foreach $namebanned (@banned) {
				if (lc $namebanned eq lc $username) {
					fopen(LOG, ">>$vardir/ban_log.txt");
					print LOG "$ban_time|$namebanned ($user_ip)\n";
					fclose(LOG);
					&UpdateCookie("delete", $username);
					$username = "Guest";
					&fatal_error("U: $security_txt{'678'}$security_txt{'430'}!");
					&redirectinternal;
				}
			}
		}
	}
}

sub CheckIcon {

	# Check the icon so HTML cannot be exploited.
	# Do it in 3 unless's because 1 is too long.
	$icon =~ s~[^A-Za-z]~~g;
	$icon =~ s~\\~~g;
	$icon =~ s~\/~~g;
	unless ($icon eq "xx" || $icon eq "thumbup" || $icon eq "thumbdown" || $icon eq "exclamation") {
		unless ($icon eq "question" || $icon eq "lamp" || $icon eq "smiley" || $icon eq "angry") {
			unless ($icon eq "cheesy" || $icon eq "grin" || $icon eq "sad" || $icon eq "wink") {
				$icon = "xx";
			}
		}
	}
}

## Checks whether access is granted to a given board
## Second argument can be 1 - posting, 2 - replying, 3 - polls, 4 - attachments, anything other - board access
## A: string (board), integer (what to check), string (permissions for board)
sub AccessCheck {
	my ($curboard, $checktype, $boardperms) = @_;

	# Put whether it's a zero post count board in global variable
	# to save need to reopen file many times.
	unless (exists $memberunfo{$username}) { &LoadUser($username); }
	my $boardmod = 0;
	${$uid.$curboard}{'mods'} =~ s/\, /\,/g;
	@board_mods = split(/\,/, ${$uid.$curboard}{'mods'});
	foreach $curuser (@board_mods) {
		if ($username eq $curuser) { $boardmod = 1; }
	}
	${$uid.$curboard}{'modgroups'} =~ s/\, /\,/g;
	${$uid.$username}{'addgroups'} =~ s/\, /\,/g;
	@board_modgrps = split(/\,/, ${$uid.$curboard}{'modgroups'});
	@user_addgrps  = split(/\,/, ${$uid.$username}{'addgroups'});
	foreach $curgroup (@board_modgrps) {
		if (${$uid.$username}{'position'} eq $curgroup) { $boardmod = 1; }
		foreach $curaddgroup (@user_addgrps) {
			if ($curaddgroup eq $curgroup) { $boardmod = 1; }
		}
	}
	$INFO{'zeropost'} = ${$uid.$curboard}{'zero'};
	if ($iamadmin) { $access = "granted"; return $access; }
	my ($viewperms, $topicperms, $replyperms, $pollperms, $attachperms);
	if ($username ne "Guest") {
		($viewperms, $topicperms, $replyperms, $pollperms, $attachperms) = split(/\|/, ${$uid.$username}{'perms'});
	}
	if ($username eq "Guest" && !$enable_guestposting) {
		$viewperms   = 0;
		$topicperms  = 1;
		$replyperms  = 1;
		$pollperms   = 1;
		$attachperms = 1;
	}
	my $access = "denied";
	if ($checktype == 1) {    # Post access check
		${$uid.$curboard}{'topicperms'} =~ s/\, /\,/g;
		@allowed_groups = split(/\,/, ${$uid.$curboard}{'topicperms'});
		if (${$uid.$curboard}{'topicperms'} eq "") { $access = "granted"; }
		if ($topicperms == 1) { $access = "notgranted"; }
	} elsif ($checktype == 2) {    # Reply access check
		${$uid.$curboard}{'replyperms'} =~ s/\, /\,/g;
		@allowed_groups = split(/\,/, ${$uid.$curboard}{'replyperms'});
		if (${$uid.$curboard}{'replyperms'} eq "") { $access = "granted"; }
#		if ($replyperms == 1 && !$topicstart{$username}) { $access = "notgranted"; }
		if ($replyperms == 1) { $access = "notgranted"; }
	} elsif ($checktype == 3) {    # Poll access check
		${$uid.$curboard}{'pollperms'} =~ s/\, /\,/g;
		@allowed_groups = split(/\,/, ${$uid.$curboard}{'pollperms'});
		if (${$uid.$curboard}{'pollperms'} eq "") { $access = "granted"; }
		if ($pollperms == 1) { $access = "notgranted"; }
	} elsif ($checktype == 4) {    # Attachment access check
		if (${$uid.$curboard}{'attperms'} == 1) { $access = "granted"; }
		if ($attachperms == 1) { $access = "notgranted"; }
	} else {                       # Board access check
		$boardperms =~ s/\, /\,/g;
		@allowed_groups = split(/\,/, $boardperms);
		if ($boardperms eq "") { $access = "granted"; }
		if ($viewperms == 1) { $access = "notgranted"; }
	}

	# age and gender check
	unless ($iamadmin || $iamgmod || $boardmod) {
		if ((${$uid.$curboard}{'minageperms'} || ${$uid.$curboard}{'maxageperms'}) && (!$age || $age == 0)) {
			$access = "notgranted";
		} elsif (${$uid.$curboard}{'minageperms'} && $age < ${$uid.$curboard}{'minageperms'}) {
			$access = "notgranted";
		} elsif (${$uid.$curboard}{'maxageperms'} && $age > ${$uid.$curboard}{'maxageperms'}) {
			$access = "notgranted";
		}
		if (${$uid.$curboard}{'genderperms'} && !${$uid.$username}{'gender'}) {
			$access = "notgranted";
		} elsif (${$uid.$curboard}{'genderperms'} eq "M" && ${$uid.$username}{'gender'} eq "Female") {
			$access = "notgranted";
		} elsif (${$uid.$curboard}{'genderperms'} eq "F" && ${$uid.$username}{'gender'} eq "Male") {
			$access = "notgranted";
		}
	}
	unless ($access eq "granted" || $access eq "notgranted") {
		$memberinform = $memberunfo{$username};
		foreach $element (@allowed_groups) {
			chomp $element;
			if ($element eq $memberinform) { $access = "granted"; }
			$memberaddgroup{$username} =~ s/\, /\,/g;
			foreach $memberaddgroups (split(/\,/, $memberaddgroup{$username})) {
				chomp $memberaddgroups;
				if ($element eq $memberaddgroups) { $access = "granted"; last; }
			}
#			if ($element eq $topicstart{$username}) { $access = "granted"; }
			if ($element eq "Global Moderator" && ($iamadmin || $iamgmod)) { $access = "granted"; }
			if ($element eq "Moderator" && ($iamadmin || $iamgmod || $boardmod)) { $access = "granted"; }
			if ($access eq "granted") { last; }
		}
	}

	return ($access);
}

sub CatAccess {
	my ($cataccess) = @_;
	if ($iamadmin || $cataccess eq "") { return 1; }

	my $access = 0;
	$cataccess =~ s/\, /\,/g;
	@allow_groups = split(/\,/, $cataccess);
	unless (exists $memberunfo{$username}) { &LoadUser($username); }
	$memberinform = $memberunfo{$username};
	foreach $element (@allow_groups) {
		chomp $element;
		if ($element eq $memberinform) { $access = 1; }
		$memberaddgroup{$username} =~ s/\, /\,/g;
		foreach $memberaddgroups (split(/\,/, $memberaddgroup{$username})) {
			chomp $memberaddgroups;
			if ($element eq $memberaddgroups) { $access = 1; last; }
		}
		if ($element eq "Moderator" && ($iamgmod || exists $moderators{$username})) { $access = 1; }
		if ($element eq "Global Moderator" && $iamgmod) { $access = 1; }
		if ($access == 1) { last; }
	}
	return $access;
}

1;
