###############################################################################
# SendTopic.pl                                                                #
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

$sendtopicplver = 'YaBB 2.1 $Revision: 1.1 $';
if ($action eq 'detailedversion') { return 1; }

LoadLanguage("SendTopic");

sub SendTopic {
	$topic = $INFO{'topic'};
	&MessageTotals("load", $topic);
	$board = ${$topic}{'board'};
	&fatal_error($sendtopic_txt{'709'}) unless ($board ne '' && $board ne '_' && $board ne ' ');
	&fatal_error($sendtopic_txt{'710'}) unless ($topic ne '' && $topic ne '_' && $topic ne ' ');

	fopen(FILE, "$datadir/$topic.txt") || &fatal_error("201 $sendtopic_txt{'106'}: $sendtopic_txt{'23'} $topic.txt", 1);
	@messages = <FILE>;
	fclose(FILE);
	($subject) = split(/\|/, $messages[0]);

	$yymain .= qq~
<form action="$scripturl?action=sendtopic2" method="post">
<table border="0"  align="center" cellspacing="1" cellpadding="0" class="bordercolor">
  <tr>
    <td width="100%" class="windowbg">
    <table width="100%" border="0" cellspacing="0" cellpadding="3">
      <tr>
        <td class="titlebg" colspan="2">
        <img src="$imagesdir/email.gif" alt="" border="0" />
        <span class="text1"><b>$sendtopic_txt{'707'}&nbsp; &#171; $subject &#187; &nbsp;$sendtopic_txt{'708'}</b></span></td>
      </tr><tr>
        <td class="windowbg" align="right" valign="top">
        <b>$sendtopic_txt{'335'}</b>
        </td>
        <td class="windowbg" align="left" valign="middle">
        <input type="text" name="y_name" size="20" maxlength="40" value="${$uid.$username}{'realname'}" />
        </td>
      </tr><tr>
        <td class="windowbg" align="right" valign="top">
        <b>$sendtopic_txt{'336'}</b>
        </td>
        <td class="windowbg" align="left" valign="middle">
        <input type="text" name="y_email" size="20" maxlength="40" value="${$uid.$username}{'email'}" />
        </td>
      </tr><tr>
        <td class="windowbg" align="center" valign="top" colspan="2">
        <hr width="100%" size="1" class="hr" />
        </td>
      </tr><tr>
        <td class="windowbg" align="right" valign="top">
        <b>$sendtopic_txt{'717'}</b>
        </td>
        <td class="windowbg" align="left" valign="middle">
        <input type="text" name="r_name" size="20" maxlength="40" />
        </td>
      </tr><tr>
        <td class="windowbg" align="right" valign="top">
        <b>$sendtopic_txt{'718'}</b>
        </td>
        <td class="windowbg" align="left" valign="middle">
        <input type="text" name="r_email" size="20" maxlength="40" />
        </td>
      </tr>
~;

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

	$yymain .= qq~
	<tr>
        <td class="windowbg" align="center" valign="middle" colspan="2">
		<input type="hidden" name="board" value="$board" />
		<input type="hidden" name="topic" value="$topic" />
        <input type="submit" name="Send" value="$sendtopic_txt{'339'}" />
        </td>
      </tr>
    </table>
    </td>
  </tr>
</table>
</form>
~;
	$yytitle = "$sendtopic_txt{'707'}&nbsp; &#171; $subject &#187; &nbsp;$sendtopic_txt{'708'}";
	&template;
	exit;

}

sub SendTopic2 {
	$topic = $FORM{'topic'};
	$board = $FORM{'board'};
	&fatal_error($sendtopic_txt{'709'}) unless ($board ne '' && $board ne '_' && $board ne ' ');
	&fatal_error($sendtopic_txt{'710'}) unless ($topic ne '' && $topic ne '_' && $topic ne ' ');

	$yname  = $FORM{'y_name'};
	$rname  = $FORM{'r_name'};
	$yemail = $FORM{'y_email'};
	$remail = $FORM{'r_email'};
	$yname =~ s/\A\s+//;
	$yname =~ s/\s+\Z//;
	$rname =~ s/\A\s+//;
	$rname =~ s/\s+\Z//;

	if ($regcheck) {
		require "$sourcedir/Decoder.pl";
		if (not checkcaptcha ()) {
			&fatal_error ("$floodtxt{'4'}");
		}
	}

	&fatal_error($sendtopic_txt{'75'}) unless ($yname ne '' && $yname ne '_' && $yname ne ' ');
	&fatal_error($sendtopic_txt{'568'}) if (length($yname) > 25);
	&fatal_error("$sendtopic_txt{'76'}") if ($yemail eq '');
	&fatal_error("$sendtopic_txt{'240'} $sendtopic_txt{'69'} $sendtopic_txt{'241'}") if ($yemail !~ /[\w\-\.\+]+\@[\w\-\.\+]+\.(\w{2,4}$)/);
	&fatal_error("$sendtopic_txt{'500'}") if (($yemail =~ /(@.*@)|(\.\.)|(@\.)|(\.@)|(^\.)|(\.$)/) || ($yemail !~ /^.+@\[?(\w|[-.])+\.[a-zA-Z]{2,4}|[0-9]{1,4}\]?$/));
	&fatal_error($sendtopic_txt{'75'}) unless ($rname ne '' && yname ne '_' && $rname ne ' ');
	&fatal_error($sendtopic_txt{'568'}) if (length($rname) > 25);
	&fatal_error("$sendtopic_txt{'76'}") if ($remail eq '');
	&fatal_error("$sendtopic_txt{'240'} $sendtopic_txt{'69'} $sendtopic_txt{'241'}") if ($remail !~ /[\w\-\.\+]+\@[\w\-\.\+]+\.(\w{2,4}$)/);
	&fatal_error("$sendtopic_txt{'500'}")                                            if (($remail =~ /(@.*@)|(\.\.)|(@\.)|(\.@)|(^\.)|(\.$)/) || ($remail !~ /^.+@\[?(\w|[-.])+\.[a-zA-Z]{2,4}|[0-9]{1,4}\]?$/));

	fopen(FILE, "$datadir/$topic.txt") || &fatal_error("201 $sendtopic_txt{'106'}: $sendtopic_txt{'23'} $topic.txt", 1);
	@messages = <FILE>;
	fclose(FILE);
	($subject) = split(/\|/, $messages[0]);
	&FromHTML($subject);
	&sendmail($remail, "$sendtopic_txt{'118'}:  $subject ($sendtopic_txt{'318'} $yname)", "$sendtopic_txt{'711'} $rname,\n\n$sendtopic_txt{'712'}: $subject, $sendtopic_txt{'30'} $mbname. $sendtopic_txt{'713'}:\n\n$scripturl?num=$topic\n\n\n$sendtopic_txt{'714'},\n$yname", $yemail);

	$yySetLocation = qq~$scripturl?num=$topic~;
	&redirectexit;
}

1;
