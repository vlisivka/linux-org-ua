###############################################################################
# Load.pl                                                                     #
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

$loadplver = 'YaBB 2.1 $Revision: 1.3 $';

require "$sourcedir/System.pl";

sub LoadBoardControl {
	my ($cntcat, $cntboard, $cntpic, $cntdescription, $cntmods, $cntmodgroups, $cnttopicperms, $cntreplyperms, $cntpollperms, $cntzero, $dummy, $dummy, $dummy, $cnttotals);
	$binboard = "";
	$annboard = "";
	fopen(FORUMCONTROL, "+<$boardsdir/forum.control");
	seek FORUMCONTROL, 0, 0;
	my @boardcontrols = <FORUMCONTROL>;
	fclose(FORUMCONTROL);
	$maxboards = $#boardcontrols;

	foreach my $boardline (@boardcontrols) {
		$boardline =~ s/[\r\n]//g;
		chomp $boardline;
		($cntcat, $cntboard, $cntpic, $cntdescription, $cntmods, $cntmodgroups, $cnttopicperms, $cntreplyperms, $cntpollperms, $cntzero, $cntmembergroups, $cntann, $cntrbin, $cntattperms, $cntminageperms, $cntmaxageperms, $cntgenderperms,) = split(/\|/, $boardline);
		## create a global boards array
		push(@allboards, $cntboard);

		%{ $uid . $cntboard } = (
			'cat'          => "$cntcat",
			'description'  => "$cntdescription",
			'pic'          => "$cntpic",
			'mods'         => "$cntmods",
			'modgroups'    => "$cntmodgroups",
			'topicperms'   => "$cnttopicperms",
			'replyperms'   => "$cntreplyperms",
			'pollperms'    => "$cntpollperms",
			'zero'         => "$cntzero",
			'membergroups' => "$cntmembergroups",
			'ann'          => "$cntann",
			'rbin'         => "$cntrbin",
			'attperms'     => "$cntattperms",
			'minageperms'  => "$cntminageperms",
			'maxageperms'  => "$cntmaxageperms",
			'genderperms'  => "$cntgenderperms",);
		if ($cntann == 1)  { $annboard = $cntboard; }
		if ($cntrbin == 1) { $binboard = $cntboard; }
	}
}

sub LoadIMs {
	if ($maintenance && !$iamadmin) { $username = "Guest"; $iamguest = "1"; }
	my $msgsize = -s "$memberdir/$username.msg";
	if (!$iamguest && $username ne '' && $action ne "logout" && $msgsize > 2) {
		fopen(IM, "$memberdir/$username.msg");
		@immessages = <IM>;
		fclose(IM);
		fopen(OM, "$memberdir/$username.outbox");
		@outmessages = <OM>;
		fclose(OM);
		fopen(SM, "$memberdir/$username.imstore");
		@storemessages = <SM>;
		fclose(SM);
		$moutnum    = @outmessages;
		$storenum   = @storemessages;
		$imnewcount = 0;

		foreach $curline (@immessages) {
			($imusername, $imsub, $imdate, $mmessage, $imessageid, $mip, $imnew) = split(/\|/, $curline);
			if ($imnew == 1) { $imnewcount++; }
		}
	}
	if (!$iamguest) {
		$mnum   = @immessages || 0;
		$minnum = @immessages || 0;
		if ($imnewcount eq "") { $imnewcount = 0; }
		if ($imnewcount == 1) { $imnewtext = qq~$load_imtxt{'16'}.~; }
		else { $imnewtext = qq~$load_imtxt{'17'}.~; }

		if ($mnum eq "1") { $yyim = qq~$load_txt{'152'} <a href="$scripturl?action=im">$mnum $load_txt{'471'}</a>, $imnewcount $imnewtext~; }
		elsif ($mnum eq "0" && $imnewcount eq "0") { $yyim = qq~$load_txt{'152'} <a href="$scripturl?action=im">$mnum $load_txt{'153'}</a>.~; }
		else { $yyim = qq~$load_txt{'152'} <a href="$scripturl?action=im">$mnum $load_txt{'153'}</a>, $imnewcount $imnewtext~; }
		if ($maintenance && $iamadmin) { $yyim .= qq~<br /><span class="highlight"><b>$load_txt{'616'}</b></span>~; }
		if (!$user_ip    && $iamadmin) { $yyim .= qq~<br /><b>$load_txt{'773'}</b>~; }
	}
}

sub LoadCensorList {
	if ($#censored > 0 || -s "$langdir/$language/censor.txt" < 3 || !-e "$langdir/$language/censor.txt") { return; }
	fopen(CENSOR, "$langdir/$language/censor.txt") || &fatal_error("205 $load_txt{'106'}: $load_txt{'23'} censor.txt", 1);
	while (chomp($buffer = <CENSOR>)) {
		if ($buffer =~ m/\~/) {
			($tmpa, $tmpb) = split(/\~/, $buffer);
			$tmpc = 0;
		} else {
			($tmpa, $tmpb) = split(/=/, $buffer);
			$tmpc = 1;
		}
		push(@censored, [$tmpa, $tmpb, $tmpc]);
	}
	fclose(CENSOR);
}

sub LoadUserSettings {
	&LoadBoardControl;
	$iamguest = $username eq 'Guest' ? 1 : 0;
	if ($username ne 'Guest') {
		&LoadUser($username);
		$iammod = &is_moderator($username);
		if (${$uid.$username}{'position'} eq 'Administrator' || ${$uid.$username}{'position'} eq 'Global Moderator' || $iammod) { $staff = 1; }
		else { $staff = 0; }
		$sessionvalid = 1;
		if ($sessions == 1 && $staff == 1) {
			$cursession = &encode_password($user_ip);
			chomp $cursession;
			if (${$uid.$username}{'session'} ne $cursession || ${$uid.$username}{'session'} ne $cookiesession) { $sessionvalid = 0; }
		}
		$spass = ${$uid.$username}{'password'};

		# Make sure that if the password doesn't match
		# That you get FULLY Logged out
		if ($spass ne $password && $action ne 'logout') {
			&UpdateCookie("delete");
			$username           = 'Guest';
			$iamguest           = '1';
			$iamadmin           = '';
			$iamgmod            = '';
			$password           = '';
			@settings           = ();
			@immessages         = ();
			$yyim               = "";
			$realname           = '';
			$realemail          = '';
			$ENV{'HTTP_COOKIE'} = '';
			$yyuname            = "";
			if (!$guestaccess) {
				$yySetLocation = qq~$scripturl?action=login~;
			} else {
				$yySetLocation = qq~$scripturl~;
			}
			&redirectexit;
		} else {
			$realname  = ${$uid.$username}{'realname'};
			$realemail = ${$uid.$username}{'email'};
			$iamadmin  = (${$uid.$username}{'position'} eq 'Administrator' && $sessionvalid == 1) ? 1 : 0;
			$iamgmod   = (${$uid.$username}{'position'} eq 'Global Moderator' && $sessionvalid == 1) ? 1 : 0;
			if ($sessionvalid == 1) { ${$uid.$username}{'session'} = $cursession; }
			if ($iamadmin or $iamgmod) {
				### FIXME: Kludge for right admin column show
				$iammod = 0;
			}
			if ($iamadmin or $iamgmod or $iammod) {
				### SAFETY LOCK ###
				if ( ${$uid.$username}{'addgroups'} ) {
					# FIXME: move to Subs.pl...
					# FIXME: how to deal with usual moderators?
					require "$sourcedir/BanWithGroup.pl" if not $loaded{'BanWithGroup.pl'};
					my $lockgid = group_gid ( 'Safety Lock' );
					if ( defined $lockgid and ${$uid.$username}{'addgroups'} =~ /(^|,)$lockgid(,|$)/ ) {
						$iamadmin = 0;
						$iamgmod  = 0;
						$iammod   = 0;
						$staff    = 0;
					};
				};
				### SAFETY LOCK ###
			};
			&CalcAge($username, "calc");
		}
	} else {
		$username = '';
		&FormatUserName($username);
		if ($ENV{REQUEST_METHOD} eq 'POST') {
		}
	}
	unless ($username) {
		&UpdateCookie("delete");

		$username           = 'Guest';
		$password           = '';
		@settings           = ();
		$realname           = '';
		$realemail          = '';
		$ENV{'HTTP_COOKIE'} = '';
	}
}

sub FormatUserName {
	my $user = $_[0];
	if ($useraccount{$user}) { return; }
	$useraccount{$user} = $user;
	$useraccount{$user} =~ s~\%~%25~g;
	$useraccount{$user} =~ s~\#~%23~g;
	$useraccount{$user} =~ s~\+~%2B~g;
	$useraccount{$user} =~ s~\,~%2C~g;
	$useraccount{$user} =~ s~\-~%2D~g;
	$useraccount{$user} =~ s~\.~%2E~g;
	$useraccount{$user} =~ s~\@~%40~g;
	$useraccount{$user} =~ s~\^~%5E~g;
}

sub LoadUser {
	my $user = $_[0];
	my $setting;
	if (${$uid.$user}{'realname'} ne "") { return 1; }
	if ($user eq "") { return 1; }		### ?
	$yyload .= qq~Loaded $user <br />~;
	if (-e "$memberdir/$user.vars") {
		fopen(LOADUSER, "$memberdir/$user.vars");
		my @settings = <LOADUSER>;
		fclose(LOADUSER);
		foreach $setting (@settings) {
			chomp $setting;
			unless (length($setting) == 0) {
				$setting =~ s/\'(.*?)\'\,\"(.*?)\"//ig;
				my $tag   = $1;
				my $value = $2;
				${$uid.$user}{$tag} = $value;
			}
		}
	} elsif (-e "$memberdir/$user.dat") {
		fopen(LOADOLDUSER, "$memberdir/$user.dat");
		my @settings = <LOADOLDUSER>;
		fclose(LOADOLDUSER);
		for (my $cnt = 0; $cnt < @settings; $cnt++) {
			$settings[$cnt] =~ s/[\r\n]//g;
			chomp $settings[$cnt];
		}
		$regtime = "$settings[14]";
		$regtime =~ s~(\d{2}\/\d{2}\/\d{2}).*?(\d{2}\:\d{2}\:\d{2})~&stringtotime("$1 at $2")~eis;
		%{ $uid . $user } = (
			'password'      => "$settings[0]",
			'realname'      => "$settings[1]",
			'email'         => "$settings[2]",
			'webtitle'      => "$settings[3]",
			'weburl'        => "$settings[4]",
			'signature'     => "$settings[5]",
			'postcount'     => "$settings[6]",
			'position'      => "$settings[7]",
			'icq'           => "$settings[8]",
			'aim'           => "$settings[9]",
			'yim'           => "$settings[10]",
			'gender'        => "$settings[11]",
			'usertext'      => "$settings[12]",
			'userpic'       => "$settings[13]",
			'regdate'       => "$settings[14]",
			'regtime'       => "$regtime",
			'location'      => "$settings[15]",
			'bday'          => "$settings[16]",
			'timeselect'    => "$settings[17]",
			'timeoffset'    => "$settings[18]",
			'hidemail'      => "$settings[19]",
			'msn'           => "$settings[20]",
			'template'      => "$settings[21]",
			'language'      => "$settings[22]",
			'lastonline'    => "$settings[23]",
			'lastpost'      => "$settings[24]",
			'lastim'        => "$settings[25]",
			'im_ignorelist' => "$settings[26]",
			'im_notify'     => "$settings[27]",
			'im_popup'      => "$settings[28]",
			'im_imspop'     => "$settings[29]",
			'cathide'       => "$settings[30]",
			'postlayout'    => "$settings[31]",);
	} else {

		return 0;
	}
	if (${$uid.$user}{'weburl'} && ${$uid.$user}{'weburl'} !~ m~\Ahttp://~) { ${$uid.$user}{'weburl'} = "http://${$uid.$user}{'weburl'}"; }
	&ToChars(${$uid.$user}{'realname'});
	&LoadMiniUser($user);
	&FormatUserName($user);
	if ($stealthurl) {
		&MakeStealthURL(${$uid.$user}{'weburl'});
	}
	return 1;
}

sub is_moderator {
	my $user = $_[0];
	my ($testline, $nospace_position, $nospace_group);
	my $is_mod = 0;
	$bd_mod = 0;

	# load all board id's into a hash
	foreach $checkboard (@allboards) {
		$bd_mod++;

		# load moderator user id's into array
		$testline = ${$uid.$checkboard}{'mods'};
		$testline =~ s/ //g;
		@bdmods = split(/\,/, $testline);

		# load moderator groups into array
		$testline = ${$uid.$checkboard}{'modgroups'};
		$testline =~ s/ //g;
		@bdmodgroups = split(/\,/, $testline);

		# check if user is in the moderator list
		foreach $testline (@bdmods) {
			chomp $testline;
			if ($testline eq $user) { $is_mod = 1; }
		}

		# check if user is member of a moderatorgroup
		foreach $testline (@bdmodgroups) {
			chomp $testline;

			# Having a mod group with spaces causes this check to fail
			# So remove spaces in the group in the file
			$nospace_position = ${$uid.$username}{'position'};
			$nospace_position =~ s/ //g;

			if ($testline eq $nospace_position) { $is_mod = 1; }

			foreach $memberaddgroups (split(/\, /, ${$uid.$username}{'addgroups'})) {
				chomp $memberaddgroups;
				if ($testline eq $memberaddgroups) { $is_mod = 1; }
			}
		}
	}
	return $is_mod;
}

sub KillModerator {
	my $killmod = $_[0];
	my ($cntcat, $cntboard, $cntpic, $cntdescription, $cntmods, $cntmodgroups, $cnttopicperms, $cntreplyperms, $cntpollperms, $cntzero, $dummy, $dummy, $dummy, $cnttotals, @boardcontrol);
	fopen(FORUMCONTROL, "+<$boardsdir/forum.control");
	seek FORUMCONTROL, 0, 0;
	@oldcontrols = <FORUMCONTROL>;

	foreach $boardline (@oldcontrols) {
		chomp $boardline;
		if ($boardline ne "") {
			my (@oldmods, @newmods, $testmod);
			($cntcat, $cntboard, $cntpic, $cntdescription, $cntmods, $cntmodgroups, $cnttopicperms, $cntreplyperms, $cntpollperms, $cntzero, $cntpassword, $cnttotals, $cntattperms, $spare, $cntminageperms, $cntmaxageperms, $cntgenderperms) = split(/\|/, $boardline);
			chomp $spare;
			$cntmods =~ s/\, /\,/g;
			(@oldmods) = split(/\,/, $cntmods);
			foreach $testmod (@oldmods) {
				chomp $testmod;

				if ($killmod ne $testmod) {
					push(@newmods, $testmod);
				}
				$cntmods = join(",", @newmods);
			}
			push(@boardcontrol, "$cntcat|$cntboard|$cntpic|$cntdescription|$cntmods|$cntmodgroups|$cnttopicperms|$cntreplyperms|$cntpollperms|$cntzero|$cntpassword|$cnttotals|$cntattperms|$spare|$cntminageperms|$cntmaxageperms|$cntgenderperms\n");
		}
	}
	seek FORUMCONTROL, 0, 0;
	truncate FORUMCONTROL, 0;
	@boardcontrol = &undupe(@boardcontrol);
	print FORUMCONTROL @boardcontrol;
	fclose(FORUMCONTROL);
}

sub KillModeratorGroup {
	my $killmod = $_[0];
	my ($cntcat, $cntboard, $cntpic, $cntdescription, $cntmods, $cntmodgroups, $cnttopicperms, $cntreplyperms, $cntpollperms, $cntzero, $dummy, $dummy, $dummy, $cnttotals, @boardcontrol);
	fopen(FORUMCONTROL, "+<$boardsdir/forum.control");
	seek FORUMCONTROL, 0, 0;
	@oldcontrols = <FORUMCONTROL>;

	foreach $boardline (@oldcontrols) {
		chomp $boardline;
		if ($boardline ne "") {
			my (@oldmods, @newmods, $testmod);
			($cntcat, $cntboard, $cntpic, $cntdescription, $cntmods, $cntmodgroups, $cnttopicperms, $cntreplyperms, $cntpollperms, $cntzero, $cntpassword, $cnttotals, $cntattperms, $spare, $cntminageperms, $cntmaxageperms, $cntgenderperms) = split(/\|/, $boardline);
			chomp $cntgenderperms;
			$cntmodgroups =~ s/\, /\,/g;
			(@oldmods) = split(/\,/, $cntmodgroups);
			foreach $testmod (@oldmods) {
				chomp $testmod;

				if ($killmod ne $testmod) {
					push(@newmods, $testmod);
				}
				$cntmodgroups = join(",", @newmods);
			}
			push(@boardcontrol, "$cntcat|$cntboard|$cntpic|$cntdescription|$cntmods|$cntmodgroups|$cnttopicperms|$cntreplyperms|$cntpollperms|$cntzero|$cntpassword|$cnttotals|$cntattperms|$spare|$cntminageperms|$cntmaxageperms|$cntgenderperms\n");
		}
	}
	seek FORUMCONTROL, 0, 0;
	truncate FORUMCONTROL, 0;
	@boardcontrol = &undupe(@boardcontrol);
	print FORUMCONTROL @boardcontrol;
	fclose(FORUMCONTROL);
}

sub LoadUserDisplay {
	my $user = $_[0];
	if (exists ${$uid.$user}{'password'}) {
		if ($yyUDLoaded{$user}) { return 1; }
	} else {
		&LoadUser($user);
	}
	&LoadCensorList;

	if (${$uid.$user}{'weburl'} !~ m~\Ahttp://~) { ${$uid.$user}{'weburl'} = "http://${$uid.$user}{'weburl'}"; }
	if ($sm) { ${$uid.$user}{'weburl'} = ${$uid.$user}{'weburl'} && ${$uid.$user}{'weburl'} ne q~http://~ ? qq~<a href="${$uid.$user}{'weburl'}" target="_blank">$img{'website_sm'}</a>~ : ''; }
	else { ${$uid.$user}{'weburl'} = ${$uid.$user}{'weburl'} && ${$uid.$user}{'weburl'} ne q~http://~ ? qq~<a href="${$uid.$user}{'weburl'}" target="_blank">$img{'website'}</a>~ : ''; }

	${$uid.$user}{'weburl'} = ${$uid.$user}{'weburl'} ? qq~${$uid.$user}{'weburl'}~ : '';
	&FromHTML(${$uid.$user}{'signature'});
	${$uid.$user}{'signature'} =~ s~\&\&~<br />~g;

	# do some ubbc on the signature
	$message     = ${$uid.$user}{'signature'};
	$displayname = ${$uid.$user}{'realname'};
	if ($enable_ubbc) {
		if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; }
		&DoUBBC;
	}
	&ToChars($message);
	${$uid.$user}{'signature'} = $message;

	# use height like code boxes do. Set to 200px at 15 newlines
	my $linecount = () = ${$uid.$user}{'signature'} =~ /\<br \/\>/g;
	if(${$uid.$user}{'signature'} && $linecount > 15) {${$uid.$user}{'signature'} = qq~<div class="scroll" style="float: left; font-size: 10px; font-family: verdana, sans-serif; overflow: auto; max-height: 200px; height: 200px; width: 99%;">${$uid.$user}{'signature'}</div>~}
	else {${$uid.$user}{'signature'} = ${$uid.$user}{'signature'} ? qq~<div class="scroll" style="float: left; font-size: 10px; font-family: verdana, sans-serif; overflow: auto; max-height: 200px; width: 99%;">${$uid.$user}{'signature'}</div>~ : '';}

	$themsnuser   = $user;
	$themsnname   = ${$uid.$user}{'realname'};
	$thegtalkuser = $user;
	$thegtalkname = ${$uid.$user}{'realname'};

	if ($MenuType == 0) {
		$yimimg   = qq~<img src="$imagesdir/yim.gif" alt="${$uid.$user}{'yim'}" border="0" />~;
		$aimimg   = qq~<img src="$imagesdir/aim.gif" alt="${$uid.$user}{'aim'}" border="0" />~;
		$msnimg   = qq~<img src="$imagesdir/msn3.gif" style="cursor: pointer" onclick="window.open('$scripturl?action=setmsn;msnname=$themsnuser','','height=80,width=340,menubar=no,toolbar=no,scrollbars=no'); return false" alt="$themsnname" border="0" />~;
		$gtalkimg = qq~<img src="$imagesdir/gtalk2.gif" style="cursor: pointer" onclick="window.open('$scripturl?action=setgtalk;gtalkname=$thegtalkuser','','height=80,width=340,menubar=no,toolbar=no,scrollbars=no'); return false" alt="$thegtalkname" border="0" />~;
		$icqimg   = qq~<img src="http://web.icq.com/whitepages/online?icq=${$uid.$user}{'icq'}&#38;img=5" alt="${$uid.$user}{'icq'}" border="0" />~;
	} elsif ($MenuType == 1) {
		$yimimg   = qq~<span class="imgwindowbg">YIM</span>~;
		$aimimg   = qq~<span class="imgwindowbg">AIM</span>~;
		$msnimg   = qq~<span class="imgwindowbg" style="cursor: pointer" onclick="window.open('$scripturl?action=setmsn;msnname=$themsnuser','','height=80,width=340,menubar=no,toolbar=no,scrollbars=no'); return false">MSN</span>~;
		$gtalkimg = qq~<span class="imgwindowbg" style="cursor: pointer" onclick="window.open('$scripturl?action=setgtalk;gtalkname=$thegtalkuser','','height=80,width=340,menubar=no,toolbar=no,scrollbars=no'); return false">GTalk</span>~;
		$icqimg   = qq~<span class="imgwindowbg">ICQ</span>~;
	} else {
		$yimimg   = qq~<img src="$html_root/Buttons/$language/yim.png" alt="${$uid.$user}{'yim'}" border="0" />~;
		$aimimg   = qq~<img src="$html_root/Buttons/$language/aim.png" alt="${$uid.$user}{'aim'}" border="0" />~;
		$msnimg   = qq~<img src="$html_root/Buttons/$language/msn.png" style="cursor: pointer" onclick="window.open('$scripturl?action=setmsn;msnname=$themsnuser','','height=80,width=340,menubar=no,toolbar=no,scrollbars=no'); return false" alt="$themsnname" border="0" />~;
		$gtalkimg = qq~<img src="$html_root/Buttons/$language/gtalk.png" style="cursor: pointer" onclick="window.open('$scripturl?action=setgtalk;gtalkname=$thegtalkuser','','height=80,width=340,menubar=no,toolbar=no,scrollbars=no'); return false" alt="$thegtalkname" border="0" />~;
		$icqimg   = qq~<img src="$html_root/Buttons/$language/icq.png" alt="${$uid.$user}{'icq'}" border="0" />~;
	}

	$icqad{$user} = $icqad{$user} ? qq~<a href="http://web.icq.com/${$uid.$user}{'icq'}" target="_blank"><img src="$imagesdir/icqadd.gif" alt="${$uid.$user}{'icq'}" border="0" /></a>~ : '';
	${$uid.$user}{'icq'}   = ${$uid.$user}{'icq'}   ? qq~<a href="http://web.icq.com/${$uid.$user}{'icq'}" title="${$uid.$user}{'icq'}" target="_blank">$icqimg</a>~ : '';
	${$uid.$user}{'aim'}   = ${$uid.$user}{'aim'}   ? qq~<a href="aim:goim?screenname=${$uid.$user}{'aim'}&#38;message=Hi.+Are+you+there?">$aimimg</a>~              : '';
	${$uid.$user}{'msn'}   = ${$uid.$user}{'msn'}   ? qq~$msnimg~                                                                                                    : '';
	${$uid.$user}{'gtalk'} = ${$uid.$user}{'gtalk'} ? qq~$gtalkimg~                                                                                                  : '';
	$yimon{$user} = $yimon{$user} ? qq~<img src="http://opi.yahoo.com/online?u=${$uid.$user}{'yim'}&#38;m=g&#38;t=0" border="0" alt="" />~ : '';
	${$uid.$user}{'yim'} = ${$uid.$user}{'yim'} ? qq~<a href="http://edit.yahoo.com/config/send_webmesg?.target=${$uid.$user}{'yim'}" target="_blank">$yimimg</a>~ : '';

	if ($showgenderimage && ${$uid.$user}{'gender'}) {
		${$uid.$user}{'gender'} = ${$uid.$user}{'gender'} =~ m~Female~i ? 'female' : 'male';
		${$uid.$user}{'gender'} = ${$uid.$user}{'gender'} ? qq~$load_txt{'231'}: <img src="$imagesdir/${$uid.$user}{'gender'}.gif" border="0" alt="${$uid.$user}{'gender'}" /><br />~ : '';
	} else {
		${$uid.$user}{'gender'} = '';
	}

	# Wrap words longer than 20 characters in user text
	if ($showusertext) {
		$message = ${$uid.$user}{'usertext'};
		$message = &Censor($message);
		&ToChars($message);
		${$uid.$user}{'usertext'} = $message;

		$wrapcut = 20;
		$wrapstr = ${$uid.$user}{'usertext'};
		&WrapChars;
		${$uid.$user}{'usertext'} = $wrapstr;

		${$uid.$user}{'usertext'} .= qq~<br />~;
	} else {
		${$uid.$user}{'usertext'} = "";
	}

	# Create the userpic / avatar html
	if ($showuserpic && $allowpics) {
		${$uid.$user}{'userpic'} ||= 'blank.gif';
		if (${$uid.$user}{'userpic'} =~ m~\A[\s\n]*http://~i) {
			${$uid.$user}{'userpic'}    = qq~${$uid.$user}{'userpic'}~;
			${$uid.$user}{'userownpic'} = 1;
		} else {
			${$uid.$user}{'userpic'}    = qq~$facesurl/${$uid.$user}{'userpic'}~;
			${$uid.$user}{'userownpic'} = 0;
		}
	} else {
		${$uid.$user}{'userpic'} = '<br />';
	}

	# Censor it
	${$uid.$user}{'signature'} = &Censor(${$uid.$user}{'signature'});
	${$uid.$user}{'usertext'}  = &Censor(${$uid.$user}{'usertext'});

	&LoadMiniUser($user);

	$yyUDLoaded{$user} = 1;
	return 1;
}

sub LoadMiniUser {
	my $user = $_[0];
	my $load = '';
	my $key  = '';
	$g = 0;
	my $dg = 0;
	my ($tempgroup, $temp_postgroup);
	my $noshow = 0;
	my $bold   = 0;

	$tempgroupcheck = ${$uid.$user}{'position'} || "";

	if (exists $Group{$tempgroupcheck} && $tempgroupcheck ne "") {
		($title, $stars, $starpic, $color, $noshow, $viewperms, $topicperms, $replyperms, $pollperms, $attachperms) = split(/\|/, $Group{$tempgroupcheck});
		$temptitle = $title;
		$tempgroup = $Group{$tempgroupcheck};
		if ($noshow == 0) { $bold = 1; }
		$memberunfo{$user} = "$tempgroupcheck";
	} elsif ($moderators{$user}) {
		($title, $stars, $starpic, $color, $noshow, $viewperms, $topicperms, $replyperms, $pollperms, $attachperms) = split(/\|/, $Group{'Moderator'});
		$temptitle         = $title;
		$tempgroup         = $Group{'Moderator'};
		$memberunfo{$user} = "$tempgroupcheck";
	} elsif (exists $NoPost{$tempgroupcheck} && $tempgroupcheck ne "") {
		($title, $stars, $starpic, $color, $noshow, $viewperms, $topicperms, $replyperms, $pollperms, $attachperms) = split(/\|/, $NoPost{$tempgroupcheck});
		$temptitle         = $title;
		$tempgroup         = $NoPost{$tempgroupcheck};
		$memberunfo{$user} = "$tempgroupcheck";
	}

	if (!$tempgroup) {
		foreach $postamount (sort { $b <=> $a } keys %Post) {
			if (${$uid.$user}{'postcount'} > $postamount) {
				($title, $stars, $starpic, $color, $noshow, $viewperms, $topicperms, $replyperms, $pollperms, $attachperms) = split(/\|/, $Post{$postamount});
				$tempgroup = $Post{$postamount};
				last;
			}
		}
		$memberunfo{$user} = "$title";
	}

	if ($noshow == 1) {
		$temptitle = $title;
		foreach $postamount (sort { $b <=> $a } keys %Post) {
			if (${$uid.$user}{'postcount'} > $postamount) {
				($title, $stars, $starpic, $color, undef, undef, undef, undef, undef, undef) = split(/\|/, $Post{$postamount});
				last;
			}
		}
	}

	if (!$tempgroup) {
		$temptitle   = "no group";
		$title       = "";
		$stars       = 0;
		$starpic     = "";
		$color       = "";
		$noshow      = 1;
		$viewperms   = "";
		$topicperms  = "";
		$replyperms  = "";
		$pollperms   = "";
		$attachperms = "";
	}

	my $is_banned = 0;
	if ($title =~ /\[banned=(\d+),.*?\]/i) {
		&LoadLanguage('BanWithGroup') if not defined %bangroup_txt;
		$title = $bangroup_txt{'banuntil'} . &timeformat($1);
		if ($1 < $date) {
			$title = qq~<a href="$scripturl?action=ebwg;username=$user" title="$bangroup_txt{'buttexp'}">$title</a>~;
		} elsif ($iamadmin || $iamgmod) {
			$title = qq~<a href="$scripturl?action=ubwg;username=$user" title="$bangroup_txt{'buttunb'}">$title</a>~;
		}
		$is_banned = 1;
	}

	# The following puts some new has variables in if this user is the user browsing the board
	if ($user eq $username) {
		if ($tempgroup) {
			($trash, $trash, $trash, $trash, $trash, $viewperms, $topicperms, $replyperms, $pollperms, $attachperms) = split(/\|/, $tempgroup);
		}
		${$uid.$user}{'perms'} = "$viewperms|$topicperms|$replyperms|$pollperms|$attachperms";
	}

	$userlink = ${$uid.$user}{'realname'} || $user;
	$userlink = qq~<b>$userlink</b>~;
	if (!$scripturl) { $scripturl = qq~$boardurl/YaBB.$yyext~; }
	if ($bold != 1) { $memberinfo{$user} = qq~$title~; }
	else {
		$memberinfo{$user} = qq~<b>$title</b>~;
	}
	if ($color ne "") {
		$link{$user}      = qq~<a href="$scripturl?action=viewprofile;username=$user" style="color:$color;">$userlink</a>~;
		$col_title{$user} = qq~<span style="color: $color;">$memberinfo{$user}</span>~;
	} else {
		$link{$user}      = qq~<a href="$scripturl?action=viewprofile;username=$user">$userlink</a>~;
		$col_title{$user} = qq~$memberinfo{$user}~;
	}
	$addmembergroup{$user} = "<br />";
	${$uid.$user}{'addgroups'} =~ s/\, /\,/g;
	foreach $addgrptitle (split(/\,/, ${$uid.$user}{'addgroups'})) {
		chomp $addgrptitle;
		foreach $key (sort { $a <=> $b } keys %NoPost) {
			($atitle, $t, $t, $t, $anoshow, $aviewperms, $atopicperms, $areplyperms, $apollperms, $aattachperms) = split(/\|/, $NoPost{$key});
			if ($addgrptitle eq $key && $atitle ne $title) {
				if ($user eq $username && !$iamadmin) {
					if ($aviewperms == 1)   { $viewperms   = 1; }
					if ($atopicperms == 1)  { $topicperms  = 1; }
					if ($areplyperms == 1)  { $replyperms  = 1; }
					if ($apollperms == 1)   { $pollperms   = 1; }
					if ($aattachperms == 1) { $attachperms = 1; }
					${$uid.$user}{'perms'} = "$viewperms|$topicperms|$replyperms|$pollperms|$attachperms";
				}
				if ($anoshow && $iamadmin) {
					$addmembergroup{$user} .= qq~($atitle)<br />~;
				} elsif (!$anoshow) {
					$addmembergroup{$user} .= qq~$atitle<br />~;
				}
			}
		}
	}

	if ( not $is_banned and $staff and $sessionvalid == 1 ) {
		$addmembergroup{$user} .= qq~<a href="$scripturl?action=pbwg;username=$user">$maintxt{'banwithgroup'}</a><br />~; #/
	}

	$addmembergroup{$user} =~ s/<br \/>\Z//;

	if ($username eq "Guest") {
		$memberunfo{$user} = "Guest";
	}

	$topicstart{$user} = "";
	$viewnum = "";
	if ($INFO{'num'} || $FORM{'threadid'} && $user eq $username) {
		if ($INFO{'num'}) {
			$viewnum = $INFO{'num'};
		}
		elsif ($FORM{'threadid'}) {
			$viewnum = $FORM{'threadid'};
		}
		if ($viewnum =~ m~/~) { ($viewnum, undef) = split('/', $viewnum); }
		fopen(MSGTXT, "$datadir/$viewnum.txt");
		$thetopic = <MSGTXT>;
		($t, $t, $t, $t, $topicstarter) = split(/[\|]/, $thetopic, 6);
		fclose(MSGTXT);
		if ($user eq $topicstarter) { $topicstart{$user} = "Topic Starter"; }
	}
	$memberaddgroup{$user} = ${$uid.$user}{'addgroups'};


	if ( $stars =~ /\D/ ) {
		$stars = 0
	}

	$memberstar{$user} =
		qq(<img src="$imagesdir/$starpic" border="0" alt="*" />)
		x $stars;


	return 1;
}

sub LoadCookie {
	foreach (split(/; /, $ENV{'HTTP_COOKIE'})) {
		$_ =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
		($cookie, $value) = split(/=/);
		$yyCookies{$cookie} = $value;
	}
	if ($yyCookies{$cookiepassword}) {
		$password      = $yyCookies{$cookiepassword};
		$username      = $yyCookies{$cookieusername} || 'Guest';
		$cookiesession = $yyCookies{$session_id};
	} else {
		$password = '';
		$username = 'Guest';
	}
}

sub UpdateCookie {
	my ($what, $user, $passw, $sessionval, $pathval, $expire) = @_;
	my ($valid, $expiration);
	$valid = 0;
	if ($what eq "delete") {
		$expiration = "Thursday, 01-Jan-1970 00:00:00 GMT";
		if ($pathval eq "") { $pathval = qq~/~; }
		$valid = 1;
	} elsif ($what eq "write") {
		$expiration = $expire;
		if ($pathval eq "") { $pathval = qq~/~; }
		$valid = 1;
	}
	if ($expire eq "persistent") { $expiration = "Sunday, 17-Jan-2038 00:00:00 GMT"; }

	if ($valid == 1) {
		$cookiewritten = "Cookie Prepared";
		$yySetCookies1 = cookie(
			-name    => "$cookieusername",
			-value   => "$user",
			-path    => "$pathval",
			-expires => "$expiration");
		$yySetCookies2 = cookie(
			-name    => "$cookiepassword",
			-value   => "$passw",
			-path    => "$pathval",
			-expires => "$expiration");
		$yySetCookies3 = cookie(
			-name    => "$cookiesession_name",
			-value   => "$sessionval",
			-path    => "$pathval",
			-expires => "$expiration");
	}
}

sub LoadAccess {

	$accesses .= "$load_txt{'805'} $load_txt{'806'} $load_txt{'808'}<br />";

	# Reply Check
	my $access = &AccessCheck($currentboard, 2) || 0;
	if ($access eq "granted") { $tmptxt = $load_txt{'806'}; }
	else { $tmptxt = $load_txt{'807'}; }
	$accesses .= "$load_txt{'805'} $tmptxt $load_txt{'809'}<br />";

	# Topic Check
	my $access = &AccessCheck($currentboard, 1) || 0;
	if ($access eq "granted") { $tmptxt = $load_txt{'806'}; }
	else { $tmptxt = $load_txt{'807'}; }
	$accesses .= "$load_txt{'805'} $tmptxt $load_txt{'810'}<br />";

	# Poll Check
	my $access = &AccessCheck($currentboard, 3) || 0;
	if ($access eq "granted") { $tmptxt = $load_txt{'806'}; }
	else { $tmptxt = $load_txt{'807'}; }
	$accesses .= "$load_txt{'805'} $tmptxt $load_txt{'811'}<br />";

	# Zero Post Check
	if ($INFO{'zeropost'} != 1) { $tmptxt = $load_txt{'806'}; }
	else { $tmptxt = $load_txt{'807'}; }
	if ($username ne 'Guest') { $accesses .= "$load_txt{'805'} $tmptxt $load_txt{'812'}"; }
}

sub WhatTemplate {
	if (!-e "$vardir/template.cfg") {
		fopen(UPDATETEMPLATE, ">$vardir/template.cfg");
		print UPDATETEMPLATE "\$templatesloaded = 1;\n";
		print UPDATETEMPLATE qq~\$templateset{'Forum default'} = "default|default|default|default|default|default";\n~;
		fclose(UPDATETEMPLATE);
		$template = qq~Forum default~;
	}
	require "$vardir/template.cfg";
	$found = 0;
	while (($curtemplate, $value) = each(%templateset)) {
		if ($curtemplate eq $default_template) { $template = $curtemplate; $found = 1; }
	}
	if (!$found) { $template = qq~Forum default~; }
	if (${$uid.$username}{'template'} ne '') {
		while (($curtemplate, $value) = each(%templateset)) {
			if ($curtemplate eq ${$uid.$username}{'template'}) { $template = $curtemplate; }
		}
	}
	($usestyle, $useimages, $usehead, $useboard, $usemessage, $usedisplay) = split(/\|/, $templateset{"$template"});

	if (!-e "$forumstylesdir/$usestyle.css")                   { $usestyle   = "default"; }
	if (!-e "$templatesdir/$usehead/$usehead.html")            { $usehead    = "default"; }
	if (!-e "$templatesdir/$useboard/BoardIndex.template")     { $useboard   = "default"; }
	if (!-e "$templatesdir/$usemessage/MessageIndex.template") { $usemessage = "default"; }
	if (!-e "$templatesdir/$usedisplay/Display.template")      { $usedisplay = "default"; }

	if (-d "$forumstylesdir/$useimages") { $imagesdir = "$forumstylesurl/$useimages"; }
	else { $imagesdir = "$forumstylesurl/default"; }
	$defaultimagesdir = "$forumstylesurl/default";
	$extpagstyle      = qq~$forumstylesurl/$usestyle.css~;
	$extpagstyle =~ s~$usestyle\/~~g;
}

sub WhatLanguage {
	if (${$uid.$username}{'language'} ne '') {
		$language = ${$uid.$username}{'language'};
	} else {
		$language = $lang;
	}

	LoadLanguage("Main");
	LoadLanguage("Menu");

	if ($adminscreen) {
		LoadLanguage("Admin");
		LoadLanguage("FA");
	}

}

1;
