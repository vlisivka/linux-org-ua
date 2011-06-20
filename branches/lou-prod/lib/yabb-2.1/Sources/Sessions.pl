###############################################################################
# Sessions.pl                                                                 #
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

$sessionsplver = 'YaBB 2.1 $Revision: 1.1 $';
if ($action eq 'detailedversion') { return 1; }

LoadLanguage("Sessions");

sub SessionReval {
	if (${$uid.$username}{'sesquest'} eq "" || ${$uid.$username}{'sesquest'} eq "password") {
		$sesremark   = qq~<br /><br /><fieldset><i>$session_txt{'10'}</fieldset></i>~;
		$sesquestion = "password";
		$sestype     = "password";
	} else {
		$sesremark   = "";
		$sesquestion = "${$uid.$username}{'sesquest'}";
		$sestype     = "text";
	}

	$yymain .= qq~
<br /><br />
<form action="$scripturl?action=revalidatesession2" method="post" name="form">
<div class="bordercolor" style="padding: 1px; width: 50%; margin-left: auto; margin-right: auto;">
    <table width="100%" cellspacing="0" cellpadding="3">
      <tr>
        <td class="titlebg" colspan="3" align="left">
        <img src="$imagesdir/session.gif" alt="" /><b>$img_txt{'34a'}</b>
		</td>
      </tr><tr>
        <td align="left" class="windowbg" colspan="3">$session_txt{'3'}<br /><br />$session_txt{'4'}$sesremark</td>
      </tr><tr>
        <td align="right" class="windowbg"><b>$sesquest_txt{$sesquestion}:</b></td>
        <td align="left" class="windowbg"><input type="$sestype" name="sesanswer" size="20" tabindex="1" /></td>
      </tr><tr>
        <td align="center" colspan="2" class="windowbg"><br /><input type="submit" value="$img_txt{'34a'}" tabindex="2" /></td>
      </tr>
    </table>
</div>
</form>
~;
	$yytitle = "$img_txt{'34a'}";
	&template;
	exit;
}

sub SessionReval2 {
	$FORM{'cookielength'}   = 360;
	$FORM{'cookieneverexp'} = 1;
	&fatal_error("$session_txt{'7'}") if ($FORM{'sesanswer'} eq "");
	if (${$uid.$username}{'sesquest'} eq "" || ${$uid.$username}{'sesquest'} eq "password") {
		$question = ${$uid.$username}{'password'};
		$answer   = &encode_password("$FORM{'sesanswer'}");
		chomp $answer;
	} else {
		$question = ${$uid.$username}{'sesanswer'};
		$answer = &scramble($FORM{'sesanswer'}, $username);
		chomp $answer;
	}
	if ($answer ne $question) {
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
		require "$sourcedir/LogInOut.pl";
		$sharedLogin_text = qq~$session_txt{'6'}~;
		$action           = "login";
		&Login;
	} else {
		$realname     = ${$uid.$username}{'realname'};
		$realemail    = ${$uid.$username}{'email'};
		$iamadmin     = ${$uid.$username}{'position'} eq 'Administrator' ? 1 : 0;
		$iamgmod      = ${$uid.$username}{'position'} eq 'Global Moderator' ? 1 : 0;
		$sessionvalid = 1;
	}
	if ($FORM{'cookielength'} < 1 || $FORM{'cookielength'} > 9999) { $FORM{'cookielength'} = $Cookie_Length; }
	if (!$FORM{'cookieneverexp'}) { $ck{'len'} = "\+$FORM{'cookielength'}m"; }
	else { $ck{'len'} = 'Sunday, 17-Jan-2038 00:00:00 GMT'; }
	${$uid.$username}{'session'} = &encode_password($user_ip);
	chomp ${$uid.$username}{'session'};
	&UserAccount($username, "update");
	&UpdateCookie("write", $username, ${$uid.$username}{'password'}, ${$uid.$username}{'session'}, "/", $ck{'len'});

	&WriteLog;
	$yySetLocation = qq~$scripturl~;
	&redirectexit;
}

1;
