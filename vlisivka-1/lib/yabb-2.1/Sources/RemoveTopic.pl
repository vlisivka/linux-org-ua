###############################################################################
# RemoveTopic.pl                                                              #
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

$removethreadplver = 'YaBB 2.1 $Revision: 1.1 $';
if ($action eq 'detailedversion') { return 1; }

sub RemoveThread {
	my ($threadline, $threadmessagecount, $a, $amfn, @messages, @message);

	$thread = $INFO{'thread'};
	if ($thread =~ /\D/)  { &fatal_error($maintxt{'337'}); }
	if (!$iammod && !$iamadmin && !$iamgmod && !$iamposter) {
		&fatal_error("$maintxt{'73'}");
	}
	if (!$currentboard) {
		&MessageTotals("load", $thread);
		$currentboard = ${$thread}{'board'};
	}
	$threadline = '';
	fopen(BOARDFILE, "+<$boardsdir/$currentboard.txt", 1) || &fatal_error("7543 $maintxt{'23'} $currentboard.txt", 1);
	seek BOARDFILE, 0, 0;
	my @buffer = <BOARDFILE>;
	for ($a = 0; $a < @buffer; $a++) {
		if ($buffer[$a] =~ m~\A$thread\|~) {
			$threadline = $buffer[$a];
			$buffer[$a] = "";
			last;
		}
	}
	truncate BOARDFILE, 0;
	seek BOARDFILE, 0, 0;
	print BOARDFILE @buffer;
	fclose(BOARDFILE);

	if ($threadline) {
		fopen(FILE, "$datadir/$thread.txt") || &fatal_error("$maintxt{'23'} $thread.txt", 1);
		@messages = <FILE>;
		fclose(FILE);
		chomp @messages;

		$threadmessagecount = @messages;

		&BoardTotals("load", $currentboard);
		${$uid.$currentboard}{'threadcount'}--;
		${$uid.$currentboard}{'messagecount'} -= $threadmessagecount;
		&BoardTotals("update", $currentboard);
		&BoardSetLastInfo($currentboard);
		&RemoveThreadFiles($thread);

		for ($a = 0; $a < @messages; $a++) {
			$mfn = (split /\|/, $messages[$a])[12];
			last if ($mfn ne '');
		}
		undef @messages;

		if ($mfn) {

			# remove attachments on old topics if present
			fopen(AMP, "+<$vardir/attachments.txt", 1) || &fatal_error("$txt{'23'} $vardir/attachments.txt", 1);
			seek AMP, 0, 0;
			my @buffer = <AMP>;
			for ($a = 0; $a < @buffer; $a++) {
				if ($buffer[$a] =~ m~\A$thread\|~) {
					chomp $buffer[$a];
					my $amfn = (split /\|/, $buffer[$a])[7];
					unlink("$uploaddir/$amfn");
					$buffer[$a] = "";
				}
			}
			truncate AMP, 0;
			seek AMP, 0, 0;
			print AMP @buffer;
			fclose(AMP);
		}
	}

	&dumplog($currentboard);

	if ($INFO{'moveit'} != 1) {
		$yySetLocation = qq~$scripturl?board=$currentboard~;
		&redirectexit;
	}
}

sub DeleteThread {
	require "$sourcedir/MoveTopic.pl";
	$delete = $FORM{'thread'};

	if (!$currentboard) {
		&MessageTotals("load", $delete);
		$currentboard = ${$delete}{'board'};
	}
	if ($FORM{'ref'} eq "favorites") {
		$INFO{'ref'} = "delete";
		require "$sourcedir/Favorites.pl";
		&RemFav($delete);
	}
	if ((!$iamadmin || !$adminbin) && $binboard ne "" && $currentboard ne $binboard) {
		$deleteboard    = $binboard;
		$INFO{'moveit'} = 1;
		$INFO{'thread'} = $delete;
		&MoveThread2;
	}
	if (($iamadmin && ($adminbin || $currentboard eq $binboard)) || $binboard eq "") {
		$INFO{'moveit'} = 1;
		$INFO{'thread'} = $delete;
		&RemoveThread;
	}
	$yySetLocation = qq~$scripturl?board=$currentboard~;
	&redirectexit;
}

sub Multi {
	require "$sourcedir/SetStatus.pl";
	require "$sourcedir/MoveTopic.pl";

	if ($FORM{'allpost'} =~ m/all/i) {
		&BoardTotals("load", $currentboard);
		$mess_loop = ${$uid.$currentboard}{'threadcount'};
	} else {
		$mess_loop = $maxdisplay;
	}

	while ($mess_loop >= $count) {
		my ($lock, $stick, $move, $delete, $ref) = "";

		if ($FORM{'action'} eq '') {
			$lock   = $FORM{"lockadmin$count"};
			$stick  = $FORM{"stickadmin$count"};
			$move   = $FORM{"moveadmin$count"};
			$delete = $FORM{"deleteadmin$count"};
		} elsif ($FORM{'action'} eq 'lock') {
			$lock = $FORM{"admin$count"};
		} elsif ($FORM{'action'} eq 'stick') {
			$stick = $FORM{"admin$count"};
		} elsif ($FORM{'action'} eq 'move') {
			$move = $FORM{"admin$count"};
		} elsif ($FORM{'action'} eq 'delete') {
			$delete = $FORM{"admin$count"};
		}

		if ($FORM{'ref'} eq "favorites") {
			$ref = qq~$scripturl?action=favorites~;
		} else {
			$ref = qq~$scripturl?board=$currentboard~;
		}

		if ($lock ne "") {
			$INFO{'moveit'} = 1;
			$INFO{'thread'} = $lock;
			$INFO{'action'} = "lock";
			$INFO{'ref'}    = $ref;
			&SetStatus;
		}
		if ($stick ne "") {
			$INFO{'moveit'} = 1;
			$INFO{'thread'} = $stick;
			$INFO{'action'} = "sticky";
			$INFO{'ref'}    = $ref;
			&SetStatus;
		}
		if ($move ne "") {
			$INFO{'moveit'} = 1;
			$INFO{'thread'} = $move;
			&MoveThread2;
		}

		if ($delete ne "") {
			if (!$currentboard) {
				&MessageTotals("load", $delete);
				$currentboard = ${$delete}{'board'};
			}
			if ($FORM{'ref'} eq "favorites") {
				$INFO{'ref'} = "delete";
				require "$sourcedir/Favorites.pl";
				&RemFav($delete);
			}
		}
		if ($delete ne "" && (!$iamadmin || !$adminbin) && (!$iamgmod || !$adminbin) && $binboard ne "" && $currentboard ne $binboard) {
			$deleteboard    = $binboard;
			$INFO{'moveit'} = 1;
			$INFO{'thread'} = $delete;
			&MoveThread2;
		}
		if (($delete ne "" && $iamadmin && ($adminbin || $currentboard eq $binboard)) || $iamgmod || $binboard eq "") {
			$INFO{'moveit'} = 1;
			$INFO{'thread'} = $delete;
			&RemoveThread;
		}
		$count++;
	}
	$yySetLocation = qq~$scripturl?board=$currentboard~;
	&redirectexit;
}

1;
