###############################################################################
# SplitSplice.pl                                                              #
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

$splitspliceplver = 'YaBB 2.1 $Revision: 1.2 $';
if ($action eq 'detailedversion') { return 1; }

LoadLanguage("SplitSplice");

sub Split {
	if (!$iammod && !$iamadmin && !$iamgmod) { &fatal_error("$sstxt{'2'}"); }
	$curthread = $INFO{'thread'};
	&LoadCensorList;

	$postlist = "";
	fopen(FILE, "$datadir/$curthread.txt");
	@messages = <FILE>;
	fclose(FILE);
	$counter = 0;
	for ($counter = 1; $counter <= $#messages; $counter++) {
		chomp $messages[$counter];
		($msub, $mname, $memail, $mdate, $musername, $micon, $mattach, $mip, $postmessage, $ns, $mlm, $mlmb) = split(/[\|]/, $messages[$counter]);
		$msub = &Censor($msub);
		if (length($msub) > 25) { $msub = substr($msub, 0, 25) . qq~ ...~; }
		$postlist .= qq~<option value="$counter">$counter: $msub</option>\n~;
	}

	$yymain .= qq~
<table border="0" width="80%" cellspacing="0" cellpadding="0" class="bordercolor" align="center">
  <tr>
    <td>
      <table cellpadding="4" cellspacing="1" border="0" width="100%">
        <tr>
          <td colspan="2" class="titlebg"><img src="$imagesdir/admin_split.gif" align="absmiddle" /> <font size="2" class="text1"><b>$sstxt{'1'}</b></font></td>
        </tr><tr>
          <td colspan="2" class="windowbg" align="center"><font size="2">
            <script language="JavaScript1.2" src="$ubbcjspath" type="text/javascript"></script>
            <form action="$scripturl?action=split2;thread=$INFO{'thread'}" method="POST" name="split" onSubmit="return submitproc()"><br />
            <b>$sstxt{'3'}:</b> <select name="postid">
		$postlist
            </select>
            <input type="submit" value="$sstxt{'1'}" />
            </form>
          </font></td>
        </tr>
	<tr>
          <td colspan="2" class="windowbg"><font size="1">$sstxt{'4'}</font></td>
        </tr>
      </table>
    </td>
  </tr>
</table><br />~;

	$yytitle = "$sstxt{'1'}";
	&template;
	exit;
}

sub Split2 {
	if (!$iammod && !$iamadmin && !$iamgmod) { &fatal_error("$sstxt{'2'}"); }
	$oldthreadid = $INFO{'thread'};
	$postid      = $FORM{'postid'} || $INFO{'postid'};

	# Read existing thread.
	fopen(FILE, "$datadir/$oldthreadid.txt");
	@messages = <FILE>;
	fclose(FILE);

	$remaining = $#messages - scalar($postid);
	($tmpsub, $tmpname, $tmpemail, $tmpdate, $tmpusername, $tmpicon, $tmpattach, $tmpip, $tmpmessage, $tmpns, $tmplm, $tmplmb, $dummy) = split(/[\|]/, $messages[$postid], 13);

	# Find a valid random ID for new thread.
	$newthreadid = $tmpdate + 1;
	while (-e "$datadir/$newthreadid.txt") { $newthreadid++; }

	$tmpmessage = qq~$sstxt{'5'} \[link=$scripturl?num=$newthreadid\]$sstxt{'6'}\[/link\]~;

	# Update existing thread.
	fopen(FILE, "+>$datadir/$oldthreadid.txt");
	for ($i = 0; $i < $postid; $i++) {
		print FILE $messages[$i];
	}
	print FILE qq~$tmpsub|${$uid.$username}{'realname'}|${$uid.$username}{'email'}|$tmpdate|$username|exclamation|0|$user_ip|$tmpmessage||\n~;
	fclose(FILE);

	# Update old ctb.
	&MessageTotals("load", $oldthreadid);
	%$newthreadid = %$oldthreadid;
	${$oldthreadid}{'replies'}    = $postid;
	${$oldthreadid}{'lastposter'} = $username;
	&MessageTotals("update", $oldthreadid);

	# Increment post count and lastpost date for the member.
	# Check whether zeropost board
	if (!${$uid.$currentboard}{'zero'}) {
		${$uid.$username}{'postcount'}++;
		&UserAccount($username, "update", "lastpost");
	} else {
		&UserAccount($username, "update", "lastpost");
	}

	# Save new thread.
	fopen(FILE, ">$datadir/$newthreadid.txt");
	for ($i = $postid; $i <= $#messages; $i++) {
		print FILE $messages[$i];
	}
	fclose(FILE);

	# Save new ctb.
	${$newthreadid}{'replies'} = $remaining;
	&MessageTotals("update", $newthreadid);

	# Update message index.
	fopen(BOARD, "+<$boardsdir/$currentboard.txt", 1);
	seek BOARD, 0, 0;
	my @buffer = <BOARD>;
	truncate BOARD, 0;
	seek BOARD, 0, 0;

	for ($a = 0; $a < @buffer; $a++) {
		if ($buffer[$a] =~ m~\A$oldthreadid\|~) {
			$OldThreadLine = $buffer[$a];
			splice(@buffer, $a, 1);
			last;
		}
	}
	chomp $OldThreadLine;
	($mnum, $msub, $mname, $memail, $mdate, $mreplies, $musername, $micon, $mstate) = split(/\|/, $OldThreadLine);
	$OldThreadLine = qq~$mnum|$msub|$mname|$memail|$tmpdate|$postid|$musername|$micon|$mstate\n~;
	$NewThreadLine = qq~$newthreadid|$tmpsub|$tmpname|$tmpemail|$mdate|$remaining|$tmpusername|$tmpicon|$mstate\n~;

	$oldinserted = 0;
	$newinserted = 0;
	for ($a = 0; $a < @buffer; $a++) {
		@boardlinedatas = split(/\|/, $buffer[$a]);
		if (!$newinserted && $boardlinedatas[4] < $mdate) {
			print BOARD $NewThreadLine;
			$newinserted = 1;
		}
		if (!$oldinserted && $boardlinedatas[4] < $tmpdate) {
			print BOARD $OldThreadLine;
			$oldinserted = 1;
		}
		print BOARD $buffer[$a];
	}
	if (!$newinserted) {
		print BOARD $NewThreadLine;
	}
	if (!$oldinserted) {
		print BOARD $OldThreadLine;
	}
	fclose(BOARD);

	# update board totals
	&BoardTotals("load", $currentboard);
	${$uid.$currentboard}{'threadcount'}++;
	${$uid.$currentboard}{'messagecount'}++;
	if (${$uid.$currentboard}{'lastpostid'} == $oldthreadid) { ${$uid.$currentboard}{'lastpostid'} = $newthreadid; }
	${$uid.$currentboard}{'lastreply'} = $remaining;
	&BoardTotals("update", $currentboard);
	&BoardSetLastInfo($toboard);

	# now fix all attachment board info
	@attachfiles = ();
	for ($a = $postid; $a < @messages; $a++) {
		@message = split(/\|/, $messages[$a]);
		if ($message[12] ne "") { push(@attachfiles, $message[12]); }
	}
	if (@attachfiles) {
		fopen(AMP, "+<$vardir/attachments.txt", 1) || &fatal_error("$txt{'23'} $vardir/attachments.txt", 1);
		seek AMP, 0, 0;
		my @buffer = <AMP>;
		truncate AMP, 0;
		for ($a = 0; $a < @buffer; $a++) {
			if ($buffer[$a] =~ m~\A$oldthreadid\|~) {
				my ($amthreadid, $amreplies, $amthreadsub, $amposter, $amcurrentboard, $amkb, $amdate, $amfn) = split(/\|/, $row);
				for ($af = 0; $af < @attachfiles; $af++) {
					if ($attachfiles[$af] eq $amfn) {
						$buffer[$a] = qq~$newthreadid|$amreplies|$amthreadsub|$amposter|$amcurrentboard|$amkb|$amdate|$amfn\n~;
					}
				}
			}
		}
		seek AMP, 0, 0;
		print AMP @buffer;
		fclose(AMP);
	}

	$yySetLocation = qq~$scripturl?num=$newthreadid~;
	&redirectexit;
}

sub Splice {
	if (!$iammod && !$iamadmin && !$iamgmod) { &fatal_error("$sstxt{'102'}"); }
	$curthread = $INFO{'thread'};
	&LoadCensorList;

	$threadlist = "";
	fopen(FILE, "$boardsdir/$currentboard.txt");
	@oldthreads = <FILE>;
	fclose(FILE);
	foreach $thread_data (@oldthreads) {
		chomp $thread_data;
		($mnum, $msub, $mname, $memail, $mdate, $mreplies, $musername, $micon, $mattach) = split(/\|/, $thread_data);
		$msub = &Censor($msub);
		if (length($msub) > 25) { $msub = substr($msub, 0, 25) . qq~ ...~; }
		chomp $msub;
		if ($mnum ne $curthread) { $threadlist .= qq~<option value="$mnum">$msub</option>\n~; }
	}

	$yymain .= qq~
<table border="0" width="80%" cellspacing="0" cellpadding="0" class="bordercolor" align="center">
  <tr>
    <td>
      <table cellpadding="4" cellspacing="1" border="0" width="100%">
        <tr>
          <td class="titlebg"><img src="$imagesdir/admin_splice.gif" align="absmiddle" /> <font size="2" class="text1"><b>$sstxt{'101'}</b></font></td>
        </tr><tr>
          <td class="windowbg" align="center"><font size="2">
            <script language="JavaScript1.2" src="$ubbcjspath" type="text/javascript"></script>
            <form action="$scripturl?action=splice2;board=$currentboard;thread=$INFO{'thread'}" method="POST" name="split" onSubmit="return submitproc()"><br />
            <b>$sstxt{'103'}:</b> <select name="newthreadid">
		$threadlist
            </select>
            <input type="submit" value="$sstxt{'101'}" />
            </form>
          </font></td>
        </tr><tr>
          <td class="windowbg"><font size="1">$sstxt{'104'}</font></td>
        </tr>
      </table>
    </td>
  </tr>
</table><br />~;

	$yytitle = "$sstxt{'101'}";
	&template;
	exit;
}

sub Splice2 {
	if (!$iammod && !$iamadmin && !$iamgmod) { &fatal_error("$sstxt{'102'}"); }
	$oldthreadid = $INFO{'thread'};
	$newthreadid = $FORM{'newthreadid'};

	# Read existing threads.
	fopen(FILE, "$datadir/$oldthreadid.txt");
	@old_messages = <FILE>;
	fclose(FILE);
	&MessageTotals("load", $oldthreadid);

	fopen(FILE, "$datadir/$newthreadid.txt");
	@new_messages = <FILE>;
	fclose(FILE);
	&MessageTotals("load", $newthreadid);
	${$newthreadid}{'lastposter'} = ${$oldthreadid}{'lastposter'};

	# Update old thread.
	($tmpsub, @dummy) = split(/\|/, $old_messages[0]);
	($dummy, $tmpname, $tmpemail, $tmpdate, $tmpusername, $tmpicon, $tmpattach, $tmpip, $tmpmessage, $tmpns, $tmplm, $tmplmb, $dummy) = split(/\|/, $old_messages[$#old_messages]);

	my $linkcount = @new_messages;
	$tmpmessage = qq~$sstxt{'105'} \[link=$scripturl?num=$newthreadid/$linkcount\#$linkcount\]$sstxt{'106'}\[/link\] $sstxt{'107'} ${$uid.$username}{'realname'}.~;
	fopen(FILE, "+>$datadir/$oldthreadid.txt");
	print FILE qq~$tmpsub|${$uid.$username}{'realname'}|${$uid.$username}{'email'}|$tmpdate|$username|exclamation|0|$user_ip|$tmpmessage||\n~;
	fclose(FILE);

	${$oldthreadid}{'replies'}    = 0;
	${$oldthreadid}{'lastposter'} = $username;
	&MessageTotals("update", $oldthreadid);

	# Increment post count and lastpost date for the member.
	# Check whether zeropost board
	if (!${$uid.$currentboard}{'zero'}) {
		${$uid.$username}{'postcount'}++;
		&UserAccount($username, "update", "lastpost");
	} else {
		&UserAccount($username, "update", "lastpost");
	}

	# Update new thread.
	fopen(FILE, "+>$datadir/$newthreadid.txt");
	print FILE @new_messages;
	print FILE @old_messages;
	fclose(FILE);

	${$newthreadid}{'replies'} = @new_messages + @old_messages - 1;
	&MessageTotals("update", $newthreadid);

	# Update message index.
	fopen(BOARD, "+<$boardsdir/$currentboard.txt", 1);
	seek BOARD, 0, 0;
	my @buffer = <BOARD>;
	truncate BOARD, 0;
	seek BOARD, 0, 0;

	my $found = 0;
	for ($a = 0; $a < @buffer; $a++) {
		if ($buffer[$a] =~ m~\A$oldthreadid\|~) {
			$OldThreadLine = $buffer[$a];

			chomp $OldThreadLine;
			($mnum, $msub, $mname, $memail, $mdate, $mreplies, $musername, $micon, $mstate) = split(/\|/, $OldThreadLine);
			$msub = qq~$sstxt{'108'}: $msub~;
			if ($mstate !~ /l/i) { $mstate .= "l"; }
			$OldThreadLine = qq~$mnum|$msub|$mname|$memail|$mdate|0|$musername|$micon|$mstate\n~;
			$buffer[$a] = $OldThreadLine;
		}
		if ($buffer[$a] =~ m~\A$newthreadid\|~) {
			$NewThreadLine = $buffer[$a];

			chomp $NewThreadLine;
			($mnum, $msub, $mname, $memail, $mdate, $mreplies, $musername, $micon, $mstate) = split(/\|/, $NewThreadLine);
			$NewThreadLine = qq~$mnum|$msub|$mname|$memail|$tmpdate|${$newthreadid}{'replies'}|$musername|$micon|$mstate\n~;
			$buffer[$a] = $NewThreadLine

		}
	}

	print BOARD @buffer;
	fclose(BOARD);

	# update board totals
	&BoardTotals("load", $currentboard);
	${$uid.$currentboard}{'messagecount'}++;
	&BoardTotals("update", $currentboard);
	&BoardSetLastInfo($currentboard);

	# now fix all attachment board info
	@attachfiles = ();
	for ($a = 0; $a < @old_messages; $a++) {
		@messages = split(/\|/, @old_messages[$a]);
		if ($message[12] ne "") { push(@attachfiles, $message[12]); }
	}
	if (@attachfiles) {
		fopen(AMP, "+<$vardir/attachments.txt", 1) || &fatal_error("$txt{'23'} $vardir/attachments.txt", 1);
		seek AMP, 0, 0;
		my @buffer = <AMP>;
		truncate AMP, 0;
		for ($a = 0; $a < @buffer; $a++) {
			if ($buffer[$a] =~ m~\A$oldthreadid\|~) {
				my ($amthreadid, $amreplies, $amthreadsub, $amposter, $amcurrentboard, $amkb, $amdate, $amfn) = split(/\|/, $row);
				for ($af = 0; $af < @attachfiles; $af++) {
					if ($attachfiles[$af] eq $amfn) {
						$buffer[$a] = qq~$newthreadid|$amreplies|$amthreadsub|$amposter|$amcurrentboard|$amkb|$amdate|$amfn\n~;
					}
				}
			}
		}
		seek AMP, 0, 0;
		print AMP @buffer;
		fclose(AMP);
	}

	$yySetLocation = qq~$scripturl?num=$newthreadid~;
	&redirectexit;
}

1;
