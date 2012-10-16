###############################################################################
# Display.pl                                                                  #
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

$displayplver = 'YaBB 2.1 $Revision: 1.5 $';
if ($action eq 'detailedversion') { return 1; }

LoadLanguage("Display");
LoadLanguage("FA");
require "$templatesdir/$usedisplay/Display.template";
if ($iamgmod) { require "$vardir/gmodsettings.txt"; }

sub Display {

	# Check if board was 'shown to all' - and whether they can view the topic
	if (&AccessCheck($currentboard, '', $boardperms) ne "granted") { &fatal_error("$maintxt{'1'}"); }

	if ($INFO{'start'} eq "new") {

		# This decides which messages were already read in the thread to
		# determing where the redirect should go. It is done by
		# comparing times in the username.log and the boardnumber.txt files.
		if (!$iamguest && $max_log_days_old) {
			$mnum = $INFO{'num'};

			getlog;

			$dlp = $yyuserlog{$mnum} || 0;
			$dlpb = $yyuserlog{"$currentboard--mark"} || 0;
			$dlp = $dlp > $dlpb ? $dlp : $dlpb;
			$dlp = $dlp > $date - ($max_log_days_old * 86400) ? $dlp : $date - ($max_log_days_old * 86400);    #renew prevent
			$i = 0;
			fopen(MNUM, "$datadir/$mnum.txt");

			foreach $mess (<MNUM>) {
				@tmp = split(/\|/, $mess);
				if ($tmp[3] > $dlp) { last; }
				$i++;
			}
			fclose(MNUM);
			if ($currentboard eq $annboard) {
				$yySetLocation = qq~$scripturl?virboard=$INFO{'virboard'};num=$mnum/$i#$i~;
			} else {
				$yySetLocation = qq~$scripturl?num=$mnum/$i#$i~;
			}
			&redirectexit;
		}
	}

	my $viewnum = $INFO{'num'};

	# strip off any non numeric values to avoid exploitation
	$viewnum =~ s/(\D*)//ig;
	if ($viewnum !~ /\d*(.\d*)?/) { &fatal_error($display_txt{'337'}); }
	$maxmessagedisplay ||= 10;
	my ($buffer, $views, $lastposter, $moderators, $moderatorgroups, $counter, $counterwords, $pagedropindex, $msubthread, $mnum, $mstate, $mdate, $msub, $mname, $memail, $mreplies, $musername, $micon, $threadclass, $notify, $max, $start, $bgcolornum, $windowbg, $mattach, $mip, $mlm, $mlmb, $lastmodified, $postinfo, $star, $sendm, $topicdate);
	my (@messages, @bgcolors);

	&LoadCensorList;

	# Determine category
	$curcat = ${$uid.$currentboard}{'cat'};

	# Figure out the name of the category
	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }

	if ($currentboard eq $annboard) {
		$vircurrentboard = $INFO{'virboard'};
		$vircurcat       = ${$uid.$vircurrentboard}{'cat'};
		($vircat, undef) = split(/\|/, $catinfo{"$vircurcat"});
		($virboardname, undef, undef) = split(/\|/, $board{"$vircurrentboard"});
		&ToChars($virboardname);
	}

	($cat, $catperms) = split(/\|/, $catinfo{"$curcat"});
	&ToChars($cat);

	($boardname, $boardperms, $boardview) = split(/\|/, $board{"$currentboard"});

	ToChars $boardname;

	# Mark current thread as read.
	($mnum, undef, undef, undef, $mdate) = split(/\|/, $yyThreadLine);
	modlog $mnum;

	# FIXME: WTF?? It's hack - we have not really seen that list!
	# Mark current board as read if called from Last Post.
	&BoardTotals("load", $currentboard);
	if ($mnum == ${$uid.$currentboard}{'lastpostid'}) {

		my $lastboardvisit = $yyuserlog{$currentboard} || 0;

		if ($mdate > $lastboardvisit) {
			modlog $currentboard;
		}
	}

	dumplog;

	$views = ${$viewnum}{'views'} - 1;

	# Check to make sure this thread isn't locked.
	($mnum, $msubthread, $mname, $memail, $mdate, $mreplies, $musername, $micon, $mstate) = split(/\|/, $yyThreadLine);
	$msubthread =~ s/\A\[m\]/$maintxt{'758'}/;

	# Look for a poll file for this thread.
	if (&AccessCheck($currentboard, 3) eq "granted") {
		$pollbutton = qq~$menusep<a href="$scripturl?action=post;num=$viewnum;title=AddPoll">$img{'addpoll'}</a>~;
	} else {
		$pollbutton = "";
	}
	if (-e "$datadir/$viewnum.poll") {
		$has_poll   = 1;
		$pollbutton = "";
	} else {
		$has_poll = 0;
		if ($useraddpoll == 0) { $pollbutton = ""; }
	}

	# Get the class of this thread, based on lock status and number of replies.
	if ($annboard eq $currentboard && !$iamadmin && !$iamgmod) {
		$replybutton = "";
	} elsif (&AccessCheck($currentboard, 2) eq "granted") {
		$replybutton = qq~$menusep<a href="$scripturl?action=post;num=$viewnum;title=PostReply">$img{'reply'}</a> ~;
	} else {
		$replybutton = "";
	}
	my $ishidden;
	$threadclass = 'thread';
	if ($mstate =~ /h/i) { $threadclass = 'hide'; $ishidden = 1; }
	elsif ($mstate =~ /l/i) { $threadclass = 'locked'; $replybutton = ""; $pollbutton  = ""; }
	elsif ($mreplies >= $VeryHotTopic) { $threadclass = 'veryhotthread'; }
	elsif ($mreplies >= $HotTopic) { $threadclass = 'hotthread'; }
	elsif ($mstate == "") { $threadclass = 'thread'; }

	if ($threadclass eq 'hide' && $mstate =~ /s/i && $mstate !~ /l/i) { $threadclass = 'hidesticky'; }
	elsif ($threadclass eq 'hide' && $mstate =~ /l/i && $mstate !~ /s/i) { $threadclass = 'hidelock'; $replybutton = ""; $pollbutton  = ""; }
	elsif ($threadclass eq 'hide' && $mstate =~ /s/i && $mstate =~ /l/i) { $threadclass = 'hidestickylock'; $replybutton = ""; $pollbutton  = ""; }
	elsif ($threadclass eq 'locked' && $mstate =~ /s/i && $mstate !~ /h/i) { $threadclass = 'stickylock'; }
	elsif ($mstate =~ /s/i && $mstate !~ /h/i) { $threadclass = 'sticky'; }
	elsif ($mstate =~ /a/i) { $threadclass = 'announcement'; $pollbutton = ""; }

	# Build a list of this board's moderators.
	$iammod = 0;
	if (scalar keys %moderators > 0) {
		if (scalar keys %moderators == 1) { $showmods = qq~($display_txt{'298'}: ~; }
		else { $showmods = qq~($display_txt{'63'}: ~; }
		while ($_ = each(%moderators)) {
			if ($username eq $_) { $iammod = 1; }
			&FormatUserName($_);
			$showmods .= qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$_}">$moderators{$_}</a>, ~;
		}
		$showmods =~ s/, \Z/)/;
	}
	if (scalar keys %moderatorgroups > 0) {
		&LoadUser($username);
		if (scalar keys %moderatorgroups == 1) { $showmodgroups = qq~($display_txt{'298a'}: ~; }
		else { $showmodgroups = qq~($display_txt{'63a'}: ~; }
		while ($_ = each(%moderatorgroups)) {
			if (${$uid.$username}{'position'} == $moderatorgroups{$_}) { $iammod = 1; }
			${$uid.$username}{'addgroups'} =~ s/\, /\,/g;
			foreach $memberaddgroups (split(/\,/, ${$uid.$username}{'addgroups'})) {
				chomp $memberaddgroups;
				if ($memberaddgroups == $moderatorgroups{$_}) { $iammod = 1; last; }
			}
			$tmpmodgrp = $moderatorgroups{$_};
			($thismodgrp, undef) = split(/\|/, $NoPost{$tmpmodgrp}, 2);
			$showmodgroups .= qq~$thismodgrp, ~;
		}
		$showmodgroups =~ s/, \Z/)/;
	}

	if ($ishidden && !$iammod && !$iamadmin && !$iamgmod) { &fatal_error("$maintxt{'1'}"); }

	if (-e "$datadir/$mnum.mail" && !$iamguest) {
		require "$sourcedir/Notify.pl";
		&ManageThreadNotify("update", $mnum, $username, "", "", "1");
	}

	if ($showmodgroups ne "" && $showmods ne "") { $showmods .= qq~ - ~; }
	if ($enable_notification) {
		my $startnum = $start || '0';
		$notify = qq~$menusep<a href="$scripturl?action=notify;thread=$viewnum/$startnum">$img{'notify'}</a>~;
	}

	# Build the page links list.
	if (!$iamguest) {
		(undef, $userthreadpage, undef) = split(/\|/, ${$uid.$username}{'pageindex'});
	}
	my ($pagetxtindex, $pagetextindex, $pagedropindex1, $pagedropindex2, $all, $allselected);
	$postdisplaynum = 3;               # max number of pages to display
	$dropdisplaynum = 10;
	$startpage      = 0;
	$max            = $mreplies + 1;
	if ($INFO{'start'} eq "all") { $maxmessagedisplay = $max; $all = 1; $allselected = qq~ selected="selected"~; $start = 0 }
	else { $start = $INFO{'start'} || 0; }
	$start    = $start > $mreplies ? $mreplies : $start;
	$start    = (int($start / $maxmessagedisplay)) * $maxmessagedisplay;
	$tmpa     = 1;
	$pagenumb = int(($max - 1) / $maxmessagedisplay) + 1;

	if ($start >= (($postdisplaynum - 1) * $maxmessagedisplay)) {
		$startpage = $start - (($postdisplaynum - 1) * $maxmessagedisplay);
		$tmpa = int($startpage / $maxmessagedisplay) + 1;
	}
	if ($max >= $start + ($postdisplaynum * $maxmessagedisplay)) { $endpage = $start + ($postdisplaynum * $maxmessagedisplay); }
	else { $endpage = $max; }
	$lastpn     = int($mreplies / $maxmessagedisplay) + 1;
	$lastptn    = ($lastpn - 1) * $maxmessagedisplay;
	$pageindex1 = qq~<span class="small" style="float: left; height: 21px; margin: 0px; margin-top: 2px;"><img src="$imagesdir/index_togl.gif" border="0" alt="" style="vertical-align: middle;" /> $display_txt{'139'}: $pagenumb</span>~;
	$pageindex2 = $pageindex1;
	if ($pagenumb > 1 || $all) {

		if ($userthreadpage == 1 || $iamguest) {
			$pagetxtindexst = qq~<span class="small" style="float: left; height: 21px; margin: 0px; margin-top: 2px;">~;
			if (!$iamguest) { $pagetxtindexst .= qq~<a href="$scripturl?action=threadpagedrop;num=$viewnum;start=$start"><img src="$imagesdir/index_togl.gif" border="0" alt="$display_txt{'19'}" style="vertical-align: middle;" /></a> $display_txt{'139'}: ~; }
			else { $pagetxtindexst .= qq~<img src="$imagesdir/index_togl.gif" border="0" alt="" style="vertical-align: middle;" /> $display_txt{'139'}: ~; }
			if ($startpage > 0) { $pagetxtindex = qq~<a href="$scripturl?num=$viewnum/0" style="font-weight: normal;">1</a>&nbsp;...&nbsp;~; }
			if ($startpage == $maxmessagedisplay) { $pagetxtindex = qq~<a href="$scripturl?num=$viewnum/0" style="font-weight: normal;">1</a>&nbsp;~; }
			for ($counter = $startpage; $counter < $endpage; $counter += $maxmessagedisplay) {
				$pagetxtindex .= $start == $counter ? qq~<b>$tmpa</b>&nbsp;~ : qq~<a href="$scripturl?num=$viewnum/$counter" style="font-weight: normal;">$tmpa</a>&nbsp;~;
				$tmpa++;
			}
			if ($endpage < $max - ($maxmessagedisplay)) { $pageindexadd = qq~...&nbsp;~; }
			if ($endpage != $max) { $pageindexadd .= qq~<a href="$scripturl?num=$viewnum/$lastptn" style="font-weight: normal;">$lastpn</a>~; }
			$pagetxtindex .= qq~$pageindexadd~;
			$pageindex1 = qq~$pagetxtindexst$pagetxtindex</span>~;
			$pageindex2 = $pageindex1;
		} else {
			$pagedropindex1 = qq~<span style="float: left; width: 320px; margin: 0px; margin-top: 2px; border: 0px;">~;
			$pagedropindex1 .= qq~<span style="float: left; height: 21px; margin: 0; margin-right: 4px;"><a href="$scripturl?action=threadpagetext;num=$viewnum;start=$start"><img src="$imagesdir/index_togl.gif" border="0" alt="$display_txt{'19'}" /></a></span>~;
			$pagedropindex2 = $pagedropindex1;
			$tstart         = $start;
			if (substr($INFO{'start'}, 0, 3) eq "all") { ($tstart, $start) = split(/\-/, $INFO{'start'}); }
			$d_indexpages = $pagenumb / $dropdisplaynum;
			$i_indexpages = int($pagenumb / $dropdisplaynum);
			if ($d_indexpages > $i_indexpages) { $indexpages = int($pagenumb / $dropdisplaynum) + 1; }
			else { $indexpages = int($pagenumb / $dropdisplaynum) }
			$selectedindex = int(($start / $maxmessagedisplay) / $dropdisplaynum);

			if ($pagenumb > $dropdisplaynum) {
				$pagedropindex1 .= qq~<span style="float: left; height: 21px; margin: 0;"><select size="1" name="decselector1" id="decselector1" style="font-size: 9px; border: 2px inset;" onchange="if(this.options[this.selectedIndex].value) SelDec(this.options[this.selectedIndex].value, 'xx')">\n~;
				$pagedropindex2 .= qq~<span style="float: left; height: 21px; margin: 0;"><select size="1" name="decselector2" id="decselector2" style="font-size: 9px; border: 2px inset;" onchange="if(this.options[this.selectedIndex].value) SelDec(this.options[this.selectedIndex].value, 'xx')">\n~;
			}
			for ($i = 0; $i < $indexpages; $i++) {
				$indexpage  = ($i * $dropdisplaynum) * $maxmessagedisplay;
				$indexstart = ($i * $dropdisplaynum) + 1;
				$indexend   = $indexstart + ($dropdisplaynum - 1);
				if ($indexend > $pagenumb)    { $indexend   = $pagenumb; }
				if ($indexstart == $indexend) { $indxoption = qq~$indexstart~; }
				else { $indxoption = qq~$indexstart-$indexend~; }
				$selected = "";
				if ($i == $selectedindex) {
					$selected    = qq~ selected="selected"~;
					$pagejsindex = qq~$indexstart|$indexend|$maxmessagedisplay|$indexpage~;
				}
				if ($pagenumb > $dropdisplaynum) {
					$pagedropindex1 .= qq~<option value="$indexstart|$indexend|$maxmessagedisplay|$indexpage"$selected>$indxoption</option>\n~;
					$pagedropindex2 .= qq~<option value="$indexstart|$indexend|$maxmessagedisplay|$indexpage"$selected>$indxoption</option>\n~;
				}
			}
			if ($pagenumb > $dropdisplaynum) {
				$pagedropindex1 .= qq~</select>\n</span>~;
				$pagedropindex2 .= qq~</select>\n</span>~;
			}
			$pagedropindex1 .= qq~<span id="ViewIndex1" class="droppageindex" style="height: 14px; visibility: hidden">&nbsp;</span>~;
			$pagedropindex2 .= qq~<span id="ViewIndex2" class="droppageindex" style="height: 14px; visibility: hidden">&nbsp;</span>~;
			$tmpmaxmessagedisplay = $maxmessagedisplay;
			if (substr($INFO{'start'}, 0, 3) eq "all") { $maxmessagedisplay = $maxmessagedisplay * $dropdisplaynum; }
			$prevpage          = $start - $tmpmaxmessagedisplay;
			$nextpage          = $start + $maxmessagedisplay;
			$pagedropindexpvbl = qq~<img src="$imagesdir/index_left0.gif" height="14" width="13" border="0" alt="" style="margin: 0px; display: inline; vertical-align: middle;" />~;
			$pagedropindexnxbl = qq~<img src="$imagesdir/index_right0.gif" height="14" width="13" border="0" alt="" style="margin: 0px; display: inline; vertical-align: middle;" />~;
			if ($start < $maxmessagedisplay) { $pagedropindexpv .= qq~<img src="$imagesdir/index_left0.gif" height="14" width="13" border="0" alt="" style="display: inline; vertical-align: middle;" />~; }
			else { $pagedropindexpv .= qq~<img src="$imagesdir/index_left.gif" border="0" height="14" width="13" alt="$pidtxt{'02'}" style="display: inline; vertical-align: middle; cursor: pointer;" onclick="location.href=\\'$scripturl?num=$viewnum/$prevpage\\'" ondblclick="location.href=\\'$scripturl?num=$viewnum/0\\'" />~; }
			if ($nextpage > $lastptn) { $pagedropindexnx .= qq~<img src="$imagesdir/index_right0.gif" border="0" height="14" width="13" alt="" style="display: inline; vertical-align: middle;" />~; }
			else { $pagedropindexnx .= qq~<img src="$imagesdir/index_right.gif" height="14" width="13" border="0" alt="$pidtxt{'03'}" style="display: inline; vertical-align: middle; cursor: pointer;" onclick="location.href=\\'$scripturl?num=$viewnum/$nextpage\\'" ondblclick="location.href=\\'$scripturl?num=$viewnum/$lastptn\\'" />~; }
			$pageindex1 = qq~$pagedropindex1</span>~;
			$pageindex2 = qq~$pagedropindex2</span>~;

			$pageindexjs = qq~
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
			else pagedropindex += '<td height="14" class="droppages"><a href="$scripturl?num=$viewnum/' + pagstart + '">' + i + '</a></td>';
			pagstart += maxpag;
		}
		if (vistart != viend) {
			if(visel == 'all') pagedropindex += '<td class="titlebg" height="14" style="height: 14px; padding-left: 1px; padding-right: 1px; font-size: 9px; font-weight: normal;"><b>$pidtxt{"01"}</b></td>';
			else pagedropindex += '<td height="14" class="droppages"><a href="$scripturl?num=$viewnum/all-' + allpagstart + '">$pidtxt{"01"}</a></td>';
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
~;
		}
	}

	$msubthread   = &Censor($msubthread);
	$curthreadurl = qq~$msubthread~;
	&ToChars($curthreadurl);

	$yymain .= qq~
		<script language="JavaScript1.2" src="$ubbcjspath" type="text/javascript"></script>
	~;

	# Insert Navigation Bit
	$prevlink = "";
	$nextlink = "";
	&NextPrev($viewnum);
	$template_prev    = qq~$prevlink~;
	$template_next    = qq~$nextlink~;
	$template_home    = qq~<a href="$scripturl" class="nav">$mbname</a>~;
	$template_viewers = "";
	$topviewers       = 0;

	if ($annboard ne "" && $currentboard eq $annboard) {
		if ($vircurrentboard) {
			$template_cat   = qq~<a href="$scripturl?catselect=$vircurcat" class="nav">$vircat</a>~;
			$template_board = qq~<a href="$scripturl?board=$vircurrentboard" class="nav">$virboardname</a>~;
			$template_mods  = qq~$showmods$showmodgroups~;
		} elsif ($iamadmin || $iamgmod) {
			$template_cat   = qq~<a href="$scripturl?catselect=$curcat" class="nav">$cat</a>~;
			$template_board = qq~<a href="$scripturl?board=$currentboard" class="nav">$boardname</a>~;
			$template_mods  = qq~$showmods$showmodgroups~;
		} else {
			$template_cat   = qq~$maintxt{'418'}~;
			$template_board = qq~$security_txt{'999'}~;
			$template_mods  = "";
		}
	} else {
		$template_cat   = qq~<a href="$scripturl?catselect=$curcat" class="nav">$cat</a>~;
		$template_board = qq~<a href="$scripturl?board=$currentboard" class="nav">$boardname</a>~;
		$template_mods  = qq~$showmods$showmodgroups~;
		if ($showtopicviewers && (($iamadmin || $iamgmod || $iammod) && $sessionvalid == 1)) {
			foreach $thisreplier (@repliers) {
				chomp $thisreplier;
				$replying = "";
				(undef, $mrepuser, $misreplying) = split(/\|/, $thisreplier);
				&LoadUser($mrepuser);
				if ($misreplying) { $replying = qq~ <span class="small">($display_txt{'645'})</span>~; }
				$template_viewers .= qq~$link{$mrepuser}$replying, ~;
				$topviewers++;
			}
			$template_viewers =~ s/\, \Z/\./;
		}

	}
	if ($template_mods) { $template_mods = qq~<br />$template_mods~; }

	# Insert 0
	unless (($enable_guestposting == 0 && $iamguest) || $annboard eq $currentboard) {
		$template_poll = qq~$pollbutton~;
	}
	if (!$iamguest) {
		if ($annboard ne "" && $currentboard eq $annboard) {
			$template_favorite = "";
		} else {
			require "$sourcedir/Favorites.pl";
			$template_favorite .= &IsFav($viewnum, $start);
		}
		$template_notify = $notify;
	} else {
		$template_favorite = "";
		$template_notify   = "";
	}
	$template_threadimage = qq~<a name="top"><img src="$imagesdir/$threadclass.gif" style="vertical-align: middle;" alt="" /></a>~;
	$template_sendtopic   = qq~$menusep<a href="$scripturl?action=sendtopic;topic=$viewnum">$img{'sendtopic'}</a>~;
	$template_print       = qq~$menusep<a href="$scripturl?action=print;num=$viewnum" target="_blank">$img{'print'}</a>~;
	$template_pollmain    = "";
	if ($has_poll) { require "$sourcedir/Poll.pl"; &display_poll($viewnum); $template_pollmain = qq~$pollmain<br />~; }

	# Load background color list.
	@bgcolors   = ($color{windowbg}, $color{windowbg2});
	$bgcolornum = scalar @bgcolors;
	@cssvalues  = ("windowbg", "windowbg2");
	$cssnum     = scalar @bgcolors;

	if (!$MenuType) { $sm = 1; }
	$counter    = 0;
	$avacounter = 0;

	#### FIXME: debugging
	fopen(MSGTXT, "$datadir/$viewnum.txt") || &fatal_error("104 $display_txt{'106'}: $display_txt{'23'} $viewnum.txt - this is display.pl instance of 104.", 1);

	# Skip past the posts in this thread until we reach $start.
	while ($counter < $start && ($buffer = <MSGTXT>)) { $counter++; }

	$#messages = $maxmessagedisplay - 1;
	for ($counter = 0; $counter < $maxmessagedisplay && ($buffer = <MSGTXT>); $counter++) {
		$messages[$counter] = $buffer;
	}
	fclose(MSGTXT);
	$#messages = $counter - 1;
	$counter   = $start;

	# For each post in this thread:
	foreach (@messages) {
		$windowbg = $bgcolors[($counter % $bgcolornum)];
		$css      = $cssvalues[($counter % $cssnum)];
		$revcss   = $cssvalues[($counter % $cssnum - 1)];
		chomp;
		($msub, $mname, $memail, $mdate, $musername, $micon, $mattach, $mip, $postmessage, $ns, $mlm, $mlmb, $mfn) = split(/[\|]/, $_);
		$msub =~ s/\A\[m\]/$maintxt{'758'}/;

		# Should we show an attachment file?
		if ($mfn && $mfn ne "") {
			if (-e ("$uploaddir/$mfn")) {
				$attachment = qq~<span class="small"><a href="$uploadurl/$mfn" target="_blank"><img src="$imagesdir/paperclip.gif" border="0" align="middle" alt="" /> $mfn</a></span>~;
				if (($mfn =~ /(jpg|gif|bmp|png|jpeg)$/i) && ($amdisplaypics == 1)) {
					$showattach   = qq~<div class="scroll" style="max-height: 400px; width: 100%; overflow: auto;" align="center"><img src="$uploadurl/$mfn" alt="$mfn" border="0" /></div>~;
					$showattachhr = qq~<hr width="100%" size="1" class="hr" style="margin: 0; margin-top: 5px; margin-bottom: 5px; padding: 0;" />~;
				} else {
					$showattach   = '';
					$showattachhr = '';
				}
			} else {
				$attachment   = qq~<span class="small"><img src="$imagesdir/paperclip.gif" border="0" align="middle" alt="" />  $mfn $fatxt{'1'}</span>~;
				$showattach   = '';
				$showattachhr = '';
			}
		} else {
			$attachment   = '';
			$showattach   = '';
			$showattachhr = '';
		}

		# Should we show "last modified by?"
		if ($mlm && $showmodify && $mlm ne "" && $mlmb ne "") {
			if ($tllastmodflag) {
				$tllastmodtimesecs = $tllastmodtime * 60;
				$tlmesstime        = $mdate + $tllastmodtimesecs;
				$tllasttime        = $mlm;
				if ($tlmesstime > $tllasttime) {
					$mlm          = '-';
					$lastmodified = '';
				} else {
					$mlm = &timeformat($mlm);
					&LoadUser($mlmb);
					$mlmb = ${$uid.$mlmb}{'realname'} || $mlmb || $display_txt{'470'};
					$lastmodified = qq~&#171; <i>$display_txt{'211'}: $mlm $display_txt{'525'} $mlmb</i> &#187;~;
				}
			} else {
				$mlm = &timeformat($mlm);
				&LoadUser($mlmb);
				$mlmb = ${$uid.$mlmb}{'realname'} || $mlmb || $display_txt{'470'};
				$lastmodified = qq~&#171; <i>$display_txt{'211'}: $mlm $display_txt{'525'} $mlmb</i> &#187;~;
			}
		} else {
			$mlm          = '-';
			$lastmodified = '';
		}
		if ($tlnomodflag) {
			unless (($iamadmin || $iamgmod || $iammod) && $sessionvalid == 1) {
				$tlnomodtimesecs = $tlnomodtime * 3600 * 24;
				$tltime          = $mdate + $tlnomodtimesecs;
				$tlcurrenttime   = $date;
				if ($tlcurrenttime > $tltime) {
					$nomodallowed = 1;
				} else {
					$nomodallowed = 0;
				}
			}
		}
		if ($tlnodelflag) {
			unless (($iamadmin || $iamgmod || $iammod) && $sessionvalid == 1) {
				$tlnodeltimesecs = $tlnodeltime * 3600 * 24;
				$tldtime         = $mdate + $tlnodeltimesecs;
				$tldcurrenttime  = $date;
				if ($tldcurrenttime > $tldtime) {
					$nodelallowed = 1;
				} else {
					$nodelallowed = 0;
				}
			}
		}
		$msub ||= $display_txt{'24'};
		$messdate = &timeformat($mdate);
		my $mip4online = $mip;
		if ($iamadmin || $iamgmod && $gmod_access2{'ipban2'} eq "on") { $mip = $mip }
		else { $mip = "$display_txt{'511'}"; }
		$sendm = '';

		# If the user isn't a guest, load their info.
		if ($musername ne 'Guest' && !$yyUDLoaded{$musername} && -e ("$memberdir/$musername.vars")) {
			&LoadUserDisplay($musername);
		}
		$messagedate = $mdate;
		if (${$uid.$musername}{'regtime'}) {
			$registrationdate = ${$uid.$musername}{'regtime'};
		} else {
			$registrationdate = int(time);
		}

		if (${$uid.$musername}{'signature'}) {
			$signature_hr = qq~<hr width="100%" size="1" class="hr" style="margin: 0; margin-top: 5px; margin-bottom: 5px; padding: 0;" />~;
		} else {
			$signature_hr = "";
		}
		$exmem = 0;
		my ($aimad, $yimad, $msnad, $gtalkad, $icqad);
		if ((${$uid.$musername}{'regdate'} && $messagedate > $registrationdate) || ${$uid.$musername}{'status'} eq "Administrator" || ${$uid.$musername}{'status'} eq "Global Moderator") {
			$displayname = ${$uid.$musername}{'realname'};
			$star        = $memberstar{$musername};
			$memberinfo  = "$memberinfo{$musername}$addmembergroup{$musername}";
			$memberinfo =~ s~\n~~g;

			if (${$uid.$musername}{'aim'}) { $aimad = qq~$menusep${$uid.$musername}{'aim'}~; }
			if (${$uid.$musername}{'icq'}) { $icqad = qq~$menusep${$uid.$musername}{'icq'}~; }
			if (${$uid.$musername}{'yim'}) { $yimad = qq~$menusep${$uid.$musername}{'yim'}~; }

			if (${$uid.$musername}{'msn'})   { $msnad   = qq~$menusep${$uid.$musername}{'msn'}~; }
			if (${$uid.$musername}{'gtalk'}) { $gtalkad = qq~$menusep${$uid.$musername}{'gtalk'}~; }

			if (!$iamguest) {

				# Allow instant message sending if current user is a member.
				$sendm = qq~$menusep<a href="$scripturl?action=imsend;to=$useraccount{$musername}">$img{'message_sm'}</a>~;
			}
			$usernamelink = qq~$link{$musername}<br />~;
			$postinfo     = qq~$display_txt{'21'}: ${$uid.$musername}{'postcount'}<br />~;
			$memail       = qq~$scripturl?action=mailto;user=$musername~;
		} elsif ($musername !~ m~Guest~ && $messagedate < $registrationdate) {
			$exmem        = 1;
			$star         = '';
			$memberinfo   = $display_txt{'470a'};
			$icqad        = '';
			$yimad        = '';
			$usernamelink = qq~<b>$mname</b><br />~;
			if ($memberinfo eq "$display_txt{'28'}") { $usernamelink = qq~<b>$mname</b><br />~; }
			$postinfo    = '';
			$displayname = $display_txt{'470a'};
		} else {
			$musername    = "Guest";
			$star         = '';
			$memberinfo   = "$display_txt{'28'}";
			$icqad        = '';
			$yimad        = '';
			$usernamelink = qq~<b>$mname</b>~;
			if ($memberinfo eq "$display_txt{'28'}") { $usernamelink = qq~<b>$mname</b><br />~; }
			$postinfo    = '';
			$displayname = $mname;
			$cryptmail   = &scramble($memail, $musername);
			$memail      = qq~$scripturl?action=mailto;user=$musername;mail_id=$cryptmail~;
		}

		# Censor the subject and message.
		$postmessage = &Censor($postmessage);
		$msub        = &Censor($msub);
		&ToChars($msub);

		# Run UBBC interpreter on the message.
		$message = $postmessage;
		&wrap;
		if ($enable_ubbc) {
			if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; }
			&DoUBBC;
		}
		&wrap2;
		&ToChars($message);

		$profbutton = $profilebutton && $musername ne 'Guest' ? qq~$menusep<a href="$scripturl?action=viewprofile;username=$useraccount{$musername}">$img{'viewprofile_sm'}</a>~ : '';
		if ($counter != 0) { $counterwords = "$display_txt{'146'} #$counter - "; }
		else { $counterwords = ""; }

		# Print the post and user info for the poster.
		my $outblock        = $messageblock;
		my $posthandelblock = $posthandellist;
		my $contactblock    = $contactlist;

		if ($mstate !~ /l/i) { # FIXME: not checks access rights.
			unless (($enable_guestposting == 0 && $iamguest) || &AccessCheck($currentboard, 2) ne "granted" || ($annboard eq $currentboard && !$iamadmin && !$iamgmod)) {
				$template_quote = qq~$menusep<a href="$scripturl?action=post;num=$viewnum;quote=$counter;title=PostReply">$img{'replyquote'}</a>~;
			}
			if ($iammod || $iamadmin || $iamgmod || ($username eq $musername && !$iamguest && !$exmem && $nomodallowed == 0) && $sessionvalid == 1) {
				$template_modify = qq~$menusep<a href="$scripturl?action=modify;board=$currentboard;message=$counter;thread=$viewnum">$img{'modify'}</a>~;
			} else {
				$template_modify = "";
			}
			if ($counter > 0 && ($iammod || $iamadmin || $iamgmod) && $sessionvalid == 1) {
				$template_split = qq~$menusep<a href="$scripturl?action=split2;board=$currentboard;thread=$viewnum;postid=$counter">$img{'admin_split'}</a>~;
			}
			if ($iammod || $iamadmin || $iamgmod || ($username eq $musername && !$iamguest && !$exmem && $nodelallowed == 0) && $sessionvalid == 1) {
#				$template_delete = qq~$menusep<span style="cursor: pointer; cursor: hand;" onclick="uncheckAllBut($counter);">$img{'delete'}</span>~;
				$template_delete = qq~$menusep<a href="$scripturl?action=multidel;thread=$viewnum;message=$counter" >$img{'delete'}</a>~;

				if (($iammod && $mdmod eq 1) || ($iamadmin && $mdadmin eq 1) || ($iamgmod && $mdglobal eq 1) && $sessionvalid == 1) {
					$template_admin = qq~<input type="checkbox" class="$css" style="border: 0px;" name="del$counter" value="$counter" />~;
				} else {
#					$template_admin = qq~ <input type="checkbox" class="$css" style="border: 0px; visibility: hidden; display: none;" name="del$counter" value="$counter" />~;
					$template_admin = qq~~;
				}
			} else {
				$template_delete = "";
				$template_admin  = qq~ <input type="checkbox" class="$css" style="border: 0px; visibility: hidden; display: none;" name="del$counter" value="$counter" />~;
			}
		}

		# Insert 3
		if (!$exmem && $musername ne "Guest" && -e "$memberdir/$musername.vars") {
			$template_userpic  = qq~${$uid.$musername}{'userpic'}~;
			$template_usertext = qq~${$uid.$musername}{'usertext'}~;
			$template_postinfo = qq~$postinfo~;
			$template_gender   = qq~${$uid.$musername}{'gender'}~;
			if ($showuserpic && $allowpics) {
				if (${$uid.$musername}{'userownpic'}) {
					$avstyle = "";
					if ($ENV{'HTTP_USER_AGENT'} !~ /MSIE/ || $ENV{'HTTP_USER_AGENT'} =~ /Opera/) {
						if ($userpic_width > 0 || $userpic_height > 0) {
							$avstyle = qq~ style="~;
							if ($userpic_width > 0)  { $avstyle .= qq~max-width: $userpic_width\px\; ~; }
							if ($userpic_height > 0) { $avstyle .= qq~max-height: $userpic_height\px\;~; }

							# Limit avatar widths/heights for safari - since Safari contains a bug
							# regarding max-width, and height when only one is present.
							# http://bugzilla.opendarwin.org/show_bug.cgi?id=5146
							if (($userpic_height == 0 && $userpic_width > 0)  && $ENV{'HTTP_USER_AGENT'} =~ /Safari/) { $avstyle .= qq~max-height: $userpic_width\px\;~; }
							if (($userpic_width == 0  && $userpic_height > 0) && $ENV{'HTTP_USER_AGENT'} =~ /Safari/) { $avstyle .= qq~max-width: $userpic_height\px\;~; }

							$avstyle .= qq~"~;
						}
						$avatar = qq~<img src="$template_userpic" alt="" border="0"$avstyle /><br />~;
					} else {
						$avatar = qq~
				<script language="JavaScript1.2" type="text/javascript">
				<!-- //
					var userpic_width = $userpic_width;
					var userpic_height = $userpic_height;
					imgEle$counter = new Image();
					imgEle$counter.src = "$template_userpic";

					if(imgEle$counter.width) {
						if (userpic_width == 0) { tmpuserpic_width = imgEle$counter.width; } else {tmpuserpic_width = userpic_width;}
						if (userpic_height == 0) { tmpuserpic_height = imgEle$counter.height; } else {tmpuserpic_height = userpic_height;}
						var ratio = imgEle$counter.width / imgEle$counter.height;
						for(z=0;z<2;z++) { 
							if (imgEle$counter.width > tmpuserpic_width) { imgEle$counter.width = tmpuserpic_width; imgEle$counter.height = parseInt(imgEle$counter.width / ratio); }    
							if (imgEle$counter.height > tmpuserpic_height) { imgEle$counter.height = tmpuserpic_height; imgEle$counter.width = parseInt(imgEle$counter.height * ratio); }
						}
						document.write('<img src=" ' + imgEle$counter.src + ' " width=" ' + imgEle$counter.width + ' " height=" ' + imgEle$counter.height + ' " alt="" border="0" /><br />');
					}
					else {
						if (userpic_width == 0) { tmpuserpic_width = 65; } else {tmpuserpic_width = userpic_width;}
						document.write('<img src="$template_userpic" width=" ' + tmpuserpic_width + ' " alt="" border="0" /><br />');
					}
				// -->
				</script>
				<noscript>
				~;
						if ($userpic_width > 0 || $userpic_height > 0) {
							$avstyle = qq~ style="~;
							if ($userpic_width > 0) { $avstyle .= qq~width: $userpic_width\px\;~; }
							$avstyle .= qq~"~;
						}
						$avatar .= qq~<img src="$template_userpic" alt="" border="0"$avstyle /><br />
				</noscript>
				~;
					}
					$avacounter++;
				} else {
					$avatar = qq~<img src="$template_userpic" alt="" border="0" /><br />~;
				}
			} else {
				$avatar = qq~$template_userpic~;
			}
		}

		# Insert 2
		if ((${$uid.$musername}{'hidemail'} ne "checked" || $iamadmin || $iamgmod || $allow_hide_email ne 1) && $exmem == 0) {
			$template_email   = qq~$menusep<a href="$memail" target="_blank">$img{'email_sm'}</a>~;
			$template_profile = qq~$profbutton~;
			$template_pm      = qq~$sendm~;
			$template_www     = ${$uid.$musername}{'weburl'} ? qq~$menusep${$uid.$musername}{'weburl'}~ : '';
		} else {
			$template_email   = qq~~;
			$template_profile = qq~$profbutton~;
			$template_pm      = qq~$sendm~;
			$template_www     = ${$uid.$musername}{'weburl'} ? qq~$menusep${$uid.$musername}{'weburl'}~ : '';
		}
		if ($musername eq "Guest") {
			$template_email    = qq~$menusep<a href="$memail" target="_blank">$img{'email_sm'}</a>~;
			$template_userpic  = "";
			$template_usertext = "";
			$template_postinfo = "";
			$template_gender   = "";
			$avatar            = "";
		}
		if ($exmem == 1) {
			$template_userpic  = "";
			$template_usertext = "";
			$template_postinfo = "";
			$template_gender   = "";
			$avatar            = "";
			$template_profile  = "";
			$icqad             = '';
			$yimad             = '';
			$aimad             = '';
			$msnad             = '';
			$gtalkad           = '';
		}

		$msgimg = qq~<a href="$scripturl?num=$viewnum/$counter#$counter"><img src="$imagesdir/$micon.gif" alt="" border="0" style="vertical-align: middle;" /></a>~;
		$ipimg  = qq~<img src="$imagesdir/ip.gif" alt="" border="0" style="vertical-align: middle;" />~;

		
		my $online = ''; #/
		if ( is_online ( ( $musername =~ m/^Guest/i or $exmem ) ? $mip4online : $musername ) ) {
			$online = qq(<span class="online">$display_txt{'online'}</span><br />)
		}

#		if ( $snark_enable ) {
#			require "$sourcedir/Snark.pl" if not $loaded{'Snark.pl'};
#			$star = snark_panel ( $musername, "$viewnum/$counter", $counter % $cssnum );
#			$yyinlinestyle = qq(<link rel="stylesheet" href="$forumstylesurl/default/snark.css" type="text/css" />);
#		}
		
		$posthandelblock =~ s/<yabb quote>/$template_quote/g;
		$posthandelblock =~ s/<yabb modify>/$template_modify/g;
		$posthandelblock =~ s/<yabb split>/$template_split/g;
		$posthandelblock =~ s/<yabb delete>/$template_delete/g;
		$posthandelblock =~ s/<yabb admin>/$template_admin/g;
		$posthandelblock =~ s/\Q$menusep//i;

		$contactblock =~ s/<yabb email>/$template_email/g;
		$contactblock =~ s/<yabb profile>/$template_profile/g;
		$contactblock =~ s/<yabb pm>/$template_pm/g;
		$contactblock =~ s/<yabb www>/$template_www/g;
		$contactblock =~ s/<yabb aim>/$aimad/g;
		$contactblock =~ s/<yabb yim>/$yimad/g;
		$contactblock =~ s/<yabb icq>/$icqad/g;
		$contactblock =~ s/<yabb msn>/$msnad/g;
		$contactblock =~ s/<yabb gtalk>/$gtalkad/g;
		$contactblock =~ s/\Q$menusep//i;

		$outblock =~ s/<yabb images>/$imagesdir/g;
		$outblock =~ s/<yabb messageoptions>/$msgcontrol/g;
		$outblock =~ s/<yabb memberinfo>/$memberinfo/g;
		$outblock =~ s/<yabb userlink>/$usernamelink/g;
		$outblock =~ s/<yabb stars>/$star/g;
		$outblock =~ s/<yabb useronline>/$online/g;
		$outblock =~ s/<yabb subject>/$msub/g;
		$outblock =~ s/<yabb msgimg>/$msgimg/g;
		$outblock =~ s/<yabb msgdate>/$messdate/g;
		$outblock =~ s/<yabb replycount>/$counterwords/g;
		$outblock =~ s/<yabb count>/$counter/g;
		$outblock =~ s/<yabb att>/$attachment/g;
		$outblock =~ s/<yabb css>/$css/g;
		$outblock =~ s/<yabb gender>/$template_gender/g;
		$outblock =~ s/<yabb postinfo>/$template_postinfo/g;
		$outblock =~ s/<yabb usertext>/$template_usertext/g;
		$outblock =~ s/<yabb userpic>/$avatar/g;
		$outblock =~ s/<yabb message>/$message/g;
		$outblock =~ s/<yabb showatt>/$showattach/g;
		$outblock =~ s/<yabb showatthr>/$showattachhr/g;
		$outblock =~ s/<yabb modified>/$lastmodified/g;
		$outblock =~ s/<yabb signature>/${$uid.$musername}{'signature'}/g;
		$outblock =~ s/<yabb signaturehr>/$signature_hr/g;
		$outblock =~ s/<yabb ipimg>/$ipimg/g;
		$outblock =~ s/<yabb ip>/$mip/g;
		$outblock =~ s/<yabb posthandellist>/$posthandelblock/g;
		$outblock =~ s/<yabb contactlist>/$contactblock/g;
		$tmpoutblock .= $outblock;

		$counter++;
	}
	# Insert 4

	# Insert 5
	my ($template_move, $template_remove, $template_splice, $template_lock, $template_hide, $template_sticky, $template_multidelete);
	if (($iammod || $iamadmin || $iamgmod) && $sessionvalid == 1) {
		$template_move   = qq~$menusep<a href="$scripturl?action=movethread;thread=$viewnum">$img{'admin_move'}</a>~;
		$template_remove = qq~$menusep<a href="javascript:document.removethread.submit();" onclick="return confirm('$display_txt{'162'}')"> $img{'admin_rem'}</a>~;

		# board=$currentboard is necessary for splicing DO NOT REMOVE!
		$template_splice = qq~$menusep<a href="$scripturl?action=splice;board=$currentboard;thread=$viewnum">$img{'admin_splice'}</a>~;

		$template_lock   = qq~$menusep<a href="$scripturl?action=lock;thread=$viewnum">$img{'admin_lock'}</a>~;
		$template_hide   = qq~$menusep<a href="$scripturl?action=hide;thread=$viewnum">$img{'hide'}</a>~;
		$template_sticky = qq~$menusep<a href="$scripturl?action=sticky;thread=$viewnum">$img{'admin_sticky'}</a>~;
		if ($mstate =~ /a/i) { $template_lock = ""; $template_hide = ""; $template_sticky = ""; }
	}
	if (($iammod && $mdmod eq 1) || ($iamadmin && $mdadmin eq 1) || ($iamgmod && $mdglobal eq 1) && $sessionvalid == 1) {
		if ($mstate !~ /l/i) {
			$template_multidelete = qq~$menusep<a href="javascript:document.multidel.submit();">$img{'admin_del'}</a>~;
		}
	}

	if ($template_viewers) {
		$topic_viewers = qq~
	<tr>
		<td class="windowbg" valign="middle" align="left">
			$display_txt{'644'} ($topviewers): $template_viewers
		</td>
	</tr>
~;
	}

	# Mark as read button has no use in global announcements or for guests
	if ($currentboard ne $annboard && !$iamguest) {
		$mark_unread = qq~$menusep<a href="$scripturl?action=markunread;thread=$viewnum;board=$currentboard">$img{'markunread'}</a>~;
	} else {
		$mark_unread = "";
	}

	&jumpto;

	# Template it
	$threadhandellist =~ s/<yabb markunread>/$mark_unread/g;
	$threadhandellist =~ s/<yabb reply>/$replybutton/g;
	$threadhandellist =~ s/<yabb poll>/$template_poll/g;
	$threadhandellist =~ s/<yabb notify>/$template_notify/g;
	$threadhandellist =~ s/<yabb favorite>/$template_favorite/g;
	$threadhandellist =~ s/<yabb sendtopic>/$template_sendtopic/g;
	$threadhandellist =~ s/<yabb print>/$template_print/g;
	$threadhandellist =~ s/\Q$menusep//i;

	$adminhandellist =~ s/<yabb move>/$template_move/g;
	$adminhandellist =~ s/<yabb remove>/$template_remove/g;
	$adminhandellist =~ s/<yabb splice>/$template_splice/g;
	$adminhandellist =~ s/<yabb lock>/$template_lock/g;
	$adminhandellist =~ s/<yabb hide>/$template_hide/g;
	$adminhandellist =~ s/<yabb sticky>/$template_sticky/g;
	$adminhandellist =~ s/<yabb multidelete>/$template_multidelete/g;
	$adminhandellist =~ s/\Q$menusep//i;

	$display_template =~ s/<yabb home>/$template_home/g;
	$display_template =~ s/<yabb category>/$template_cat/g;
	$display_template =~ s/<yabb board>/$template_board/g;
	$display_template =~ s/<yabb moderators>/$template_mods/g;
	$display_template =~ s/<yabb topicviewers>/$topic_viewers/g;
	$display_template =~ s/<yabb prev>/$template_prev/g;
	$display_template =~ s/<yabb next>/$template_next/g;
	$display_template =~ s/<yabb pageindex top>/$pageindex1/g;
	$display_template =~ s/<yabb pageindex bottom>/$pageindex2/g;

	$display_template =~ s/<yabb threadhandellist>/$threadhandellist/g;
	$display_template =~ s/<yabb threadimage>/$template_threadimage/g;
	$display_template =~ s/<yabb threadurl>/$curthreadurl/g;
	$display_template =~ s/<yabb views>/$views/g;
	if ($username eq $poll_uname || ($iammod || $iamadmin || $iamgmod && $sessionvalid == 1)) {
		if ($mstate !~ /l/i) {
			# Only put poll form in if has a poll...
			if (-e "$datadir/$viewnum.poll") {
				$formstart .= qq~<form name="removepoll" action="$scripturl?action=modify2;d=1" method="post" style="display: inline">
				<input type="hidden" name="thread" value="$viewnum" />
				<input type="hidden" name="id" value="Poll" />
				</form>~;
			}
		}

		# Board=$currentboard is necessary for multidel - DO NOT REMOVE!!
		# This form is necessary to allow thread deletion in locked topics.
		$formstart .= qq~<form name="removethread" action="$scripturl?action=removethread" method="post" style="display: inline">
		<input type="hidden" name="thread" value="$viewnum" />
		</form>~;

	}
	$formstart .= qq~<form name="multidel" action="$scripturl?action=multidel;board=$currentboard;thread=$viewnum/$start" method="post" style="display: inline">~;
	$formend = qq~</form>~;

	$display_template =~ s/<yabb multistart>/$formstart/g;
	$display_template =~ s/<yabb multiend>/$formend/g;

	$display_template =~ s/<yabb pollmain>/$template_pollmain/g;
	$display_template =~ s/<yabb postsblock>/$tmpoutblock/g;
	$display_template =~ s/<yabb adminhandellist>/$adminhandellist/g;
	$display_template =~ s/<yabb forumselect>/$selecthtml/g;

	$yymain .= qq~
	$display_template
	<script language="JavaScript1.2" type="text/javascript">
	<!-- //

	function uncheckAllBut(counter) {
		for (var i = $start; i < $counter; i++) {
			var z = i - $start;
	 		if(i == counter) document.multidel.elements[z].checked = true;
			else document.multidel.elements[z].checked = false;
		}
		document.multidel.submit();
	}


	$pageindexjs
	// -->
	</script>
	~;
	&ToChars($msubthread);
	$yytitle = $msubthread;
	&template;
	exit;
}

sub NextPrev {
	fopen(MSGTXT, "$boardsdir/$currentboard.txt") || &fatal_error("300 $txt{'106'}: $txt{'23'} $currentboard.txt", 1);
	@threadlist = <MSGTXT>;
	fclose(MSGTXT);

	$thevirboard = qq~num=~;
	if ($vircurrentboard) {
		fopen(MSGTXT, "$boardsdir/$vircurrentboard.txt") || &fatal_error("300 $txt{'106'}: $txt{'23'} $vircurrentboard.txt", 1);
		@virthreadlist = <MSGTXT>;
		fclose(MSGTXT);
		@threadlist = (@threadlist, @virthreadlist);
		$thevirboard = qq~virboard=$vircurrentboard;num=~;
	}

	$threadcount = $#threadlist;

	$countsticky   = 0;
	$countnosticky = 0;

	for ($i = 0; $i <= $threadcount; $i++) {
		my @array = split(/\|/, $threadlist[$i]);
		my $threadstatus = pop(@array);    #get only status
		undef @array;
		if ($threadstatus =~ /s/i || $threadstatus =~ /a/i) {
			$stickythreadlist[$countsticky] = $threadlist[$i];
			$countsticky++;
		} else {
			$nostickythreadlist[$countnosticky] = $threadlist[$i];
			$countnosticky++;
		}
	}

	if ($countsticky > 0) { @threadlist = (@stickythreadlist, @nostickythreadlist); }
	my $name = $_[0];
	$is = 0;
	for ($i = 0; $i <= $threadcount; $i++) {
		($mnum) = split(/\|/, $threadlist[$i]);
		if ($mnum == $name) {
			if ($i > 0) {
				($prev) = split(/\|/, $threadlist[$i - 1]);
				$prevlink = qq~<a href="$scripturl?$thevirboard$prev">$display_txt{'768'}</a>~;
			} else {
				$prevlink = qq~$display_txt{'766'}~;
			}
			if ($i < $threadcount) {
				($next) = split(/\|/, $threadlist[$i + 1]);
				$nextlink = qq~<a href="$scripturl?$thevirboard$next">$display_txt{'767'}</a>~;
			} else {
				$nextlink = qq~$display_txt{'766'}~;
			}
			$is = 1;
			last;
		}
	}
	if (!$is) { $yySetLocation = qq~$scripturl?~; &redirectexit; }    # boardlist if topic not found
}

sub SetMsn {

	$msnstyle = qq~<link rel="stylesheet" href="$forumstylesurl/$usestyle.css" type="text/css" />~;
	$msnstyle =~ s~$usestyle\/~~g;
	my $msnname = $INFO{'msnname'};
	if (!${$uid.$msnname}{'password'}) { &LoadUser($msnname); }
	$msnuser = ${$uid.$msnname}{'msn'};

	print qq~Content-type: text/html\n\n~;
	print qq~<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<title>$msntxt{'5'}</title>
$msnstyle
</head>
<body class="windowbg2" style="margin: 0px; padding: 0px;">
<table border="0" width="100%" cellspacing="1" cellpadding="4" class="bordercolor">
  <tr>
     <td class="titlebg" align="left" width="100%" height="22">
     <img src="$defaultimagesdir/msn3.gif" width="16" height="14" alt="" title="" border="0" />
     $msntxt{'5'}
     </td>
  </tr>
  <tr>
    <td align="center" valign="bottom" class="windowbg" width="100%" height="58">
	<img src="$defaultimagesdir/msn3.gif" width="16" height="16" style="vertical-align: middle;" alt="${$uid.$msnname}{'realname'}" title="${$uid.$msnname}{'realname'}" border='0' /> $msnuser<br /><br />

<script language="JavaScript1.2" type="text/javascript">
<!--

function sendmsn(msnto) {
	var msnControl = new ActiveXObject('Messenger.UIAutomation.1');
	if(!msnControl.MyContacts.Count) {
		alert("$msntxt{'3'}");
		return false;
	}
	msnControl.AutoSignin();
	msnControl.InstantMessage(msnto);
	window.close();
}

function addtomsn(msnto) {
	var msnControl = new ActiveXObject('Messenger.UIAutomation.1');
	msnControl.AutoSignin(); 
	msnControl.AddContact(0, msnto);
	window.close();
}

function notOnline() {
	alert("$msntxt{'3'}");
	return true;
}

if(navigator.appName == "Microsoft Internet Explorer" && navigator.appVersion.charAt(0) >= 4 && navigator.userAgent.indexOf("Opera") < 0) {
	var msnControl = new ActiveXObject('Messenger.UIAutomation.1');
	document.write("<input type='button' value='$msntxt{'1'}' style='font-size: 10px' onclick=sendmsn('$msnuser') />");
	document.write("<input type='button' value='$msntxt{'2'}' style='font-size: 10px' onclick=addtomsn('$msnuser') />");
}
else {
      document.write("$msntxt{'4'}<br /><br />");
}

window.onerror = notOnline;
//-->
</script>
    </td>
  </tr>
</table>
</body>
</html>
~;

}

sub SetGtalk {
	$gtalkstyle = qq~<link rel="stylesheet" href="$forumstylesurl/$usestyle.css" type="text/css" />~;
	$gtalkstyle =~ s~$usestyle\/~~g;
	my $gtalkname = $INFO{'gtalkname'};
	if (!${$uid.$gtalkname}{'password'}) { &LoadUser($gtalkname); }
	$gtalkuser = ${$uid.$gtalkname}{'gtalk'};

	print qq~Content-type: text/html\n\n~;
	print qq~<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<title>Google Talk</title>
$gtalkstyle
</head>
<body class="windowbg2" style="margin: 0px; padding: 0px;">
<table border="0" width="100%" cellspacing="1" cellpadding="4" class="bordercolor">
  <tr>
     <td class="titlebg" align="left" width="100%" height="22">
     <img src="$defaultimagesdir/gtalk2.gif" width="16" height="14" alt="" title="" border="0" />
     Google Talk
     </td>
  </tr>
  <tr>
    <td align="center" valign="bottom" class="windowbg" width="100%" height="58">
	<img src="$defaultimagesdir/gtalk2.gif" width="16" height="14" style="vertical-align: middle;" alt="${$uid.$gtalkname}{'realname'}" title="${$uid.$gtalkname}{'realname'}" border='0' /> $gtalkuser<br /><br />
    </td>
  </tr>
</table>
</body>
</html>
~;

}

sub ThreadPageindex {
	my ($msindx, $trindx, $mbindx);
	($msindx, $trindx, $mbindx) = split(/\|/, ${$uid.$username}{'pageindex'});
	if ($INFO{'action'} eq "threadpagedrop") {
		${$uid.$username}{'pageindex'} = qq~$msindx|0|$mbindx~;
	}
	if ($INFO{'action'} eq "threadpagetext") {
		${$uid.$username}{'pageindex'} = qq~$msindx|1|$mbindx~;
	}
	&UserAccount($username, "update");
	$yySetLocation = qq~$scripturl?num=$INFO{'num'}/$INFO{'start'}~;
	&redirectexit;
}

sub undumplog {
	# Used to mark a thread as unread

	$thread = $INFO{'thread'};
	if ($iamguest || $max_log_days_old == 0) { return; }

	fopen(UNDUMPLOG, "+<$memberdir/$username.log");
	@entries = <UNDUMPLOG>;
	$edited  = 0;
	$i       = 0;
	foreach $entry (@entries) {
		if ($entry =~ m/\A$thread/) { $entries[$i] = "$thread--unread||$date\n"; $edited = 1; last; }
		$i++;
	}

	if ($edited) {
		seek UNDUMPLOG, 0, 0;
		truncate UNDUMPLOG, 0;
		print UNDUMPLOG @entries;
	}
	fclose(UNDUMPLOG);

	$yySetLocation = qq~$scripturl?board=$currentboard~;
	&redirectexit;
}

1;
