###############################################################################
# Favorites.pl                                                                #
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

$favoritesplver = 'YaBB 2.1 $Revision: 1.1 $';
if ($action eq 'detailedversion') { return 1; }

sub Favorites {
	LoadLanguage("MessageIndex");
	require "$templatesdir/$usemessage/MessageIndex.template";
	my $start = int($INFO{'start'}) || 0;
	my ($counter, $buffer, $pages, $showmods, $mnum, $msub, $mname, $memail, $mdate, $mreplies, $musername, $micon, $mstate, $dlp, $threadlength, $threaddate);
	my (@boardinfo, @threads, @loadthreads, @anns, @stickythreadlist);

	# grab all relevant info on the favorite thread for this user and check access to them
	if (!$maxfavs) { $maxfavs = 10; }
	${$uid.$username}{'favorites'} =~ s~\, ~\,~g;
	@fav = split(/\,/, ${$uid.$username}{'favorites'});
	foreach $fav (@fav) {
		chomp $fav;
		if (-e "$datadir/$fav.ctb") {
			&MessageTotals("load", $fav);
			$favoboard = ${$fav}{'board'};
			push(@favboards, "$favoboard|$fav");
		} else {

			# If thread no longer exists, remove it from favourites.
			&RemFav($fav, "nonexist");
			next;
		}
	}
	&BoardTotals("load", @favboards);
	@loadboards = sort(@favboards);
	foreach $loadstuff (@loadboards) {
		chomp $loadstuff;
		($loadboard, $loadfav) = split(/\|/, $loadstuff);
		($boardname, $boardperms, $boardview) = split(/\|/, $loadboard);
		$access = &AccessCheck($loadboard, '', $boardperms);
		if (!$iamadmin && $access ne "granted" && $boardview != 1) {
			next;
		}
		$catid = ${$uid.$loadboard}{'cat'};
		($cat, $catperms) = split(/\|/, $catinfo{"$catid"});
		$cataccess = &CatAccess($catperms);
		unless ($annboard ne "" && $loadboard eq $annboard) {
			if (!$cataccess) {
				next;
			}
		}
		fopen(BRDTXT, "$boardsdir/$loadboard.txt") || &fatal_error("300 $txt{'106'}: $txt{'23'} $currentboard.txt", 1);
		@threadlist = <BRDTXT>;
		fclose(BRDTXT);
		foreach (@threadlist) {
			($mnum, $msub, $mname, $memail, $mdate, $mreplies, $musername, $micon, $mstate) = split(/\|/, $_);
			if ($mnum eq $loadfav) {
				push(@threads, $_);
				$threadcount++;
			}
		}
	}

	$curfav = scalar(@threads);

	&LoadCensorList;

	my $homelink = qq~<a href="$scripturl" class="nav">$mbname</a>~;
	my $catlink  = qq~<a href="$scripturl?action=favorites" class="nav">$img_txt{'70'}</a>~;

	$colspan = 7;

	if (!$iamguest) {
		$markalllink = qq~<a href="$scripturl?action=markasread;board=$INFO{'board'}">$img{'markboardread'}</a>~;
	}
	if (&AccessCheck($currentboard, 1) eq "granted") {
		$postlink = qq~<a href="$scripturl?action=post;board=$INFO{'board'};title=StartNewTopic">$img{'newthread'}</a>~;
	}
	if (&AccessCheck($currentboard, 3) eq "granted") {
		$polllink = qq~<a href="$scripturl?action=post;board=$INFO{'board'};title=CreatePoll">$img{'createpoll'}</a>~;
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
			($dummy, $poll_locked, $dummy) = split(/\|/, $poll_question, 3);
			$micon = qq~$img{'pollicon'}~;
			if ($poll_locked) { $micon = $img{'polliconclosed'}; }
			elsif (!$iamguest && $max_log_days_old && $mdate > time - ($max_log_days_old * 86400)) {

				if ($dlp < $createpoll_date) {
					$micon = qq~$img{'polliconnew'}~;
				} else {
					fopen(POLLED, "$datadir/$mnum.polled");
					$polled = <POLLED>;
					fclose(POLLED);
					($dummy, $dummy, $dummy, $vote_date, $dummy) = split(/\|/, $polled);
					if ($dlp < $vote_date) { $micon = qq~$img{'polliconnew'}~; }
				}
			}
		}

		# Load the current nickname of the account name of the thread starter.
		if ($musername ne 'Guest') {
			&LoadUser($musername);
			if (${$uid.$musername}{'realname'}) {
				$mname = qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$musername}">$ {$uid.$musername}{'realname'}</a>~;
			} else {
				$mname .= qq~ ($messageindex_txt{'470a'})~;
			}
		}

		# Censor the subject of the thread.
		$msub = &Censor($msub);
		&ToChars($msub);

		# Build the page links list.
		$pages = '';
		if (int(($mreplies + 1) / $maxmessagedisplay) > 6) {
			$pages = qq~ <a href="$scripturl?num=$mnum/0#0">1</a>~;
			$pages .= qq~ <a href="$scripturl?num=$mnum/$maxmessagedisplay#$maxmessagedisplay">2</a>~;
			$endpage = int(($mreplies + 1) / $maxmessagedisplay);
			$i       = ($endpage - 1) * $maxmessagedisplay;
			$j       = $i - $maxmessagedisplay;
			$k       = $endpage - 1;
			$tmpa    = $endpage - 2;
			$tmpb    = $j - $maxmessagedisplay;
			$pages .= qq~ <a href="$scripturl?action=pages;num=$mnum">...</a>~;
			$pages .= qq~ <a href="$scripturl?num=$mnum/$tmpb#$tmpb">$tmpa</a>~;
			$pages .= qq~ <a href="$scripturl?num=$mnum/$j#$j">$k</a>~;
			$pages .= qq~ <a href="$scripturl?num=$mnum/$i#$i">$endpage</a>~;
			$pages = qq~<br /><span class="small">&#171; $messageindex_txt{'139'} $pages <a href="$scripturl;num=$mnum;start=all">$pidtxt{'01'}</a> &#187;</span>~;
		} elsif ($mreplies + 1 > $maxmessagedisplay) {
			$tmpa = 1;
			for ($tmpb = 0; $tmpb < $mreplies + 1; $tmpb += $maxmessagedisplay) {
				$pages .= qq~<a href="$scripturl?num=$mnum/$tmpb#$tmpb">$tmpa</a>\n~;
				++$tmpa;
			}
			$pages =~ s/\n\Z//;
			$pages = qq~<br /><span class="small">&#171; $messageindex_txt{'139'} $pages &#187;</span>~;
		}

		&MessageTotals("load", $mnum);
		$views      = ${$mnum}{'views'};
		$lastposter = ${$mnum}{'lastposter'};
		if ($lastposter =~ m~\AGuest-(.*)~) {
			$lastposter = $1;
		} elsif ($lastposter !~ m~Guest~ && !(-e "$memberdir/$lastposter.vars")) {
			$lastposter = $messageindex_txt{'470a'};
		} else {
			unless (($lastposter eq $messageindex_txt{'470'} || $lastposter eq $messageindex_txt{'470a'}) && -e "$memberdir/$lastposter.vars") {
				&LoadUser($lastposter);
				if (${$uid.$lastposter}{'realname'}) { $lastposter = qq~<a href="$scripturl?action=viewprofile;username=$lastposter">${$uid.$lastposter}{'realname'}</a>~; }
			}
		}
		$lastpostername = $lastposter || $messageindex_txt{'470'};
		$views = $views ? $views - 1 : 0;

		# Print the thread info.
		$mydate = &timeformat($mdate);

		my $threadpic    = qq~<img src="$imagesdir/$threadclass.gif" alt=""/>~;
		my $msublink     = qq~<a href="$scripturl?num=$mnum">$msub</a>~;
		my $lastpostlink = qq~<a href="$scripturl?num=$mnum/$mreplies#$mreplies">$img{'lastpost'}$mydate</a>~;
		my $tempbar      = $threadbar;

		$adminbar = qq~<input type="checkbox" name="admin$mcount" class="windowbg" style="border: 0px;" value="$mnum" />~;
		$admincol = $admincolumn;
		$admincol =~ s/<yabb admin>/$adminbar/g;

		$tempbar =~ s/<yabb admin column>/$admincol/g;
		$tempbar =~ s/<yabb threadpic>/$threadpic/g;
		$tempbar =~ s/<yabb icon>/$micon/g;
		$tempbar =~ s/<yabb new>/$new/g;
		$tempbar =~ s/<yabb poll>/$mpoll/g;
		$tempbar =~ s/<yabb favorite>/$favicon{$mnum}/g;
		$tempbar =~ s/<yabb subjectlink>/$msublink/g;
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

	# Put a "no messages" message if no threads exisit:
	if (!$tmptempbar) {
		$tmptempbar = qq~
		<tr>
			<td class="windowbg2" valign="middle" align="center" colspan="8"><br />$messageindex_txt{'840'}<br /><br /></td>
		</tr>
		~;
	}

	&jumpto;

	$yabbicons = qq~
	<img src="$imagesdir/thread.gif" alt="" /> $messageindex_txt{'457'}<br />
	<img src="$imagesdir/hotthread.gif" alt="" /> $messageindex_txt{'454'} $HotTopic $messageindex_txt{'454a'}<br />
	<img src="$imagesdir/veryhotthread.gif" alt="" /> $messageindex_txt{'455'} $VeryHotTopic $messageindex_txt{'454a'}<br />
	<img src="$imagesdir/locked.gif" alt="" /> $messageindex_txt{'456'}
~;
	if (($iamadmin || $iamgmod || $iammod) && $sessionvalid == 1) {
		$yabbadminicons = qq~<img src="$imagesdir/hide.gif" alt="" /> $messageindex_txt{'458'}<br />~;
	}
	$yabbadminicons .= qq~
	<img src="$imagesdir/announcement.gif" alt="" /> $messageindex_txt{'779a'}<br />
	<img src="$imagesdir/sticky.gif" alt="" /> $messageindex_txt{'779'}<br />
	<img src="$imagesdir/stickylock.gif" alt="" /> $messageindex_txt{'780'}
~;

	$formstart = qq~<form name="multiremfav" action="$scripturl?action=multiremfav;board=$currentboard" method="post" style="display: inline">~;
	$formend   = qq~<input type="hidden" name="allpost" value="$INFO{'start'}" /></form>~;

	&LoadAccess;

	$adminselector = qq~
	<input type="submit" value="$messageindex_txt{'842'}" />
~;

	$admincheckboxes = qq~
	<input type="checkbox" name="checkall" value="" class="titlebg" style="border: 0px;" onclick="if (this.checked) checkAll(0); else uncheckAll(0);" />
~;
	$subfooterbar =~ s/<yabb admin selector>/$adminselector/g;
	$subfooterbar =~ s/<yabb admin checkboxes>/$admincheckboxes/g;

	# Template it
	$adminheader =~ s/<yabb admin>/$messageindex_txt{'2'}/g;

	$messageindex_template =~ s/<yabb home>/$homelink/g;
	$messageindex_template =~ s/<yabb category>/$catlink/g;
	$messageindex_template =~ s/<yabb board>//g;
	$messageindex_template =~ s/<yabb moderators>//g;
	$bdescrip = qq~<b>$img_txt{'70'}</b><br />$messageindex_txt{'75'}<br />$messageindex_txt{'76'} $curfav $messageindex_txt{'77'} $maxfavs $messageindex_txt{'78'}~;
	if ($ShowBDescrip) {
		&ToChars($bdescrip);
		$boarddescription      =~ s/<yabb boarddescription>/$bdescrip/g;
		$messageindex_template =~ s/<yabb description>/$boarddescription/g;
	} else {
		$messageindex_template =~ s/<yabb description>//g;
	}
	$messageindex_template =~ s/<yabb colspan>/$colspan/g;
	$messageindex_template =~ s/<yabb notify button>//g;
	$messageindex_template =~ s/<yabb markall button>//g;
	$messageindex_template =~ s/<yabb new post button>//g;
	$messageindex_template =~ s/<yabb new poll button>//g;
	$messageindex_template =~ s/<yabb pageindex top>//g;
	$messageindex_template =~ s/<yabb pageindex bottom>//g;
	$messageindex_template =~ s/<yabb topichandellist>//g;
	$messageindex_template =~ s/<yabb pageindex toggle>//g;

	$messageindex_template =~ s/<yabb admin column>/$adminheader/g;
	$messageindex_template =~ s/<yabb modupdate>/$formstart/g;
	$messageindex_template =~ s/<yabb modupdateend>/$formend/g;

	$messageindex_template =~ s/<yabb stickyblock>//g;
	$messageindex_template =~ s/<yabb threadblock>/$tmptempbar/g;
	$messageindex_template =~ s/<yabb adminfooter>/$subfooterbar/g;
	$messageindex_template =~ s/<yabb forumjump>/$selecthtml/g;
	$messageindex_template =~ s/<yabb icons>/$yabbicons/g;
	$messageindex_template =~ s/<yabb admin icons>/$yabbadminicons/g;
	$messageindex_template =~ s/<yabb access>//g;
	$yymain .= qq~$messageindex_template~;

	$yymain .= qq~
<script language="JavaScript1.2" type="text/javascript">
	<!-- Begin
		function checkAll(j) {
			for (var i = 0; i < document.multiremfav.elements.length; i++) {
				if (j == 0 ) {document.multiremfav.elements[i].checked = true;}
			}
		}
		function uncheckAll(j) {
			for (var i = 0; i < document.multiremfav.elements.length; i++) {
				if (j == 0 ) {document.multiremfav.elements[i].checked = false;}
			}
		}
	//-->
</script>
	~;

	$yytitle = $img_txt{'70'};
	&template;
	exit;
}

sub ShowFav {
	if (${$uid.$username}{'favorites'} eq "") { return 0; }
	${$uid.$username}{'favorites'} =~ s~\, ~\,~g;
	@fav = split(/\,/, ${$uid.$username}{'favorites'});
	foreach $fav (@fav) {
		chomp $fav;
		if (-e "$datadir/$fav.txt") {
			$favicon{$fav} = qq~<img src="$imagesdir/addfav.gif" alt="$img_txt{'70'}" />~;
		}
	}
}

sub AddFav {
	my $favo = $INFO{'fav'}   || $_[0];
	my $goto = $INFO{'start'} || $_[1];
	if (!$goto) { $goto = 0; }
	my (@oldfav, @newfav, $favorites);
	if (${$uid.$username}{'favorites'}) { @oldfav = split(/\,/, ${$uid.$username}{'favorites'}); }
	push(@oldfav, $favo);
	@newfav = &undupe(@oldfav);
	${$uid.$username}{'favorites'} = join(",", @newfav);
	&UserAccount($username, "update");
	$yySetLocation = qq~$scripturl?num=$favo/$goto~;
	&redirectexit;
}

sub MultiRemFav {
	while ($maxfavs >= $count) {
		$delete = $FORM{"admin$count"};
		&RemFav($delete);
		$count++;
	}
	$yySetLocation = qq~$scripturl?action=favorites~;
	&redirectexit;
}

sub RemFav {
	my $favo = $INFO{'fav'}   || $_[0];
	my $goto = $INFO{'start'} || $_[1];
	if (!$goto) { $goto = 0; }
	my @oldfav = split(/\,/, ${$uid.$username}{'favorites'});
	my (@fav, @newfav, $fav);
	foreach $fav (@oldfav) {
		chomp $fav;
		unless ($favo eq $fav) {
			push(@newfav, $fav);
		}
	}
	@fav = &undupe(@newfav);
	${$uid.$username}{'favorites'} = join(",", @fav);
	&UserAccount($username, "update");
	if     ($_[1]        eq "nonexist") { return; }
	unless ($INFO{'ref'} eq "delete")   {
		unless ($action eq "multiremfav") {
			$yySetLocation = qq~$scripturl?num=$favo/$goto~;
			&redirectexit;
		}
	}
}

sub IsFav {
	$favo = $_[0];
	$goto = $_[1];
	if (!$goto)    { $goto    = 0; }
	if (!$maxfavs) { $maxfavs = 10; }
	my @oldfav = split(/\,/, ${$uid.$username}{'favorites'});
	my (@fav, $button, $fav, $favcount);
	$favcount = scalar(@oldfav);
	if ($favcount < $maxfavs) { $button = qq~$menusep<a href="$scripturl?action=addfav;fav=$favo;start=$goto">$img{'addfav'}</a>~; }
	else { $button = ""; }

	foreach $fav (@oldfav) {
		chomp $fav;
		if ($favo eq $fav) {
			$button = qq~$menusep<a href="$scripturl?action=remfav;fav=$favo;start=$goto">$img{'remfav'}</a>~;
		}
	}
	return $button;
}

1;
