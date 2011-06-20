###############################################################################
# Register.pl                                                                 #
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

$registerplver = 'YaBB 2.1 $Revision: 1.7 $';
if ($action eq 'detailedversion') { return 1; }

LoadLanguage('Register');

my $serveros = "$^O";
if ($serveros =~ m/Win/) {
	my $regstyle = qq~style=" text-transform: lowercase"~;
} else {
	my $regstyle = '';
}

sub Register {
	if ($regdisable && $iamguest) { &fatal_error("$register_txt{'3'}"); }
	my ($langopt, $tmpregname, $tmpregemail, $tmpregpasswrd1, $tmpregpasswrd2, $hidechecked);
	if ($FORM{'reglanguage'}) {
		$language = $FORM{'reglanguage'};
		LoadLanguage('Main');
		LoadLanguage('Register');
	}
	if ($FORM{'tusername'})  { $tmpregname     = $FORM{'tusername'}; }
	if ($FORM{'temail'})     { $tmpregemail    = $FORM{'temail'}; }
	if ($FORM{'thideemail'}) { $hidechecked    = qq~checked="checked"~; }
	if ($FORM{'tpasswrd1'})  { $tmpregpasswrd1 = $FORM{'tpasswrd1'}; }
	if ($FORM{'tpasswrd2'})  { $tmpregpasswrd2 = $FORM{'tpasswrd2'}; }
	opendir(DIR, $langdir);
	$morelang = 0;

	while (my $filesanddirs = readdir(DIR)) {
		chomp $filesanddirs;
		if (($filesanddirs ne '.') && ($filesanddirs ne '..') && (-e "$langdir/$filesanddirs/Register.lng")) {
			$lngsel = "";
			if ($filesanddirs eq $language) { $lngsel = qq~selected="selected"~; }
			$langopt .= qq~<option value="$filesanddirs"$lngsel>$filesanddirs</option>~;
			$morelang++;
		}
	}
	close(DIR);

	if (!$iamguest) { &fatal_error("$register_txt{'2'}"); }

	$yymain .= qq~
<div class="bordercolor" style="padding: 1px;">
<table border="0" width="100%" cellspacing="0" class="bordercolor" cellpadding="4">
  <tr class="titlebg">
    <td colspan="2">
    <img src="$imagesdir/register.gif" alt="$register_txt{'97'}" border="0" /> <span class="text1"><b>$register_txt{'97'}</b> $register_txt{'517'}</span></td>
  </tr>
~;

	if ($morelang > 1) {
		$yymain .= qq~
  <tr class="windowbg">
    <td class="windowbg" width="100%">
        <b>$register_txt{'101'}</b>
	</td>
        <td>
		<form action="$scripturl?action=register" method="post" name="sellanguage">
	        <select name="reglanguage" onchange="addsettings(); submit();">
		$langopt
		</select>
		<input type="hidden" name="tusername" id="tusername" value="" />
		<input type="hidden" name="temail" id="temail" value="" />
		<input type="hidden" name="tpasswrd1" id="tpasswrd1" value="" />
		<input type="hidden" name="tpasswrd2" id="tpasswrd2" value="" />
		<input type="hidden" name="thideemail" id="thideemail" value="" />
		<noscript><input type="submit" value="$maintxt{'32'}" /></noscript>
		</form>
	</td>
  </tr>
~;
	}
	$yymain .= qq~
  <tr class="windowbg">
    <td class="windowbg" width="100%">
        * <b>$register_txt{'98'}:</b>
        <br /><span class="small">$register_txt{'520'}</span>
	</td>
    <td>
		<form action="$scripturl?action=register2" method="post" name="creator">
		<input type="text" name="username" size="30" value="$tmpregname" maxlength="18"$regstyle />
		<input type="hidden" name="language" id="language" value="$language" />
	</td>
  </tr><tr class="windowbg">
    <td>* <b>$register_txt{'69'}:</b>
        <br /><span class="small">$register_txt{'679'}</span>
	</td>
~;
	if ($allow_hide_email == 1) {
		$yymain .= qq~
    <td valign="middle">
	    <input type="text" maxlength="60" name="email" value="$tmpregemail" size="45" />
	    <input type="checkbox" name="hideemail" value="checked"$hidechecked /> $register_txt{'721'}
	</td>
~;
	} else {
		$yymain .= qq~
    <td>
		<input type="text" name="email" size="50" />
        <br /><span class="small">$register_txt{'679'}</span>
	</td>
~;
	}
	$yymain .= qq~
  </tr>
~;
	unless ($emailpassword) {
		$yymain .= qq~
  <tr class="windowbg">
	<td>* <b>$register_txt{'81'}:</b></td>
    <td><input type="password" maxlength="30" name="passwrd1" value="$tmpregpasswrd1" size="30" /></td>
  </tr><tr class="windowbg">
    <td>* <b>$register_txt{'82'}:</b></td>
    <td><input type="password" maxlength="30" name="passwrd2" value="$tmpregpasswrd2" size="30" /></td>
  </tr>
~;
	}

	if ($regcheck) {
		require "$sourcedir/Decoder.pl";
		my @fields = newcaptcha ();
		while (@fields) {
			my $desc = shift @fields;
			my $cont = shift @fields;
			$yymain .= qq(
		<tr class="windowbg">
			<td><b>$desc</b></td>
			<td>$cont</td>
		</tr>);
		}
	}

	if ($RegAgree) {
		if ($language) {
			fopen(AGREE, "$langdir/$language/agreement.txt");
		} else {
			fopen(AGREE, "$langdir/$lang/agreement.txt");
		}
		@agreement = <AGREE>;
		fclose(AGREE);
		$fullagree = join("", @agreement);
		$fullagree =~ s/\n/<br \/>/g;
		$yymain .= qq~
  <tr>
	<td width="100%" colspan="2" class="windowbg">
		&nbsp;
	</td>
  </tr>
  <tr>
	<td width="100%" colspan="2" class="titlebg">
		<img src="$imagesdir/xx.gif" alt="$register_txt{'97'}" border="0" /> <b>$register_txt{'764a'}</b>
	</td>
  </tr>
  <tr>
	<td width="100%" colspan="2" class="windowbg2">
		<span style="float: left; padding: 5px;">
		<br />$fullagree<br /><br />
		</span>
	</td>
  </tr>
  <tr>
	<td width="100%" colspan="2" class="catbg" align="center">
		<b>$register_txt{'585'}</b> <input type="radio" name="regagree" value="yes" />
		&nbsp;&nbsp;&nbsp; <b>$register_txt{'586'}</b> <input type="radio" name="regagree" value="no" checked="checked" />
	</td>
  </tr>
  <tr>
	<td width="100%" colspan="2" class="windowbg">
		&nbsp;
	</td>
  </tr>

~;
	}

	$yymain .= qq~
  <tr class="titlebg">
	<td width="100%" colspan="2">
	<br /><center><input type="submit" value="$register_txt{'97'}" /></center>
	</td>
  </tr>
</table>
</div>
</form>
~;

	$yymain .= qq~


<script type="text/javascript" language="JavaScript"> <!--
	document.creator.username.focus();

	function addsettings() {
		var mailpass = $emailpassword;
		var hidemail = $allow_hide_email

		document.sellanguage.tusername.value = document.creator.username.value;
		document.sellanguage.temail.value = document.creator.email.value;
		if(hidemail == 1) {
			if(document.creator.hideemail.checked) document.sellanguage.thideemail.value = 1;
		}
		if(mailpass != 1) {
			document.sellanguage.tpasswrd1.value = document.creator.passwrd1.value;
			document.sellanguage.tpasswrd2.value = document.creator.passwrd1.value;
		}
	}
//--> </script>
~;
	$yytitle = "$register_txt{'97'}";
	&template;
	exit;
}

# sub reg_banning has been moved to Subs.pl

sub Register2 {
	if ($regdisable && $iamguest) { &fatal_error("$register_txt{'3'}"); }
	if ($FORM{'regagree'} eq "no") {
		$yySetLocation = qq~$scripturl~;
		&redirectexit;
	}
	my %member;
	while (($key, $value) = each(%FORM)) {
		$value =~ s~\A\s+~~;
		$value =~ s~\s+\Z~~;
		$value =~ s~[\n\r]~~g;
		$member{$key} = $value;
	}
	$member{'username'} =~ s/\s/_/g;

	# Make sure users can't register with banned details
	&reg_banning("$member{'username'}", "$member{'email'}");

	# check if there is a system hash named like this by checking existence through size
	my $hsize = keys(%{ $member{'username'} });
	if ($hsize > 0) { &fatal_error("Username prohibited by system"); }
	if (length($member{'username'}) > 25) { $member{'username'} = substr($member{'username'}, 0, 25); }
	&fatal_error("($member{'username'}) $register_txt{'37'}") if ($member{'username'} eq '');
	&fatal_error("($member{'username'}) $register_txt{'99'}") if ($member{'username'} eq '_' || $member{'username'} eq '|');
	&fatal_error("$register_txt{'244'} $member{'username'}") if ($member{'username'} =~ /guest/i);
	&fatal_error("$register_txt{'240'} $register_txt{'35'} $register_txt{'241'}") if ($member{'username'} !~ /\A[0-9A-Za-z#+-\.@^_]+\Z/);
	&fatal_error("$register_txt{'240'} $register_txt{'35'} $register_txt{'241'}") if ($member{'username'} =~ /,/);
	&fatal_error("($member{'username'}) $register_txt{'76'}")                     if ($member{'email'} eq "");
	&fatal_error("($member{'username'}) $register_txt{'100'}")                    if (-e ("$memberdir/$member{'username'}.vars"));
	&fatal_error("$register_txt{'1'}")                                            if ($member{'username'} eq $member{'passwrd1'});

	$testname    = lc $member{'username'};
	$testemail   = lc $member{'email'};
	$is_existing = lc &MemberIndex("check_exist", "$testname");
	if ($is_existing eq $testname) { &fatal_error("($member{'username'}) $register_txt{'473'}"); }
	$is_existing = lc &MemberIndex("check_exist", "$testemail");
	if ($is_existing eq $testemail) { &fatal_error("$register_txt{'730'} ($member{'email'}) $register_txt{'731'}"); }

	&ToHTML($member{'email'});

	if ($regcheck) {
		require "$sourcedir/Decoder.pl";
		if (not checkcaptcha ()) {
			&fatal_error ("$floodtxt{'4'}");
		}
	}

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
		&fatal_error("($member{'username'}) $register_txt{'213'}") if ($member{'passwrd1'} ne $member{'passwrd2'});
		&fatal_error("($member{'username'}) $register_txt{'91'}") if ($member{'passwrd1'} eq '');
		&fatal_error("$register_txt{'240'} $register_txt{'36'} $register_txt{'241'}") if ($member{'passwrd1'} !~ /\A[\s0-9A-Za-z!@#$%\^&*\(\)_\+|`~\-=\\:;'",\.\/?\[\]\{\}]+\Z/);
	}
	&fatal_error("$register_txt{'240'} $register_txt{'69'} $register_txt{'241'}") if ($member{'email'} !~ /[\w\-\.\+]+\@[\w\-\.\+]+\.(\w{2,4}$)/);
	&fatal_error("$register_txt{'500'}") if (($member{'email'} =~ /(@.*@)|(\.\.)|(@\.)|(\.@)|(^\.)|(\.$)/) || ($member{'email'} !~ /\A.+@\[?(\w|[-.])+\.[a-zA-Z]{2,4}|[0-9]{1,4}\]?\Z/));
	fopen(BAN, "$vardir/ban_email.txt");
	@banned = <BAN>;
	fclose(BAN);
	foreach $curban (@banned) {
		if ($member{'email'} eq "$curban") { &fatal_error("$register_txt{'678'}$register_txt{'430'}!"); }
	}

	fopen(RESERVE, "$vardir/reserve.txt") || &fatal_error("$register_txt{'23'} reserve.txt", 1);
	@reserve = <RESERVE>;
	fclose(RESERVE);
	fopen(RESERVECFG, "$vardir/reservecfg.txt") || &fatal_error("$register_txt{'23'} reservecfg.txt", 1);
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
				if ($namecheck eq $reservecheck) { &fatal_error("$register_txt{'244'} $reserved"); }
			} else {
				if ($namecheck =~ $reservecheck) { &fatal_error("$register_txt{'244'} $reserved"); }
			}
		}
	}

	&fatal_error("$register_txt{'100'})") if (-e ("$memberdir/$member{'username'}.vars"));
	if ($send_welcomeim == 1 && $preregister == 0) {
		$messageid = $^T . $$;
		fopen(IM, ">$memberdir/$member{'username'}.msg", 1);
		print IM "$sendname|$imsubject|$date|$imtext|$messageid|$ENV{'REMOTE_ADDR'}|1\n";
		fclose(IM);
	}
	$encryptopass = &encode_password($member{'passwrd1'});
	$reguser      = $member{'username'};
	$registerdate = &timetostring($date);
	$language     = $member{'language'};

        &ToHTML($member{'hideemail'});
        &ToHTML($member{'language'});

	${$uid.$reguser}{'password'}      = $encryptopass;
	${$uid.$reguser}{'realname'}      = $member{'username'};
	${$uid.$reguser}{'email'}         = lc($member{'email'});
	${$uid.$reguser}{'postcount'}     = 0;
	${$uid.$reguser}{'usertext'}      = $defaultusertxt;
	${$uid.$reguser}{'userpic'}       = "blank.gif";
	${$uid.$reguser}{'regdate'}       = $registerdate;
	${$uid.$reguser}{'regtime'}       = $date;
	${$uid.$reguser}{'timeselect'}    = $timeselected;
	${$uid.$reguser}{'timeoffset'}    = $timeoffset;
	${$uid.$reguser}{'dsttimeoffset'} = $dstoffset;
	${$uid.$reguser}{'hidemail'}      = $member{'hideemail'};
	${$uid.$reguser}{'timeformat'}    = qq~MM D+ YYYY @ HH:mm:ss*~;
	${$uid.$reguser}{'template'}      = $default_template;
	${$uid.$reguser}{'language'}      = $member{'language'};
	${$uid.$reguser}{'pageindex'}     = qq~1|1|1~;

	if ($preregister) {
		# If a pre-registration list exists load it
		if (-e "$memberdir/memberlist.inactive") {
			fopen(INACT, "$memberdir/memberlist.inactive");
			@reglist = <INACT>;
			fclose(INACT);
		}
		# check if user isn't already in pre-registration
		foreach $regline (@reglist) {
			chomp $regline;
			($dummy, $dummy, $regmember, $dummy) = split(/\|/, $regline);
			if ($reguser eq $regmember) { &fatal_error("$prereg_txt{'13'}"); last; }
		}

		# create pre-registration .pre file and write log and inactive list
		$regpassword = $member{'passwrd1'};
		$regtime     = int(time);
		require "$sourcedir/Decoder.pl";
		my ($sessionid, $regdate) = validation_code ();
		$activationcode = substr($sessionid, 0, 20);

		&UserAccount($reguser, "preregister");

		fopen(INACT, ">$memberdir/memberlist.inactive", 1);
		foreach $curreg (@reglist) { print INACT "$curreg\n"; }
		print INACT "$regtime|$activationcode|$reguser|$regpassword\n";
		fclose(INACT);
		fopen(REGLOG, ">>$vardir/registration.log", 1);
		print REGLOG "$regtime|N|$member{'username'}\n";
		fclose(REGLOG);
		&sendmail($member{'email'}, "$register_txt{'700'} $mbname", "$register_txt{'248'} $member{'username'}!\n\n$prereg_txt{'2'} $member{'username'}.\n\n$prereg_txt{'3'}.\n\n$prereg_txt{'4'}\n\n$scripturl?action=activate;username=$member{'username'};activationkey=$activationcode\n\n$register_txt{'130'}");

		$yymain .= qq~
		<br /><br />
		<table border="0" width="600" cellspacing="1" class="bordercolor" align="center">
		<tr>
		<td colspan="2" class="titlebg">
		<img src="$imagesdir/register.gif" alt="$prereg_txt{'1a'}" border="0" /> <span class="text1"><b>$prereg_txt{'1a'}</b></span></td>
		</tr><tr>
		<td colspan="2" class="windowbg" align="center">
		<br />$prereg_txt{'1'}<br /><br />
		</td>
		</tr>~;
		require "$sourcedir/LogInOut.pl";
		&sharedLogin;
		$yymain .= qq~
		</table>
		<br /><br />
		~;
		$yytitle = "$prereg_txt{'1a'}";
	} else {
		&UserAccount($reguser, "register") & MemberIndex("add", $reguser) & FormatUserName($reguser);
		if ($emailpassword) {
			&sendmail($member{'email'}, "$register_txt{'700'} $mbname", "$register_txt{'248'} $member{'username'}!\n\n$register_txt{'719'} $member{'username'}, $register_txt{'492'} $member{'passwrd1'}\n\n$register_txt{'701'}\n$scripturl?action=profileCheck;username=$useraccount{$member{'username'}}\n\n$register_txt{'130'}");
			require "$sourcedir/LogInOut.pl";
			$sharedLogin_title = "$register_txt{'97'}";
			$sharedLogin_text  = "$register_txt{'703'}";
			$yymain .= qq~<div class="bordercolor" style="width: 400px; margin-bottom: 8px; margin-left: auto; margin-right: auto;">~;
			$shared_log = &sharedLogin;
			$yymain .= qq~$shared_log~;
			$yymain .= qq~</div>~;
		} else {
			if ($emailwelcome) {
				&sendmail($member{'email'}, "$register_txt{'700'} $mbname", "$register_txt{'248'} $member{'username'}!\n\n$register_txt{'719'} $member{'username'}, $register_txt{'492'} $member{'passwrd1'}\n\n$register_txt{'701'}\n$scripturl?action=profileCheck;username=$useraccount{$member{'username'}}\n\n$register_txt{'130'}");
			}
			$yymain .= qq~
			<br /><br />
			<form action="$scripturl?action=login2" method="post">
			<table border="0" width="300" cellspacing="1" class="bordercolor" align="center">
			<tr>
			<td class="titlebg">
			<img src="$imagesdir/register.gif" alt="$register_txt{'97'}" border="0" /> <span class="text1"><b>$register_txt{'97'}</b></span></td>
			</tr><tr>
			<td class="windowbg" align="center">
			<br />$register_txt{'431'}<br /><br />
			<input type="hidden" name="username" value="$member{'username'}" />
			<input type="hidden" name="passwrd" value="$member{'passwrd1'}" />
			<input type="hidden" name="cookielength" value="$Cookie_Length" />
			<input type="submit" value="$register_txt{'34'}" />
			</td>
			</tr>
			</table>
			</form>
			<br /><br />
			~;
		}
		$yytitle = "$register_txt{'245'}";
	}
	&template;
	exit;
}

sub activation_check {
	$changed  = 0;
	$timer    = int(time);
	$timespan = $preregspan * 3600;
	fopen(INACT, "$memberdir/memberlist.inactive");
	@actlist = <INACT>;
	fclose(INACT);

	# check if user is in pre-registration and check activation key
	foreach $regline (@actlist) {
		($regtime, $dummy, $regmember, $dummy) = split(/\|/, $regline);
		$difftime = $timer - $regtime;
		if ($difftime > $timespan) {
			$changed = 1;
			unlink "$memberdir/$regmember.pre";

			# add entry to registration log
			fopen(REGLOG, ">>$vardir/registration.log", 1);
			print REGLOG "$timer|T|$regmember\n";
			fclose(REGLOG);
		} else {
			# update non activate user list
			# write valid registration to the list again
			push(@outlist, $regline);
		}
	}
	if ($changed) {
		# re-open inactive list for update if changed
		fopen(INACT, ">$memberdir/memberlist.inactive", 1);
		print INACT @outlist;
		fclose(INACT);
	}
}

sub user_activation {
	$changed       = 0;
	$reguser       = $INFO{'username'};
	$activationkey = $INFO{'activationkey'};
	if (!-e "$memberdir/$reguser.pre" && -e "$memberdir/$reguser.vars") { &fatal_error("$prereg_txt{'14a'}"); }
	if (!-e "$memberdir/$reguser.pre") { &fatal_error("$prereg_txt{'14'}"); }
	# If a pre-registration list exists load it
	if (-e "$memberdir/memberlist.inactive") {
		fopen(INACT, "$memberdir/memberlist.inactive");
		@reglist = <INACT>;
		fclose(INACT);
	}

	# check if user is in pre-registration and check activation key
	foreach $regline (@reglist) {
		($regtime, $testkey, $regmember, $regpassword) = split(/\|/, $regline);

		# update non activate user list
		if ($regmember ne $reguser) {
			push(@chnglist, $regline);
		} else {
			if ($activationkey ne $testkey) {
				push(@chnglist, $regline);
				# add entry to registration log
				my $logtime = int(time);
				fopen(REGLOG, ">>$vardir/registration.log", 1);
				print REGLOG "$logtime|E|$reguser\n";
				fclose(REGLOG);
				&fatal_error("$prereg_txt{'10'}");
			} else {
				$changed = 1;

				# user is in list and the keys match, so let him/her in
				rename("$memberdir/$reguser.pre", "$memberdir/$reguser.vars");
				&UserCheck($reguser, "email");
				&MemberIndex("add", $reguser);

				# add entry to registration log
				my $logtime = int(time);
				fopen(REGLOG, ">>$vardir/registration.log", 1);
				print REGLOG "$logtime|A|$reguser\n";
				fclose(REGLOG);
				if ($send_welcomeim == 1) {
					$messageid = $^T . $$;
					fopen(IM, ">$memberdir/$reguser.msg", 1);
					print IM "$sendname|$imsubject|$date|$imtext|$messageid|$ENV{'REMOTE_ADDR'}|1\n";
					fclose(IM);
				}
				if ($emailpassword) {
					LoadUser("$reguser");
					&sendmail(${$uid.$reguser}{'email'}, "$register_txt{'700'} $mbname", "$register_txt{'248'} $reguser!\n\n$register_txt{'719'} $reguser, $register_txt{'492'} $regpassword\n\n$register_txt{'701'}\n$scripturl?action=profileCheck;username=$reguser\n\n$register_txt{'130'}");
					$yymain .= qq~<br /><table border="0" width="100%" cellspacing="1" class="bordercolor" align="center">~;
					$sharedLogin_title = "$register_txt{'97'}";
					$sharedLogin_text  = "$register_txt{'703'}";
					$yymain .= qq~</table>~;
				} else {
					if ($emailwelcome) {
						LoadUser("$reguser");
						&sendmail(${$uid.$reguser}{'email'}, "$register_txt{'700'} $mbname", "$register_txt{'248'} $reguser!\n\n$register_txt{'719'} $reguser, $register_txt{'492'} $regpassword\n\n$register_txt{'701'}\n$scripturl?action=profileCheck;username=$reguser\n\n$register_txt{'130'}");
					}
				}
			}
		}
	}
	if ($changed) {
		# if changed write new inactive list
		fopen(INACT, ">$memberdir/memberlist.inactive");
		print INACT @chnglist;
		fclose(INACT);
	}
	$yymain .= qq~
	<br /><br />
	<table border="0" width="600" cellspacing="1" class="bordercolor" align="center">
	<tr>
	<td colspan="2" class="titlebg">
	<img src="$imagesdir/register.gif" alt="$prereg_txt{'1a'}" border="0" /> <span class="text1"><b>$prereg_txt{'1a'}</b></span></td>
	</tr><tr>
	<td colspan="2" class="windowbg" align="center">
	<br />$prereg_txt{'5'}<br /><br />~;
	if ($emailpassword eq "1") {
		$yymain .= qq~$register_txt{'703'}<br /> <br />~;
	}
	$yymain .= qq~
	</td>
	</tr>~;
	require "$sourcedir/LogInOut.pl";
	&sharedLogin;
	$yymain .= qq~
	</table>
	<br /><br />
	~;
	$yytitle = "$prereg_txt{'5'}";
	&template;
	exit;
}

1;
