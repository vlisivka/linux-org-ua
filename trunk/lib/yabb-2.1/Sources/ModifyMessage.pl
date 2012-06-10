###############################################################################
# ModifyMessage.pl                                                            #
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

$modifymessageplver = 'YaBB 2.1 $Revision: 1.10 $';
if ($action eq 'detailedversion') { return 1; }

if (!$post_txt_loaded) {
	LoadLanguage("Post");
	$post_txt_loaded = 1;
}
LoadLanguage("FA");

$set_subjectMaxLength ||= 100;

sub ModifyMessage {
	my ($mfn);
	if ($iamguest) { &fatal_error($post_txt{'223'}); }

	if ($currentboard eq '') { &fatal_error($post_txt{'1'}); }

	my ($mnum, $msub, $mname, $memail, $mdate, $mreplies, $musername, $micon, $mstate, @messages, $curmessage, $msubject, $mattach, $mip, $mmessage, $mns, $mlm, $mlmb);
	$threadid = $INFO{'thread'};
	$postid   = $INFO{'message'};

	my ($filetype_info, $filesize_info, $extensions);
	$extensions = join(" ", @ext);
	$filetype_info = $checkext == 1 ? qq~$fatxt{'2'} $extensions~ : qq~$fatxt{'2'} $fatxt{'4'}~;
	$filesize_info = $limit != 0    ? qq~$fatxt{'3'} $limit KB~   : qq~$fatxt{'3'} $fatxt{'5'}~;

	($mnum, $msub, $mname, $memail, $mdate, $mreplies, $musername, $micon, $mstate) = split(/\|/, $yyThreadLine);

	$postthread = 2;

	if ($mstate =~ /l/i) {
		&fatal_error($post_txt{'90'});
	} else {
		if ($tlnomodflag) {
			unless ($iamadmin || $iamgmod || $iammod) {
				$tlnomodtimesecs = $tlnomodtime * 3600 * 24;
				$tltime          = $mdate + $tlnomodtimesecs;
				$tlcurrenttime   = time + (3600 * $timeoffset);
				if ($tlcurrenttime > $tltime) {
					&fatal_error("$timelocktxt{'01'}$tlnomodtime$timelocktxt{'02'}");
				}
			}
		}
	}
	if ($postid eq "Poll") {
		unless (-e "$datadir/$threadid.poll") { &fatal_error("$post_polltxt{'13'}"); }

		fopen(FILE, "$datadir/$threadid.poll");
		@poll_data = <FILE>;
		fclose(FILE);
		chomp $poll_data[0];
		($poll_question, $poll_locked, $poll_uname, $poll_name, $poll_email, $poll_date, $guest_vote, $hide_results, $multi_choice, $poll_mod, $poll_modname, $poll_comment, $vote_limit) = split(/\|/, $poll_data[0]);
		&FromHTML($poll_question);
		&FromHTML($poll_comment);
		&ToChars($poll_question);
		&ToChars($poll_comment);

		for (my $i = 0; $i < @poll_data; $i++) {
			chomp $poll_data[$i];
			($votes[$i], $options[$i]) = split(/\|/, $poll_data[$i]);
			&FromHTML($options[$i]);
			&ToChars($options[$i]);
		}

		unless ($poll_uname eq $username || $iammod || $iamadmin || $iamgmod) { &fatal_error("$post_polltxt{'13'}"); }

		$poll_comment =~ s~<br \/>~\n~g;
		$poll_comment =~ s~<br>~\n~g;
		$pollthread = 2;
		$settofield = "question";

	} else {

		fopen(FILE, "$datadir/$threadid.txt") || &fatal_error("$post_txt{'23'} $threadid.txt", 1);
		@messages = <FILE>;
		fclose(FILE);

		$curmessage = $messages[$postid];
		chomp $curmessage;
		($sub, $mname, $memail, $mdate, $musername, $micon, $mattach, $mip, $message, $mns, $mlm, $mlmb, $mfn) = split(/\|/, $messages[$postid]);

		$set_subjectMaxLength += 4 if ($postid);

		$messagedate      = $mdate;
		$registrationdate = ${$uid.$username}{'regtime'};

		if (($registrationdate > $messagedate || $musername ne $username) && !($iammod || $iamadmin || $iamgmod)) {
			&fatal_error($post_txt{'67'});
		}

		$lastmod = $mlm ? &timeformat($mlm) : '-';
		$nscheck = $mns ? ' checked'        : '';

		$lastmod = qq~
<tr>
	<td valign="top" width="23%"><span class="text1"><b>$post_txt{'211'}:</b></span></td>
	<td><span class="text1">$lastmod</span></td>
</tr>
~;
		$icon = $micon;
		if    ($icon eq "xx")          { $ic1  = " selected"; }
		elsif ($icon eq "thumbup")     { $ic2  = " selected"; }
		elsif ($icon eq "thumbdown")   { $ic3  = " selected"; }
		elsif ($icon eq "exclamation") { $ic4  = " selected"; }
		elsif ($icon eq "question")    { $ic5  = " selected"; }
		elsif ($icon eq "lamp")        { $ic6  = " selected"; }
		elsif ($icon eq "smiley")      { $ic7  = " selected"; }
		elsif ($icon eq "angry")       { $ic8  = " selected"; }
		elsif ($icon eq "cheesy")      { $ic9  = " selected"; }
		elsif ($icon eq "grin")        { $ic10 = " selected"; }
		elsif ($icon eq "sad")         { $ic11 = " selected"; }
		elsif ($icon eq "wink")        { $ic12 = " selected"; }
		$isatt = $mfn;
		chomp $isatt;
		$message =~ s~<br \/>~\n~ig;
		$message =~ s~<br>~\n~ig;
		$message =~ s/ \&nbsp; \&nbsp; \&nbsp;/\t/ig;

		$settofield = "message";
	}
	$submittxt   = "$post_txt{'10'}";
	$destination = "modify2";
	$is_preview  = 0;
	$post        = "postmodify";
	$preview     = "previewmodify";
	if ($mfn ne "") {
		$oldattcheck = qq~checked~;
		$newattcheck = qq~~;
	} else {
		$newattcheck = qq~checked~;
		$oldattcheck = qq~~;
	}
	require "$sourcedir/Post.pl";
	$yytitle = "$post_txt{'66'}";
	$mename  = qq~$mname~;
	&Postpage;
	&template;
	exit;
}

sub ModifyMessage2 {
	if ($iamguest) { &fatal_error($post_txt{'223'}); }

	if ($FORM{'previewmodify'}) {
		$mename = qq~$FORM{'mename'}~;
		require "$sourcedir/Post.pl";
		&Preview;
	}

	# the post is to be deleted...
	if ($INFO{'d'} eq '1') {
		$threadid = $FORM{'thread'};
		$postid   = $FORM{'id'};

		if ($postid eq "Poll") {
			unlink("$datadir/$threadid.poll");
			unlink("$datadir/$threadid.polled");
			$yySetLocation = qq~$scripturl?num=$threadid~;
			&redirectexit;
		} else {
			fopen(FILE, "$datadir/$threadid.txt") || &fatal_error("$post_txt{'23'} $threadid.txt", 1);
			@messages = <FILE>;
			fclose(FILE);
			$msgcnt = @messages;

			# Make sure the user is allowed to edit this post.
			if ($postid >= 0 && $postid < $msgcnt) {

				chomp $messages[$postid];
				($msub, $mname, $memail, $mdate, $musername, $micon, $mattach, $mip, $mmessage, $mns, $mlm, $mlmb, $mfn) = split(/\|/, $messages[$postid]);
				$messagedate = $mdate;

				if ($tlnodelflag) {
					unless ($iamadmin || $iamgmod || $iammod) {
						$tlnodeltimesecs = $tlnodeltime * 3600 * 24;
						$tldtime         = $mdate + $tlnodeltimesecs;
						$tldcurrenttime  = time + (3600 * $timeoffset);
						if ($tldcurrenttime > $tldtime) {
							&fatal_error("$timelocktxt{'01'}$tlnodeltime$timelocktxt{'02a'}");
						}
						unless ($registrationdate < $messagedate && $musername eq $username) {
							&fatal_error("$post_txt{'73'}");
						}
					}
				}
			} else {
				&fatal_error("$post_txt{'580'} $postid");
			}
			$iamposter = ($musername eq $username && $msgcnt == 1) ? 1 : 0;
			$FORM{"del$postid"} = 1;
			&MultiDel;
		}
	}

	if ($FORM{'file'} && $FORM{'w_file'} eq "attachnew") {
		$file = $FORM{'file'};
		$OS   = $^O;             # operating system name
		if    ($OS =~ /darwin/i) { $isUNIX = 1; }
		elsif ($OS =~ /win/i)    { $isWIN  = 1; }
		else { $isUNIX = 1; }
		$mylimit    = 1024 * $limit;
		$mydirlimit = 1024 * $dirlimit;
		$fixfile    = $filename;
		$fixfile =~ s/.+\\([^\\]+)$|.+\/([^\/]+)$/$1/;
		$fixfile =~ s/[#%+,\/:?"<>'|@^!]//g;         # edit in between [ ] to include characters you dont want to allow in filenames (dont put a . there or you wont be able to get any file extensions).
		$fixfile =~ s/ /_/g;                         # replaces spaces in filenames with a "_" character.

		# replace . with _ in the filename except for the extension
		$fixname = $fixfile;
		$fixname =~ s/(\S+)(\.\S+\Z)/$1/gi;
		$fixext = $2;
		$fixext  =~ s/(pl|cgi|php)/_$1/gi;
		$fixname =~ s/\./\_/g;
		$fixfile = qq~$fixname$fixext~;

		if ($overwrite == 2 && (-e "$uploaddir/$fixfile")) { &fatal_error("$fatxt{'8'}"); }
		if (!$overwrite) {
			$fixfile = check_existence($uploaddir, $fixfile);
		}
		if ($checkext == 0) { $match = 1; }
		else {
			foreach $ext (@ext) {
				chomp($ext);
				if (grep /$ext$/i, $fixfile) { $match = 1; last; }
			}
		}
		if ($match) {
			if ($allowattach == 1 && (($allowguestattach == 0 && $username ne 'Guest') || $allowguestattach == 1)) {
				$upload_okay = 1;
			}
		} else {
			&write_error("$fatxt{'20'} @ext ($fixfile)");
		}
		if ($mydirlimit > 0) {
			&dirstats;
		}
		$filesize   = $ENV{'CONTENT_LENGTH'} - $postsize;
		$filesizekb = int($filesize / 1024);
		if ($filesize > $mylimit && $mylimit != 0) {
			$filesizediff = $filesizekb - $limit;
			if ($filesizediff == 1) { $sizevar = "kilobyte"; }
			else { $sizevar = "kilobytes"; }
			&write_error("$fatxt{'21'} $filesizediff $sizevar $fatxt{'21b'}");
		} elsif ($filesize > $spaceleft && $mydirlimit != 0) {
			$filesizediff = $filesizekb - $kbspaceleft;
			if ($filesizediff == 1) { $sizevar = "kilobyte"; }
			else { $sizevar = "kilobytes"; }
			&write_error("$fatxt{'22'} $filesizediff $sizevar $fatxt{'22b'}");
		}
		$save_file = "$uploadurl/$fixfile";
		if ($upload_okay == 1) {

			# create a new file on the server using the formatted ( new instance ) filename
			if (fopen(NEWFILE, ">$uploaddir/$fixfile")) {
				binmode NEWFILE, ':bytes';

				# start reading users HD 1 kb at a time.				                                    
				while (read($filename, $buffer, 1024)) {

					# print each kb to the new file on the server
					print NEWFILE $buffer;
				}

				# close the new file on the server and we're done
				fclose(NEWFILE);
			} else {

				# return the server's error message if the new file could not be created
				&fatal_error("$fatxt{'60'} $uploaddir");
			}
		}

		# check if file has actually been uploaded, by checking the file has a size
		if (-s "$uploaddir/$fixfile") {
			$upload_ok = 1;
		} else {

			# delete the file as it has no content
			unlink("$uploaddir/$fixfile");
			&fatal_error("$fatxt{'59'} $fixfile");
		}

		if (($fixfile =~ /(jpg|gif|png|jpeg)$/i)) {
			$okatt = 1;
			if ($fixfile =~ /(gif)$/i) {
				fopen(ATTFILE, "$uploaddir/$fixfile");
				binmode ATTFILE, ':bytes';
				read(ATTFILE, $header, 10);
				($giftest, undef, undef, undef, undef, undef) = unpack("a3a3C4", $header);
				fclose(ATTFILE);
				if ($giftest ne "GIF") { $okatt = 0; }
			}
			fopen(ATTFILE, "$uploaddir/$fixfile");
			binmode ATTFILE, ':bytes';
			while ( read(ATTFILE, $buffer, 1024) ) {
				if ($buffer =~ /\<html/ig || $buffer =~ /\<script/ig) { $okatt = 0; last; }
			}
			fclose(ATTFILE);
			if(!$okatt) {
				# delete the file as it contains illegal code
				unlink("$uploaddir/$fixfile");
				&fatal_error("$fatxt{'59'} $fixfile");
			}
		}

		&clear_temp;
	}

	my ($threadid, $postid, @messages, $msub, $mname, $memail, $mdate, $musername, $micon, $mattach, $mip, $mmessage, $mns, $mlm, $mlmb, $tnum, $tsub, $tname, $temail, $tdate, $treplies, $tusername, $ticon, $tstate, @threads, $tmpa, $tmpb, $tnum2, $tdate2, $newlastposttime, $newlastposter, $lastpostid, $views, $name, $email, $subject, $message, $ns,);
	my ($mfn);

	$threadid   = $FORM{'threadid'};
	$postid     = $FORM{'postid'};
	$pollthread = $FORM{'pollthread'};

	if ($pollthread) {
		$maxpq          ||= 60;
		$maxpo          ||= 50;
		$maxpc          ||= 0;
		$numpolloptions ||= 8;
		$vote_limit     ||= 0;

		unless (-e "$datadir/$threadid.poll") { &fatal_error("$post_polltxt{'13'}"); }

		fopen(FILE, "$datadir/$threadid.poll");
		@poll_data = <FILE>;
		fclose(FILE);
		chomp $poll_data[0];
		($poll_question, $poll_locked, $poll_uname, $poll_name, $poll_email, $poll_date, $guest_vote, $hide_results, $multi_choice, $poll_mod, $poll_modname, $poll_comment, $vote_limit) = split(/\|/, $poll_data[0]);

		unless ($poll_uname eq $username || $iammod || $iamadmin || $iamgmod) { &fatal_error("$post_polltxt{'13'}"); }

		$numcount = 0;
		unless ($FORM{"question"}) { &fatal_error("$post_polltxt{'37'}"); }
		$FORM{"question"} =~ s/\&nbsp;/ /g;
		$testspaces = $FORM{"question"};
		$testspaces =~ s/[\r\n\ ]//g;
		$testspaces =~ s/\&nbsp;//g;
		$testspaces =~ s~\[table\].*?\[tr\].*?\[td\]~~g;
		$testspaces =~ s~\[/td\].*?\[/tr\].*?\[/table\]~~g;

		if (length($testspaces) == 0 && length($FORM{"question"}) > 0) { fatal_error("$maintxt{'2'} $testmessage"); }
		$poll_question = $FORM{"question"};

		$poll_question =~ s/&amp;/&/g;
		$poll_question =~ s/&quot;/"/g;
		$poll_question =~ s/&lt;/</g;
		$poll_question =~ s/&gt;/>/g;
		&FromChars($poll_question);
		$convertstr = $poll_question;
		$convertcut = $maxpq;
		&CountChars;
		$poll_question = $convertstr;
		$poll_question =~ s/"/&quot;/g;
		$poll_question =~ s/</&lt;/g;
		$poll_question =~ s/>/&gt;/g;
		if ($cliped) { &fatal_error("$post_polltxt{'40'} $post_polltxt{'34a'} $maxpq $post_polltxt{'34b'} $post_polltxt{'36'}"); }

		&ToHTML($poll_question);
		$guest_vote   = $FORM{'guest_vote'}   || 0;
		$hide_results = $FORM{'hide_results'} || 0;
		$multi_choice = $FORM{'multi_choice'} || 0;
		$poll_comment = $FORM{'poll_comment'} || "";
		$vote_limit   = $FORM{'vote_limit'}   || 0;

		if ($vote_limit =~ /\D/) { $vote_limit = 0; &fatal_error("$post_polltxt{'62'}"); }

		$poll_comment =~ s/&amp;/&/g;
		$poll_comment =~ s/&quot;/"/g;
		$poll_comment =~ s/&lt;/</g;
		$poll_comment =~ s/&gt;/>/g;
		&FromChars($poll_comment);
		$convertstr = $poll_comment;
		$convertcut = $maxpc;
		&CountChars;
		$poll_comment = $convertstr;
		$poll_comment =~ s/"/&quot;/g;
		$poll_comment =~ s/</&lt;/g;
		$poll_comment =~ s/>/&gt;/g;

		if ($cliped) { &fatal_error("$post_polltxt{'57'} $post_polltxt{'34a'} $maxpc $post_polltxt{'34b'} $post_polltxt{'36'}"); }
		&ToHTML($poll_comment);
		$poll_comment =~ s~\n~<br />~g;
		$poll_comment =~ s~\r~~g;
		my @new_poll_data;
		push @new_poll_data, qq~$poll_question|$poll_locked|$poll_uname|$poll_name|$poll_email|$poll_date|$guest_vote|$hide_results|$multi_choice|$date|$username|$poll_comment|$vote_limit\n~;

		for ($i = 1; $i <= $numpolloptions; $i++) {
			chomp $poll_data[$i];
			($votes, $dummy) = split(/\|/, $poll_data[$i]);
			if (!$votes) { $votes = "0"; }
			if ($FORM{"option$i"}) {
				$FORM{"option$i"} =~ s/\&nbsp;/ /g;
				$testspaces = $FORM{"option$i"};
				$testspaces =~ s/[\r\n\ ]//g;
				$testspaces =~ s/\&nbsp;//g;
				$testspaces =~ s~\[table\].*?\[tr\].*?\[td\]~~g;
				$testspaces =~ s~\[/td\].*?\[/tr\].*?\[/table\]~~g;

				# Down boy, bad regex! - what is it doing? Removed as causes lots of problems
				#				$testspaces =~ s/\[.*?\]//g;
				if (length($testspaces) == 0 && length($FORM{"option$i"}) > 0) { fatal_error("$maintxt{'2'} $testmessage"); }

				$FORM{"option$i"} =~ s/&amp;/&/g;
				$FORM{"option$i"} =~ s/&quot;/"/g;
				$FORM{"option$i"} =~ s/&lt;/</g;
				$FORM{"option$i"} =~ s/&gt;/>/g;
				&FromChars($FORM{"option$i"});
				$convertstr = $FORM{"option$i"};
				$convertcut = $maxpo;
				&CountChars;
				$FORM{"option$i"} = $convertstr;
				$FORM{"option$i"} =~ s/"/&quot;/g;
				$FORM{"option$i"} =~ s/</&lt;/g;
				$FORM{"option$i"} =~ s/>/&gt;/g;
				if ($cliped) { &fatal_error("$post_polltxt{'7'} $i  $post_polltxt{'34a'} $maxpo $post_polltxt{'34b'} $post_polltxt{'36'}"); }

				&ToHTML($FORM{"option$i"});
				$numcount++;
				push @new_poll_data, qq~$votes|$FORM{"option$i"}\n~;
			}
		}
		if ($numcount < 2) { &fatal_error("$post_polltxt{'38'}"); }

		fopen(POLL, ">$datadir/$threadid.poll");
		print POLL @new_poll_data;
		fclose(POLL);

		$yySetLocation = qq~$scripturl?num=$threadid~;

		&redirectexit;
	}

	fopen(FILE, "$datadir/$threadid.txt") || &fatal_error("$post_txt{'23'} $threadid.txt", 1);
	@messages = <FILE>;
	fclose(FILE);

	# Make sure the user is allowed to edit this post.
	if ($postid >= 0 && $postid < @messages) {
		chomp $messages[$postid];
		($msub, $mname, $memail, $mdate, $musername, $micon, $mattach, $mip, $mmessage, $mns, $mlm, $mlmb, $mfn) = split(/\|/, $messages[$postid]);
		$messagedate      = $mdate;
		$registrationdate = ${$uid.$username}{'regdate'};
		unless (($registrationdate < $messagedate && $musername eq $username) || $iammod || $iamadmin || $iamgmod) {
			&fatal_error("$post_txt{'67'}");
		}
		$set_subjectMaxLength += 4;
	} else {
		&fatal_error("$post_txt{'580'} $postid");
	}

	$thestatus = $FORM{'topicstatus'};
	$thestatus =~ s/\, //g;

	($tnum, $tsub, $tname, $temail, $tdate, $treplies, $tusername, $ticon, $tstate) = split(/\|/, $yyThreadLine);

	if ($tstate =~ /l/i) {
		&fatal_error($post_txt{'90'});
	}
	if ($tstate !~ /a/i && $thestatus && ($iamadmin || $iamgmod || $iammod)) {
		$tstate = "0$thestatus";
	}

	&MessageTotals("load", $tnum);
	${$tnum}{'threadstatus'} = "$tstate";
	&MessageTotals("update", $tnum);

	# the post is to be modified...
	$name    = $FORM{'name'};
	$email   = $FORM{'email'};
	$subject = $FORM{'subject'};
	$message = $FORM{'message'};
	$icon    = $FORM{'icon'};
	$ns      = $FORM{'ns'};
	$notify  = $FORM{'notify'};
	&CheckIcon;

	&fatal_error($post_txt{'78'}) unless ($message);
	$mess_len = $message;
	$mess_len =~ s/[\r\n]//g;

	if (length($mess_len) > $MaxMessLen) {
		require "$sourcedir/Post.pl";
		&Preview($post_txt{'536'} . " " . (length($message) - $MaxMessLen) . " " . $post_txt{'537'});
	}

	$subject =~ s/&amp;/&/g;
	$subject =~ s/&quot;/"/g;
	$subject =~ s/&lt;/</g;
	$subject =~ s/&gt;/>/g;
	&FromChars($subject);
	$convertstr = $subject;
	$convertcut = $set_subjectMaxLength;
	&CountChars;
	$subject = $convertstr;
	$subject =~ s/"/&quot;/g;
	$subject =~ s/</&lt;/g;
	$subject =~ s/>/&gt;/g;

	&ToHTML($name);
	$email =~ s/\|//g;
	&ToHTML($email);
	&fatal_error($post_txt{'77'}) unless ($subject && $subject !~ m~\A[\s_.,]+\Z~);
	my $testmessage = $message;
	$testmessage =~ s/[\r\n\ ]//g;
	$testmessage =~ s/\&nbsp;//g;
	$testmessage =~ s~\[table\].*?\[tr\].*?\[td\]~~g;
	$testmessage =~ s~\[/td\].*?\[/tr\].*?\[/table\]~~g;
	$testmessage =~ s/\[.*?\]//g;
	if ($testmessage eq "" && $message ne "" && $pollthread != 2) { fatal_error("$maintxt{'2'} $testmessage"); }

	&FromChars($message);
	$message =~ s/\cM//g;
	$message =~ s~\[([^\]]{0,30})\n([^\]]{0,30})\]~\[$1$2\]~g;
	$message =~ s~\[/([^\]]{0,30})\n([^\]]{0,30})\]~\[/$1$2\]~g;
	$message =~ s~(\w+://[^<>\s\n\"\]\[]+)\n([^<>\s\n\"\]\[]+)~$1\n$2~g; # "
	&ToHTML($message);
	$message =~ s/\t/ \&nbsp; \&nbsp; \&nbsp;/g;
	$message =~ s~\n~<br />~g;
	if ($postid == 0) {
		$tsub  = $subject;
		$ticon = $icon;
	}
	$yyThreadLine = qq($tnum|$tsub|$tname|$temail|$tdate|$treplies|$tusername|$ticon|$tstate\n);

	if ($mip =~ /$user_ip/) { $useredit_ip = $mip; }
	else { $useredit_ip = "$mip $user_ip"; }

	if ($FORM{'w_file'} eq "attachnew" && $fixfile) {
		$messages[$postid] = qq~$subject|$mname|$memail|$mdate|$musername|$icon|0|$useredit_ip|$message|$ns|$date|$username|$fixfile\n~;
		fopen(FILE, ">$datadir/$threadid.txt", 1) || &fatal_error("$txt{'23'} $threadid.txt");
		print FILE @messages;
		fopen(AML, "$vardir/attachments.txt");
		my @attachments = <AML>;
		fclose(AML);
		fopen(AML, ">$vardir/attachments.txt");
		foreach $file (@attachments) {
			chomp $file;
			my ($amthreadid, $amreplies, $amthreadsub, $amposter, $amcurrentboard, $amkb, $amdate, $amfn) = split(/\|/, $file);
			if ($amfn ne $mfn) {
				print AML qq~$amthreadid|$amreplies|$amthreadsub|$amposter|$amcurrentboard|$amkb|$amdate|$amfn\n~;
			}
		}
		print AML qq~$threadid|$treplies|$subject|$musername|$currentboard|$filesizekb|$date|$fixfile\n~;
		fclose(AML);
		unlink("$uploaddir/$mfn");
	} elsif ($FORM{'w_file'} eq "attachold") {
		$messages[$postid] = qq~$subject|$mname|$memail|$mdate|$musername|$icon|0|$useredit_ip|$message|$ns|$date|$username|$mfn\n~;
		fopen(FILE, ">$datadir/$threadid.txt", 1) || &fatal_error("$txt{'23'} $threadid.txt");
		print FILE @messages;
		fclose(FILE);
	} elsif ($FORM{'w_file'} eq "attachnew" && !$fixfile) {
		$messages[$postid] = qq~$subject|$mname|$memail|$mdate|$musername|$icon|0|$useredit_ip|$message|$ns|$date|$username|$mfn\n~;
		fopen(FILE, ">$datadir/$threadid.txt", 1) || &fatal_error("$txt{'23'} $threadid.txt");
		print FILE @messages;
		fclose(FILE);
	} elsif ($FORM{'w_file'} eq "attachdel" && -e ("$uploaddir/$mfn")) {
		$messages[$postid] = qq~$subject|$mname|$memail|$mdate|$musername|$icon|0|$useredit_ip|$message|$ns|$date|$username|\n~;
		fopen(FILE, ">$datadir/$threadid.txt", 1) || &fatal_error("$txt{'23'} $threadid.txt");
		print FILE @messages;
		fopen(AML, "$vardir/attachments.txt");
		my @attachments = <AML>;
		fclose(AML);
		fopen(AML, ">$vardir/attachments.txt");
		foreach $file (@attachments) {
			chomp $file;
			my ($amthreadid, $amreplies, $amthreadsub, $amposter, $amcurrentboard, $amkb, $amdate, $amfn) = split(/\|/, $file);
			if ($amfn ne $mfn) {
				print AML qq~$amthreadid|$amreplies|$amthreadsub|$amposter|$amcurrentboard|$amkb|$amdate|$amfn\n~;
			}
		}
		unlink("$uploaddir/$mfn");
		fclose(FILE);
	} elsif ($FORM{'w_file'} eq "attachdel" && !-e ("$uploaddir/$mfn")) {
		$messages[$postid] = qq~$subject|$mname|$memail|$mdate|$musername|$icon|0|$useredit_ip|$message|$ns|$date|$username|\n~;
		fopen(FILE, ">$datadir/$threadid.txt", 1) || &fatal_error("$txt{'23'} $threadid.txt");
		print FILE @messages;
		fclose(FILE);
	} else {
		$messages[$postid] = qq~$subject|$mname|$memail|$mdate|$musername|$icon|0|$useredit_ip|$message|$ns|$date|$username|$mfn\n~;
		fopen(FILE, ">$datadir/$threadid.txt", 1) || &fatal_error("$txt{'23'} $threadid.txt");
		print FILE @messages;
		fclose(FILE);
	}

	if ($postid == 0) {

		# maybe thread sub and/or icon was changed -> Save the current board
		fopen(FILE, "+<$boardsdir/$currentboard.txt", 1) || &fatal_error("$post_txt{'23'} $currentboard.txt", 1);
		seek FILE, 0, 0;
		my @buffer = <FILE>;
		truncate FILE, 0;
		for ($a = 0; $a < @buffer; $a++) {
			if ($buffer[$a] =~ m~\A$threadid\|~o) { $buffer[$a] = $yyThreadLine; last; }
		}
		seek FILE, 0, 0;
		print FILE @buffer;
		fclose(FILE);
		&BoardTotals("load", $currentboard);
		&BoardSetLastInfo($currentboard);
	} elsif ($postid == $#messages && $a == 0) {
		# maybe last message sub and/or icon was changed -> update and board info
		&BoardTotals("load", $currentboard);
		&BoardSetLastInfo($currentboard);
	}

	&dumplog($currentboard);

	my $start = int($postid / $maxmessagedisplay) * $maxmessagedisplay;

	$thread = $threadid;
	if ($notify) {
		$INFO{'thread'} = $thread;
		$INFO{'start'}  = $start;
		require "$sourcedir/Notify.pl";
		&Notify2;
	} else {
		require "$sourcedir/Notify.pl";
		&ManageThreadNotify("delete", $thread, $username);
	}

	$yySetLocation = qq($scripturl?num=$threadid/$start#$postid);
	&redirectexit;
}

# All this sub represents premature optimization :(
sub remove_atts {

	my $attfiles = shift;
	if ( not ref $attfiles ) {
		$attfiles = [ $attfiles ]
	}

	if ( not fopen ( ATTLIST, "+< $vardir/attachments.txt" ) ) {
		# what to do here?
		return 0
	}

	my @attachments = <ATTLIST>;

	# make regex to match all files in list at once for one grep lookup
	my $attfile_rx = '\|(';
	my $first = 1;
	foreach my $attfile ( @$attfiles ) {

		if ( -e "$uploaddir/$attfile" ) { # do it later?
			if ( not -e "$uploadtrashdir/$attfile" ) { # paranoid :(
				rename "$uploaddir/$attfile", "$uploadtrashdir/$attfile"
			}

			if ( -e "$uploaddir/$attfile" ) {
				unlink "$uploaddir/$attfile"
			}
		}
		
		$attfile_rx .= quotemeta $attfile;

		if ( not $first ) {
			$attfile_rx .= '|'
		} else {
			undef $first
		}
	}
	$attfile_rx .= ')\Z';

	my $num = @attachments;
	@attachments = grep !m/$attfile_rx/, @attachments; # FIXME: check shompness!!

	if ( @attachments != $num ) {
		seek     ATTLIST, 0, 0;
		print    ATTLIST  @attachments;
		truncate ATTLIST, tell ATTLIST;
	}

	fclose ( ATTLIST );

	return 1
}

# tid arref/num
# I wanted to make an utility function from that, but failed :(
# it is either too expensive or too unmaintainable.
# so, security checks and fatal errors are present here.
# IMHO, we just need a routine to load thread into form of hash
# this can be wasteful if used on many threads, but for such
# actions we can work directly or make 'unload' routine.
# then all security checks can be done before calling utility routine.
sub delete_posts {

	my $tid = shift;


	MessageTotals 'load', $tid;

	# I know about that strange checks in Security, but
	# they are strange and in this case they, imho, will not
	# work... - there is used 'thread' instead of 'num'
	our $curboard = ${$tid}{board};

	# hm. now it checks for postthread ('1') rights.
	# but we also have '2' - postreply rights.

	# we use '1' (postthread) to restrict board changing, and so,
	# require it only if we need to remove entire thread...
	# we use '2' (postreply) to restrict reply changing...

	# damn. we should require '1' only for first thread post...
	# and require '2' for any of non-first posts o_O
	# Ok, now it does so.

	# all that AccessCheck stuff so complicated...
	# unix oga-rwx is much better.

	unless ( $iamadmin or $iamgmod or $iammod and $sessionvalid ) {
		if ( not CatAccess ( ( split /\|/, $catinfo{${$uid.$curboard}{cat}} )[1] ) or
		     AccessCheck ( $curboard, 0, ( split /\|/, $board{$curboard} )[1] ) ne 'granted' ) {
			fatal_error 'access denied' # FIXME
		} elsif ( ${$tid}{threadstatus} =~ m/l/i ) {
			fatal_error 'thread locked' # FIXME
		}
	}


	if ( not fopen ( THREAD, "$datadir/$tid.txt", 1 ) ) {
		fatal_error "$post_txt{'23'} $tid.txt", 1
	}

	my @messages = <THREAD>;

	fclose ( THREAD );

	my $pids = shift;
	if ( not ref $pids ) {
		$pids = [ $pids ]
	}

	my @killatts;
	my %killpc;
	my $killboardpc;

	foreach my $pid ( @$pids ) {

		my ( $pdate, $puid, $attfile ) = ( split /\|/, $messages[$pid] )[3,4,12];

		if ( $pid > $#messages ) {
			fatal_error 'wrong pid' # FIXME
		}

		# FIXME: o_O one more check: ex-memberness
		unless ( $iamadmin or $iamgmod or $iammod and $sessionvalid ) {
			unless ( $puid eq $username and # non-admin must own post to delete it
			         $puid ne 'Guest' ) {
				fatal_error 'not own post' # FIXME
			} elsif ( $tlnodelflag and # timelock
	 	              $date > $pdate + $tlnodeltime * 24 * 60 * 60 ) {
				fatal_error 'locked post' # FIXME
			} elsif ( ( $pid == 0 and # starting post - check thread posting perms
			            AccessCheck ( $curboard, 1 ) ne 'granted' ) or
			          ( $pid != 0 and # reply - chneck reply posting perms
			            AccessCheck ( $curboard, 2 ) ne 'granted' ) ) {
				fatal_error 'access denied' # FIXME
			}
		}

		chomp $attfile;
		push @killatts, $attfile;

		$killpc{$puid}++;
		$killboardpc++;

		splice @messages, $pid, 1;
	}

	# decrease members post count if not in a zero post count board
	if ( not ${$uid.$curboard}{zero} ) {
		foreach my $puid ( keys %killpc ) {
			if ( $puid eq 'Guest' ) {
				next
			}

			LoadUser $puid;

			if ( ${$uid.$puid}{postcount} > 0 ) {
			
				${$uid.$puid}{postcount} -= $killpc{$puid};
				if ( ${$uid.$puid}{postcount} < 0 ) {
					${$uid.$puid}{postcount} = 0
				}

				UserAccount $puid, 'update';

				# WTF with this - why so strange things organization?
				# it shouldn't be here
				my $grp_after = ${$uid.$puid}{position};
				if ( not $grp_after ) {
					foreach my $postamount ( reverse sort keys %Post ) {
						if ( ${$uid.$puid}{postcount} > $postamount ) {
							( $grp_after, undef ) = split /\|/, $Post{$postamount}, 2;
							last;
						}
					}
				}

				ManageMemberinfo 'update', $puid, '', '', $grp_after, ${$uid.$puid}{postcount};
			}

			Recent_Load $tid;
			if ( exists $recent{$puid} and $recent{$puid} > 0 ) {
				$recent{$puid} -= $killpc{$puid};
				if ( $recent{$puid} <= 0 ) {
					delete $recent{$puid}
				}
				Recent_Save $tid;
			}
		}
	}

	# delete entire thread, this *does not* affects post counters,
	# so they are decreased before.
	if ( @messages < 1 ) {

		# all post was deleted, call removethread
		require "$sourcedir/Favorites.pl";
		$INFO{'ref'} = 'delete';
		&RemFav ( $tid );

		# This is weird thing... we should check, is it actually works now.
		# Seems to be planned to be initialized in Security or somewhere else
		# If it is not working - then we should fix that in other place, not here.
		# It does not works :( so, uncommented
		our $iamposter = 1; # Security checks are done before.
		require "$sourcedir/RemoveTopic.pl";
		&RemoveThread;

		exit # to be sure
	}

	if ( -d "$datatrashdir" ) { # even more paranoid - just while test it all to not lose info while testing
		rename "$datadir/$tid.txt", "$datatrashdir/$date-$tid.txt"
	}

	remove_atts \@killatts if @killatts;

	# if thread has not been deleted: update thread, update message index details ...
	if ( not fopen ( THREAD, "> $datadir/$tid.txt", 1 ) ) {
		fatal_error "$post_txt{'23'} $tid.txt", 1
	}

	print THREAD @messages;

	fclose ( THREAD );

	my ( $sub, $icon ) = ( split /\|/, $messages[0] )[0,5];
	my ( $lpnick, $lpdate, $lpuid ) =
						( split /\|/, $messages[$#messages] )[1,3,4];

	# update the current thread
	${$tid}{'replies'}    = $#messages;
	${$tid}{'lastposter'} = $lpuid eq 'Guest' ? qq(Guest-$lpnick) : $lpuid;
	MessageTotals 'update', $tid;

	# update the current board.
	BoardTotals 'load', $curboard;
	if ( ${$uid.$curboard}{messagecount} > 0 ) { # to be sure :D
		${$uid.$curboard}{messagecount} -= $killboardpc;
		if ( ${$uid.$curboard}{messagecount} < 0 ) {
			${$uid.$curboard}{messagecount} = 0
		}
		BoardTotals 'update', $curboard;
	}

	if ( not fopen ( BOARD, "+< $boardsdir/$curboard.txt", 1 ) ) {
		fatal_error "$subs_txt{'23'} $curboard.txt", 1
	}

	my @buffer = <BOARD>;

	my $threadline = '';

	for ( my $num = 0; $num < @buffer; $num++ ) {
		if ( $buffer[$num] =~ m/\A$tid\|/ ) {
			$threadline = $buffer[$num];
			splice @buffer, $num, 1;
			last;
		}
	}

	chomp $threadline;

	my @newthreadline = split /\|/, $threadline;

	$newthreadline[1] = $sub;
	$newthreadline[7] = $icon;
	$newthreadline[4] = $lpdate;
	$newthreadline[5] = ${$tid}{replies};
	my $NewThreadLine = join ( '|', @newthreadline ) . "\n";

	seek BOARD, 0, 0;

	my $inserted = 0;
	for ( my $num = 0; $num < @buffer; $num++ ) {
		# Here appears cURL :)
		my $curlpdate = ( split /\|/, $buffer[$num] )[4];
		if ( not $inserted and $curlpdate < $newthreadline[4] ) {
			print BOARD $NewThreadLine;
			$inserted = 1;
		}
		print BOARD $buffer[$num];
	}

	if ( not $inserted ) {
		print BOARD $NewThreadLine;
	}

	truncate BOARD, tell BOARD;

	fclose ( BOARD );

# why? we have not seen board. Or supply date to mark with...
# which relationship between $board and $curboard?
#	dumplog $board;

	BoardSetLastInfo $curboard; # TODO: check, is it required

	return 1
}

sub MultiDel {
	
	my $tid = $INFO{'thread'};

	if ( $tid =~ /\D/s ) {
		fatal_error $post_txt{337} # check
	}

	if ( exists $INFO{message} ) {

		my $pid = $INFO{message};

		if ( $pid =~ /\D/s ) {
			fatal_error "wrong post id" # FIXME
		}

		delete_posts $tid, $pid

	} else {

		my @pids;

		foreach my $arg ( keys %FORM ) {
			next if $arg !~ /\Adel(\d+)\Z/i;
			next if $FORM{$arg} eq '';

			push @pids, $1;
		}

		delete_posts $tid, \@pids
	}

	my $pid   = $INFO{messages} || $INFO{start};
	if ( $pid > ${$tid}{replies} ) {
		$pid  = ${$tid}{replies}
	}

	# Actually, isn't necessary
	my $start = int ( $pid / $maxmessagedisplay ) * $maxmessagedisplay;

	# Hm, now it also can be called from lastmessages - do we need
	# referer analysing?
	our $yySetLocation = qq($scripturl?num=$tid/$start#$pid);

	redirectexit
}

1;

# The End # vim: set tabstop=4: #
