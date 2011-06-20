###############################################################################
# MessageIndex.pl                                                             #
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

$messageindexplver = 'YaBB 2.1 $Revision: 1.7 $';
if ($action eq 'detailedversion') { return 1; }

LoadLanguage("MessageIndex");
require "$templatesdir/$usemessage/MessageIndex.template";
require "$sourcedir/Favorites.pl";
&ShowFav;

sub MessageIndex {
	# Check if board was 'shown to all' - and whether they can view the board
	if (&AccessCheck($currentboard, '', $boardperms) ne "granted") { &fatal_error("$maintxt{'1'}"); }
	if ($annboard eq $currentboard && !$iamadmin && !$iamgmod) { &fatal_error("$maintxt{'1'}"); }

	my ($counter, $buffer, $pages, $showmods, $mnum, $msub, $mname, $memail, $mdate, $mreplies, $musername, $micon, $mstate, $dlp, $threadlength, $threaddate);
	my (@boardinfo, @threads, @anns, @stickythreadlist);
	&BoardTotals("load", $currentboard);
	my $threadcount  = ${$uid.$currentboard}{'threadcount'};
	my $messagecount = ${$uid.$currentboard}{'messagecount'};

	# Load announcements, if they exist.
	if ($annboard && $annboard ne $currentboard) {
		chomp $annboard;
		fopen(ANN, "$boardsdir/$annboard.txt");
		@tmpanns = <ANN>;
		fclose(ANN);
		$numanns = 0;
		foreach $realanns (@tmpanns) {
			my @annarray = split(/\|/, $realanns);
			my $annstatus = pop(@annarray);
			if ($annstatus =~ /a/i) {
				$anns[$numanns] = $realanns;
				$numanns++;
			}
		}
	} else {
		@anns = ();
	}

	$threadcount = $threadcount + $numanns;
	my $maxindex = $INFO{'view'} eq 'all' ? $threadcount : $maxdisplay;


	# There are three kinds of lies: lies, damned lies, and statistics.
	# - Mark Twain


	# Construct the page links for this board.
	if (!$iamguest) {
		($usermessagepage, undef, undef) = split(/\|/, ${$uid.$username}{'pageindex'});
	}
	my ($pagetxtindex, $pagetextindex, $pagedropindex1, $pagedropindex2, $all, $allselected);
	$indexdisplaynum = 3;              # max number of pages to display
	$dropdisplaynum  = 10;
	$startpage       = 0;
	$max             = $threadcount;
	if ($INFO{'start'} eq "all") { $maxindex = $max; $all = 1; $allselected = qq~ selected="selected"~; $start = 0 }
	else { $start = $INFO{'start'} || 0; }
	if ($start > $threadcount - 1) { $start = $threadcount - 1; }
	elsif ($start < 0) { $start = 0; }
	$start    = int($start / $maxindex) * $maxindex;
	$tmpa     = 1;
	$pagenumb = int(($threadcount - 1) / $maxindex) + 1;

	if ($start >= (($indexdisplaynum - 1) * $maxindex)) {
		$startpage = $start - (($indexdisplaynum - 1) * $maxindex);
		$tmpa = int($startpage / $maxindex) + 1;
	}
	if ($threadcount >= $start + ($indexdisplaynum * $maxindex)) { $endpage = $start + ($indexdisplaynum * $maxindex); }
	else { $endpage = $threadcount }
	$lastpn     = int(($threadcount - 1) / $maxindex) + 1;
	$lastptn    = ($lastpn - 1) * $maxindex;
	$pageindex1 = qq~<span class="small" style="float: left; height: 21px; margin: 0px; margin-top: 2px;"><img src="$imagesdir/index_togl.gif" border="0" alt="" style="vertical-align: middle;" /> $messageindex_txt{'139'}: $pagenumb</span>~;
	$pageindex2 = $pageindex1;
	if ($pagenumb > 1 || $all) {

		if ($usermessagepage == 1 || $iamguest) {
			$pagetxtindexst = qq~<span class="small" style="float: left; height: 21px; margin: 0px; margin-top: 2px;">~;
			if (!$iamguest) { $pagetxtindexst .= qq~<a href="$scripturl?board=$INFO{'board'};start=$start;action=messagepagedrop"><img src="$imagesdir/index_togl.gif" border="0" alt="$messageindex_txt{'19'}" style="vertical-align: middle;" /></a> $messageindex_txt{'139'}: ~; }
			else { $pagetxtindexst .= qq~<img src="$imagesdir/index_togl.gif" border="0" alt="" style="vertical-align: middle;" /> $messageindex_txt{'139'}: ~; }
			if ($startpage > 0)          { $pagetxtindex = qq~<a href="$scripturl?board=$currentboard/0" style="font-weight: normal;">1</a>&nbsp;...&nbsp;~; }
			if ($startpage == $maxindex) { $pagetxtindex = qq~<a href="$scripturl?board=$currentboard/0" style="font-weight: normal;">1</a>&nbsp;~; }
			for ($counter = $startpage; $counter < $endpage; $counter += $maxindex) {
				$pagetxtindex .= $start == $counter ? qq~<b>$tmpa</b>&nbsp;~ : qq~<a href="$scripturl?board=$currentboard/$counter" style="font-weight: normal;">$tmpa</a>&nbsp;~;
				$tmpa++;
			}
			if ($endpage < $threadcount - $maxindex) { $pageindexadd = qq~...&nbsp;~; }
			if ($endpage != $threadcount) { $pageindexadd .= qq~<a href="$scripturl?board=$currentboard/$lastptn" style="font-weight: normal;">$lastpn</a>~; }

			$pagetxtindex .= qq~$pageindexadd~;
			$pageindex1 = qq~$pagetxtindexst$pagetxtindex</span>~;
			$pageindex2 = $pageindex1;
		} else {
			$pagedropindex1 = qq~<span style="float: left; width: 320px; margin: 0px; margin-top: 2px; border: 0px;">~;
			$pagedropindex1 .= qq~<span style="float: left; height: 21px; margin: 0; margin-right: 4px;"><a href="$scripturl?board=$INFO{'board'};start=$start;action=messagepagetext"><img src="$imagesdir/index_togl.gif" border="0" alt="$messageindex_txt{'19'}" /></a></span>~;
			$pagedropindex2 = $pagedropindex1;
			$tstart         = $start;
			if (substr($INFO{'start'}, 0, 3) eq "all") { ($tstart, $start) = split(/\-/, $INFO{'start'}); }
			$d_indexpages = $pagenumb / $dropdisplaynum;
			$i_indexpages = int($pagenumb / $dropdisplaynum);
			if ($d_indexpages > $i_indexpages) { $indexpages = int($pagenumb / $dropdisplaynum) + 1; }
			else { $indexpages = int($pagenumb / $dropdisplaynum) }
			$selectedindex = int(($start / $maxindex) / $dropdisplaynum);

			if ($pagenumb > $dropdisplaynum) {
				$pagedropindex1 .= qq~<span style="float: left; height: 21px; margin: 0;"><select size="1" name="decselector1" id="decselector1" style="font-size: 9px; border: 2px inset;" onchange="if(this.options[this.selectedIndex].value) SelDec(this.options[this.selectedIndex].value, 'xx')">\n~;
				$pagedropindex2 .= qq~<span style="float: left; height: 21px; margin: 0;"><select size="1" name="decselector2" id="decselector2" style="font-size: 9px; border: 2px inset;" onchange="if(this.options[this.selectedIndex].value) SelDec(this.options[this.selectedIndex].value, 'xx')">\n~;
			}
			for ($i = 0; $i < $indexpages; $i++) {
				$indexpage  = ($i * $dropdisplaynum) * $maxindex;
				$indexstart = ($i * $dropdisplaynum) + 1;
				$indexend   = $indexstart + ($dropdisplaynum - 1);
				if ($indexend > $pagenumb)    { $indexend   = $pagenumb; }
				if ($indexstart == $indexend) { $indxoption = qq~$indexstart~; }
				else { $indxoption = qq~$indexstart-$indexend~; }
				$selected = "";
				if ($i == $selectedindex) {
					$selected    = qq~ selected="selected"~;
					$pagejsindex = qq~$indexstart|$indexend|$maxindex|$indexpage~;
				}
				if ($pagenumb > $dropdisplaynum) {
					$pagedropindex1 .= qq~<option value="$indexstart|$indexend|$maxindex|$indexpage"$selected>$indxoption</option>\n~;
					$pagedropindex2 .= qq~<option value="$indexstart|$indexend|$maxindex|$indexpage"$selected>$indxoption</option>\n~;
				}
			}
			if ($pagenumb > $dropdisplaynum) {
				$pagedropindex1 .= qq~</select>\n</span>~;
				$pagedropindex2 .= qq~</select>\n</span>~;
			}
			$pagedropindex1 .= qq~<span id="ViewIndex1" class="droppageindex" style="height: 14px; visibility: hidden">&nbsp;</span>~;
			$pagedropindex2 .= qq~<span id="ViewIndex2" class="droppageindex" style="height: 14px; visibility: hidden">&nbsp;</span>~;
			$tmpmaxindex = $maxindex;
			if (substr($INFO{'start'}, 0, 3) eq "all") { $maxindex = $maxindex * $dropdisplaynum; }
			$prevpage          = $start - $tmpmaxindex;
			$nextpage          = $start + $maxindex;
			$pagedropindexpvbl = qq~<img src="$imagesdir/index_left0.gif" height="14" width="13" border="0" alt="" style="margin: 0px; display: inline; vertical-align: middle;" />~;
			$pagedropindexnxbl = qq~<img src="$imagesdir/index_right0.gif" height="14" width="13" border="0" alt="" style="margin: 0px; display: inline; vertical-align: middle;" />~;
			if ($start < $maxindex) { $pagedropindexpv .= qq~<img src="$imagesdir/index_left0.gif" height="14" width="13" border="0" alt="" style="display: inline; vertical-align: middle;" />~; }
			else { $pagedropindexpv .= qq~<img src="$imagesdir/index_left.gif" border="0" height="14" width="13" alt="$pidtxt{'02'}" style="display: inline; vertical-align: middle; cursor: pointer;" onclick="location.href=\\'$scripturl?board=$currentboard/$prevpage\\'" ondblclick="location.href=\\'$scripturl?board=$currentboard/0\\'" />~; }
			if ($nextpage > $lastptn) { $pagedropindexnx .= qq~<img src="$imagesdir/index_right0.gif" border="0" height="14" width="13" alt="" style="display: inline; vertical-align: middle;" />~; }
			else { $pagedropindexnx .= qq~<img src="$imagesdir/index_right.gif" height="14" width="13" border="0" alt="$pidtxt{'03'}" style="display: inline; vertical-align: middle; cursor: pointer;" onclick="location.href=\\'$scripturl?board=$currentboard/$nextpage\\'" ondblclick="location.href=\\'$scripturl?board=$currentboard/$lastptn\\'" />~; }
			$pageindex1 = qq~$pagedropindex1</span>~;
			$pageindex2 = qq~$pagedropindex2</span>~;

			$pageindexjs = qq~
<script language="JavaScript1.2" type="text/javascript">
<!-- 
	function SelDec(decparam, visel) {
		splitparam = decparam.split("|");
		var vistart = parseInt(splitparam[0]);
		var viend = parseInt(splitparam[1]);
		var maxpag = parseInt(splitparam[2]);
		var pagstart = parseInt(splitparam[3]);
		var allpagstart = parseInt(splitparam[3]);
		if(visel == 'xx' && decparam == '$pagejsindex') visel = '$tstart';
		var pagedropindex = '<table border="0" cellpadding="0" cellspacing="0"><tr>';
		for(i=vistart; i<=viend; i++) {
			if(visel == pagstart) pagedropindex += '<td class="titlebg" height="14" style="height: 14px; padding-left: 1px; padding-right: 1px; font-size: 9px; font-weight: bold;">' + i + '</td>';
			else pagedropindex += '<td height="14" class="droppages"><a href="$scripturl?board=$currentboard/' + pagstart + '">' + i + '</a></td>';
			pagstart += maxpag;
		}
		if (vistart != viend) {
			if(visel == 'all') pagedropindex += '<td class="titlebg" height="14" style="height: 14px; padding-left: 1px; padding-right: 1px; font-size: 9px; font-weight: normal;"><b>$pidtxt{"01"}</b></td>';
			else pagedropindex += '<td height="14" class="droppages"><a href="$scripturl?board=$currentboard/all-' + allpagstart + '">$pidtxt{"01"}</a></td>';
		}
		if(visel != 'xx') pagedropindex += '<td height="14" class="small" style="height: 14px; padding-left: 4px;">$pagedropindexpv$pagedropindexnx</td>';
		else pagedropindex += '<td height="14" class="small" style="height: 14px; padding-left: 4px;">$pagedropindexpvbl$pagedropindexnxbl</td>';
		pagedropindex += '</tr></table>';
		document.getElementById("ViewIndex1").innerHTML=pagedropindex;
		document.getElementById("ViewIndex1").style.visibility = "visible";
		document.getElementById("ViewIndex2").innerHTML=pagedropindex;
		document.getElementById("ViewIndex2").style.visibility = "visible";
		~;
			if ($pagenumb > $dropdisplaynum) {
				$pageindexjs .= qq~
		document.getElementById("decselector1").value = decparam;
		document.getElementById("decselector2").value = decparam;
		~;
			}
			$pageindexjs .= qq~
	}
	document.onload = SelDec('$pagejsindex', '$tstart');
	//-->
</script>
~;
		}
	}

	# Determine what category we are in.
	$catid = ${$uid.$currentboard}{'cat'};
	($cat, $catperms) = split(/\|/, $catinfo{"$catid"});
	&ToChars($cat);
	fopen(BRDTXT, "$boardsdir/$currentboard.txt") || &fatal_error("300 $txt{'106'}: $txt{'23'} $currentboard.txt", 1);
	@threadlist = <BRDTXT>;
	fclose(BRDTXT);
	$threadcount = $#threadlist;

	if (-e "$vardir/attachments.txt" && -s "$vardir/attachments.txt") {
		fopen(ATT, "$vardir/attachments.txt");
		@attachmentlist = <ATT>;
		fclose(ATT);

		@temparr = ();
		$i       = 1;
		foreach $theatt (@attachmentlist) {
			($check, undef) = split(/\|/, $theatt, 2);
			$duped = 0;
			foreach $checkout (@temparr) {
				if ($checkout eq $check) {
					$duped = 1;
					$attachments{$check}++;
				}
			}
			if ($duped == 0) {
				push(@temparr, $check);
				$attachments{$check} = $i;
			}
		}
		undef @temparr;
	}


	# Mark current board as seen.
	&dumplog($currentboard);

	# Build a list of the board's moderators.
	$iammod = 0;
	if (scalar keys %moderators > 0) {
		if (scalar keys %moderators == 1) { $showmods = qq~($messageindex_txt{'298'}: ~; }
		else { $showmods = qq~($messageindex_txt{'63'}: ~; }
		while ($_ = each(%moderators)) {
			if ($username eq $_) { $iammod = 1; }
			&FormatUserName($_);
			$showmods .= qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$_}">$moderators{$_}</a>, ~;
		}
		$showmods =~ s/, \Z/)/;
	}
	if (scalar keys %moderatorgroups > 0) {
		&LoadUser($username);
		if (scalar keys %moderatorgroups == 1) { $showmodgroups = qq~($messageindex_txt{'298a'}: ~; }
		else { $showmodgroups = qq~($messageindex_txt{'63a'}: ~; }
		while ($mdgrps = each(%moderatorgroups)) {
			$tmpmodgrp = $moderatorgroups{$mdgrps};
			if (${$uid.$username}{'position'} == $tmpmodgrp) { $iammod = 1; }
			${$uid.$username}{'addgroups'} =~ s/\, /\,/g;
			(@memaddgrp) = split(/\,/, ${$uid.$username}{'addgroups'});
			foreach $memberaddgroups (@memaddgrp) {
				chomp $memberaddgroups;
				if ($memberaddgroups == $tmpmodgrp) { $iammod = 1; last; }
			}
			($thismodgrp, undef) = split(/\|/, $NoPost{$tmpmodgrp}, 2);
			$showmodgroups .= qq~$thismodgrp, ~;
		}
		$showmodgroups =~ s/, \Z/)/;
	}
	if ($showmodgroups ne "" && $showmods ne "") { $showmods .= qq~ - ~; }

	if ($numanns) { $countsticky = $numanns; }
	else { $countsticky = 0; }
	$countnosticky = 0;
	if ($numanns) { push(@stickythreadlist, @anns); }
	for ($i = 0; $i <= $threadcount; $i++) {
		my ($mnum, $threadstatus) = (split /\|/, $threadlist[$i])[0,8];
#		my @array        = split(/\|/, $threadlist[$i]);
#		my $threadstatus = pop(@array);                    #get only status
#		my $mnum         = shift(@array);                  # get only number
#		undef @array;
		if ($threadstatus =~ /s/i) {
			unless(!$iamadmin && !$iamgmod && !$iammod && $threadstatus =~ /h/i) {
				$stickythreadlist[$countsticky] = $threadlist[$i];
				$countsticky++;
			}
		} else {
			$nostickythreadlist[$countnosticky] = $threadlist[$i];
			$countnosticky++;
		}
	}

	if ($countsticky) { @threadlist = (@stickythreadlist, @nostickythreadlist); }
	@threads = splice(@threadlist, $start, $maxindex);
	chomp @threads;

	$stkynum = '';
	if ($start <= $#stickythreadlist) { $stkynum = scalar @stickythreadlist; }

	&LoadCensorList;

	# Print the header and board info.
	&ToChars($boardname);
#	$curboardurl = $curposlinks ? qq~<a href="$scripturl?board=$currentboard" class="nav">$boardname</a>~ : $boardname;
	if ((($iammod && $modview == 1) || ($iamadmin && $adminview == 1) || ($iamgmod && $gmodview == 1)) && $sessionvalid == 1) {
		$yymain .= qq~<script language="JavaScript1.2" src="$ubbcjspath" type="text/javascript"></script>~;
	}

	my $homelink  = qq~<a href="$scripturl" class="nav">$mbname</a>~;
	my $catlink   = qq~<a href="$scripturl?catselect=$catid" class="nav">$cat</a>~;
	my $boardlink = qq~<a href="$scripturl?board=$currentboard" class="nav">$boardname</a>~;
	my $modslink  = qq~$showmods~;

	# check howmany col's must be spanned
	if ((($iamadmin && $adminview >= 1) || ($iamgmod && $gmodview >= 1) || ($iammod && $modview >= 1)) && $sessionvalid == 1) {
		$colspan = 8;
	} else {
		$colspan = 7;
	}

	if (!$iamguest) {
		$markalllink = qq~$menusep<a href="$scripturl?board=$INFO{'board'};action=markasread">$img{'markboardread'}</a>~;
		if ($enable_notification) {
			$notify_board = qq~$menusep<a href="$scripturl?action=boardnotify;board=$INFO{'board'}">$img{'notify'}</a>~;
		} else {
			$notify_board = "";
		}
	}

	if (&AccessCheck($currentboard, 1) eq "granted") {
		$postlink = qq~$menusep<a href="$scripturl?board=$INFO{'board'};action=post;title=StartNewTopic">$img{'newthread'}</a>~;
	}
	if (&AccessCheck($currentboard, 3) eq "granted") {
		$polllink = qq~$menusep<a href="$scripturl?board=$INFO{'board'};action=post;title=CreatePoll">$img{'createpoll'}</a>~;
	}

	if ((($iamadmin && $adminview == 3) || ($iamgmod && $gmodview == 3) || ($iammod && $modview == 3)) && $sessionvalid == 1) {

		if ($currentboard eq $annboard) {
			$adminlink = qq~<img src="$imagesdir/admin_move.gif" alt="$messageindex_txt{'132'}" border="0" /><img src="$imagesdir/admin_rem.gif" alt="$messageindex_txt{'54'}" border="0" />~;
		} else {
			$adminlink = qq~<img src="$imagesdir/locked.gif" alt="$messageindex_txt{'104'}" border="0" /><img src="$imagesdir/sticky.gif" alt="$messageindex_txt{'781'}" border="0" /><img src="$imagesdir/admin_move.gif" alt="$messageindex_txt{'132'}" border="0" /><img src="$imagesdir/admin_rem.gif" alt="$messageindex_txt{'54'}" border="0" />~;
		}
		$adminheader =~ s/<yabb admin>/$adminlink/g;
	} elsif ((($iamadmin && $adminview != 0) || ($iamgmod && $gmodview != 0) || ($iammod && $modview != 0)) && $sessionvalid == 1) {
		$adminlink = qq~$messageindex_txt{'2'}~;

		$adminheader =~ s/<yabb admin>/$adminlink/g;
	}

	# check to display moderator column
	my $tmpstickyheader;
	if ($stkynum) {
		$stickyheader =~ s/<yabb colspan>/$colspan/g;
		$tmpstickyheader = $stickyheader;
	}

	# Begin printing the message index for current board.
	$counter = $start;

	getlog;

	foreach (@threads) {
		($mnum, $msub, $mname, $memail, $mdate, $mreplies, $musername, $micon, $mstate) = split(/\|/, $_);

		# Set thread class depending on locked status and number of replies.
		if ($mnum == "") { next; }
		$threadclass = 'thread';
		if    ($mstate =~ /h/i) { $threadclass = 'hide'; }
		elsif ($mstate =~ /l/i) { $threadclass = 'locked'; }
		elsif ($mreplies >= $VeryHotTopic) { $threadclass = 'veryhotthread'; }
		elsif ($mreplies >= $HotTopic)     { $threadclass = 'hotthread'; }
		elsif ($mstate == "")              { $threadclass = 'thread'; }

		if ($threadclass eq "hide" && ((!$iamadmin && !$iamgmod && !$iammod) || $sessionvalid == 0)) { next; }
		elsif ($threadclass eq 'hide' && $mstate =~ /s/i && $mstate !~ /l/i) { $threadclass = 'hidesticky'; }
		elsif ($threadclass eq 'hide' && $mstate =~ /l/i && $mstate !~ /s/i) { $threadclass = 'hidelock'; }
		elsif ($threadclass eq 'hide' && $mstate =~ /s/i && $mstate =~ /l/i) { $threadclass = 'hidestickylock'; }
		elsif ($threadclass eq 'locked' && $mstate =~ /s/i && $mstate !~ /h/i) { $threadclass = 'stickylock'; }
		elsif ($mstate =~ /s/i && $mstate !~ /h/i) { $threadclass = 'sticky'; }
		elsif ($mstate =~ /a/i && $mstate !~ /h/i) { $threadclass = 'announcement'; }

		if (!$iamguest && $max_log_days_old) {

			# Decide if thread should have the "NEW" indicator next to it.
			# Do this by reading the user's log for last read time on thread,
			# and compare to the last post time on the thread.
			$dlp  = $yyuserlog{$mnum}                 ? $yyuserlog{$mnum}                 : 0;
			$dlpb = $yyuserlog{"$currentboard--mark"} ? $yyuserlog{"$currentboard--mark"} : 0;
			$dlp  = $dlp > $dlpb                      ? $dlp                              : $dlpb;
			$threaddate = $mdate;
			if ($dlp < $threaddate && ($dlp > $max_log_days_old * 86400 || $dlp eq 0)) {
				if ($mstate =~ /a/i) {
					$new = qq~<a href="$scripturl?virboard=$currentboard;num=$mnum/new"><img src="$imagesdir/new.gif" alt="$messageindex_txt{'302'}" border="0"/></a>~;
				} else {
					$new = qq~<a href="$scripturl?num=$mnum/new"><img src="$imagesdir/new.gif" alt="$messageindex_txt{'302'}" border="0"/></a>~;
				}
			} elsif ($yyuserlog{"$mnum--unread"} && !$yyuserlog{$mnum}) {
				if ($mstate =~ /a/i) {
					$new = qq~<a href="$scripturl?virboard=$currentboard;num=$mnum/new"><img src="$imagesdir/new.gif" alt="$messageindex_txt{'302'}" border="0"/></a>~;
				} else {
					$new = qq~<a href="$scripturl?num=$mnum/new"><img src="$imagesdir/new.gif" alt="$messageindex_txt{'302'}" border="0"/></a>~;
				}
			} else {
				$new = '';
			}
		}

		$micon = qq~<img src="$imagesdir/$micon.gif" alt="" border="0" align="middle" />~;
		$mpoll = "";
		if (-e "$datadir/$mnum.poll") {
			$mpoll = qq~<b>$messageindex_polltxt{'15'}: </b>~;
			fopen(POLL, "$datadir/$mnum.poll");
			$poll_question = <POLL>;
			fclose(POLL);
			chomp $poll_question;
			(undef, $poll_locked, undef) = split(/\|/, $poll_question, 3);
			$micon = qq~$img{'pollicon'}~;
			if ($poll_locked) { $micon = $img{'polliconclosed'}; }
			elsif (!$iamguest && $max_log_days_old && $mdate > time - ($max_log_days_old * 86400)) {

				if ($dlp < $createpoll_date) {
					$micon = qq~$img{'polliconnew'}~;
				} else {
					fopen(POLLED, "$datadir/$mnum.polled");
					$polled = <POLLED>;
					fclose(POLLED);
					(undef, undef, undef, $vote_date, undef) = split(/\|/, $polled);
					if ($dlp < $vote_date) { $micon = qq~$img{'polliconnew'}~; }
				}
			}
		}

		# Load the current nickname of the account name of the thread starter.
		if ($musername ne 'Guest') {
			&LoadUser($musername);
			$registrationdate = ${$uid.$musername}{'regtime'};
			$threadstartdate  = $mnum;

			if ((${$uid.$musername}{'regdate'} && $threadstartdate > $registrationdate) || ${$uid.$musername}{'status'} eq "Administrator" || ${$uid.$musername}{'status'} eq "Global Moderator") {
				$mname = qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$musername}">$ {$uid.$musername}{'realname'}</a>~;
			} else {
				$mname .= qq~ ($messageindex_txt{'470a'})~;
			}
		}
		$msub =~ s/\A\[m\]/$maintxt{'758'}/;

		# Censor the subject of the thread.
		$msub = &Censor($msub);
		&ToChars($msub);

		# Build the page links list.
		$pages = '';
		if (int(($mreplies + 1) / $maxmessagedisplay) > 6) {
			$pages = qq~ <a href="$scripturl?num=$mnum/0#0">1</a>~;
			$pages .= qq~ <a href="$scripturl?num=$mnum/$maxmessagedisplay#$maxmessagedisplay">2</a>~;
			$endpage = int(($mreplies) / $maxmessagedisplay) + 1;
			$i       = ($endpage - 1) * $maxmessagedisplay;
			$j       = $i - $maxmessagedisplay;
			$k       = $endpage - 1;
			$tmpa    = $endpage - 2;
			$tmpb    = $j - $maxmessagedisplay;
			$pages .= qq~ <a href="$scripturl?action=pages;num=$mnum">...</a>~;
			$pages .= qq~ <a href="$scripturl?num=$mnum/$tmpb#$tmpb">$tmpa</a>~;
			$pages .= qq~ <a href="$scripturl?num=$mnum/$j#$j">$k</a>~;
			$pages .= qq~ <a href="$scripturl?num=$mnum/$i#$i">$endpage</a>~;
			$pages = qq~<br /><span class="small">&#171; $messageindex_txt{'139'} $pages <a href="$scripturl?num=$mnum;start=all">$pidtxt{'01'}</a> &#187;</span>~;
		} elsif ($mreplies + 1 > $maxmessagedisplay) {
			$tmpa = 1;
			for ($tmpb = 0; $tmpb < $mreplies + 1; $tmpb += $maxmessagedisplay) {
				$pages .= qq~<a href="$scripturl?num=$mnum/$tmpb#$tmpb">$tmpa</a>\n~;
				++$tmpa;
			}
			$pages =~ s/\n\Z//;
			$pages = qq~<br /><span class="small">&#171; $messageindex_txt{'139'} $pages <a href="$scripturl?num=$mnum;start=all">$pidtxt{'01'}</a> &#187;</span>~;
		}

		&MessageTotals("load", $mnum);
		$views      = ${$mnum}{'views'};
		$lastposter = ${$mnum}{'lastposter'};
		if ($lastposter =~ m~\AGuest-(.*)~) {
			$lastposter = $1;
		} else {
			&LoadUser($lastposter);
			$registrationdate = ${$uid.$lastposter}{'regtime'};

			$messagedate = ${$mnum}{'lastpostdate'};

			if ((${$uid.$lastposter}{'regdate'} && $messagedate > $registrationdate) || ${$uid.$lastposter}{'position'} eq "Administrator" || ${$uid.$lastposter}{'position'} eq "Global Moderator") { $lastposter = qq~<a href="$scripturl?action=viewprofile;username=$lastposter">${$uid.$lastposter}{'realname'}</a>~; }
			else { $lastposter .= qq~ - $messageindex_txt{'470a'}~; }
		}
		$lastpostername = $lastposter || $messageindex_txt{'470'};
		$views = $views ? $views - 1 : 0;

		if (($stkynum && ($counter >= $stkynum)) && ($stkyshowed < 1)) {
			$nonstickyheader =~ s/<yabb colspan>/$colspan/g;
			$tmptempbar .= $nonstickyheader;
			$stkyshowed = 1;
		}

		# Check if the thread contains attachments and create a paper-clip icon if it does
		$temp_attachment = "";
		if (exists $attachments{$mnum}) {
			$atnum = qq~$attachments{$mnum}~;
			if($atnum == 1) { $attalttext = qq~$messageindex_txt{'3'} $atnum $messageindex_txt{'5'}~; }
			else { $attalttext = qq~$messageindex_txt{'3'} $atnum $messageindex_txt{'4'}~; }
			$temp_attachment = qq~<img src="$imagesdir/paperclip.gif" alt="$attalttext" />~;
		}

		# Print the thread info.
		$mydate = &timeformat($mdate);
		if ((($iamadmin && $adminview == 3) || ($iamgmod && $gmodview == 3) || ($iammod && $modview == 3 && !$iamadmin && !$iamgmod)) && $sessionvalid == 1) {
			if ($currentboard eq $annboard) {
				$adminbar = qq~
		<input type="checkbox" name="moveadmin$mcount" class="windowbg" style="border: 0px;" value="$mnum" />
		<input type="checkbox" name="deleteadmin$mcount" class="windowbg" style="border: 0px;" value="$mnum" />
        	~;
			} elsif ($currentboard ne $annboard && $counter < @anns) {
				$adminbar = qq~&nbsp;~;
			} else {
				$adminbar = qq~
		<input type="checkbox" name="lockadmin$mcount" class="windowbg" style="border: 0px;" value="$mnum" />
		<input type="checkbox" name="stickadmin$mcount" class="windowbg" style="border: 0px;" value="$mnum" />
		<input type="checkbox" name="moveadmin$mcount" class="windowbg" style="border: 0px;" value="$mnum" />
		<input type="checkbox" name="deleteadmin$mcount" class="windowbg" style="border: 0px;" value="$mnum" />
        	~;
			}
			$admincol = $admincolumn;
			$admincol =~ s/<yabb admin>/$adminbar/g;
		} elsif ((($iamadmin && $adminview == 2) || ($iamgmod && $gmodview == 2) || ($iammod && $modview == 2 && !$iamadmin && !$iamgmod)) && $sessionvalid == 1) {
			if ($currentboard ne $annboard && $counter < @anns) {
				$adminbar = qq~&nbsp;~;
			} else {
				$adminbar = qq~<input type="checkbox" name="admin$mcount" class="windowbg" style="border: 0px;" value="$mnum" />~;
			}
			$admincol = $admincolumn;
			$admincol =~ s/<yabb admin>/$adminbar/g;
		} elsif ((($iamadmin && $adminview == 1) || ($iamgmod && $gmodview == 1) || ($iammod && $modview == 1 && !$iamadmin && !$iamgmod)) && $sessionvalid == 1) {
			if ($currentboard eq $annboard) {
				$adminbar = qq~
		<a href="$scripturl?action=movethread;thread=$mnum"><img src="$imagesdir/admin_move.gif" alt="$messageindex_txt{'132'}" border="0" /></a>&nbsp;
		<a href="$scripturl?action=removethread;thread=$mnum" onclick="return confirm('$messageindex_txt{'162'}')"><img src="$imagesdir/admin_rem.gif" alt="$messageindex_txt{'54'}" border="0" /></a>
        	~;
			} elsif ($currentboard ne $annboard && $counter < @anns) {
				$adminbar = qq~&nbsp;~;
			} else {
				$adminbar = qq~
		<a href="$scripturl?action=lock;thread=$mnum"><img src="$imagesdir/locked.gif" alt="$messageindex_txt{'104'}" border="0" /></a>&nbsp;
		<a href="$scripturl?action=sticky;thread=$mnum"><img src="$imagesdir/sticky.gif" alt="$messageindex_txt{'781'}" border="0" /></a>&nbsp;
		<a href="$scripturl?action=movethread;thread=$mnum"><img src="$imagesdir/admin_move.gif" alt="$messageindex_txt{'132'}" border="0" /></a>&nbsp;
		<a href="$scripturl?action=removethread;thread=$mnum" onclick="return confirm('$messageindex_txt{'162'}')"><img src="$imagesdir/admin_rem.gif" alt="$messageindex_txt{'54'}" border="0" /></a>
        	~;
			}
			$admincol = $admincolumn;
			$admincol =~ s/<yabb admin>/$adminbar/g;
		}
		my $threadpic = qq~<img src="$imagesdir/$threadclass.gif" alt=""/>~;

		if ($mstate =~ /a/i) {
			$msublink = qq~<a href="$scripturl?virboard=$currentboard;num=$mnum">$msub</a>~;
		} else {
			$msublink = qq~<a href="$scripturl?num=$mnum">$msub</a>~;
		}

		my $lastpostlink = qq~<a href="$scripturl?num=$mnum/$mreplies#$mreplies">$img{'lastpost'} $mydate</a>~;
		my $tempbar      = $threadbar;

		$tempbar =~ s/<yabb admin column>/$admincol/g;
		$tempbar =~ s/<yabb threadpic>/$threadpic/g;
		$tempbar =~ s/<yabb icon>/$micon/g;
		$tempbar =~ s/<yabb new>/$new/g;
		$tempbar =~ s/<yabb poll>/$mpoll/g;
		$tempbar =~ s/<yabb favorite>/$favicon{$mnum}/g;
		$tempbar =~ s/<yabb subjectlink>/$msublink/g;
		$tempbar =~ s/<yabb attachmenticon>/$temp_attachment/g;
		$tempbar =~ s/<yabb pages>/$pages/g;
		$tempbar =~ s/<yabb starter>/$mname/g;
		$tempbar =~ s/<yabb replies>/$mreplies/g;
		$tempbar =~ s/<yabb views>/$views/g;
		$tempbar =~ s/<yabb lastpostlink>/$lastpostlink/g;
		$tempbar =~ s/<yabb lastposter>/$lastpostername/g;
		$tempbar =~ s/<yabb replies>/$mreplies/g;
		$tempbar =~ s/<yabb favorite>/$favicon{$mnum}/g;
		$tmptempbar .= $tempbar;
		++$counter;
		$mcount++;
	}

	# Put a "no messages" message if no threads exisit - just a  bit more friendly...
	if (!$tmptempbar) {

		# check howmany col's must be spanned
		if ((($iamadmin && $adminview >= 1) || ($iamgmod && $gmodview >= 1) || ($iammod && $modview >= 1)) && $sessionvalid == 1) {
			$colspan = 8;
		} else {
			$colspan = 7;
		}

		$tmptempbar = qq~
		<tr>
			<td class="windowbg2" valign="middle" align="center" colspan="$colspan"><br />$messageindex_txt{'841'}<br /><br /></td>
		</tr>
		~;
	}

	my $multiview = 0;
	my $tmptempfooter;
	if    ((($iamadmin && $adminview == 3) || ($iamgmod && $gmodview == 3) || ($iammod && $modview == 3 && !$iamadmin && !$iamgmod)) && $sessionvalid == 1) { $multiview = 3; }
	elsif ((($iamadmin && $adminview == 2) || ($iamgmod && $gmodview == 2) || ($iammod && $modview == 2 && !$iamadmin && !$iamgmod)) && $sessionvalid == 1) { $multiview = 2; }

	if ($multiview >= 2) {
		&moveto;
		if ($multiview eq '3') {
			$tempfooter    = $subfooterbar;
			$adminselector = qq~
				$messageindex_txt{'133'}: <select name="toboard">$boardlist</select><input type="submit" value="$messageindex_txt{'462'}" />
			~;
			if ($currentboard eq $annboard) {
				$admincheckboxes = qq~
				<input type="checkbox" name="moveall" value="" class="titlebg" style="border: 0px;" onclick="if (this.checked) checkAll(1); else uncheckAll(1);" />
				<input type="checkbox" name="deleteall" value="" class="titlebg" style="border: 0px;" onclick="if (this.checked) checkAll(2); else uncheckAll(2);" />
				<input type="hidden" name="fromboard" value="$currentboard" />
			~;
			} else {
				$admincheckboxes = qq~
				<input type="checkbox" name="lockall" value="" class="titlebg" style="border: 0px;" onclick="if (this.checked) checkAll(1); else uncheckAll(1);" />
				<input type="checkbox" name="stickall" value="" class="titlebg" style="border: 0px;" onclick="if (this.checked) checkAll(2); else uncheckAll(2);" />
				<input type="checkbox" name="moveall" value="" class="titlebg" style="border: 0px;" onclick="if (this.checked) checkAll(3); else uncheckAll(3);" />
				<input type="checkbox" name="deleteall" value="" class="titlebg" style="border: 0px;" onclick="if (this.checked) checkAll(4); else uncheckAll(4);" />
				<input type="hidden" name="fromboard" value="$currentboard" />
			~;
			}
			$tempfooter =~ s/<yabb admin selector>/$adminselector/g;
			$tempfooter =~ s/<yabb admin checkboxes>/$admincheckboxes/g;
		} elsif ($multiview eq '2') {
			$tempfooter = $subfooterbar;
			if ($currentboard eq $annboard) {
				$adminselector = qq~
				<input type="radio" name="action" value="delete" class="titlebg" style="border: 0px;" checked="checked" /> $messageindex_txt{'31'}
				<input type="radio" name="action" value="move" class="titlebg" style="border: 0px;" /> $messageindex_txt{'133'}: <select name="toboard">$boardlist</select>
				<input type="hidden" name="fromboard" value="$currentboard" />
				<input type="submit" value="$messageindex_txt{'462'}" />
			~;
			} else {
				$adminselector = qq~
				<input type="radio" name="action" value="lock" class="titlebg" style="border: 0px;" checked="checked" /> $messageindex_txt{'104'}
				<input type="radio" name="action" value="stick" class="titlebg" style="border: 0px;" /> $messageindex_txt{'781'}
				<input type="radio" name="action" value="delete" class="titlebg" style="border: 0px;" /> $messageindex_txt{'31'}
				<input type="radio" name="action" value="move" class="titlebg" style="border: 0px;" /> $messageindex_txt{'133'}: <select name="toboard">$boardlist</select>
				<input type="hidden" name="fromboard" value="$currentboard" />
				<input type="submit" value="$messageindex_txt{'462'}" />
			~;
			}
			$admincheckboxes = qq~
				<input type="checkbox" name="checkall" value="" class="titlebg" style="border: 0px;" onclick="if (this.checked) checkAll(0); else uncheckAll(0);" />
			~;
			$tempfooter =~ s/<yabb admin selector>/$adminselector/g;
			$tempfooter =~ s/<yabb admin checkboxes>/$admincheckboxes/g;
		}
	}
	$tmptempfooter .= $tempfooter;
	&jumpto;

$yabbicons = qq~
	<img src="$imagesdir/thread.gif" alt="" /> $messageindex_txt{'457'}<br />
	<img src="$imagesdir/sticky.gif" alt="" /> $messageindex_txt{'779'}<br />
	<img src="$imagesdir/locked.gif" alt="" /> $messageindex_txt{'456'}<br />
	<img src="$imagesdir/stickylock.gif" alt="" /> $messageindex_txt{'780'}<br />
~;
	if (($iamadmin || $iamgmod || $iammod) && $sessionvalid == 1) {
		$yabbadminicons = qq~<img src="$imagesdir/hide.gif" alt="" /> $messageindex_txt{'458'}<br />~;
		$yabbadminicons .= qq~<img src="$imagesdir/hidesticky.gif" alt="" /> $messageindex_txt{'459'}<br />~;
		$yabbadminicons .= qq~<img src="$imagesdir/hidelock.gif" alt="" /> $messageindex_txt{'460'}<br />~;
		$yabbadminicons .= qq~<img src="$imagesdir/hidestickylock.gif" alt="" /> $messageindex_txt{'461'}<br />~;
	}
$yabbadminicons .= qq~
	<img src="$imagesdir/announcement.gif" alt="" /> $messageindex_txt{'779a'}<br />
	<img src="$imagesdir/hotthread.gif" alt="" /> $messageindex_txt{'454'} $HotTopic $messageindex_txt{'454a'}<br />
	<img src="$imagesdir/veryhotthread.gif" alt="" /> $messageindex_txt{'455'} $VeryHotTopic $messageindex_txt{'454a'}<br />
~;

	&LoadAccess;

	#template it
	$template_mods = qq~$modslink$showmodgroups~;
	if ($template_mods) { $template_mods = qq~<br />$template_mods~; }

	$messageindex_template =~ s/<yabb home>/$homelink/g;
	$messageindex_template =~ s/<yabb category>/$catlink/g;
	$messageindex_template =~ s/<yabb board>/$boardlink/g;
	$messageindex_template =~ s/<yabb moderators>/$template_mods/g;
	if ($ShowBDescrip && $bdescrip ne "") {
		&ToChars($bdescrip);
		$boarddescription      =~ s/<yabb boarddescription>/$bdescrip/g;
		$messageindex_template =~ s/<yabb description>/$boarddescription/g;
	} else {
		$messageindex_template =~ s/<yabb description>//g;
	}
	$messageindex_template =~ s/<yabb colspan>/$colspan/g;

	$topichandellist       =~ s/<yabb notify button>/$notify_board/g;
	$topichandellist       =~ s/<yabb markall button>/$markalllink/g;
	$topichandellist       =~ s/<yabb new post button>/$postlink/g;
	$topichandellist       =~ s/<yabb new poll button>/$polllink/g;
	$topichandellist       =~ s/\Q$menusep//i;
	$messageindex_template =~ s/<yabb topichandellist>/$topichandellist/g;

	$messageindex_template =~ s/<yabb pageindex top>/$pageindex1/g;
	$messageindex_template =~ s/<yabb pageindex bottom>/$pageindex2/g;

	if ((($iamadmin && $adminview == 3) || ($iamgmod && $gmodview == 3) || ($iammod && $modview == 3 && !$iamadmin && !$iamgmod)) && $sessionvalid == 1) {
		$messageindex_template =~ s/<yabb admin column>/$adminheader/g;
	} elsif ((($iamadmin && $adminview != 0) || ($iamgmod && $gmodview != 0) || ($iammod && $modview != 0 && !$iamadmin && !$iamgmod)) && $sessionvalid == 1) {
		$messageindex_template =~ s/<yabb admin column>/$adminheader/g;
	} else {
		$messageindex_template =~ s/<yabb admin column>//g;
	}

	if ((($iamadmin && $adminview >= 2) || ($iamgmod && $gmodview >= 2) || ($iammod && $modview >= 2 && !$iamadmin && !$iamgmod)) && $sessionvalid == 1) {
		$formstart = qq~<form name="multiadmin" action="$scripturl?board=$currentboard;action=multiadmin" method="post" style="display: inline">~;
		$formend   = qq~<input type="hidden" name="allpost" value="$INFO{'start'}" /></form>~;
		$messageindex_template =~ s/<yabb modupdate>/$formstart/g;
		$messageindex_template =~ s/<yabb modupdateend>/$formend/g;
	} else {
		$messageindex_template =~ s/<yabb modupdate>//g;
		$messageindex_template =~ s/<yabb modupdateend>//g;
	}
	if ($tmpstickyheader) {
		$messageindex_template =~ s/<yabb stickyblock>/$tmpstickyheader/g;
	} else {
		$messageindex_template =~ s/<yabb stickyblock>//g;
	}
	$messageindex_template =~ s/<yabb threadblock>/$tmptempbar/g;
	if ($tmptempfooter) {
		$messageindex_template =~ s/<yabb adminfooter>/$tmptempfooter/g;
	} else {
		$messageindex_template =~ s/<yabb adminfooter>//g;
	}
	$messageindex_template =~ s/<yabb forumjump>/$selecthtml/g;
	$messageindex_template =~ s/<yabb icons>/$yabbicons/g;
	$messageindex_template =~ s/<yabb admin icons>/$yabbadminicons/g;
	$messageindex_template =~ s/<yabb access>/$accesses/g;
	$yymain .= qq~
	$messageindex_template
	$pageindexjs
	~;

	if ((($iamadmin && $adminview >= 2) || ($iamgmod && $gmodview >= 2) || ($iammod && $modview >= 2 && !$iamadmin && !$iamgmod)) && $sessionvalid == 1) {
		if ((($iamadmin && $adminview == 3) || ($iamgmod && $gmodview == 3) || ($iammod && $modview == 3 && !$iamadmin && !$iamgmod)) && $sessionvalid == 1) { $offset = "7"; }
		else { $offset = "8"; }

		if ($currentboard eq $annboard) { $modul = 2; $offset = ($offset - 2); }
		else { $modul = 4; }

		if ($sessionvalid == 1) {
			$yymain .= qq~
<script language="JavaScript1.2" type="text/javascript">
	<!-- Begin
		function checkAll(j) {
  			for (var i = 0; i < document.multiadmin.elements.length - $offset; i++) {
  				if(document.multiadmin.elements[i].name != "subfield" && document.multiadmin.elements[i].name != "msgfield") {
					if (j == 0 ) {document.multiadmin.elements[i].checked = true;}
					if (j != 0 && (i % $modul) == (j - 1))  {document.multiadmin.elements[i].checked = true;}
    			}
  			}
		}
		function uncheckAll(j) {
  			for (var i = 0; i < document.multiadmin.elements.length - $offset; i++) {
  				if(document.multiadmin.elements[i].name != "subfield" && document.multiadmin.elements[i].name != "msgfield") {
					if (j == 0 ) {document.multiadmin.elements[i].checked = false;}
					if (j != 0 && (i % $modul) == (j - 1))  {document.multiadmin.elements[i].checked = false;}
		    	}
  			}
		}
	//-->
</script>
			~;
		}
	}

	$yytitle = $boardname;
	&template;
	exit;
}

sub MarkRead {

	# Mark all threads in this board as read.
	&dumplog("$currentboard--mark");
	$yySetLocation = qq~$scripturl?board=$currentboard~;
	&redirectexit;
}

sub ListPages {
	my $testthread = $INFO{'num'};
	$mreplies   = ${$testthread}{'replies'};
	$mviews     = ${$testthread}{'views'};
	$lastposter = ${$testthread}{'lastposter'};
	$tmpa       = 1;
	for ($tmpb = 0; $tmpb < $mreplies; $tmpb += $maxmessagedisplay) {
		$pages .= qq~<a href="$scripturl?num=$INFO{'num'}/$tmpb#$tmpb">$tmpa</a>\n~;
		++$tmpa;
	}
	$pages =~ s/\n\Z//;
	$yymain  = qq~<p align="center">&#171; $messageindex_txt{'139'} $pages &#187;</p><br />~;
	$yytitle = "$messageindex_txt{'139'} $messageindex_txt{'18'}";
	&template;
}

sub MessagePageindex {
	my ($msindx, $trindx, $mbindx);
	($msindx, $trindx, $mbindx) = split(/\|/, ${$uid.$username}{'pageindex'});
	if ($INFO{'action'} eq "messagepagedrop") {
		${$uid.$username}{'pageindex'} = qq~0|$trindx|$mbindx~;
	}
	if ($INFO{'action'} eq "messagepagetext") {
		${$uid.$username}{'pageindex'} = qq~1|$trindx|$mbindx~;
	}
	&UserAccount($username, "update");
	&redirectinternal;
	exit;
}

1;

