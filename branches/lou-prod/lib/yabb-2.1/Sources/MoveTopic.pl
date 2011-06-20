###############################################################################
# MoveTopic.pl                                                                #
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
###############################################################################

$movethreadplver = 'YaBB 2.1 $Revision: 1.3 $';
if ($action eq 'detailedversion') { return 1; }

sub MoveThread {
	if (!$iammod && !$iamadmin && !$iamgmod) { &fatal_error("$maintxt{'134'}"); }
	$boardlist = "";
	&moveto;
	$yymain .= qq~
<table border="0" width="60%" cellspacing="1" class="bordercolor" cellpadding="4" align="center">
  <tr>
    <td class="titlebg"><b>$maintxt{'132'}</b></td>
  </tr><tr>
    <td class="windowbg" align="center">
    <script language="JavaScript1.2" src="$ubbcjspath" type="text/javascript"></script>
    <form action="$scripturl?action=movethread2;board=$INFO{'board'};thread=$INFO{'thread'}" method="post" name="move" onSubmit="return submitproc()"><br />
    <b>$maintxt{'133'}:</b> <select name="toboard">$boardlist</select>
	<input type="hidden" name="fromboard" value="$currentboard">
    <input type="submit" value="$maintxt{'132'}">
    </form>
    </td>
  </tr>
</table>
~;
	$yytitle = "$maintxt{'132'}";
	&template;
	exit;
}

sub MoveThread2 {
	if (!$iammod && !$iamadmin && !$iamgmod) { &fatal_error("$maintxt{'134'}"); }
	my ($thread, @messages, $newthreadid, $fromboard, $toboard, $recycle, $a, $inserted, @buffer, $OrigThreadLine, @origlinedatas, @toboardlinedatas);

	$thread = $FORM{'thread'} || $INFO{'thread'};
	if ($thread =~ /\D/) { &fatal_error($maintxt{'337'}); }

	$fromboard = $FORM{'board'} || $INFO{'board'};
	if ($fromboard =~ m~/~)  { &fatal_error($maintxt{'399'}); }
	if ($fromboard =~ m~\\~) { &fatal_error($maintxt{'400'}); }
	if (!$fromboard) {
		&MessageTotals("load", $thread);
		$fromboard = ${$thread}{'board'};
	}

	$toboard = $deleteboard || $FORM{'toboard'};
	if ($toboard =~ m~/~)  { &fatal_error($maintxt{'399'}); }
	if ($toboard =~ m~\\~) { &fatal_error($maintxt{'400'}); }

	$recycle = $toboard eq $binboard ? 1 : 0;

	# thread check
	fopen(THREAD, "$datadir/$thread.txt") || &fatal_error("$maintxt{'23'} $thread.txt", 1);
	@messages = <THREAD>;
	fclose(THREAD);
	chomp @messages;

	# open fromboard, seek thread, if found then write a new thread
	$orgstate       = "";
	$OrigThreadLine = '';
	fopen(FROMBOARD, "+<$boardsdir/$fromboard.txt", 1) || &fatal_error("$txt{'23'} $fromboard.txt", 1);
	seek FROMBOARD, 0, 0;
	@buffer = <FROMBOARD>;
	for ($a = 0; $a < @buffer; $a++) {
		if ($buffer[$a] =~ m~\A$thread\|~) {
			$OrigThreadLine = $buffer[$a];
			chomp $OrigThreadLine;

			if (!$recycle) {
				($mnum, $msub, $mname, $memail, $mdate, $mreplies, $musername, $micon, $mstate) = split(/\|/, $OrigThreadLine);

				if ($mstate !~ /0/) {
					$mstate .= "0";
					$OrigThreadLine = qq~$mnum|$msub|$mname|$memail|$mdate|$mreplies|$musername|$micon|$mstate~;
				}

				# Find a valid ID for new thread. New threadid is nearest moved thread
				$newthreadid = $thread + 1;
				while (-e "$datadir/$newthreadid.txt") { $newthreadid++; }

				# changes subject in message index to "Moved: Subject"
				$msub = qq~[m]: $msub~;

				# thread status - add (l)ocked and (m)oved - remove (a)nnoumcement
				$mstate =~ s/a//ig;
				$mstate .= "lm";
				$orgstate = $mstate;
				$buffer[$a] = qq~$newthreadid|$msub|$mname|$memail|$mdate|0|$username|exclamation|$mstate\n~;
			} else {
				$buffer[$a] = "";
			}
			last;
		}
	}
	unless ($OrigThreadLine) {
		fclose(FROMBOARD);
		&fatal_error("$maintxt{'472'} $thread.");
	}
	truncate FROMBOARD, 0;
	seek FROMBOARD, 0, 0;
	print FROMBOARD @buffer;
	fclose(FROMBOARD);

	&MessageTotals("load", $thread);
	@tmprepliers = @repliers;

	# write new thread ('Moved:'+orig thread sub)
	if (!$recycle) {
		my $tmpip = (split /\|/, $messages[0])[7];
		$tmpsub = qq~[m]: $tmpsub~;

		my ($boardtitle, undef, undef) = split(/\|/, $board{$toboard});

		$tmpmessage = "[moved] [link=$scripturl?num=$thread/0]" . "$boardtitle" . "[/link] [move by] ${$uid.$username}{'realname'}.";
		&FromChars($tmpmessage);
		fopen(NEWTHREAD, ">$datadir/$newthreadid.txt") || &write_error("$post_txt{'23'} $newthreadid.txt", 1);
		print NEWTHREAD qq~$msub|$mname|$memail|$mdate|$musername|exclamation|0|$tmpip|$tmpmessage||$date|$username|\n~;
		fclose(NEWTHREAD);

		# save newthread.ctb
		%$newthreadid = %$thread;
		${$newthreadid}{'replies'}      = 0;
		${$newthreadid}{'views'}        = 0;
		${$newthreadid}{'lastposter'}   = $username;
		${$newthreadid}{'threadstatus'} = $orgstate;
		&MessageTotals("update", $newthreadid);
		
		&modlog($newthreadid);
	}

	&UserAccount($username, "update", "lastpost");

	# recount and set lastpost info of fromboard
	&BoardTotals("load", $fromboard);
	${$uid.$fromboard}{'threadcount'} -= $recycle;
	${$uid.$fromboard}{'messagecount'} = ${$uid.$fromboard}{'messagecount'} - ${$thread}{'replies'} - $recycle;
	&BoardTotals("update", $fromboard);
	&BoardSetLastInfo($fromboard);

	# write original thread to toboard
	@origlinedatas = split(/\|/, $OrigThreadLine);

	# set announcement state
	if ($toboard eq $annboard) {
		$origlinedatas[8] .= "a" if ($origlinedatas[8] !~ /a/i);
		$origlinedatas[8] =~ s/[ls]+//ig;
	} elsif ($fromboard eq $annboard) {
		$origlinedatas[8] =~ s/a//ig;
	}
	$newstatus = $origlinedatas[8];

	$OrigThreadLine = join("|", @origlinedatas) . "\n";

	fopen(TOBOARD, "+<$boardsdir/$toboard.txt", 1) || &fatal_error("210 $maintxt{'106'}: $maintxt{'23'} $toboard.txt", 1);
	seek TOBOARD, 0, 0;
	@buffer = <TOBOARD>;
	truncate TOBOARD, 0;
	seek TOBOARD, 0, 0;

	$inserted = 0;
	for ($a = 0; $a < @buffer; $a++) {
		@toboardlinedatas = split(/\|/, $buffer[$a]);
		if (!$inserted && $toboardlinedatas[4] < $origlinedatas[4]) {
			print TOBOARD $OrigThreadLine;
			$inserted = 1;
		}
		print TOBOARD $buffer[$a];
	}
	if (!$inserted) {
		print TOBOARD $OrigThreadLine;
	}
	fclose(TOBOARD);
	&dumplog($toboard);

	# save changed thread.ctb
	@repliers = @tmprepliers;
	${$thread}{'threadstatus'} = $newstatus;
	${$thread}{'board'}        = $toboard;
	&MessageTotals("update", $thread);

	# recount and set lastpost info of toboard
	&BoardTotals("load", $toboard);
	${$uid.$toboard}{'threadcount'}++;
	${$uid.$toboard}{'messagecount'} = ${$uid.$toboard}{'messagecount'} + ${$thread}{'replies'} + 1;
	&BoardTotals("update", $toboard);
	&BoardSetLastInfo($toboard);

	# now fix all attachment board info
	for ($a = 0; $a < @messages; $a++) {
		$mfn = (split /\|/, $messages[$a])[12];
		last if ($mfn);
	}
	undef @messages;

	if ($mfn) {

		# change attachments board on topics
		fopen(AMP, "+<$vardir/attachments.txt", 1) || &fatal_error("$txt{'23'} $vardir/attachments.txt", 1);
		seek AMP, 0, 0;
		@buffer = <AMP>;
		for ($a = 0; $a < @buffer; $a++) {
			if ($buffer[$a] =~ m~\A$thread\|~) {
				chomp $buffer[$a];
				@attachfile = split(/\|/, $buffer[$a]);
				$attachfile[4] = $toboard;
				$buffer[$a] = join("|", @attachfile) . "\n";
			}
		}
		truncate AMP, 0;
		seek AMP, 0, 0;
		print AMP @buffer;
		fclose(AMP);
	}

	if ($INFO{'moveit'} != 1) {
		$yySetLocation = qq~$scripturl?num=$thread/0~;
		&redirectexit;
	}
}

1;
