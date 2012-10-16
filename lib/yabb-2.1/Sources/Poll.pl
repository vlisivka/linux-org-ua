###############################################################################
# Poll.pl                                                                     #
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

$pollplver = 'YaBB 2.1 $Revision: 1.7 $';
if ($action eq 'detailedversion') { return 1; }

LoadLanguage("Poll");

sub DoVote {
	$pollnum = $INFO{'num'};
	$start   = $INFO{'start'};
	unless (-e "$datadir/$pollnum.poll") { &fatal_error("$polltxt{'14'}: $pollnum"); }

	$novote = 0;
	$vote   = "";
	fopen(FILE, "$datadir/$pollnum.poll");
	$poll_question = <FILE>;
	@poll_data     = <FILE>;
	fclose(FILE);
	chomp $poll_question;
	($dummy, $poll_locked, $dummy, $dummy, $dummy, $dummy, $guest_vote, $dummy, $multi_vote, $dummy, $dummy, $dummy, $vote_limit) = split(/\|/, $poll_question);
	for (my $i = 0; $i < @poll_data; $i++) {
		chomp $poll_data[$i];
		($votes[$i], $options[$i]) = split(/\|/, $poll_data[$i]);
		$tmp_vote = qq~$FORM{"option$i"}~;
		if ($multi_vote && $tmp_vote ne "") {
			$votes[$i]++;
			$novote = 1;
			if ($vote ne "") { $vote .= ","; }
			$vote .= "$tmp_vote";
		}
	}
	$tmp_vote = "$FORM{'option'}";
	if (!$multi_vote && $tmp_vote ne "") { $vote = $tmp_vote; $votes[$tmp_vote]++; $novote = 1; }

	if ($novote == 0 || $vote eq "") { &fatal_error("$polltxt{'12'}"); }
	if ($iamguest && !$guest_vote) { &fatal_error("$polltxt{'8'}"); }
	if ($poll_locked) { &fatal_error("$polltxt{'11'}"); }

	fopen(FILE, "$datadir/$pollnum.polled");
	@polled = <FILE>;
	fclose(FILE);

	for (my $i = 0; $i < @polled; $i++) {
		($voters_ip, $voters_name, $voters_vote, $vote_time) = split(/\|/, $polled[$i]);
		chomp $voters_vote;
		if ($iamguest && $voters_name eq "Guest" && lc $voters_ip eq lc $user_ip) { &fatal_error("$polltxt{'51'}"); }
		elsif ($iamguest  && $voters_name ne "Guest" && lc $voters_ip eq lc $user_ip)     { &fatal_error("$polltxt{'52'}"); }
		elsif (!$iamguest && $voters_name ne "Guest" && lc $username  eq lc $voters_name) { &fatal_error("$polltxt{'50'}"); }
		elsif (!$iamguest && $voters_name eq "Guest" && lc $voters_ip eq lc $user_ip) {
			foreach $oldvote (split(/\,/, $voters_vote)) {
				$votes[$oldvote]--;
			}
			$polled[$i] = "";
			last;
		}
	}

	fopen(FILE, ">$datadir/$pollnum.poll");
	print FILE "$poll_question\n";
	for (my $i = 0; $i < @poll_data; $i++) { print FILE "$votes[$i]|$options[$i]\n"; }
	fclose(FILE);

	fopen(FILE, ">$datadir/$pollnum.polled");
	print FILE "$user_ip|$username|$vote|$date\n";
	print FILE @polled;
	fclose(FILE);

	if ($start) { $start = "/$start"; }
	$yySetLocation = qq~$scripturl?num=$pollnum$start~;
	&redirectexit;

}

sub UndoVote {
	$pollnum = $INFO{'num'};
	unless (-e "$datadir/$pollnum.poll") { &fatal_error("$polltxt{'14'}: $pollnum"); }

	&check_deletepoll;
	if (!$iamadmin && $poll_nodelete{$username}) { &fatal_error($maintxt{'1'}); }

	fopen(FILE, "$datadir/$pollnum.poll");
	$poll_question = <FILE>;
	@poll_data     = <FILE>;
	fclose(FILE);
	chomp $poll_question;
	($dummy, $poll_locked, $dummy) = split(/\|/, $poll_question);
	my @options;
	my @votes;

	for (my $i = 0; $i < @poll_data; $i++) {
		chomp $poll_data[$i];
		($votes[$i], $options[$i]) = split(/\|/, $poll_data[$i]);
	}

	fopen(FILE, "$datadir/$pollnum.polled");
	@polled = <FILE>;
	fclose(FILE);

	if ($FORM{'multidel'} eq "1") {
		&is_admin;
		for (my $i = 0; $i < @polled; $i++) {
			($voters_ip, $voters_name, $voters_vote, $vote_date) = split(/\|/, $polled[$i]);
			chomp $voters_vote;
			$id = $FORM{"$voters_ip-$voters_name"};
			if ($id eq "1") {
				foreach $oldvote (split(/\,/, $voters_vote)) {
					$votes[$oldvote]--;
				}
				$polled[$i] = "";
			}
		}
	} else {
		if ($iamguest)  { &fatal_error("$polltxt{'13'}"); }
		if ($poll_lock) { &fatal_error("$polltxt{'10'}"); }
		$found = 0;
		for (my $i = 0; $i < @polled; $i++) {
			($voters_ip, $voters_name, $voters_vote, $vote_date) = split(/\|/, $polled[$i]);
			chomp $voters_vote;
			if ($voters_name eq $username) {
				$found = 1;
				foreach $oldvote (split(/\,/, $voters_vote)) {
					$votes[$oldvote]--;
				}
				$polled[$i] = "";
				last;
			}
		}
		if (!$found) { &fatal_error("$polltxt{'9'}"); }
	}

	fopen(FILE, ">$datadir/$pollnum.poll");
	print FILE "$poll_question\n";
	for (my $i = 0; $i < @poll_data; $i++) { print FILE "$votes[$i]|$options[$i]\n"; }
	fclose(FILE);

	fopen(FILE, ">$datadir/$pollnum.polled");
	print FILE @polled;
	fclose(FILE);

	if ($start) { $start = "/$start"; }
	$yySetLocation = qq~$scripturl?num=$pollnum$start~;
	&redirectexit;

}

sub LockPoll {
	$pollnum = $INFO{'num'};
	unless (-e "$datadir/$pollnum.poll") { &fatal_error("$polltxt{'14'}: $pollnum"); }

	fopen(FILE, "$datadir/$pollnum.poll");
	$poll_question = <FILE>;
	@poll_data     = <FILE>;
	fclose(FILE);
	chomp $poll_question;
	($poll_question, $poll_locked, $poll_uname, $poll_stuff) = split(/\|/, $poll_question, 4);
	unless ($username eq $poll_uname || $iamadmin || $iamgmod || $iammod) { &fatal_error("$polltxt{'13'}"); }

	if ($poll_locked) { $poll_locked = 0; }
	else { $poll_locked = 1; }

	fopen(FILE, ">$datadir/$pollnum.poll");
	print FILE "$poll_question|$poll_locked|$poll_uname|$poll_stuff\n";
	print FILE @poll_data;
	fclose(FILE);

	if ($start) { $start = "/$start"; }
	$yySetLocation = qq~$scripturl?num=$pollnum$start~;
	&redirectexit;

}

sub votedetails {
	&is_admin;

	$pollnum = $INFO{'num'};
	unless (-e "$datadir/$pollnum.poll") { &fatal_error("$polltxt{'14'}: $pollnum"); }
	if ($start) { $start = "/$start"; }

	&LoadCensorList;

	# Figure out the name of the category
	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }
	($curcat, $catperms) = split(/\|/, $catinfo{"$cat"});

	fopen(FILE, "$datadir/$pollnum.poll");
	$poll_question = <FILE>;
	@poll_data     = <FILE>;
	fclose(FILE);
	chomp $poll_question;
	($poll_question, $poll_locked, $poll_uname, $poll_name, $poll_email, $poll_date, $guest_vote, $hide_results, $multi_vote, $poll_mod, $poll_modname, $poll_comment) = split(/\|/, $poll_question);
	&ToChars($poll_question);
	&ToChars($poll_comment);
	fopen(POLLTP, "$datadir/$pollnum.txt");
	$poll_topic = <POLLTP>;
	fclose(POLLTP);
	chomp $poll_topic;
	($psub, $dummy) = split(/[\|]/, $poll_topic, 2);
	&ToChars($psub);

	# Censor the options.
	$poll_question = &Censor($poll_question);

	if ($ubbcpolls) {
		if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; }
		$message = $poll_question;
		&DoUBBC;
		$poll_question = $message;
	}
	&FromHTML($poll_question);
	&FromHTML($poll_comment);

	my @options;
	my @votes;
	my $totalvotes = 0;
	my $maxvote    = 0;
	for (my $i = 0; $i < @poll_data; $i++) {
		chomp $poll_data[$i];
		($votes[$i], $options[$i]) = split(/\|/, $poll_data[$i]);
		&ToChars($options[$i]);
		$totalvotes += int($votes[$i]);
		if (int($votes[$i]) >= $maxvote) { $maxvote = int($votes[$i]); }
		$options[$i] = &Censor($options[$i]);
		if ($ubbcpolls) {
			$message = $options[$i];
			&DoUBBC;
			$options[$i] = $message;
		}
	}

	fopen(FILE, "$datadir/$pollnum.polled");
	@polled = <FILE>;
	fclose(FILE);

	if ($poll_modname ne "" && $poll_mod ne "") {
		$poll_mod = &timeformat($poll_mod);
		&LoadUser($poll_modname);
		$displaydate = qq~<span class="small">&#171; $polltxt{'45a'}: <a href="$scripturl?action=viewprofile;username=$poll_modname">${$uid.$poll_modname}{'realname'}</a> $polltxt{'46'}: $poll_mod &#187;</span>~;
	}
	if ($poll_uname ne "" && $poll_date ne "") {
		$poll_date = &timeformat($poll_date);
		if ($poll_uname ne 'Guest' && -e "$memberdir/$poll_uname.vars") {
			&LoadUser($poll_uname);
			$displaydate = qq~<span class="small">&#171; $polltxt{'45'}: <a href="$scripturl?action=viewprofile;username=$poll_uname">${$uid.$poll_uname}{'realname'}</a> $polltxt{'46'}: $poll_date &#187;</span>~;
		} else {
			$displaydate = qq~<span class="small">&#171; $polltxt{'45'}: $poll_name $polltxt{'46'}: $poll_date &#187;</span>~;
		}
	}
	&ToChars($boardname);
	$yytitle = $polltxt{'42'};
	$yymain .= qq~
<table width="90%" align="center" cellpadding="0" cellspacing="0">
  <tr>
    <td valign="bottom" align="left" colspan="2">
    <span class="small"><b>		   
	    <a href="$scripturl" class="nav">$mbname</a> &rsaquo;
		<a href="$scripturl?catselect=$curcat" class="nav">$cat</a> &rsaquo;
		<a href="$scripturl?board=$currentboard" class="nav">$boardname</a> &rsaquo;
		<a href="$scripturl?num=$pollnum" class="nav">$psub</a> &rsaquo;
		$polltxt{'42'}</b></span></td>
  </tr>
</table>
<form action="$scripturl?action=undovote;num=$pollnum$start" method="post" style="display:inline">
<input type="hidden" name="multidel" value="1" />
<table cellpadding="4" cellspacing="1" border="0" width="90%" class="bordercolor" align="center">
        <tr>
          <td class="titlebg" colspan="5">$img{'pollicon'} <span class="text1"><b>$polltxt{'42'}</b></span></td>
        </tr><tr>
          <td class="windowbg2" colspan="5"><br /><b>$polltxt{'16'}:</b> $poll_question<br /><br /></td>
        </tr><tr>
          <td class="catbg" align="center"><b>&nbsp;</b></td>
          <td class="catbg" align="center"><b>$txt{'35'}</b></td>
          <td class="catbg" align="center"><b>$polltxt{'30'}</b></td>
          <td class="catbg" align="center"><b>$polltxt{'31'}</b></td>
          <td class="catbg" align="center"><b>$polltxt{'24'}</b></td>
        </tr><tr>~;

	foreach $entry (@polled) {
		chomp $entry;
		$voted = "";
		($voters_ip, $voters_name, $voters_vote, $vote_date) = split(/\|/, $entry);
		$id = qq~$voters_ip-$voters_name~;
		if ($voters_name ne 'Guest' && -e "$memberdir/$voters_name.vars") {
			&LoadUser($voters_name);
			$voters_name = qq~<a href="$scripturl?action=viewprofile;username=$voters_name">${$uid.$voters_name}{'realname'}</a>~;
		}
		foreach $oldvote (split(/\,/, $voters_vote)) {
			&FromHTML($options[$oldvote]);
			$voted .= qq~$options[$oldvote]<br />~;
		}

		$vote_date = &timeformat($vote_date);
		$yymain .= qq~
          <td class="windowbg2" align="center"><input type="checkbox" name="$id" value="1" /></td>
          <td class="windowbg2">$voters_name</td>
          <td class="windowbg2" align="center">$voters_ip</td>
          <td class="windowbg2" align="center">$vote_date</td>
          <td class="windowbg2">$voted</td>
        </tr><tr>~;
	}

	$yymain .= qq~
          <td class="titlebg" align="center" colspan="5"><input type="submit" value="$polltxt{'49'}" /></td>
        </tr>
</table>
</form>~;
	&template;
	exit;

}

sub display_poll {
	$pollnum = @_[0];

	&LoadCensorList;

	fopen(FILE, "$datadir/$pollnum.poll");
	my $poll_question = <FILE>;
	my @poll_data     = <FILE>;
	fclose(FILE);
	chomp $poll_question;
	chomp @poll_data;

	($poll_question, $poll_locked, $poll_uname, $poll_name, $poll_email, $poll_date, $guest_vote, $hide_results, $multi_vote, $poll_mod, $poll_modname, $poll_comment)
			= split(/\|/, $poll_question);
	&ToChars($poll_question);
	&ToChars($poll_comment);

	fopen(FILE, "$datadir/$pollnum.polled");
	my @polled = <FILE>;
	fclose(FILE);
	chomp @polled;

	my $totalvoted = @polled;

	$users_votetext = "";
	$has_voted      = 0;
	if ((!$guest_vote || $poll_locked) && $iamguest) {
		$has_voted = 4;
	} else {
		foreach $tmpLine (@polled) {
			($voters_ip, $voters_name, $voters_vote, $vote_date) = split(/\|/, $tmpLine);
			if ($iamguest && $voters_name eq "Guest" && lc $voters_ip eq lc $user_ip) { $has_voted = 1; last; }
			elsif ($iamguest && $voters_name ne "Guest" && lc $voters_ip eq lc $user_ip) { $has_voted = 2; last; }
			elsif (!$iamguest && lc $username eq lc $voters_name) {
				$has_voted      = 3;
				$users_votedate = &timeformat($vote_date);
				@users_vote     = split(/\,/, $voters_vote);
				$users_votetext = qq~$polltxt{'64'} $users_votedate:~;
				last;
			}
		}
	}

	my @options;
	my @votes;
	my $totalvotes = 0;
	my $maxvote    = 0;
	for (my $i = 0; $i < @poll_data; $i++) {
		($votes[$i], $options[$i]) = split(/\|/, $poll_data[$i]);

		&ToChars($options[$i]);

		$totalvotes += int($votes[$i]);
		if (int($votes[$i]) >= $maxvote) { $maxvote = int($votes[$i]); }
	}

	$endedtext = "";
	if (!$iamguest && ($username eq $poll_uname || $iamadmin || $iamgmod || $iammod)) {
		if ($poll_locked) {
			$lockpoll = qq~<a href="$scripturl?action=lockpoll;num=$pollnum" class="altlink">$img{'openpoll'}</a>~;
		} else {
			$lockpoll = qq~<a href="$scripturl?action=lockpoll;num=$pollnum" class="altlink">$img{'closepoll'}</a>~;
		}
		$modifypoll = qq~$menusep<a href="$scripturl?action=modify;board=$currentboard;message=Poll;thread=$pollnum" class="altlink">$img{'modifypoll'}</a>~;
		$deletepoll = qq~$menusep<a href="javascript:document.removepoll.submit();" class="altlink" onclick="return confirm('$polltxt{'44'}')">$img{'deletepoll'}</a>~;
		if ($iamadmin) { $displayvoters = qq~<a href="$scripturl?action=showvoters;num=$pollnum">$img{'viewvotes'}</a>~; }
		if ($hide_results) {
			$endedtext = qq~<span style="color: #FF0000;"><b>$polltxt{'53'}</b></span></td>
                </tr>
                <tr>
                  <td colspan="2" align="center" class="windowbg2"><br />~;
			$hide_results = 0;
			$bgclass      = "windowbg2";
		}
	}

	if ($poll_modname ne "" && $poll_mod ne "" && $showmodify) {
		$poll_mod = &timeformat($poll_mod);
		&LoadUser($poll_mod);
		$displaydate = qq~<span class="small">&#171; $polltxt{'45a'}: <a href="$scripturl?action=viewprofile;username=$poll_modname">${$uid.$poll_modname}{'realname'}</a> $polltxt{'46'}: $poll_mod &#187;</span>~;
	} elsif ($poll_uname ne "" && $poll_date ne "") {
		$poll_date = &timeformat($poll_date);
		if ($poll_uname ne 'Guest' && -e "$memberdir/$poll_uname.vars") {
			&LoadUser($poll_uname);
			$displaydate = qq~<span class="small">&#171; $polltxt{'45'}: <a href="$scripturl?action=viewprofile;username=$poll_uname">${$uid.$poll_uname}{'realname'}</a> $polltxt{'46'}: $poll_date &#187;</span>~;
		} elsif ($poll_name ne "") {
			$displaydate = qq~<span class="small">&#171; $polltxt{'45'}: $poll_name $polltxt{'46'}: $poll_date &#187;</span>~;
		} else {
			$displaydate = "";
		}
	} else {
		$displaydate = "";
	}

	if ($poll_locked) {
		$bgclass   = "windowbg2";
		$endedtext = qq~<span style="color: #FF0000;"><b>$polltxt{'22'}</b></span></td>
                </tr>
                <tr>
                  <td colspan="2" align="center" class="windowbg2"><br />~;
		$poll_icon = qq~$img{'polliconclosed'}~;
		$has_voted = 5;
	} else {
		$bgclass   = "windowbg2";
		$poll_icon = qq~$img{'pollicon'}~;
	}

	# Censor the question.
	$poll_question = &Censor($poll_question);
	$poll_comment  = &Censor($poll_comment);

	if ($ubbcpolls) {
		if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; }
		$message = $poll_question;
		&DoUBBC;
		$poll_question = $message;
	}
	&FromHTML($poll_question);
	&FromHTML($poll_comment);

	$deletevote = "";
	if ($has_voted) {
		if ($users_votetext) {
			if (!$yyYaBBCloaded && $ubbcpolls) { require "$sourcedir/YaBBC.pl"; }
			$footer = qq~<br /><span style="font-weight: bold;">$users_votetext</span><br />~;
			for ($i = 0; $i < @users_vote; $i++) {
				$optnum = $users_vote[$i];
				if ($ubbcpolls) {
					$message = $options[$optnum];
					&DoUBBC;
					$options[$optnum] = $message;
				}
				&FromHTML($options[$optnum]);
				$footer .= qq~$options[$optnum]<br />~;
			}
		}
		$footer .= qq~<br /><b>$polltxt{'17'}: $totalvoted</b>~;
		$width      = qq~~;
		$deletevote = qq~<a href="$scripturl?action=undovote;num=$pollnum">$img{'deletevote'}</a>~;
		if ($iamadmin && $displayvoters) { $deletevote .= $menusep; }
	} else {
		$footer  = qq~<input type="submit" value="$polltxt{'18'}" />~;
		$width   = qq~ width="80%"~;
		$bgclass = "windowbg2";
	}
	&check_deletepoll;
	if ($iamguest || $poll_locked || $poll_nodelete{$username}) { $deletevote = ""; }

	$pollmain = qq~
<form name="poll" method="post" action="$scripturl?action=vote;num=$pollnum" style="display:inline">
<table cellpadding="4" cellspacing="1" border="0" width="100%" class="bordercolor" align="center">
  <tr>
     <td class="titlebg" valign="middle" align="left">
		<div style="float: left; width: 50%; text-align: left;">
			<span class="text1">$poll_icon <b>$polltxt{'15'}</b></span>
		</div>
		<div style="float: left; width: 50%; text-align: right;">
			<span class="small">$lockpoll$modifypoll$deletepoll</span>
		</div>
	</td>
  </tr>
  <tr>
     <td valign="top" class="catbg">
	<div style="width: 100%;">
		<b>$polltxt{'16'}:</b> $poll_question<br />
	</div>
</td>
</tr>
<tr>
<td colspan="2" align="center" class="$bgclass">
	$endedtext
    <div style="width: 100%;"><br />~;

	if ($has_voted && $hide_results && !$poll_locked) {

		# Display Poll Hidden Message
		$pollmain .= qq~$polltxt{'47'}<br /><span class="small">($polltxt{'48'})</span><br />~;

	} else {
		for ($i = 0; $i < @options; $i++) {

			unless ($options[$i]) { next; }

			# Censor the options.
			$options[$i] = &Censor($options[$i]);

			$options[$i] =~ s~[\n\r]~~g;
			&FromHTML($options[$i]);

			if ($ubbcpolls) {
				if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; }
				$message = $options[$i];
				&DoUBBC;
				$options[$i] = $message;
			}

			my $input = '';
			if ( not $has_voted ) {
				
				if ( $multi_vote ) {
					$input = qq~<input type="checkbox" name="option$i" value="$i" />~;
				} else {
					$input = qq~<input type="radio" name="option" value="$i" />~;
				}
			}

			# Display Poll Results
			$pollpercent = 0;
			$pollbar     = 0;
			if ($totalvotes ne 0 && $maxvote ne 0) {
				$pollpercent = int(1000 * $votes[$i] / $totalvotes);
				$pollpercent = $pollpercent / 10;
				$pollbar     = int(150 * $votes[$i] / $maxvote);
			}

			$pollmain .= qq~
			<div style="clear: both;">
	<div style="float: left; width: 50%; text-align: right;"><b>$options[$i]&nbsp;&nbsp;</b></div>
        <div style="float: left; width: 25px; text-align: right;">$input</div>
	<div style="float: left; text-align: left;">&nbsp;<img src="$imagesdir/poll_left.gif" align="middle" alt="" /><img src="$imagesdir/poll_middle.gif" height="12" width="$pollbar" align="middle" alt="" /><img src="$imagesdir/poll_right.gif" align="middle" alt="" /> $votes[$i] ($pollpercent%)</div>
			</div>~;

		}
	}
	$pollmain .= qq~
		<br />
		</div>
		<div style="width: 100%;">
		  <br />$footer
		</div>~;
	if ($poll_comment ne "") {
		$message = $poll_comment;
		if ($enable_ubbc) {
			if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; }
			&DoUBBC;
		}
		$poll_comment = $message;
		$pollmain .= qq~
		<div style="width: 100%;"><br />$poll_comment</div>~;
	}
	$pollmain .= qq~
		<div style="width: 100%; clear: both;">
		  <div style="width: 100%; clear: both; text-align: left;">
			<span class="small">$displaydate</span>
		  </div>
		  <div style="width: 100%; clear: both; text-align: right;">
            <span class="small">$deletevote$displayvoters</span>
		  </div>
		</div>   
    </td>
  </tr>
</table>
</form>~;

}

sub check_deletepoll {
	fopen(FILE, "$datadir/$pollnum.poll");
	$poll_chech = <FILE>;
	fclose(FILE);
	chomp $poll_question;
	(undef, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef, $vote_limit) = split(/\|/, $poll_chech);
	$poll_nodelete{$username} = 0;
	if (!$vote_limit) {
		$poll_nodelete{$username} = 1;
		return;
	}
	if (-e "$datadir/$pollnum.polled") {
		fopen(FILE, "$datadir/$pollnum.polled");
		@chpolled = <FILE>;
		fclose(FILE);
		foreach $chvoter (@chpolled) {
			(undef, $chvotersname, undef, $chvotedate) = split(/\|/, $chvoter);
			if ($chvotersname eq $username) {
				$chdiff = $date - $chvotedate;
				if ($chdiff > ($vote_limit * 60)) {
					$poll_nodelete{$username} = 1;
					last;
				}
			}
		}
	}
}

1;
