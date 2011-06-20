###############################################################################
# Profile.pl                                                                  #
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

$profileplver = 'YaBB 2.1 $Revision: 1.15 $';
if ($action eq 'detailedversion') { return 1; }

LoadLanguage("Profile");
if (!$parseflash) { LoadLanguage("Display"); }

if (-e "$vardir/gmodsettings.txt") { require "$vardir/gmodsettings.txt"; }

# If someone registers with a '+' in their name It causes problems.
# Get's turned into a <space> in the query string Change it back here.
# Users who register with spaces get them replaced with _
# So no problem there.
$INFO{'username'} =~ tr/ /+/;

sub ProfileCheck {
	my $user = $INFO{'username'};
	if (!${$uid.$user}{'password'}) { &LoadUser($user); }
	if ($iamguest) { &fatal_error($profile_txt{'1'}); }
	if ($user =~ m~/~)  { &fatal_error($profile_txt{'224'}); }
	if ($user =~ m~\\~) { &fatal_error($profile_txt{'225'}); }

	if ($user ne $username && !$iamadmin && !$iamgmod) {
		&fatal_error($profile_txt{'80'});
	}

	if ($iamgmod && ${$uid.$user}{'position'} eq "Administrator") {
		&fatal_error($profile_txt{'80'});
	}

	if ($iamgmod && $user ne $username && !$allow_gmod_profile) {
		&fatal_error($profile_txt{'80'});
	}

	if ($user eq "admin" && $username ne "admin") {
		&fatal_error($profile_txt{'80'});
	}

	if (!-e ("$memberdir/$user.vars")) { &fatal_error("$profile_txt{'453'}"); }

	$yymain .= qq~
		<div class="bordercolor" style="width: 400px; margin-bottom: 8px; margin-left: auto; margin-right: auto;">
		<table cellpadding="4" cellspacing="1" border="0" width="100%" align="center">
		<tr><td class="titlebg" colspan="2"><b>$profile_txt{'901'}</b></td></tr>
		
		<tr><td class="windowbg2" colspan="2" valign="middle">
		
        <form action="$scripturl?action=profileCheck2;username=$INFO{'username'}" method="post">
		<div style="clear: both; padding-top: 4px; margin-left: auto; margin-right: auto; width: 370px;">
			<span style="float: left; width: 100%; text-align: center; align: center;">
				<input type="password" name="passwrd" size="15" style="width: 150px;" tabindex="2" />
			</span>
		</div>
		<div style="clear: both; margin-top: 35px; margin-left: auto; margin-right: auto; width: 310px;">
			<span style="float: left; width: 100%; text-align: center;">
				<input type="submit" value="$profile_txt{'900'}" tabindex="5" accesskey="l" style="width: 140px;" />
			</span>
		</div>
        </form>
       </td>
      </tr>
	</table>
</div>
~;

	$yytitle = "$profile_txt{'900'}";
	&template;
}

sub ProfileCheck2 {
	my $user     = $INFO{'username'};
	my $new_pass = $FORM{'passwrd'};
	if (!${$uid.$user}{'password'}) { &LoadUser($user); }
	if ($iamguest) { &fatal_error($profile_txt{'1'}); }
	if ($user =~ m~/~)  { &fatal_error($profile_txt{'224'}); }
	if ($user =~ m~\\~) { &fatal_error($profile_txt{'225'}); }

	if (!-e ("$memberdir/$user.vars")) { &fatal_error("$profile_txt{'453'}"); }

	if ($user ne $username && !$iamadmin && !$iamgmod) {
		&fatal_error($profile_txt{'80'});
	}

	if ($iamgmod && $user ne $username && !$allow_gmod_profile) {
		&fatal_error($profile_txt{'80'});
	}

	if ($user eq "admin" && $username ne "admin") {
		&fatal_error($profile_txt{'80'});
	}

	if ($user eq $username) {
		if (&encode_password($new_pass) ne ${$uid.$user}{'password'}) {
			&fatal_error("$profile_txt{'822'}");
		}
	}

	if (($iamadmin || ($iamgmod && $allow_gmod_profile))) {
		if (&encode_password($new_pass) ne ${$uid.$username}{'password'}) {
			&fatal_error("$profile_txt{'897'}");
		}
	}

	# Get a semi-secure SID - only profile changes, so not full sessions
	# People would complain that they had to update their session otherwise
	$sid = reverse(substr(int(time), 6, 4));
	$yySetLocation = qq~$scripturl?action=profile;username=$user;sid=$sid~;
	&redirectexit;
}

sub PrepareProfile {

	my $user = $INFO{'username'};
	if (!${$uid.$user}{'password'}) { &LoadUser($user); }
	if ($iamguest) { &fatal_error($profile_txt{'1'}); }

	if ($iamgmod && (${$uid.$user}{'position'} eq "Administrator" || ${$uid.$user}{'position'} eq "Administrator")) {
		&fatal_error($profile_txt{'80'});
	}

	if ($user =~ m~/~)  { &fatal_error($profile_txt{'224'}); }
	if ($user =~ m~\\~) { &fatal_error($profile_txt{'225'}); }

	if ($user ne $username && !$iamadmin && !$iamgmod) {
		&fatal_error($profile_txt{'80'});
	}

	if ($iamgmod && $user ne $username && !$allow_gmod_profile) {
		&fatal_error($profile_txt{'80'});
	}

	if ($user eq "admin" && $username ne "admin") {
		&fatal_error($profile_txt{'80'});
	}

	if (!-e ("$memberdir/$user.vars")) { &fatal_error("$profile_txt{'453'}"); }
	if ($allowpics) {
		opendir(DIR, "$facesdir") || fatal_error("$profile_txt{'230'} ($facesdir)!<br \/>$profile_txt{'681'}", 1);
		closedir(DIR);
	}
	$dr = ${$uid.$user}{'regdate'} ? ${$uid.$user}{'regdate'} : $forumstart;
	$dr =~ m~(\d{2})\/(\d{2})\/(\d{2,4}).*?(\d{2})\:(\d{2})\:(\d{2})~is;
	$dr_month = $1;
	$dr_day = $2;
	$dr_year = $3;
	$dr_hour = $4;
	$dr_minute = $5;
	$dr_secund = $6;

	if (${$uid.$user}{'gender'} eq 'Male')   { $GenderMale   = ' selected="selected" '; }
	if (${$uid.$user}{'gender'} eq 'Female') { $GenderFemale = ' selected="selected" '; }
	&FromHTML(${$uid.$user}{'signature'});
	$signature = ${$uid.$user}{'signature'};
	&ToChars($signature);
	$signature =~ s/\&\&/\n/g;
	$signature =~ s/</&lt;/g;
	$signature =~ s/>/&gt;/g;

	&CalcAge($user, "parse");
	${$uid.$user}{'aim'} =~ tr/+/ /;
	${$uid.$user}{'yim'} =~ tr/+/ /;

	if    (${$uid.$user}{'timeselect'} == 7) { $tsl7 = ' selected="selected" '; }
	elsif (${$uid.$user}{'timeselect'} == 6) { $tsl6 = ' selected="selected" '; }
	elsif (${$uid.$user}{'timeselect'} == 5) { $tsl5 = ' selected="selected" '; }
	elsif (${$uid.$user}{'timeselect'} == 4) { $tsl4 = ' selected="selected" '; }
	elsif (${$uid.$user}{'timeselect'} == 3) { $tsl3 = ' selected="selected" '; }
	elsif (${$uid.$user}{'timeselect'} == 2) { $tsl2 = ' selected="selected" '; }
	elsif (${$uid.$user}{'timeselect'} == 1) { $tsl1 = ' selected="selected" '; }
	elsif (${$uid.$user}{'timeselect'} == 0) { $tsl0 = ' selected="selected" '; }
	elsif ($timeselected == 7)                   { $tsl7 = ' selected="selected" '; }
	elsif ($timeselected == 6)                   { $tsl6 = ' selected="selected" '; }
	elsif ($timeselected == 5)                   { $tsl5 = ' selected="selected" '; }
	elsif ($timeselected == 4)                   { $tsl4 = ' selected="selected" '; }
	elsif ($timeselected == 3)                   { $tsl3 = ' selected="selected" '; }
	elsif ($timeselected == 2)                   { $tsl2 = ' selected="selected" '; }
	elsif ($timeselected == 1)                   { $tsl1 = ' selected="selected" '; }
	else { $tsl0 = ' selected="selected" '; }
	$pddd = ((${$uid.$user}{'timeoffset'} * 10) + 120);
	$pdel{$pddd} = ' selected="selected"';

	$dayormonthm = qq~$profile_txt{'564'}<input type="text" name="bday1" size="2" maxlength="2" value="$umonth" />~;
	$dayormonthd = qq~$profile_txt{'565'}<input type="text" name="bday2" size="2" maxlength="2" value="$uday" />~;
	if ($tsl2 || $tsl3 || $tsl6) { $dayormonth = $dayormonthd . $dayormonthm; }
	else { $dayormonth = $dayormonthm . $dayormonthd; }

	$proftime = &timeformat((time + (3600 * $timeoffset) - (${$uid.$user}{'timeoffset'} * 3600)), 1);
	@menucolors = qw(catbg catbg catbg catbg catbg);
}

sub ProfileMenu {

	my $user = $INFO{'username'};

	$yymain .= qq~

      <table cellspacing="1" cellpadding="4" width="100%" border="0" class="bordercolor">
        <tr>
          <td class="$menucolors[0]" valign="bottom" align="center" width="16%"><span class="small"><b><a href="$scripturl?action=profile;username=$INFO{'username'};sid=$INFO{'sid'}">$profile_txt{79}</a></b></span></td>
          <td class="$menucolors[1]" valign="bottom" align="center" width="16%"><span class="small"><b><a href="$scripturl?action=profileContacts;username=$INFO{'username'};sid=$INFO{'sid'}">$profile_txt{819}</a></b></span></td>
          <td class="$menucolors[2]" valign="bottom" align="center" width="16%"><span class="small"><b><a href="$scripturl?action=profileOptions;username=$INFO{'username'};sid=$INFO{'sid'}">$profile_txt{818}</a></b></span></td>
          <td class="$menucolors[3]" valign="bottom" align="center" width="16%"><span class="small"><b><a href="$scripturl?action=profileIM;username=$INFO{'username'};sid=$INFO{'sid'}">$profile_imtxt{56} $profile_txt{323}</a></b></span></td>~;
	if ($iamadmin) {
		$yymain .= qq~
          <td class="$menucolors[4]" valign="bottom" width="16%" align="center"><span class="small"><b><a href="$scripturl?action=profileAdmin;username=$INFO{'username'};sid=$INFO{'sid'}">$profile_txt{820}</a></b></span></td>~;
	}

	if ($iamgmod && $allow_gmod_profile && $gmod_access2{"profileAdmin"} eq "on") {
		$yymain .= qq~
          <td class="$menucolors[4]" valign="bottom" width="16%" align="center"><span class="small"><b><a href="$scripturl?action=profileAdmin;username=$INFO{'username'};sid=$INFO{'sid'}">$profile_txt{820}</a></b></span></td>~;
	}

	$yymain .= qq~
        </tr>
      </table>
<br />
~;
}

sub ModifyProfile {
	&SidCheck;

	&PrepareProfile;
	my $user = $INFO{'username'};
	if (!${$uid.$user}{'password'}) { &LoadUser($user); }
	$menucolors[0] = "titlebg";
	&ProfileMenu;
	if ($iamadmin) {
		$confdel_text = "$profile_txt{'775'} $profile_txt{'777'} $INFO{'username'} $profile_txt{'778'}";
		if ($user eq $username) {
			$passtext = qq~$profile_txt{'821'}~;
		} else {
			$passtext = qq~$profile_txt{'2'} $profile_txt{'36'}~;
		}
	} else {
		$confdel_text = "$profile_txt{'775'} $profile_txt{'776'} $profile_txt{'778'}";
		$passtext     = qq~$profile_txt{'821'}~;
	}

	$passtext .= qq~<br /><span class="small" style="font-weight: normal;">$profile_txt{'895'}</span>~;
	$yymain   .= qq~
<form action="$scripturl?action=profile2;username=$INFO{'username'};sid=$INFO{'sid'}" method="post" name="creator">
<table cellspacing="1" cellpadding="4" width="100%" align="center" class="bordercolor" border="0">
  <tr>
    <td class="catbg" colspan="2"><img src="$imagesdir/profile.gif" alt="" border="0" /> <b>$profile_txt{79} ($INFO{'username'})</b><br /><span class="small">$profile_txt{'698'}</span></td>
  </tr><tr class="windowbg">
   <td width="220" align="left"><b>$profile_txt{81}: </b><br />
<span class="small">$profile_txt{'896'}</span>
</td>
   <td align="left"><input type="password" maxlength="30" name="passwrd1" size="20" /></td>
 </tr><tr class="windowbg">
   <td width="220" align="left"><b>$profile_txt{82}: </b><br />
<span class="small">$profile_txt{'896'}</span>
</td>
   <td align="left"><input type="password" maxlength="30" name="passwrd2" size="20" /></td>
 </tr><tr class="windowbg">
   <td width="220" align="left"><b>$profile_txt{68}: </b></td>
   <td align="left"><input type="text" maxlength="30" name="name" size="30" value="${$uid.$user}{'realname'}" /></td>
 </tr><tr class="windowbg">
   <td width="220" align="left"><b>$profile_txt{231}: </b></td>
   <td align="left"><select name="gender" size="1"><option value=""></option><option value="Male"$GenderMale>$profile_txt{'238'}</option><option value="Female"$GenderFemale>$profile_txt{'239'}</option></select></td>
 </tr><tr class="windowbg">
   <td width="220" align="left"><b>$profile_txt{'563'}: </b></td>
   <td align="left"><span class="small">$dayormonth$profile_txt{'566'}<input type="text" name="bday3" size="4" maxlength="4" value="$uyear" /></span></td>
 </tr><tr class="windowbg">
   <td width="220" align="left"><b>$profile_txt{'227'}: </b></td>
   <td align="left"><input type="text" maxlength="30" name="location" size="50" value="${$uid.$user}{'location'}" /></td>
 </tr>
~;
	if ($sessions == 1 && $sessionvalid == 1 && ($iamadmin || $iamgmod || $iammod) && $username eq $user) {
		&LoadLanguage("Sessions");
		my $decanswer = &descramble(${$uid.$user}{'sesanswer'}, $user);
		$questsel = qq~<select name="sesquest" size="1">\n~;
		while (($key, $val) = each %sesquest_txt) {
			if (${$uid.$user}{'sesquest'} eq $key && ${$uid.$user}{'sesquest'} ne "") {
				$sessel = qq~ selected="selected"~;
			} elsif ($key eq "password" && ${$uid.$user}{'sesquest'} eq "") {
				$sessel = qq~ selected="selected"~;
			} else {
				$sessel = "";
			}
			$questsel .= qq~<option value="$key"$sessel>$val</option>\n~;
		}
		$questsel .= qq~</select>\n~;
		$yymain   .= qq~
  <tr>
    <td class="catbg" colspan="2"><img src="$imagesdir/session.gif" alt="" border="0" /> <b>$img_txt{'34a'}</b><br /><span class="small">$session_txt{'9'}<br />$session_txt{'9a'}</span></td>
  </tr><tr class="windowbg">
	   <td width="220" align="left">$questsel</td>
	   <td align="left"><input type="text" maxlength="30" name="sesanswer" size="20" value="$decanswer" /></td>
	 </tr>~;
	}
	$yymain .= qq~
<tr class="catbg">
   <td height="30" valign="middle" align="center" colspan="2"><input type="submit" name="moda" value="$profile_txt{'88'}" /> <input type="submit" name="moda" value="$profile_txt{'89'}" onclick="return confirm('$confdel_text')" /></td>
 </tr>
</table>
</form>
~;
	$yytitle = $profile_txt{'79'};
	&template;
	exit;
}

sub ModifyProfileContacts {
	&SidCheck;

	&PrepareProfile;
	my $user = $INFO{'username'};
	if (!${$uid.$user}{'password'}) { &LoadUser($user); }
	$menucolors[1] = "titlebg";
	&ProfileMenu;
	$yymain .= qq~
<form action="$scripturl?action=profileContacts2;username=$INFO{'username'};sid=$INFO{'sid'}" method="post" name="creator">
<table cellspacing="1" cellpadding="4" width="100%" align="center" class="bordercolor" border="0">
  <tr>
    <td colspan="2" class="catbg"><img src="$imagesdir/profile.gif" alt="" border="0" /> <b>$profile_txt{79} ($INFO{'username'}) &rsaquo; $profile_txt{819}</b></td>
  </tr><tr class="windowbg">
    <td width="320" align="left"><b>$profile_txt{'69'}: </b><br /><span class="small">$profile_txt{'679'} </span></td>
    <td align="left"><input type="text" maxlength="60" name="email" size="40" value="${$uid.$user}{'email'}" /></td>
  </tr>~;
	if ($allow_hide_email) {
		my $checked = '';
		if (${$uid.$user}{'hidemail'} eq 'checked') { $checked = 'checked="checked"'; }
		$yymain .= qq~<tr class="windowbg">
          <td width="320" align="left"><b>$profile_txt{'721'}</b></td>
          <td align="left"><input type="checkbox" name="hideemail" value="checked" $checked /></td>
        </tr>~;
	}
	$yymain .= qq~<tr class="windowbg">
     <td width="320" align="left"><b>$profile_txt{'513'}: </b><br /><span class="small">$profile_txt{'600'}</span></td>
     <td align="left"><input type="text" maxlength="10" name="icq" size="40" value="${$uid.$user}{'icq'}" /></td>
   </tr><tr class="windowbg">
     <td width="320" align="left"><b>$profile_txt{'603'}: </b><br /><span class="small">$profile_txt{'601'}</span></td>
     <td align="left"><input type="text" maxlength="30" name="aim" size="40" value="${$uid.$user}{'aim'}" /></td>
   </tr><tr class="windowbg">
     <td width="320"><b>$profile_txt{'604'}: </b><br /><span class="small">$profile_txt{'602'}</span></td>
     <td align="left"><input type="text" maxlength="30" name="yim" size="40" value="${$uid.$user}{'yim'}" /></td>
   </tr><tr class="windowbg">
     <td width="320"><b>$profile_txt{'823'}: </b><br /><span class="small">$profile_txt{'824'}</span></td>
     <td align="left"><input type="text" maxlength="50" name="msn" size="40" value="${$uid.$user}{'msn'}" /></td>
   </tr><tr class="windowbg">
     <td width="320"><b>$profile_txt{'825'}: </b><br /><span class="small">$profile_txt{'826'}</span></td>
     <td align="left"><input type="text" maxlength="50" name="gtalk" size="40" value="${$uid.$user}{'gtalk'}" /></td>
   </tr><tr class="windowbg">
     <td width="320" align="left"><b>$profile_txt{'83'}: </b><br /><span class="small">$profile_txt{'598'}</span></td>
     <td align="left"><input type="text" maxlength="30" name="webtitle" size="50" value="${$uid.$user}{'webtitle'}" /></td>
   </tr><tr class="windowbg">
     <td width="320" align="left"><b>$profile_txt{'84'}: </b><br /><span class="small">$profile_txt{'599'}</span></td>
     <td align="left"><input type="text" name="weburl" size="50" value="${$uid.$user}{'weburl'}" /></td>
   </tr><tr class="catbg">
     <td height="30" valign="middle" align="center" colspan="2"><input type="submit" name="moda" value="$profile_txt{'88'}" /></td>
   </tr>
</table>
</form>
~;
	$yytitle = "$profile_txt{'79'} $profile_txt{'819'}";
	&template;
	exit;
}

sub ModifyProfileOptions {
	&SidCheck;

	&PrepareProfile;
	my $user = $INFO{'username'};
	if (!${$uid.$user}{'password'}) { &LoadUser($user); }
	$menucolors[2] = "titlebg";
	&ProfileMenu;
	&ToChars(${$uid.$user}{'usertext'});
	$yymain .= qq~
<form action="$scripturl?action=profileOptions2;username=$INFO{'username'};sid=$INFO{'sid'}" method="post" name="creator">
<table cellspacing="1" cellpadding="4" width="100%" align="center" class="bordercolor" border="0">
  <tr>
    <td colspan="2" class="catbg"><img src="$imagesdir/profile.gif" alt="" border="0" /><b>$profile_txt{'79'} ($INFO{'username'}) &rsaquo; $profile_txt{818}</b></td>
  </tr><tr class="windowbg">~;

	if ($allowpics) {
		opendir(DIR, "$facesdir") || fatal_error("$profile_txt{'230'} ($facesdir)!<br />$profile_txt{'681'}", 1);
		@contents = readdir(DIR);
		closedir(DIR);
		$images = "";
		foreach $line (sort @contents) {
			($name, $extension) = split(/\./, $line);
			$checked = "";
			if ($line eq ${$uid.$user}{'userpic'}) { $checked = ' selected="selected"'; }
			if (${$uid.$user}{'userpic'} =~ m~\Ahttp://~ && $line eq 'blank.gif') { $checked = ' selected="selected" '; }
			if ($extension =~ /gif/i || $extension =~ /jpg/i || $extension =~ /jpeg/i || $extension =~ /png/i) {
				if ($line eq 'blank.gif') {
					$images = qq~              <option value="$line"$checked>$profile_txt{'422'}</option>\n$images~;
				} else {
					$images .= qq~              <option value="$line"$checked>$name</option>\n~;
				}
			}
		}
		if (${$uid.$user}{'userpic'} =~ m~\Ahttp://~) {
			$pic     = 'blank.gif';
			$checked = ' checked="checked" ';
			$tmp     = ${$uid.$user}{'userpic'};
		} else {
			$pic = ${$uid.$user}{'userpic'};
			$tmp = 'http://';
		}

		if(${$uid.$user}{'dsttimeoffset'}) { $dsttimechecked = qq~ checked="checked"~; }

		$yymain .= qq~
          <td width="320" align="left"><b>$profile_txt{'229'}:</b><br /><span class="small">$profile_txt{'474'}</span></td>
          <td align="left">
            <script language="JavaScript1.2" type="text/javascript">
            function showimage()
            {
              if (!document.images) return;
              document.images.icons.src="$facesurl/"+document.creator.userpic.options[document.creator.userpic.selectedIndex].value;
            }
            </script>
            <select name="userpic" size="6" onchange="showimage()">
$images            </select>
            &nbsp;&nbsp;<img src="$facesurl/$pic" name="icons" border="0" hspace="15" alt="" />
          </td>
        </tr><tr class="windowbg">
          <td width="320" align="left"><b>$profile_txt{'475'}</b></td>
          <td align="left"><input type="checkbox" name="userpicpersonalcheck" $checked />&nbsp;<input type="text" name="userpicpersonal" size="45" value="$tmp" /></td>
        </tr>~;
	}

	$yymain .= qq~<tr class="windowbg">
          <td width="320" align="left"><b>$profile_txt{'228'}: </b></td>
          <td align="left"><input type="text" name="usertext" size="50" value="${$uid.$user}{'usertext'}" maxlength="50" /></td>
        </tr><tr class="windowbg">
          <td width="320" align="left"><b>$profile_txt{'85'}:</b><br /><span class="small">$profile_txt{'606'}</span></td>
          <td align="left"><textarea name="signature" rows="4" cols="50">$signature</textarea><br />
            <span class="small">$profile_txt{'664'} <input value="$MaxSigLen" size="3" name="msgCL" disabled="disabled" /></span><br /><br />
            <script type="text/javascript" language="JavaScript">
            <!--
            var supportsKeys = false
            function tick() {
              calcCharLeft(document.forms[0])
              if (!supportsKeys) timerID = setTimeout("tick()",$MaxSigLen)
            }

            function calcCharLeft(sig) {
              clipped = false
              maxLength = $MaxSigLen
              if (document.creator.signature.value.length > maxLength) {
                document.creator.signature.value = document.creator.signature.value.substring(0,maxLength)
                charleft = 0
                clipped = true
              } else {
                charleft = maxLength - document.creator.signature.value.length
              }
              document.creator.msgCL.value = charleft
              return clipped
            }

            tick();
            //-->
            </script>
          </td>
        </tr><tr class="windowbg">
          <td width="320" align="left"><b>$profile_txt{'486'}:</b><br />
            <span class="small">$profile_txt{'479'}</span></td>
          <td width="50" align="left">
            <select name="usertimeselect" size="1">
              <option value="1"$tsl1>$profile_txt{'480'}</option>
              <option value="5"$tsl5>$profile_txt{'484'}</option>
              <option value="4"$tsl4>$profile_txt{'483'}</option>
              <option value="2"$tsl2>$profile_txt{'481'}</option>
              <option value="3"$tsl3>$profile_txt{'482'}</option>
              <option value="6"$tsl6>$profile_txt{'485'}</option>
              <option value="7"$tsl7>$profile_txt{'480a'}</option>
            </select>
          </td>
       </tr><tr class="windowbg">
          <td width="320" align="left"><b>$profile_txt{'486a'}:</b><br />
            <span class="small">$profile_txt{'479a'}</span></td>
           <td align="left"><input type="text" name="timeformat" size="40" value="${$uid.$user}{'timeformat'}" /></td>
        </tr><tr class="windowbg">
          <td width="320" align="left"><b>$profile_txt{'371'}:</b><br /><span class="small">$profile_txt{'519'}</span></td>
          <td align="left"><span class="small"><select name="usertimeoffset">
		<option value="">$time_zone_txt{'1'}</option>
		<option value="12"$pdel{'240'}>$time_zone_txt{'2'}</option>
		<option value="11"$pdel{'230'}>$time_zone_txt{'3'}</option>
		<option value="10"$pdel{'220'}>$time_zone_txt{'4'}</option>
		<option value="9.5"$pdel{'215'}>$time_zone_txt{'5'}</option>
		<option value="9"$pdel{'210'}>$time_zone_txt{'6'}</option>
		<option value="8"$pdel{'200'}>$time_zone_txt{'7'}</option>
		<option value="6.5"$pdel{'185'}>$time_zone_txt{'9'}</option>
		<option value="6"$pdel{'180'}>$time_zone_txt{'10'}</option>
		<option value="5.5"$pdel{'175'}>$time_zone_txt{'11'}</option>
		<option value="5"$pdel{'170'}>$time_zone_txt{'12'}</option>
		<option value="4"$pdel{'160'}>$time_zone_txt{'13'}</option>
		<option value="3.5"$pdel{'155'}>$time_zone_txt{'14'}</option>
		<option value="3"$pdel{'150'}>$time_zone_txt{'15'}</option>
		<option value="2"$pdel{'140'}>$time_zone_txt{'16'}</option>
		<option value="1"$pdel{'130'}>$time_zone_txt{'17'}</option>
		<option value="0"$pdel{'120'}>$time_zone_txt{'18'}</option>
		<option value="-1"$pdel{'110'}>$time_zone_txt{'19'}</option>
		<option value="-2"$pdel{'100'}>$time_zone_txt{'20'}</option>
		<option value="-3"$pdel{'90'}>$time_zone_txt{'21'}</option>
		<option value="-3.5"$pdel{'85'}>$time_zone_txt{'22'}</option>
		<option value="-4"$pdel{'80'}>$time_zone_txt{'23'}</option>
		<option value="-5"$pdel{'70'}>$time_zone_txt{'24'}</option>
		<option value="-6"$pdel{'60'}>$time_zone_txt{'25'}</option>
		<option value="-7"$pdel{'50'}>$time_zone_txt{'26'}</option>
		<option value="-8"$pdel{'40'}>$time_zone_txt{'27'}</option>
		<option value="-9"$pdel{'30'}>$time_zone_txt{'28'}</option>
		<option value="-10"$pdel{'20'}>$time_zone_txt{'29'}</option>
		<option value="-11"$pdel{'10'}>$time_zone_txt{'30'}</option>
		</select><br />$profile_txt{'741'}: <i>$proftime</i></span></td>
       </tr><tr class="windowbg">
          <td width="320" align="left"><b>$profile_txt{'519a'}</b></td>
          <td align="left"><input type="checkbox" name="dsttimeoffset"$dsttimechecked /></td>
        </tr>
~;
	&CheckNewTemplates;

	unless ($templatesloaded == 1) { require "$vardir/template.cfg"; }

	while (($curtemplate, $value) = each(%templateset)) {
		$selected = "";
		if ($curtemplate eq ${$uid.$user}{'template'}) { $selected = qq~ selected="selected"~; $akttemplate = $curtemplate; }
		$drawndirs .= qq~<option value="$curtemplate"$selected>$curtemplate</option>\n~;
	}

	$yymain .= qq~<tr class="windowbg">
          <td width="320" align="left"><b>$profile_txt{'814'}</b></td>
          <td align="left"><select name="usertemplate">$drawndirs</select></td>
        </tr>~;

	opendir(dir, $langdir);
	my @lfilesanddirs = readdir(dir);
	close(dir);
	foreach $fld (@lfilesanddirs) {
		if (-d "$langdir/$fld" && $fld =~ m^\A[0-9a-zA-Z_\#\%\-\:\+\?\$\&\~\,\@/]+\Z^ && -e "$langdir/$fld/Main.lng") {
			if (${$uid.$user}{'language'} eq $fld) { $drawnldirs .= qq~<option value="$fld" selected="selected">$fld</option>~; }
			else { $drawnldirs .= qq~<option value="$fld">$fld</option>~; }
		}
	}

	$yymain .= qq~<tr class="windowbg">
          <td width="320" align="left"><b>$profile_txt{'817'}</b></td>
          <td align="left"><select name="userlanguage">$drawnldirs</select></td>
        </tr><tr class="catbg">
          <td height="30" valign="middle" align="center" colspan="2"><input type="submit" name="moda" value="$profile_txt{'88'}" /></td>
        </tr>
      </table>
</form>
~;
	$yytitle = "$profile_txt{'79'} $profile_txt{'818'}";
	&template;
	exit;
}

sub ModifyProfileIM {
	&SidCheck;

	&PrepareProfile;
	my $user = $INFO{'username'};
	if (!${$uid.$user}{'password'}) { &LoadUser($user); }
	$menucolors[3] = "titlebg";
	&ProfileMenu;

	${$uid.$user}{'im_ignorelist'} =~ s/[\n\r]//g;
	${$uid.$user}{'im_ignorelist'} =~ s/\|/\n/g;
	${$uid.$user}{'im_notify'}     =~ s/[\n\r]//g;
	if (${$uid.$user}{'im_notify'}) {
		$sel0 = '';
		$sel1 = ' selected="selected"';
	} else {
		$sel0 = ' selected="selected"';
		$sel1 = '';
	}

	$yymain .= qq~
<form action="$scripturl?action=profileIM2;username=$INFO{'username'};sid=$INFO{'sid'}" method="post" name="creator">
<table cellspacing="1" cellpadding="4" width="100%" align="center" class="bordercolor" border="0">
 <tr>
   <td colspan="2" class="catbg"><img src="$imagesdir/profile.gif" alt="" border="0" /><b>$profile_txt{79} ($INFO{'username'}) &rsaquo; $profile_imtxt{38}</b></td>
 </tr><tr class="windowbg">
   <td valign="top"><b>$profile_txt{'325'}:</b><br /><span class="small">$profile_txt{'326'}</span></td>
   <td><textarea name="ignore" rows="4" cols="50">${$uid.$user}{'im_ignorelist'}</textarea></td>
 </tr>~;
	if ($enable_notification) {
		$yymain .= qq~<tr class="windowbg">
   <td valign="top"><b>$profile_txt{'327'}:</b></td>
   <td><select name="notify"><option value="0" $sel0>$profile_txt{'164'}</option><option value="1"$sel1>$profile_txt{'163'}</option></select></td>
 </tr>~;
	} else {
		$yymain .= qq~<input type="hidden" name="notify" value="${$uid.$user}{'im_notify'}" />~;
	}

	chomp(${$uid.$user}{'im_popup'});
	chomp(${$uid.$user}{'im_imspop'});
	if (${$uid.$user}{'im_popup'}  eq "on") { $enable_userimpopup = 'checked="checked"'; }
	if (${$uid.$user}{'im_imspop'} eq "on") { $popup_userim       = 'checked="checked"'; }
	$yymain .= qq~<tr class="windowbg">
    <td width="320"><b>$profile_imtxt{'53'}</b></td>
    <td><input type="checkbox" name="popupims" $popup_userim /></td>
  </tr><tr class="windowbg">
    <td width="320"><b>$profile_imtxt{'05'}</b></td>
    <td><input type="checkbox" name="userpopup" $enable_userimpopup /></td>
  </tr><tr class="catbg">
    <td height="30" valign="middle" align="center" colspan="2"><input type="submit" name="moda" value="$profile_txt{'88'}" /></td>
 </tr>
</table>
</form>
~;
	$yytitle = "$profile_txt{'323'}: $profile_txt{'144'}";
	&template;
	exit;
}

sub ModifyProfileAdmin {
	&SidCheck;

	&is_admin_or_gmod;
	&PrepareProfile;
	my $user = $INFO{'username'};
	if (!${$uid.$user}{'password'}) { &LoadUser($user); }

	$menucolors[4] = "titlebg";
	&ProfileMenu;

	($MemStatAdmin, $MemStarNumAdmin, $MemStarPicAdmin, $MemTypeColAdmin) = split(/\|/, $Group{"Administrator"});
	($MemStatGMod,  $MemStarNumGMod,  $MemStarPicGMod,  $MemTypeColGMod)  = split(/\|/, $Group{"Global Moderator"});
	($MemStatMod,   $MemStarNumMod,   $MemStarPicMod,   $MemTypeColMod)   = split(/\|/, $Group{"Moderator"});

	if    (${$uid.$user}{'position'} eq 'Administrator')    { $tt = $MemStatAdmin; }
	elsif (${$uid.$user}{'position'} eq 'Global Moderator') { $tt = $MemStatGMod; }
	elsif (${$uid.$user}{'position'}) { $ttgrp = ${$uid.$user}{'position'}; ($tt, undef) = split(/\|/, $NoPost{$ttgrp}, 2); }
	else { $tt = ${$uid.$user}{'position'}; }

	$tta = "";
	if (%NoPost) {
		$tta = &DrawGroups(${$uid.$user}{'addgroups'}, ${$uid.$user}{'position'});
		$selsize = $k;
		if ($selsize > 6) { $selsize = 6; }
	}

	$userlastlogin = &timeformat(${$uid.$user}{'lastonline'});
	$userlastpost  = &timeformat(${$uid.$user}{'lastpost'});
	$userlastim    = &timeformat(${$uid.$user}{'lastim'});
	if ($userlastlogin eq "") { $userlastlogin = "$profile_txt{'470'}"; }
	if ($userlastpost  eq "") { $userlastpost  = "$profile_txt{'470'}"; }
	if ($userlastim    eq "") { $userlastim    = "$profile_txt{'470'}"; }
	if (${$uid.$user}{'postcount'} > 100000) { ${$uid.$user}{'postcount'} = "$profile_txt{'683'}"; }

	$yymain .= qq~
<form action="$scripturl?action=profileAdmin2;username=$INFO{'username'};sid=$INFO{'sid'}" method="post" name="creator">
<table cellspacing="1" cellpadding="4" width="100%" align="center" class="bordercolor" border="0">
 <tr>
   <td colspan="2" class="catbg"><img src="$imagesdir/profile.gif" alt="" border="0" /> <b>$profile_txt{79} ($INFO{'username'}) &rsaquo; $profile_txt{820}</b><input type="hidden" name="username" value="$INFO{'username'}" /></td>
 </tr><tr class="windowbg">
   <td width="320" align="left"><b>$profile_txt{'21'}: </b></td>
   <td align="left"><input type="text" name="settings6" size="4" value="${$uid.$user}{'postcount'}" /></td>
 </tr><tr class="windowbg">
   <td width="320" align="left"><b>$profile_txt{'87'}: </b></td>
   <td align="left">
           <select name="settings7">
           <option value="${$uid.$user}{'position'}">$tt</option>
           <option value="${$uid.$user}{'position'}">---------------</option>
           <option value=""></option>~;
	$z = 0;

	unless ($iamgmod) {
		($title, $stars, $starpic, $color) = split(/\|/, $Group{"Administrator"});
		$yymain .= qq~
           <option value="Administrator">$title</option>~;
		($title, $stars, $starpic, $color) = split(/\|/, $Group{"Global Moderator"});
		$yymain .= qq~
           <option value="Global Moderator">$title</option>~;
	}

	foreach (sort { $a <=> $b } keys %NoPost) {
		($title, $stars, $starpic, $color, undef) = split(/\|/, $NoPost{$_}, 5);
		$yymain .= qq~<option value="$_">$title</option>~;
		$z++;
	}
	$yymain .= qq~
           </select></td>

 </tr>
~;
	if ($tta ne "") {
		$yymain .= qq~
 <tr class="windowbg">
   <td width="320" align="left" valign="top"><b>$profile_txt{'87a'}: </b><br /><span class="small">$profile_txt{'87b'}</span></td>
   <td align="left">
           <select name="addgroup" size="$selsize" multiple="multiple">
           $tta
 </td>
 </tr>
~;
	}

	if($dr_month > 12) { $dr_month = 12; }
	if($dr_month < 1) { $dr_month = 1; }
	if($dr_day > 31) { $dr_day = 31; }
	if($dr_day < 1) { $dr_day = 1; }
	if(length($dr_year) > 2) { $dr_year = substr($dr_year , length($dr_year) - 2, 2); }
	if($dr_year < 90 && $dr_year > 20) { $dr_year = 90; }
	if($dr_year > 20 && $dr_year < 90) { $dr_year = 20; }
	if($dr_hour > 23) { $dr_hour = 23; }
	if($dr_minute > 59) { $dr_minute = 59; }
	if($dr_secund > 59) { $dr_secund = 59; }

	$sel_day = qq~
	<select name="dr_day">\n~;
	for($i = 1; $i <= 31; $i++) {
		$day_val = sprintf("%02d", $i);
		if($dr_day == $i) {
			$sel_day .= qq~<option value="$day_val" selected="selected">$i</option>\n~;
		}
		else {
			$sel_day .= qq~<option value="$day_val">$i</option>\n~;
		}
	}
	$sel_day .= qq~</select>\n~;

	$sel_month = qq~
	<select name="dr_month">\n~;
	for($i = 0; $i < 12; $i++) {
		$z = $i+1;
		$month_val = sprintf("%02d", $z);
		if($dr_month == $z) {
			$sel_month .= qq~<option value="$month_val" selected="selected">$months[$i]</option>\n~;
		}
		else {
			$sel_month .= qq~<option value="$month_val">$months[$i]</option>\n~;
		}
	}
	$sel_month .= qq~</select>\n~;

	$sel_year = qq~
	<select name="dr_year">\n~;
	for($i = 90; $i <= 120; $i++) {
		if($i < 100) { $z = $i; $year_pre = qq~19~; } else { $z = $i-100; $year_pre = qq~20~; }
		$year_val = sprintf("%02d", $z);
		$year_opt = qq~$year_pre$year_val~;
		if($dr_year == $z) {
			$sel_year .= qq~<option value="$year_val" selected="selected">$year_opt</option>\n~;
		}
		else {
			$sel_year .= qq~<option value="$year_val">$year_opt</option>\n~;
		}
	}
	$sel_year .= qq~</select>\n~;

	$time_sel = ${$uid.$username}{'timeselect'};
	if($time_sel == 1 || $time_sel == 4 || $time_sel == 5) { $all_date = qq~$sel_month $sel_day $sel_year~; }
	else { $all_date = qq~$sel_day $sel_month $sel_year~; }		

	$sel_hour = qq~
	<select name="dr_hour">\n~;
	for($i = 0; $i <= 23; $i++) {
		$hour_val = sprintf("%02d", $i);
		if($dr_hour == $i) {
			$sel_hour .= qq~<option value="$hour_val" selected="selected">$hour_val</option>\n~;
		}
		else {
			$sel_hour .= qq~<option value="$hour_val">$hour_val</option>\n~;
		}
	}
	$sel_hour .= qq~</select>\n~;

	$sel_minute = qq~
	<select name="dr_minute">\n~;
	for($i = 0; $i <= 59; $i++) {
		$minute_val = sprintf("%02d", $i);
		if($dr_minute == $i) {
			$sel_minute .= qq~<option value="$minute_val" selected="selected">$minute_val</option>\n~;
		}
		else {
			$sel_minute .= qq~<option value="$minute_val">$minute_val</option>\n~;
		}
	}
	$sel_minute .= qq~</select>\n~;

	$sel_secund = qq~<input type="hidden" value="$dr_secund" name="dr_secund" />~;

	$all_time = qq~$sel_hour $sel_minute $sel_secund~;

	$yymain .= qq~
 <tr class="windowbg">
    <td width="320" align="left"><b>$profile_txt{'233'}:</b></td>
    <td align="left" valign="middle">$all_date $maintxt{'107'} $all_time</td>
 </tr><tr class="windowbg">
    <td width="320" align="left"><b>$profile_amv_txt{'9'}: </b></td>
    <td align="left">$userlastlogin</td>
 </tr><tr class="windowbg">
    <td width="320" align="left"><b>$profile_amv_txt{'10'}: </b></td>
    <td align="left">$userlastpost</td>
 </tr><tr class="windowbg">
    <td width="320" align="left"><b>$profile_amv_txt{'11'}: </b><br /><br /></td>
    <td align="left">$userlastim<br /><br /></td>
 </tr><tr class="catbg">
    <td height="30" valign="middle" align="center" colspan="2"><input type="submit" name="moda" value="$profile_txt{'88'}" /></td>
 </tr>
</table>
</form>
~;
	$yytitle = "$profile_txt{'79'} $profile_txt{'820'}";
	&template;
	exit;
}

sub ModifyProfile2 {
	&SidCheck;

	$currentdate = timetostring(int(time));

	my (%member, $key, $value, $newpassemail, @memberlist, $a, @check_settings, @reserve, $matchword, $matchcase, $matchuser, $matchname, $namecheck, $reserved, $reservecheck, @dirdata, $filename, @entries, $entry, $umail, @members, $tempname);
	$FORM{'signature'} =~ s~\n~\&\&~g;
	while (($key, $value) = each(%FORM)) {
		$value =~ s~\A\s+~~;
		$value =~ s~\s+\Z~~;
		$value =~ s~[\n\r]~~g;
		$member{$key} = $value;
	}
	my $user = $INFO{'username'};
	$member{'username'} = $user;
	if (!${$uid.$user}{'password'}) { &LoadUser($user); }

	if ($sessions == 1 && $sessionvalid == 1 && ($iamadmin || $iamgmod) && $username eq $user) {
		&LoadLanguage("Sessions");
		if ($member{'sesquest'} ne "password" && $member{'sesanswer'} eq "") { &fatal_error($session_txt{'7'}); }
		if ($member{'sesquest'} eq "password") { $member{'sesanswer'} = ""; }
	}

	# make sure this person has access to this profile
	if ($user eq "admin" && $username ne "admin") { &fatal_error($profile_txt{'80'}); }
	if ($user ne $username && !$iamadmin && (!$iamgmod || !$allow_gmod_profile)) { &fatal_error($profile_txt{'80'}); }
	if (!$iamadmin) {
		$member{'settings6'} = ${$uid.$user}{'postcount'};
		$member{'settings7'} = ${$uid.$user}{'position'};
		$member{'addgroup'}  = ${$uid.$user}{'addgroups'};
	}

	if ($member{'username'} =~ /\//) { &fatal_error($profile_txt{'224'}); }
	if ($member{'username'} =~ /\\/) { &fatal_error($profile_txt{'225'}); }

	my $encryptpassw = ${$uid.$user}{'password'};
	my $encryptuname = &encode_password($member{'name'});

	if ($member{'passwrd1'} || $member{'passwrd2'}) {
		&fatal_error("($member{'username'}) $profile_txt{'213'}") if ($member{'passwrd1'} ne $member{'passwrd2'});
		&fatal_error("($member{'username'}) $profile_txt{'91'}") if ($member{'passwrd1'} eq '');
		&fatal_error("$profile_txt{'240'} $profile_txt{'36'} $profile_txt{'241'}") if ($member{'passwrd1'} !~ /\A[\s0-9A-Za-z!@#$%\^&*\(\)_\+|`~\-=\\:;'",\.\/?\[\]\{\}]+\Z/);
		&fatal_error("$profile_txt{'7'}") if ($member{'username'} eq $member{'passwrd1'});
		$member{'cpasswrd'} = $member{'passwrd1'};
		my $passchanged = 1;
	}

	if ($member{'name'} eq '') {
		&fatal_error("$profile_txt{'75'}");
	}

	&LoadCensorList;

	$censored_word = &CheckCensor("$member{'name'}");
	$censored_name = &Censor("$member{'name'}");

	if ($censored_name ne $member{'name'}) {
		&fatal_error("$profile_txt{'890'} <b>$censored_word</b>");
	}

	&FromChars($member{'name'});
	$convertstr = $member{'name'};
	$convertcut = 30;
	&CountChars;
	$member{'name'} = $convertstr;
	&fatal_error("$profile_txt{'568'}") if ($cliped);

	&fatal_error("$profile_txt{'240'} $profile_txt{'68'} $profile_txt{'241'}") if ($member{'name'} !~ /^[\s0-9A-Za-z\x80-\xFF\[\]#%+,-|\.:=?@^_]+$/);
	&fatal_error("$profile_txt{'75'}") if ($member{'name'} eq '|');
	if ($member{'bday1'} ne "" || $member{'bday2'} ne "" || $member{'bday3'} ne "") {
		&fatal_error("$profile_txt{'567'} 1 ($member{'bday1'}/$member{'bday2'}/$member{'bday3'})") if ($member{'bday1'} !~ /^[0-9]+$/ || $member{'bday2'} !~ /^[0-9]+$/ || $member{'bday3'} !~ /^[0-9]+$/ || length($member{'bday3'}) < 4);
		&fatal_error("$profile_txt{'567'} 2 ($member{'bday1'}/$member{'bday2'}/$member{'bday3'})") if ($member{'bday1'} < 1 || $member{'bday1'} > 12 || $member{'bday2'} < 1 || $member{'bday2'} > 31 || $member{'bday3'} < 1901 || $member{'bday3'} > $year - 5);
	}

	if ($member{'moda'} eq $profile_txt{'88'}) {
		$member{'bday1'} =~ s/[^0-9]//g;
		$member{'bday2'} =~ s/[^0-9]//g;
		$member{'bday3'} =~ s/[^0-9]//g;
		if ($member{'bday1'}) { $member{'bday'} = "$member{'bday1'}/$member{'bday2'}/$member{'bday3'}"; }
		else { $member{'bday'} = ''; }

		$tempname = $member{'name'};

		&ToHTML($member{'gender'});
		&ToHTML($member{'name'});

		# Check to see if name is already taken or reserved

		fopen(FILE, "$vardir/reservecfg.txt") || &fatal_error("$profile_txt{'23'} reservecfg.txt", 1);
		@reservecfg = <FILE>;
		fclose(FILE);
		for ($a = 0; $a < @reservecfg; $a++) { chomp $reservecfg[$a]; }
		$matchword = $reservecfg[0] eq 'checked';
		$matchcase = $reservecfg[1] eq 'checked';
		$matchuser = $reservecfg[2] eq 'checked';
		$matchname = $reservecfg[3] eq 'checked';
		$namecheck = $matchcase eq 'checked' ? $member{'name'} : lc $member{'name'};

		if($user ne "admin") {
			if ($encryptpassw eq $encryptuname) { &fatal_error("$profile_txt{'7'}"); }
			fopen(FILE, "$vardir/reserve.txt") || &fatal_error("$profile_txt{'23'} reserve.txt", 1);
			@reserve = <FILE>;
			fclose(FILE);
			foreach $reserved (@reserve) {
				chomp $reserved;
				$reservecheck = $matchcase ? $reserved : lc $reserved;
				if ($matchname) {
					if ($matchword) {
						if ($namecheck eq $reservecheck) { &fatal_error("$profile_txt{'244'} $namecheck"); }
					} else {
						if ($namecheck =~ $reservecheck) { &fatal_error("$profile_txt{'244'} $namecheck"); }
					}
				}
			}
		}

		if (${$uid.$user}{'realname'} ne $member{'name'}) {
			my $testname = lc $member{'name'};
			$is_existing = &MemberIndex("check_exist", "$testname");
			if (lc $is_existing eq $testname && lc $is_existing ne lc $user) { &fatal_error("($member{'name'}) $profile_txt{'473'}"); }

			#Since we haven't encountered a fatal error, time to rewrite our memberlist a little.
			&ToChars($member{'name'});
			&ManageMemberinfo("update", $user, $member{'name'});
		}

		# let's restore the name now
		&ToHTML($tempname);
		$member{'name'} = $tempname;
		&ToChars($member{'name'});
		&ToHTML($member{'location'});
		&ToHTML($member{'bday'});
		&ToHTML($member{'sesquest'});

		# Free code is the best code, like this code
		# Time to print the changes to the username.vars file
		if ($member{'passwrd1'}) { ${$uid.$user}{'password'} = &encode_password($member{'passwrd1'}); }
		${$uid.$user}{'realname'}    = "$member{'name'}";
		${$uid.$user}{'gender'}      = "$member{'gender'}";
		${$uid.$user}{'location'}    = "$member{'location'}";
		${$uid.$user}{'bday'}        = "$member{'bday'}";
		${$uid.$user}{'sesquest'}    = "$member{'sesquest'}";
		${$uid.$user}{'sesanswer'}   = &scramble($member{'sesanswer'}, $user);
		${$uid.$username}{'session'} = &encode_password($user_ip);
		&UserAccount($user, "update");

		if ($username eq $user) {
			my $pword      = ${$uid.$user}{'password'};
			my $expiration = "Sunday, 17-Jan-2038 00:00:00 GMT";
			&UpdateCookie("write", $user, $pword, ${$uid.$user}{'session'}, "/", $expiration);
			&LoadUser($user);
		}
		&WriteLog;
		$yySetLocation = qq~$scripturl?action=profileContacts;username=$member{'username'};sid=$INFO{'sid'}~;
		&redirectexit;
	} elsif ($member{'moda'} eq $profile_txt{'89'}) {
		&fatal_error("$profile_txt{'751'}") if ($member{'username'} eq 'admin');

		# For security, remove username from mod position
		&KillModerator($member{'username'});

		$membertrashdir ||= "$memberdir/../Trash"; # FIXME

		if ( $iamadmin or $user eq $member{'username'} ) {

			for my $ext (qw( vars log rlog msg outbox storage ims imstore )) {
				next if not -e "$memberdir/$member{'username'}.$ext";

				rename ( "$memberdir/$member{'username'}.$ext",
				         "$membertrashdir/$member{'username'}.$ext" )
				or unlink ( "$memberdir/$member{'username'}.$ext" )
			}

			$noteuser = $member{'username'};
		}

		opendir(DIRECTORY, "$datadir");
		@dirdata = readdir(DIRECTORY);
		closedir(DIRECTORY);

		&getMailFiles;
		&MemberIndex("remove", $noteuser);

		if (!$iamadmin) { # ?? change to $user eq $member{'username'} ?
			require "$sourcedir/LogInOut.pl";
			&Logout;
		}
		$yySetLocation = qq~$scripturl~;
		&redirectexit;
	} else {
		&fatal_error("$polltxt{'13'}");
	}
	exit;
}

sub ModifyProfileContacts2 {
	&SidCheck;

	my (%member, $key, $value, $newpassemail, @memberlist, $a, @check_settings, @reserve, $matchword, $matchcase, $matchuser, $matchname, $namecheck, $reserved, $reservecheck, @dirdata, $filename, @entries, $entry, $umail, @members, $tempname);
	while (($key, $value) = each(%FORM)) {
		$value =~ s~\A\s+~~;
		$value =~ s~\s+\Z~~;
		$value =~ s~[\n\r]~~g;
		$member{$key} = $value;
	}
	my $user = $INFO{'username'};
	$member{'username'} = $user;
	if (!${$uid.$user}{'password'}) { &LoadUser($user); }

	# make sure this person has access to this profile
	if ($user ne $username && !$iamadmin && (!$iamgmod || !$allow_gmod_profile)) { &fatal_error($profile_txt{'80'}); }
	if (!$iamadmin) {
		$member{'settings6'} = ${$uid.$user}{'postcount'};
		$member{'settings7'} = ${$uid.$user}{'position'};
		$member{'addgroup'}  = ${$uid.$user}{'addgroups'};
	}

	if ($emailnewpass && lc $member{'email'} ne lc ${$uid.$user}{'email'} && !$iamadmin) {
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
		${$uid.$user}{'password'} = &encode_password($member{'passwrd1'});
		$newpassemail = 1;
	}

	&fatal_error("$profile_txt{'76'}") if ($member{'email'} eq '');
	&fatal_error("$profile_txt{'240'} $profile_txt{'69'} $profile_txt{'241'}") if ($member{'email'} !~ /[\w\-\.\+]+\@[\w\-\.\+]+\.(\w{2,4}$)/);
	&fatal_error("$profile_txt{'500'}")                                        if (($member{'email'} =~ /(@.*@)|(\.\.)|(@\.)|(\.@)|(^\.)|(\.$)/) || ($member{'email'} !~ /^.+@\[?(\w|[-.])+\.[a-zA-Z]{2,4}|[0-9]{1,4}\]?$/));

	if ($member{'moda'} eq $profile_txt{'88'}) {
		$member{'icq'} =~ s/[^0-9]//g;
		$member{'aim'} =~ s/ /\+/g;
		$member{'yim'} =~ s/ /\+/g;
		$member{'msn'} =~ s/ /\+/g;

		# store the name temorarily so we can restore any _'s later
		$tempname = $member{'name'};
		$member{'name'} =~ s/\_/ /g;

		&ToHTML($member{'aim'});
		&ToHTML($member{'yim'});
		&ToHTML($member{'msn'});
		&ToHTML($member{'gtalk'});
		&ToHTML($member{'weburl'});
		&ToHTML($member{'webtitle'});
		&ToHTML($member{'email'});
		&ToHTML($member{'hideemail'});

		# Check to see if email is already taken
		if (lc ${$uid.$user}{'email'} ne lc $member{'email'}) {
			$testemail = lc $member{'email'};
			$is_existing = &MemberIndex("check_exist", "$testemail");
			if (lc $is_existing eq $testemail) { &fatal_error("$profile_txt{'730'} ($member{'email'}) $profile_txt{'731'}"); }

			# Since we haven't encountered a fatal error, time to rewrite our memberlist a little.
			&ManageMemberinfo("update", $user, '', $member{'email'});
		}

		# let's restore the name now
		&ToHTML($tempname);
		$member{'name'} = $tempname;

		# Time to print the changes to the username.vars file
                ${$uid.$user}{'email'}    = $member{'email'};
                ${$uid.$user}{'hidemail'} = $member{'hideemail'};
                ${$uid.$user}{'icq'}      = $member{'icq'};
                ${$uid.$user}{'msn'}      = $member{'msn'};
                ${$uid.$user}{'yim'}      = $member{'yim'};
                ${$uid.$user}{'aim'}      = $member{'aim'};
                ${$uid.$user}{'gtalk'}    = $member{'gtalk'};
                ${$uid.$user}{'webtitle'} = $member{'webtitle'};
                ${$uid.$user}{'weburl'}   = $member{'weburl'};
		&UserAccount($user, "update");
		&WriteLog; # FIXME: strange thing

		if ($emailnewpass && $newpassemail == 1) {

			# Write log
			load_online_users;

			delete $online_users{$user} if exists $online_users{$user};

			fopen LOG, "> $vardir/log.txt", 1;
			foreach my $login ( keys %online_users ) {
				print LOG "$login|$online_users{$login}\n";
			}
			fclose LOG;

			if ($username eq $user) {
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
			}
			&FormatUserName($member{'username'});
			&sendmail($member{'email'}, qq~$profile_txt{'700'} $mbname~, "$profile_txt{'733'} $member{'passwrd1'} $profile_txt{'734'} $member{'username'}.\n\n$profile_txt{'701'} $scripturl?action=profile;username=$useraccount{$member{'username'}}\n\n$profile_txt{'130'}");
			require "$sourcedir/LogInOut.pl";
			$sharedLogin_title = "$profile_txt{'34'}: $user";
			$sharedLogin_text  = "$profile_txt{'638'}";
			$shared_login      = &sharedLogin;
			$yymain .= qq~$shared_login~;
			$yytitle = "$profile_txt{'245'}";
			&template;
			exit;
		}
	} else {
		&fatal_error("$polltxt{'13'}");
	}
	$yySetLocation = qq~$scripturl?action=profileOptions;username=$member{'username'};sid=$INFO{'sid'}~;
	&redirectexit;
	exit;
}

sub ModifyProfileOptions2 {
	&SidCheck;

	my @onoff = qw/dsttimeoffset/;
	my $fi;
	map { $fi = lc $_; ${$_} = $FORM{$fi} eq 'on' ? 1 : 0; } @onoff;
	my (%member, $key, $value, $newpassemail, @memberlist, $a, @check_settings, @reserve, $matchword, $matchcase, $matchuser, $matchname, $namecheck, $reserved, $reservecheck, @dirdata, $filename, @entries, $entry, $umail, @members, $tempname);
	$FORM{'signature'} =~ s~\&\&~\&amp\;\&amp\;~g;
	$FORM{'signature'} =~ s~\n~\&\&~g;
	while (($key, $value) = each(%FORM)) {
		$value =~ s~\A\s+~~;
		$value =~ s~\s+\Z~~;
		$value =~ s~[\n\r]~~g;
		$member{$key} = $value;
	}
	my $user = $INFO{'username'};
	$member{'username'} = $user;
	if (!${$uid.$user}{'password'}) { &LoadUser($user); }

	# make sure this person has access to this profile
	if ($user ne $username && !$iamadmin && (!$iamgmod || !$allow_gmod_profile)) { &fatal_error($profile_txt{'80'}); }
	if (!$iamadmin) {
		$member{'settings6'} = ${$uid.$user}{'postcount'};
		$member{'settings7'} = ${$uid.$user}{'position'};
		$member{'addgroup'}  = ${$uid.$user}{'addgroups'};
	}

	if ($member{'username'} =~ /\//) { &fatal_error($profile_txt{'224'}); }
	if ($member{'username'} =~ /\\/) { &fatal_error($profile_txt{'225'}); }
	$INFO{'username'} = $member{'username'};

	&FromChars($member{'usertext'});
	$convertstr = $member{'usertext'};
	$convertcut = 51;
	&CountChars;
	$member{'usertext'} = $convertstr;

	if ($member{'userpicpersonalcheck'} && ($member{'userpicpersonal'} =~ m/\.gif\Z/i || $member{'userpicpersonal'} =~ m/\.jpg\Z/i || $member{'userpicpersonal'} =~ m/\.jpeg\Z/i || $member{'userpicpersonal'} =~ m/\.png\Z/i)) {
		$member{'userpic'} = $member{'userpicpersonal'};
	}
	if ($member{'userpic'} eq "") { $member{'userpic'} = "blank.gif"; }
	&fatal_error("$profile_txt{'592'}") if ($member{'userpic'} !~ m^\A[0-9a-zA-Z_\.\#\%\-\:\+\?\$\&\~\.\,\@/]+\Z^);
	if (!$allowpics) { $member{'userpic'} = "blank.gif"; }

	if ($member{'moda'} eq $profile_txt{'88'}) {

		&FromChars($member{'signature'});
		$convertstr = $member{'signature'};
		$convertcut = $MaxSigLen;
		&CountChars;
		$member{'signature'} = $convertstr;

		$member{'signature'} =~ s/</&lt;/g;
		$member{'signature'} =~ s/>/&gt;/g;

		# store the name temorarily so we can restore any _'s later
		$tempname = $member{'name'};
		$member{'name'} =~ s/\_/ /g;
		if ($member{'usertemplate'} !~ m^\A[0-9a-zA-Z_\(\)\Є\ \.\#\%\-\:\+\?\$\&\~\.\,\@/]+\Z^ && $member{'usertemplate'} ne "") { &fatal_error($profile_txt{'815'}); }
		if ($member{'usertemplate'} eq "") { $member{'usertemplate'} = "$template"; }
		#### FIXME: Restriction to avoid vulnerability.
		if ($member{'userlanguage'} !~ m^\A[0-9a-zA-Z_\#\%\-\:\+\?\$\&\~\,\@]+\Z^ && $member{'userlanguage'} ne "") { &fatal_error($profile_txt{'815'}); }
		if (!$member{'userlanguage'}) { $member{'userlanguage'} = "$language"; }

		# update notifications if users language is changed
		if (${$uid.$user}{'language'} ne "$member{'userlanguage'}") {
			&getMailFiles;
			require "$sourcedir/Notify.pl";
			&updateLanguage($user, $member{'userlanguage'});
		}

		&ToHTML($member{'usertext'});

		if (length $member{'signature'} > 1000) { $member{'signature'} = substr($member{'signature'}, 0, 1000); }
		&ToHTML($member{'signature'});

		$member{'usertimeoffset'} =~ tr/,/./;
		$member{'usertimeoffset'} =~ s/[^\d*|\.|\-|w*]//g;
		if (($member{'usertimeoffset'} < -23.5) || ($member{'usertimeoffset'} > 23.5)) { &fatal_error($profile_txt{'487'}); }

		# let's restore the name now
		&ToHTML($tempname);
		$member{'name'} = $tempname;

                &ToHTML($member{'userpic'});
                &ToHTML($member{'usertimeoffset'});
                &ToHTML($member{'usertimeselect'});
                &ToHTML($member{'usertemplate'});
                &ToHTML($member{'userlanguage'});
                &ToHTML($member{'timeformat'});

		# Time to print the changes to the username.vars file
		${$uid.$user}{'usertext'}      = "$member{'usertext'}";
		${$uid.$user}{'userpic'}       = "$member{'userpic'}";
		${$uid.$user}{'signature'}     = "$member{'signature'}";
		${$uid.$user}{'timeoffset'}    = "$member{'usertimeoffset'}";
		${$uid.$user}{'dsttimeoffset'} = "$dsttimeoffset";
		${$uid.$user}{'timeselect'}    = "$member{'usertimeselect'}";
		${$uid.$user}{'template'}      = "$member{'usertemplate'}";
		${$uid.$user}{'language'}      = "$member{'userlanguage'}";
		${$uid.$user}{'timeformat'}    = "$member{'timeformat'}";
		&UserAccount($user, "update");

		$yySetLocation = qq~$scripturl?action=profileIM;username=$INFO{'username'};sid=$INFO{'sid'}~;
		&redirectexit;
	} else {
		&fatal_error("$polltxt{'13'}");
	}
	exit;
}

sub ModifyProfileIM2 {
	&SidCheck;

	my ($ignorelist, $notify, $popup, $imprev, $imspop, $enableaim, $awayim);
	my $user = $INFO{'username'};
	if (!${$uid.$user}{'password'}) { &LoadUser($user); }

        while (($key, $value) = each(%FORM)) {
                $value =~ s~\A\s+~~;
                $value =~ s~\s+\Z~~;
                unless ($key eq 'ignore') { $value =~ s~[\n\r]~~g; }
                $member{$key} = $value;
        }

	# make sure this person has access to this profile
	if ($user ne $username && !$iamadmin && (!$iamgmod || !$allow_gmod_profile)) { &fatal_error($profile_txt{'80'}); }
        $ignorelist = $FORM{'ignore'};

        $ignorelist =~ s~\A\n\s*~~;
        $ignorelist =~ s~\s*\n\Z~~;
        $ignorelist =~ s~\n\s*\n~\n~g;
        $ignorelist =~ s~[\n\r]~\|~g;
        $ignorelist =~ s~\|\|~\|~g;

        &ToHTML($ignorelist);
        &ToHTML($member{'notify'});
        &ToHTML($member{'userpopup'});
        &ToHTML($member{'popupims'});

        # Time to print the changes to the username.vars file
	${$uid.$user}{'im_ignorelist'} = $ignorelist;
        ${$uid.$user}{'im_notify'} = $member{'notify'};
        ${$uid.$user}{'im_popup'} = $member{'userpopup'};
        ${$uid.$user}{'im_imspop'} = $member{'popupims'};

	&UserAccount($user, "update");
	if (!$iamadmin) {
		$yySetLocation = qq~$scripturl?action=viewprofile;username=$INFO{'username'};sid=$INFO{'sid'}~;
		&redirectexit;
	} else {
		$yySetLocation = qq~$scripturl?action=profileAdmin;username=$INFO{'username'};sid=$INFO{'sid'}~;
		&redirectexit;
	}
}

sub ModifyProfileAdmin2 {

	&SidCheck;
	&is_admin_or_gmod;

	my (%member, $key, $value, $newpassemail, @memberlist, @check_settings, @reserve, $matchword, $matchcase, $matchuser, $matchname, $namecheck, $reserved, $reservecheck, @dirdata, $filename, @entries, $entry, $umail, @members, $tempname);
	$FORM{'signature'} =~ s~\n~\&\&~g;
	while (($key, $value) = each(%FORM)) {
		$value =~ s~\A\s+~~;
		$value =~ s~\s+\Z~~;
		$value =~ s~[\n\r]~~g;
		$member{$key} = $value;
	}
	my $user = $INFO{'username'};
	$member{'username'} = $user;
	if (!${$uid.$user}{'password'}) { &LoadUser($user); }

	$member{'addgroup'} =~ s/\, /\,/g;

	# make sure this person has access to this profile
	if ($user ne $username && !$iamadmin && (!$iamgmod || !$allow_gmod_profile)) { &fatal_error($profile_txt{'80'}); }

	if (!$iamadmin && ($member{'settings7'} eq "Administrator" || $member{'settings7'} eq "Global Moderator")) {
		$member{'settings7'} = ${$uid.$user}{'position'};
	}

	if ($member{'settings6'} !~ /\A[0-9]+\Z/) { &fatal_error("$profile_txt{'749'}"); }
	&fatal_error("$profile_txt{'680'}") if ($member{'username'} eq "admin" && $member{'settings7'} ne "Administrator");

	$dr_month = $member{'dr_month'};
	$dr_day = $member{'dr_day'};
	$dr_year = $member{'dr_year'};
	$dr_hour = $member{'dr_hour'};
	$dr_minute = $member{'dr_minute'};
	$dr_secund = $member{'dr_secund'};

	if($dr_month == 4 || $dr_month == 6 || $dr_month == 9 || $dr_month == 11) {
		$max_days = 30;
	}
	elsif($dr_month == 2 && $dr_year % 4 == 0) {
		$max_days = 29;
	}
	elsif($dr_month == 2 && $dr_year % 4 != 0) {
		$max_days = 28;
	}
	else {
		$max_days = 31;
	}
	if($dr_day > $max_days) { $dr_day = $max_days; }

	$member{'dr'} = qq~$dr_month/$dr_day/$dr_year $maintxt{'107'} $dr_hour:$dr_minute:$dr_secund~;

	if ($member{'settings6'} != ${$uid.$user}{'postcount'} || $member{'settings7'} ne ${$uid.$user}{'position'}) {
		if ($member{'settings7'}) {
			$grp_after = qq~$member{'settings7'}~;
		} else {
			foreach $postamount (sort { $b <=> $a } keys %Post) {
				if ($member{'settings6'} > $postamount) {
					($title, undef) = split(/\|/, $Post{$postamount}, 2);
					$grp_after = $title;
					last;
				}
			}
		}
		&ManageMemberinfo("update", $user, '', '', $grp_after, $member{'settings6'});
	}
	if ($member{'addgroup'} ne ${$uid.$user}{'addgroups'}) {
		&ManageMemberinfo("update", $user, '', '', '', '', $member{'addgroup'});
	}

	if ($member{'dr'} ne ${$uid.$user}{'regdate'}) {
		$newreg = &stringtotime($member{'dr'});
		$newreg = sprintf("%010d", $newreg);
		&ManageMemberlist("update", $user, $newreg);
		${$uid.$user}{'regtime'}   = "$newreg";
	}

	if ($member{'moda'} eq $profile_txt{'88'}) {
		if (!$iamadmin) { $member{'dr'} = ${$uid.$user}{'regdate'}; }
		$member{'addgroup'} =~ s/\A\,//;
		${$uid.$user}{'postcount'} = "$member{'settings6'}";
		${$uid.$user}{'position'}  = "$member{'settings7'}";
		${$uid.$user}{'addgroups'} = "$member{'addgroup'}";
		${$uid.$user}{'regdate'}   = "$member{'dr'}";
		&UserAccount($user, "update");
		&WriteLog;
		$yySetLocation = qq~$scripturl?action=viewprofile;username=$member{'username'}~;
		&redirectexit;
	} else {
		&fatal_error("$profile_txt{'751'}");
	}
	exit;
}

sub ViewProfile {

	# If someone registers with a '+' in their name It causes problems.
	# Get's turned into a <space> in the query string Change it back here.
	# Users who register with spaces get them replaced with _
	# So no problem there.
	$INFO{'username'} =~ tr/ /+/;

	if ($iamguest) { &fatal_error("$profile_txt{'223'}"); }
	if ($INFO{'username'} =~ /\//) { &fatal_error("$profile_txt{'224'}"); }
	if ($INFO{'username'} =~ /\\/) { &fatal_error("$profile_txt{'225'}"); }
	if (!-e ("$memberdir/$INFO{'username'}.vars")) { &fatal_error("$profile_txt{'453'}"); }

	my ($memberinfo, $modify, $email, $gender, $pic);

	# Convert forum start date to string, if there is no date set,
	# Defaults to 1st Jan, 2005
	if ($forumstart) {
		$forumstart = &stringtotime($forumstart);
	} else {
		$forumstart = "1104537600";
	}

	my $user = $INFO{'username'};
	if (!${$uid.$user}{'password'}) { &LoadUser($user); }

	if (${$uid.$user}{'weburl'} !~ m~\Ahttp://~) { ${$uid.$user}{'weburl'} = "http://${$uid.$user}{'weburl'}"; }
	$memsettingsd[9] = ${$uid.$user}{'aim'};
	$memsettingsd[9] =~ tr/+/ /;
	$memsettingsd[10] = ${$uid.$user}{'yim'};
	$memsettingsd[10] =~ tr/+/ /;
	$dr = "";
	if (${$uid.$user}{'regtime'} eq "") { $dr = "$profile_txt{'470'}"; }
	else { $dr = &timeformat(${$uid.$user}{'regtime'}); }
	&CalcAge($user, "calc");      # How old is he/she?
	&CalcAge($user, "isbday");    # is it the bday?
	if ($isbday) { $isbday = "<img src=\"$imagesdir/bdaycake.gif\" width=\"40\" />"; }

	if ($user eq $username || $iamadmin || ($iamgmod && $allow_gmod_profile && ${$uid.$user}{'position'} ne "Administrator")) {
		$modify = qq~<a href="$scripturl?action=profileCheck;username=$useraccount{$INFO{'username'}}">$img{'modify'}</a>~;
	}
	if ($user eq "admin" && $username ne "admin") { $modify = ""; }
	if (${$uid.$user}{'hidemail'} ne "checked" || $iamadmin || !$allow_hide_email) {
		$email = qq~<a href="$scripturl?action=mailto;user=$INFO{'username'}" target="_blank">$profile_txt{'889'} ${$uid.$user}{'realname'}</a>~;
	} else {
		$email = qq~<i>$profile_txt{'722'}</i>~;
	}
	$gender = "";
	if (${$uid.$user}{'gender'} eq "Male")   { $gender = qq~$profile_txt{'238'}~; }
	if (${$uid.$user}{'gender'} eq "Female") { $gender = qq~$profile_txt{'239'}~; }

	$pic_row = "";
	if ($allowpics) {
		$avstyle = "";
		if ($ENV{'HTTP_USER_AGENT'} !~ /MSIE/ || $ENV{'HTTP_USER_AGENT'} =~ /Opera/) {
			if ($ENV{'HTTP_USER_AGENT'} =~ /Safari/) { $avstyle = qq~ style="max-width: 65px; max-height: 65px;"~; }
			else { $avstyle = qq~ style="max-width: 65px;"~; }
		}
		if (${$uid.$user}{'userpic'} =~ /^\http:\/\//) {
			$pic = qq~<img src="${$uid.$user}{'userpic'}" id="avatar" border="0" alt=""$avstyle />~;
		} else {
			$pic = qq~<img src="$facesurl/${$uid.$user}{'userpic'}" id="avatar" border="0" alt=""$avstyle />~;
		}

		if (${$uid.$user}{'userpic'} eq "blank.gif") {
			$pic = qq~<img src="$imagesdir/nn.gif" id="avatar" border="0" alt="" />~;
		}
		$pic_row = qq~
			<div style="float: left; width: 20%; text-align: center; padding: 5px 5px 5px 0px;">
			$pic
			</div>
		~;
	}


	#"# Determine, if user is online
	my $online = qq(<img src="$imagesdir/off_led.png" alt="${$uid.$user}{'realname'} $profile_txt{'113'} $profile_txt{'687'}" />);
	
	load_users_online;

	if ( is_online $user ) {
		$online = qq(<img src="$imagesdir/on_led.png" alt="${$uid.$user}{'realname'} $profile_txt{'113'} $profile_txt{'686'}" />)
	}


	# Hide empty profile fields from display
	if ($addmembergroup{$user}) {
		$showaddgr = $addmembergroup{$user};
		$showaddgr =~ s/<br \/>/\, /g;
		$showaddgr =~ s/\A, //;
		$showaddgr =~ s/, \Z//;
		$row_addgrp .= qq~<br /><span class="small">$showaddgr</span>~;
	} else {
		$row_addgrp = "";
	}

	if (${$uid.$user}{'gender'}) {
		if (${$uid.$user}{'gender'} eq "Male") {
			$gender = qq~$profile_txt{'238'}~;
		} elsif (${$uid.$user}{'gender'} eq "Female") {
			$gender = qq~$profile_txt{'239'}~;
		}
		$row_gender = qq~
		<div style="float: left; width: 30%; padding-top: 5px;  padding-bottom: 5px;">
		<b>$profile_txt{'231'}: </b>
		</div>
		<div style="float: left; width: 70%; padding-top: 5px;  padding-bottom: 5px;">
		$gender
		</div>
	~;
	} else {
		$row_gender = "";
	}

	if ($age) {
		$row_age = qq~
		<div style="float: left; width: 30%; padding-top: 5px;  padding-bottom: 5px;">
		<b>$profile_txt{'420'}:</b>
		</div>
		<div style="float: left; width: 70%; padding-top: 5px;  padding-bottom: 5px;">
		$age &nbsp; $isbday
		</div>
	~;
	} else {
		$row_age = "";
	}

	if (${$uid.$user}{'location'}) {
		$row_location = qq~
		<div style="float: left; width: 30%; padding-top: 5px;  padding-bottom: 5px;">
		<b>$profile_txt{'227'}: </b>
		</div>
		<div style="float: left; width: 70%; padding-top: 5px;  padding-bottom: 5px;">
		${$uid.$user}{'location'}
		</div>
	~;
	} else {
		$row_location = "";
	}

	if (${$uid.$user}{'icq'} && ${$uid.$user}{'icq'} !~ m/\D/) {
		$row_icq .= qq~
		<div style="float: left; width: 30%; padding-top: 5px;  padding-bottom: 5px;">
		<b>$profile_txt{'513'}:</b>
		</div>
		<div style="float: left; width: 70%; padding-top: 5px;  padding-bottom: 5px;">
		<a href="http://web.icq.com/${$uid.$user}{'icq'}" title="${$uid.$user}{'icq'}" target="_blank">
		<img src="http://web.icq.com/whitepages/online?icq=${$uid.$user}{'icq'}&#38;img=5" alt="${$uid.$user}{'icq'}" border="0" style="vertical-align: middle;" /> ${$uid.$user}{'icq'}</a>
		</div>
	~;
	} else {
		$row_icq = "";
	}

	if (${$uid.$user}{'aim'}) {
		$row_aim = qq~
		<div style="float: left; width: 30%; padding-top: 5px;  padding-bottom: 5px;">
		<b>$profile_txt{'603'}: </b>
		</div>
		<div style="float: left; width: 70%; padding-top: 5px;  padding-bottom: 5px;">
		<a href="aim:goim?screenname=${$uid.$user}{'aim'}&#38;message=Hi,+are+you+there?">
		<img src="$imagesdir/aim.gif" alt="${$uid.$user}{'aim'}" border="0" style="vertical-align: middle;" /> $memsettingsd[9]</a>
		</div>
	~;
	} else {
		$row_aim = "";
	}

	if (${$uid.$user}{'yim'}) {
		$row_yim = qq~
		<div style="float: left; width: 30%; padding-top: 5px;  padding-bottom: 5px;">
		<b>$profile_txt{'604'}: </b>
		</div>
		<div style="float: left; width: 70%; padding-top: 5px;  padding-bottom: 5px;">
		<img src="http://opi.yahoo.com/online?u=${$uid.$user}{'yim'}&#38;m=g&#38;t=0" border="0" alt="${$uid.$user}{'yim'}" style="vertical-align: middle;" />
		<a href="http://edit.yahoo.com/config/send_webmesg?.target=${$uid.$user}{'yim'}" target="_blank"> $memsettingsd[10]</a>
		</div>
	~;
	} else {
		$row_yim = "";
	}

	if (${$uid.$user}{'msn'}) {
		$row_msn = qq~
		<div style="float: left; width: 30%; padding-top: 5px;  padding-bottom: 5px;">
		<b>$profile_txt{'823'}: </b>
		</div>
		<div style="float: left; width: 70%; padding-top: 5px;  padding-bottom: 5px;">
		<img src="$imagesdir/msn3.gif" alt="" border="0" style="vertical-align: middle;" />
		<a href="#" onclick="window.open('$scripturl?action=setmsn;msnname=$user','','height=80,width=340,menubar=no,toolbar=no,scrollbars=no'); return false">$profile_txt{'823'} ${$uid.$user}{'realname'}</a>
		</div>
	~;
	} else {
		$row_msn = "";
	}

	if (${$uid.$user}{'gtalk'}) {
		$row_gtalk = qq~
		<div style="float: left; width: 30%; padding-top: 5px;  padding-bottom: 5px;">
		<b>$profile_txt{'825'}: </b>
		</div>
		<div style="float: left; width: 70%; padding-top: 5px;  padding-bottom: 5px;">
		<img src="$imagesdir/gtalk2.gif" alt="" border="0" style="vertical-align: middle;" />
		<a href="#" onclick="window.open('$scripturl?action=setgtalk;gtalkname=$user','','height=80,width=340,menubar=no,toolbar=no,scrollbars=no'); return false">$profile_txt{'825'} ${$uid.$user}{'realname'}</a>
		</div>
	~;
	} else {
		$row_gtalk = "";
	}

	if (${$uid.$user}{'hidemail'} ne "checked" || $iamadmin || !$allow_hide_email) {
		$row_email = qq~
		<div style="float: left; width: 30%; padding-top: 5px;  padding-bottom: 5px;">
		<b>$profile_txt{'69'}: </b>
		</div>
		<div style="float: left; width: 70%; padding-top: 5px;  padding-bottom: 5px;">
		<a href="$scripturl?action=mailto;user=$INFO{'username'}" target="_blank">$profile_txt{'889'} ${$uid.$user}{'realname'}</a>
		</div>
	~;
	} else {
		$row_email = "";
	}

	if (${$uid.$user}{'weburl'} && ${$uid.$user}{'webtitle'}) {
		$row_website = qq~
		<div style="float: left; width: 30%; padding-top: 5px;  padding-bottom: 5px;">
		<b>$profile_txt{'96'}: </b>
		</div>
		<div style="float: left; width: 70%; padding-top: 5px;  padding-bottom: 5px;">
		<a href="${$uid.$user}{'weburl'}" target="_blank">${$uid.$user}{'webtitle'}</a>
		</div>
	~;
	} else {
		$row_website = "";
	}

	if (${$uid.$user}{'signature'}) {

		# do some ubbc on the signature to display in the view profile area
		&FromHTML(${$uid.$user}{'signature'});
		${$uid.$user}{'signature'} =~ s~\&\&~<br />~g;
		$message     = ${$uid.$user}{'signature'};
		$displayname = ${$uid.$user}{'realname'};

		if ($enable_ubbc) {
			if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; }
			&DoUBBC;
		}

		&LoadCensorList;

		# Censor the signature.
		$message = &Censor($message);
		&ToChars($message);
		${$uid.$user}{'signature'} = $message;

		# Censor the usertext
		$message = ${$uid.$user}{'usertext'};
		$message = &Censor($message);
		&ToChars($message);
		${$uid.$user}{'usertext'} = $message;

		$row_signature = qq~
		<tr>
		<td class="catbg" align="left">
			<img src="$imagesdir/profile.gif" alt="" border="0" style="vertical-align: middle;" />&nbsp; 
			<span class="text1"><b>$profile_txt{'85'}</b></span>
		</td>
		</tr>
		<tr>
		<td align="left" class="windowbg2">
			<div style="float: left; width: 100%; padding-top: 8px; padding-bottom: 8px; overflow: auto;">
			${$uid.$user}{'signature'}
			</div>
		</td>
		</tr>
	~;
	} else {
		$row_signature = "";
	}

	# End empty field checking
	$wrapcut = 20;
	$wrapstr = ${$uid.$user}{'usertext'};
	&WrapChars;
	${$uid.$user}{'usertext'} = $wrapstr;

	# Just maths below...
	$post_count = ${$uid.$user}{'postcount'};
	if (!$post_count) { $post_count = 0 }

	$string_regdate = &stringtotime(${$uid.$user}{'regdate'});
	$string_curdate = int(time);

	if ($string_regdate < $forumstart) { $string_regdate = $forumstart }
	if ($string_curdate < $forumstart) { $string_curdate = $forumstart }

	$member_for_days = int(($string_curdate - $string_regdate) / 86400);

	if ($member_for_days < 1) { $tmpmember_for_days = 1; }
	else { $tmpmember_for_days = $member_for_days; }
	$post_per_day = sprintf("%.2f", ($post_count / $tmpmember_for_days));

	# End statistics.

	if (${$uid.$user}{'usertext'}) {
		$showusertext = ${$uid.$user}{'usertext'};
		$showusertext =~ s/<br \/>/ /g;
	} else {
		$showusertext = "";
	}

	$yymain .= qq~
<table border="0" cellpadding="8" cellspacing="1" class="bordercolor" align="center" width="570">
	<tr>
		<td class="titlebg" width="100%" align="left">
			<div class="text1" style="float: left; width: 100%;">
			<img src="$imagesdir/profile.gif" alt="" border="0" style="vertical-align: middle;" />&nbsp; <b>$profile_txt{'35'}: $INFO{'username'}</b>
			</div>
		</td>
	</tr>
	<tr>
		<td class="windowbg" valign="middle">
			$pic_row
			<div style="float: left; width: 60%; padding-top: 5px;  padding-bottom: 5px;">
			$online <span style="font-size: 18px;">${$uid.$user}{'realname'}</span><br />
			$col_title{$user}
			$row_addgrp<br />
			<span class="small">$showusertext</span>
			</div>
			<div style="float: right; width: 19%; text-align: right;">
			$modify
			</div>
		</td>
	</tr>
	<tr>
		<td class="windowbg2" align="left" valign="top">
			<div style="float: left; width: 30%; padding-top: 5px;  padding-bottom: 5px;">
			<b>$profile_txt{'21'}: </b>
			</div>
			<div style="float: left; width: 70%; padding-top: 5px;  padding-bottom: 5px;">
			<b>${$uid.$user}{'postcount'}<br />$post_per_day</b> $profile_txt{'893'}
			</div>
			<div style="float: left; width: 30%; padding-top: 5px;  padding-bottom: 5px;">
			<b>$profile_txt{'233'}: </b>
			</div>
			<div style="float: left; width: 70%; padding-top: 5px;  padding-bottom: 5px;">
			$dr<br /><b>$member_for_days</b> $profile_txt{'894'}
			</div>
		</td>
	</tr>
  ~;

	if ($row_gender || $row_age || $row_location) {
		$yymain .= qq~
	<tr>
		<td class="windowbg2" align="left" valign="top">
		$row_gender
		$row_age
		$row_location
		</td>
	</tr>
	~;
	}

	$yymain .= qq~
	<tr>
		<td class="catbg" align="left">
			<img src="$imagesdir/profile.gif" alt="" border="0" style="vertical-align: middle;" />&nbsp; 
			<span class="text1"><b>$profile_txt{'819'}</b></span>
		</td>
	</tr>
	<tr>
		<td class="windowbg2" align="left">
			<div style="float: left; width: 30%; padding-top: 5px;  padding-bottom: 5px;">
			<b>$profile_txt{'144'}: </b>
			</div>
			<div style="float: left; width: 70%; padding-top: 5px;  padding-bottom: 5px;">
			<a href="$scripturl?action=imsend;to=$useraccount{$INFO{'username'}}">$profile_txt{'688'} ${$uid.$user}{'realname'}</a>
			</div>
			$row_email
			$row_website
			$row_aim
			$row_msn
			$row_yim
			$row_gtalk
			$row_icq
		</td>
	</tr>
  ~;

	$userlastlogin = &timeformat(${$uid.$user}{'lastonline'});
	$userlastpost  = &timeformat(${$uid.$user}{'lastpost'});
	$userlastim    = &timeformat(${$uid.$user}{'lastim'});
	if ($userlastlogin eq "") { $userlastlogin = "$profile_txt{'470'}"; }
	if ($userlastpost  eq "") { $userlastpost  = "$profile_txt{'470'}"; }
	if ($userlastim    eq "") { $userlastim    = "$profile_txt{'470'}"; }
	if (${$uid.$user}{'postcount'} > 100000) { ${$uid.$user}{'postcount'} = "$profile_txt{'683'}"; }

	$yymain .= qq~  
	$row_signature
	<tr>
		<td class="catbg" align="left">
			<img src="$imagesdir/profile.gif" alt="" border="0" style="vertical-align: middle;" />&nbsp; 
			<span class="text1"><b>$profile_txt{'459'}</b></span>
		</td>
	</tr>
	<tr>
 	<td class="windowbg2" align="left">
		<div style="float: left; width: 30%; padding-top: 5px;  padding-bottom: 5px;">
		<b>$profile_amv_txt{'9'}: </b>
		</div>
		<div style="float: left; width: 70%; padding-top: 5px;  padding-bottom: 5px;">
		$userlastlogin
		</div>
		<div style="float: left; width: 30%; padding-top: 5px;  padding-bottom: 5px;">
		<b>$profile_amv_txt{'10'}:</b>
		</div>
		<div style="float: left; width: 70%; padding-top: 5px;  padding-bottom: 5px;">
		$userlastpost
		</div>
		<div style="float: left; width: 30%; padding-top: 5px;  padding-bottom: 5px;">
		<b>$profile_amv_txt{'11'}: </b>
		</div>
		<div style="float: left; width: 70%; padding-top: 5px;  padding-bottom: 5px;">
		$userlastim
		</div>
	</td>
	</tr>
~;

	if ($maxrecentdisplay > 0) {
		$yymain .= qq~
	<tr>
	<td class="windowbg2" align="left">
		<form action="$scripturl?action=usersrecentposts;username=$useraccount{$INFO{'username'}}" method="post">
		$profile_txt{'460'} <select name="viewscount" size="1">
		<option value="5" selected="selected">5</option>
		<option value="10">10</option>
		<option value="15">15</option>
		<option value="$maxrecentdisplay">$maxrecentdisplay</option>
		</select> $profile_txt{'461'} ${$uid.$user}{'realname'}. 
		<input type="submit" value="$profile_txt{'462'}" />
		</form>
	</td>
	</tr>
~;
	}
	$yymain .= qq~
</table>

	<script language="JavaScript1.2" type="text/javascript">
	<!-- //
	var userpic_width = 65;
	var userpic_height = 65;

	function ResizeAvatars(){
		if(navigator.appName == "Microsoft Internet Explorer" && navigator.appVersion.charAt(0) >= 4 && navigator.userAgent.indexOf("Opera") < 0) {
		var imgEle=document.getElementById('avatar');
		if(imgEle) {
		if (userpic_width == 0) { tmpuserpic_width = imgEle.width; } else {tmpuserpic_width = userpic_width;}
		if (userpic_height == 0) { tmpuserpic_height = imgEle.height; } else {tmpuserpic_height = userpic_height;}
		var ratio = imgEle.width / imgEle.height;
		for(z=0;z<2;z++) { 
			if (imgEle.width > tmpuserpic_width) { imgEle.width = tmpuserpic_width; imgEle.height = parseInt(imgEle.width / ratio); }    
			if (imgEle.height > tmpuserpic_height) { imgEle.height = tmpuserpic_height; imgEle.width = parseInt(imgEle.height * ratio); }
		}
		}
		}
	}
	document.onload = ResizeAvatars();
	// -->
	</script>
~;
	$yytitle = "$profile_txt{'92'} $user";
	&template;
	exit;
}

sub usersrecentposts {
	if ($iamguest) { &fatal_error("$profile_txt{'223'}"); }
	if ($INFO{'username'} =~ /\//) { &fatal_error("$profile_txt{'224'}"); }
	if ($INFO{'username'} =~ /\\/) { &fatal_error("$profile_txt{'225'}"); }
	if (!-e ("$memberdir/$INFO{'username'}.vars")) { &fatal_error("$profile_txt{'453'}"); }
	&spam_protection;

	my $curuser = $INFO{'username'};
	&FormatUserName($curuser);
	if ($curuser =~ m~/~)  { &fatal_error($profile_txt{'224'}); }
	if ($curuser =~ m~\\~) { &fatal_error($profile_txt{'225'}); }
	my $display = $FORM{'viewscount'} || 5;
	if ($display =~ /\D/) { &fatal_error($profile_txt{'337'}); }

	# added to avoid flooding by abusing viewcount form inputs
	if ($display > $maxrecentdisplay) { $display = $maxrecentdisplay; }
	my (%data, $numfound, $oldestfound, $curcat, %catname, %cataccess, %catboards, $openmemgr, @membergroups, $tmpa, %openmemgr, $curboard, @threads, @boardinfo, $i, $c, @messages, $tnum, $tsub, $tname, $temail, $tdate, $treplies, $tusername, $ticon, $tstate, $mname, $memail, $mdate, $musername, $micon, $mattach, $mip, $mns, $mtime, $counter, $board, $notify);

	&LoadCensorList;

	unless ($recentloaded) { &Recent_Load($curuser); }
	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }
	foreach $catid (@categoryorder) {
		$boardlist = $cat{$catid};

		(@bdlist) = split(/\,/, $boardlist);
		($catname, $catperms) = split(/\|/, $catinfo{"$catid"});
		&ToChars($catname);
		$cataccess = &CatAccess($catperms);
		if (!$cataccess) { next; }

	  boardcheck: foreach $curboard (@bdlist) {
			($boardname{$curboard}, $boardperms, $boardview) = split(/\|/, $board{"$curboard"});

			my $access = &AccessCheck($curboard, '', $boardperms);
			if (!$iamadmin && $access ne "granted" && $boardview != 1) { next; }

			$catname{$curboard} = $catname;

			fopen(FILE, "$boardsdir/$curboard.txt");
			@threads = <FILE>;
			fclose(FILE);

			if (@threads > $display) { $ii = @threads; }
			else { $ii = $display; }

		  threadcheck: for ($i = 0; $i < $ii; $i++) {
				chomp $threads[$i];
				($tnum, $tsub, $tname, $temail, $tdate, $treplies, $tusername, $ticon, $tstate) = split(/\|/, $threads[$i]);
				if (exists($recent{$tnum})) {
					unless ($tstate =~ /h/) {
						fopen(FILE, "$datadir/$tnum.txt") || next;
						@messages = <FILE>;
						fclose(FILE);

						for ($c = 0; $c < @messages; $c++) {
							chomp $messages[$c];
							($msub, $mname, $memail, $mdate, $musername, $micon, $mattach, $mip, $message, $mns) = split(/\|/, $messages[$c]);
							if ($curuser eq $musername) {
								$mtime = $mdate;
								if ($numfound >= $display && $mtime <= $oldestfound) {
									next boardcheck;
								} else {
									$data{$mtime} = [$curboard, $tnum, $c, $msub, $mname, $memail, $mdate, $musername, $micon, $mattach, $mip, $message, $mns];
									if ($mtime < $oldestfound) { $oldestfound = $mtime; }
									++$numfound;
								}    #end if
							}    #end if
						}    #end for ($c
					}    #end unless($tstate
				} else {
					next;
				}    # end if exists
			}    #end threadcheck
		}    #endboardcheck
	}    #end of foreach $catid(

	$yymain .= qq~
<p align=left><a href="$scripturl?action=viewprofile;username=$useraccount{$curuser}"><b>$profile_txt{'92'} $curuser</b></a></p>
~;
	@messages = sort { $b <=> $a } keys %data;
	if (@messages > $display) { $#messages = $display - 1; }
	$counter = 1;
	for ($i = 0; $i < @messages; $i++) {
		($board, $tnum, $c, $msub, $mname, $memail, $mdate, $musername, $micon, $mattach, $mip, $message, $mns) = @{ $data{ $messages[$i] } };
		$message = &Censor($message);
		$msub    = &Censor($msub);
		&wrap;
		$displayname = $mname;
		if ($enable_ubbc) {
			$ns = $mns;
			if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; }
			&DoUBBC;
		}
		&wrap2;
		&ToChars($msub);
		&ToChars($message);
		&ToChars($boardname{$board});
		if ($enable_notification) { $notify = qq~$menusep<a href="$scripturl?board=$board;action=notify;thread=$tnum/$c">$img{'notify'}</a>~; }
		$mdate = timeformat($mdate);

		# Get the class of this thread, based on lock status and number of replies.
		if ($annboard eq $currentboard && !$iamadmin && !$iamgmod) {
			$replybutton = "";
		} elsif (&AccessCheck($currentboard, 2) eq "granted") {
			$replybutton = qq~$menusep<a href="$scripturl?action=post;num=$tnum/$c#$c;title=PostReply">$img{'reply'}</a> ~;
			$quotebutton = qq~$menusep<a href="$scripturl?action=post;num=$tnum;quote=$c;title=PostReply">$img{'replyquote'}</a>~;
		} else {
			$replybutton = "";
		}

		if (!$iamguest) {
			require "$sourcedir/Favorites.pl";
			$notify = $notify;
		} else {
			$notify = "";
		}

		$yymain .= qq~
<table border="0" width="100%" cellspacing="1" class="bordercolor" style="table-layout: fixed;">
  <tr>
    <td width="5%" align="center" class="titlebg"><span class="text1">$counter</span></td>
    <td width="95%" class="titlebg"><span class="text1"><b>&nbsp;$catname{$board} / $boardname{$board} / <a href="$scripturl?num=$tnum/$c#$c"><span class="text1" ><u>$msub</u></span></a></b></span><br />
    &nbsp;<span class="small" >$profile_txt{'30'}: $mdate&nbsp;</span></td>
  </tr><tr height="80">
    <td colspan="2" class="windowbg2" valign="top">$message</td>
  </tr><tr>
    <td colspan="2" class="catbg" align="right">
    $replybutton $quotebutton $notify &nbsp;
   </td>
  </tr>
</table><br />
~;
		++$counter;
	}
	if ($counter <= 1) { $yymain .= "<span class=\"text1\"><b>$profile_txt{'755'}</b></span>"; }
	else {
		$yymain .= qq~
<p align=left><a href="$scripturl?action=viewprofile;username=$useraccount{$curuser}"><b>$profile_txt{'92'} $curuser</b></a></p></span>
~;
	}
	$yytitle = "$profile_txt{'458'} $memset[1]";
	&template;
	exit;
}

sub DrawGroups {
	my ($availgroups) = @_[0];
	my ($userpos)     = @_[1];
	my @groups, $foundit, %found, $groupsel, $groupsel2, $name;
	%found = ();
	if ($availgroups eq "") { $availgroups = "xk8yj56ndkal"; }
	(@groups) = split(/\,/, $availgroups);
	$groupsel  = "\n";
	$groupsel2 = "";
	$count     = 0;
	foreach $curgroup (@groups) {
		$foundit = 0;
		chomp $curgroup;
		if ($foundit != 1 || $count == $#groups) {
			$k = 0;
			foreach my $key (sort { $a <=> $b } keys %NoPost) {
				($name, undef) = split(/\|/, $NoPost{$key}, 2);
				if ($key ne $userpos) {
					if ($curgroup eq $key) {
						$foundit = 1;
						$found{$key} = 1;
						$groupsel .= qq~<option value="$key" selected="selected">$name</option>\n~;
					}
					if ($found{$key} != 1 && $count == $#groups) { $groupsel2 .= qq~<option value="$key">$name</option>\n~; }
					$k++;
				}
			}
		}
		$count++;
	}
	$groupsel .= $groupsel2;
	$groupsel .= "</select>";
	return $groupsel;
}

sub SidCheck {
	# Check that profile-editing session is still valid
	$sid_check = substr(int(time), 6, 4);
	$cur_sid = reverse($INFO{'sid'});
	if ($cur_sid < 9700) { $cur_sid += 300; }
	else { $sid_check -= 300; }
	if ($cur_sid < $sid_check) {
		&fatal_error("$profile_txt{'898'} <a href=\"$scripturl?action=profileCheck;username=$INFO{'username'}\">$profile_txt{'899'}</a>");
	} else {
		return 1;
	}
}

1;
