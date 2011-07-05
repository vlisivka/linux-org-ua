###############################################################################
# BoardIndex.pl                                                               #
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

$boardindexplver = 'YaBB 2.1 $Revision: 1.4 $';

if ($action eq 'detailedversion') { return 1; }

LoadLanguage("BoardIndex");
require "$templatesdir/$useboard/BoardIndex.template";

sub Del_Max_IM {
	fopen(DELMAXIM, "$memberdir/$username.msg");
	@messages = <DELMAXIM>;
	fclose(DELMAXIM);

	fopen(DELMAXIM, ">$memberdir/$username.msg", 1);
	for ($a = 0; $a < @messages; $a++) {
		chomp $messages[$a];
		if ($a < $numibox) { print DELMAXIM "$messages[$a]\n"; }
	}
	fclose(DELMAXIM);
}

sub Del_Max_IMOUT {
	fopen(DELMAXIMOUT, "$memberdir/$username.outbox");
	@omessages = <DELMAXIMOUT>;
	fclose(DELMAXIMOUT);

	fopen(DELMAXIMOUT, ">$memberdir/$username.outbox", 1);
	for ($a = 0; $a < @omessages; $a++) {
		chomp $omessages[$a];
		if ($a < $numobox) { print DELMAXIMOUT "$omessages[$a]\n"; }
	}
	fclose(DELMAXIMOUT);
}

sub Del_Max_STORE {
	fopen(DELMAXIMSTORE, "$memberdir/$username.imstore");
	@smessages = <DELMAXIMSTORE>;
	fclose(DELMAXIMSTORE);

	fopen(DELMAXIMSTORE, ">$memberdir/$username.imstore", 1);
	for ($a = 0; $a < @smessages; $a++) {
		chomp $smessages[$a];
		if ($a < $numstore) { print DELMAXIMSTORE "$smessages[$a]\n"; }
	}
	fclose(DELMAXIMSTORE);
}

sub BoardIndex {
	my ($lspostid, $lspostbd, $lssub, $lsposttime, $lsposter, $lsreply, $lsdatetime, $lastthreadtime, @goodboards, @loadboards);
	my ($memcount, $latestmember) = &MembershipGet;
	chomp $latestmember;
	$totalm         = 0;
	$totalt         = 0;
	$lastposttime   = 0;
	$lastthreadtime = 0;


#	my $checkadded = 0;
	my $users     = qq~<span class="small">~;
	my $guestlist = qq~<span class="small">~;
	my $guests    = 0;
	my $numusers  = 0;

	load_online_users;

	foreach my $login ( keys %online_users ) {

		my ( $value, $last_ip ) = split /\|/, $online_users{$login};

		if ( not $last_ip ) {
			$last_ip = qq(<span class="error">$boardindex_txt{'no_ip'}</span>)
		}

		if ( -e "$memberdir/$login.vars" ) {

			LoadUser $login unless exists ${$uid.$login}{'realname'};
			LoadMiniUser $login;

			$numusers++;

			$users .= "$link{$login}";
			if ( ( $iamadmin and $show_online_ip_admin )
			  or ( $iamgmod  and $show_online_ip_gmod  ) ) {

				$users .= " <i>($last_ip)</i>"
			}
			$users .= qq~, ~;

		} else {

			$guests++;

			if ( ( $iamadmin and $show_online_ip_admin )
			  or ( $iamgmod  and $show_online_ip_gmod  ) ) {

				$guestlist .= "<i>$last_ip</i>, "
			}
		}
	}

	$users  =~ s/, \Z//;
	$users .=  "</span>";
	$users .=  "<br />" if $numusers;

	$guestlist  =~ s/, \Z//;
	$guestlist .=  "</span>";


#	$curforumurl = $curposlinks ? qq~<a href="$scripturl" class="nav">$mbname</a>~ : $mbname;
	if (!$INFO{'catselect'}) {
		$curforumurl = qq~<a href="$scripturl" class="nav">$mbname</a>~;
	} else {
		($tmpcat, $tmpmod, $tmpcol) = split(/\|/, $catinfo{ $INFO{'catselect'} });
		$curforumurl = qq~<a href="$scripturl" class="nav">$mbname</a> &rsaquo; <a href="$scripturl?catselect=$INFO{'catselect'}" class="nav">$tmpcat</a>~;
	}

	if (!$iamguest) {
		&Collapse_Load;
	}

	# first get all the boards based on the categories found in forum.master
	foreach $catid (@categoryorder) {
		if ($INFO{'catselect'} ne $catid && $INFO{'catselect'}) { next; }
		$boardlist = $cat{$catid};
		(@bdlist) = split(/\,/, $boardlist);
		my ($catname, $catperms, $catallowcol) = split(/\|/, $catinfo{"$catid"});

		# Category Permissions Check
		my $access = &CatAccess($catperms);
		if (!$access) { next; }
		$cat_boardcnt{$catid} = 0;

		# next determine all the boards a user has access to
		foreach $curboard (@bdlist) {

			# now fill all the neccesary hashes to show all board index stuff
			chomp $curboard;
			if (!exists $board{$curboard}) {
				&gostRemove($catid, $curboard);
				next;
			}

			# hide the actual global announcement board for all normal users but admins and gmods
			if ($annboard eq $curboard && !$iamadmin && !$iamgmod) { next; }

			my ($boardname, $boardperms, $boardview) = split(/\|/, $board{"$curboard"});
			my $access = &AccessCheck($curboard, '', $boardperms);
			if (!$iamadmin && $access ne "granted" && $boardview != 1) { next; }
			push(@goodboards, "$catid|$curboard");
			push(@loadboards, $curboard);
			$cat_boardcnt{$catid}++;
		}
	}

	&BoardTotals("load", @loadboards);

	getlog;

	foreach $curboard (@loadboards) {
		chomp $curboard;
		$lastposttime = ${$uid.$curboard}{'lastposttime'};
		${$uid.$curboard}{'lastposttime'} = ${$uid.$curboard}{'lastposttime'} eq 'N/A' || !${$uid.$curboard}{'lastposttime'} ? $boardindex_txt{'470'} : ${$uid.$curboard}{'lastposttime'};
		if (${$uid.$curboard}{'lastposttime'} != 0) { $lastposttime{$curboard} = &timeformat(${$uid.$curboard}{'lastposttime'}); }
		else { $lastposttime{$curboard} = $boardindex_txt{'470'}; }
		$lastpostrealtime{$curboard} = ${$uid.$curboard}{'lastposttime'} eq 'N/A' || !${$uid.$curboard}{'lastposttime'} ? '' : ${$uid.$curboard}{'lastposttime'};
		$lsreply{$curboard} = ${$uid.$curboard}{'lastreply'} + 1;
		if (${$uid.$curboard}{'lastposter'} =~ m~\AGuest-(.*)~) {
			${$uid.$curboard}{'lastposter'} = $1;
			$lastposterguest{$curboard} = 1;
		}
		${$uid.$curboard}{'lastposter'}   = ${$uid.$curboard}{'lastposter'} eq 'N/A' || !${$uid.$curboard}{'lastposter'} ? $boardindex_txt{'470'} : ${$uid.$curboard}{'lastposter'};
		${$uid.$curboard}{'messagecount'} = ${$uid.$curboard}{'messagecount'}        || 0;
		${$uid.$curboard}{'threadcount'}  = ${$uid.$curboard}{'threadcount'}         || 0;
		$totalm += ${$uid.$curboard}{'messagecount'};
		$totalt += ${$uid.$curboard}{'threadcount'};

		# hide hidden threads for ordinary members and guests
		$iammodhere = "";
		$bdmods     = ${$uid.$curboard}{'mods'};
		$bdmods =~ s/\, /\,/g;
		$bdmods =~ s/\ /\,/g;
		foreach $curuser (split(/\,/, $bdmods)) {
			if ($username eq $curuser) { $iammodhere = 1; }
		}
		if (!$iammodhere && !$iamadmin && !$iamgmod) {
			fopen(MNUM, "$boardsdir/$curboard.txt");
			@threadlist = <MNUM>;
			fclose(MNUM);
			my (@messarr) = split(/\|/, $threadlist[0]);
			$messagestate = pop(@messarr);
			if ($messagestate =~ /h/i) {
				${$uid.$curboard}{'lastpostid'}   = "";
				${$uid.$curboard}{'lastsubject'}  = "";
				${$uid.$curboard}{'lastreply'}    = "";
				${$uid.$curboard}{'lastposter'}   = qq~$boardindex_txt{'470'}~;
				${$uid.$curboard}{'lastposttime'} = "";
				$lastposttime{$curboard} = qq~$boardindex_txt{'470'}~;
				for ($i = 1; $i < @threadlist; $i++) {
					($messageid, $messagesubject, undef, undef, undef, undef, undef, undef, $messagestate) = split(/\|/, $threadlist[$i]);
					if ($messagestate !~ /h/i) {
						fopen(MDATA, "$datadir/$messageid.ctb");
						@threaddata = <MDATA>;
						fclose(MDATA);
						chomp @threaddata;
						${$uid.$curboard}{'lastpostid'}   = $messageid;
						${$uid.$curboard}{'lastsubject'}  = $messagesubject;
						${$uid.$curboard}{'lastreply'}    = $threaddata[1];
						${$uid.$curboard}{'lastposter'}   = $threaddata[3];
						${$uid.$curboard}{'lastposttime'} = $threaddata[4];
						$lastposttime{$curboard} = &timeformat($threaddata[4]);
						last;
					}
				}
			}
		}
		# determine the true last post on all the boards a user has access to
		if (${$uid.$curboard}{'lastposttime'} > $lastthreadtime && $lastposttime{$curboard} ne $boardindex_txt{'470'}) {
			$lsdatetime     = $lastposttime{$curboard};
			$lsposter       = ${$uid.$curboard}{'lastposter'};
			$lssub          = ${$uid.$curboard}{'lastsubject'};
			$lspostid       = ${$uid.$curboard}{'lastpostid'};
			$lsreply        = ${$uid.$curboard}{'lastreply'};
			$lastthreadtime = ${$uid.$curboard}{'lastposttime'};
			$lspostbd       = $curboard;
		}

	}

	foreach $catid (@categoryorder) {
		if ($INFO{'catselect'} ne $catid && $INFO{'catselect'}) { next; }
		my ($catname, $catperms, $catallowcol) = split(/\|/, $catinfo{"$catid"});
		&ToChars($catname);

		$cataccess = &CatAccess($catperms);
		if (!$cataccess) { next; }

		# Skip any empty categories.
		if ($cat_boardcnt{$catid} == 0) { next; }

		if (!$iamguest) {
			my $newmsg = 0;
			$newms{$catname}       = "";
			$newrowicon{$catname}  = "";
			$newrowstart{$catname} = "";
			$newrowend{$catname}   = "";

			if ($catallowcol) {
				$collapse_link = qq~<a href="$scripturl?action=collapse_cat;cat=$catid">~;
			} else {
				$collapse_link = qq~~;
			}

			# loop through any collapsed boards to find new posts in it and change the image to match
			if (!$catcol{$catid} && $INFO{'catselect'} eq '') {

				foreach my $boardinfo (@goodboards) {
					chomp $boardinfo;
					my ($testcat);
					($testcat, $curboard) = split(/\|/, $boardinfo);
					if ($testcat ne $catid) { next; }

					# as we fill the vars based on all boards we need to skip any cat already shown before
					my $dlp = $yyuserlog{$curboard} ? $yyuserlog{$curboard} : 0;
					if ($max_log_days_old && ${$uid.$curboard}{'lastposttime'} ne $boardindex_txt{'470'} && $dlp < $lastpostrealtime{$curboard} && ($dlp > $max_log_days_old * 86400 || $dlp == 0)) {
						my (undef, $boardperms, $boardview) = split(/\|/, $board{"$curboard"});
						if (&AccessCheck($curboard, '', $boardperms) eq "granted") { $newmsg = 1; }
					}
				}
				$newrowstart{$catname} = qq~<tr><td colspan="5" class="$new_msg_bg" height="18"><span class="$new_msg_class">~;
				$newrowend{$catname}   = qq~</span></td></tr>~;
				if ($newmsg) {
					if ($catallowcol) {
						$hash{$catname}       = qq~ <img src="$imagesdir/cat_expand.gif" alt="$boardindex_exptxt{'1'}" border="0" /></a>~;
						$newrowicon{$catname} = qq~<img src="$imagesdir/on.gif" alt="$boardindex_txt{'333'}" border="0" style="margin-left: 4px; margin-right: 6px; vertical-align: middle;" />~;
						$newms{$catname}      = qq~$boardindex_exptxt{'5'}~;
					}
				} else {
					if ($catallowcol) {
						$hash{$catname}       = qq~ <img src="$imagesdir/cat_expand.gif" alt="$boardindex_exptxt{'1'}" border="0" /></a>~;
						$newrowicon{$catname} = qq~<img src="$imagesdir/off.gif" alt="$boardindex_txt{'334'}" border="0" style="margin-left: 4px; margin-right: 6px; vertical-align: middle;" />~;
						$newms{$catname}      = qq~$boardindex_exptxt{'6'}~;
					}
				}
			} else {
				if ($catallowcol) {
					if ($INFO{'catselect'} ne '') { $collapse_link = ""; $hash{$catname} = ""; }
					else { $hash{$catname} = qq~<img src="$imagesdir/cat_collapse.gif" alt="$boardindex_exptxt{'2'}" border="0" /></a>~; }
				}
			}
			$catlink = qq~$collapse_link $hash{$catname} <a href="$scripturl?catselect=$catid" title="$boardindex_txt{'797'} $catname">$catname</a>~;
		} else {
			$catlink = qq~<a href="$scripturl?catselect=$catid">$catname</a>~;
		}
		$templatecat = $catheader;
		$templatecat =~ s/<yabb catlink>/$catlink/g;
		$templatecat =~ s/<yabb newmsg start>/$newrowstart{$catname}/g;
		$templatecat =~ s/<yabb newmsg icon>/$newrowicon{$catname}/g;
		$templatecat =~ s/<yabb newmsg>/$newms{$catname}/g;
		$templatecat =~ s/<yabb newmsg end>/$newrowend{$catname}/g;
		$iammod = "";
		$tmptemplateblock .= $templatecat;
		## loop through any non collapsed boards to show the board index ##
		if ($catcol{$catid} || $INFO{'catselect'} ne '' || $iamguest) {
			foreach my $boardinfo (@goodboards) {
				chomp $boardinfo;
				my ($testcat);
				($testcat, $curboard) = split(/\|/, $boardinfo);

				if ($testcat ne $catid) { next; }

				# as we fill the vars based on all boards we need to skip any cat already shown before
				if (${$uid.$curboard}{'ann'} == 1)  { ${$uid.$curboard}{'pic'} = "ann.gif"; }
				if (${$uid.$curboard}{'rbin'} == 1) { ${$uid.$curboard}{'pic'} = "recycle.gif"; }
				($boardname, $boardperms, $boardview) = split(/\|/, $board{"$curboard"});
				&ToChars($boardname);
				$INFO{'zeropost'} = 0;
				$zero             = "";
				$bdpic            = ${$uid.$curboard}{'pic'};
				$bddescr          = ${$uid.$curboard}{'description'};
				&ToChars($bddescr);
				$bdmods = ${$uid.$curboard}{'mods'};
				$bdmods =~ s/\, /\,/g;
				$bdmods =~ s/\ /\,/g;
				%moderators = ();

				foreach $curuser (split(/\,/, $bdmods)) {
					if ($username eq $curuser) { $iammod = 1; }
					&LoadUser($curuser);
					$moderators{$curuser} = ${$uid.$curuser}{'realname'};
				}
				$showmods = '';
				if    (scalar keys %moderators == 1) { $showmods = qq~$boardindex_txt{'298'}: ~; }
				elsif (scalar keys %moderators != 0) { $showmods = qq~$boardindex_txt{'63'}: ~; }
				while ($tmpa = each(%moderators)) {
					&FormatUserName($tmpa);
					$showmods .= qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$tmpa}">$moderators{$tmpa}</a>, ~;
				}
				$showmods =~ s/, \Z//;

				&LoadUser($username);
				$bdmodgroups = ${$uid.$curboard}{'modgroups'};
				$bdmodgroups =~ s/\, /\,/g;
				%moderatorgroups = ();
				foreach $curgroup (split(/\,/, $bdmodgroups)) {
					if (${$uid.$username}{'position'} eq $curgroup) { $iammod = 1; }
					foreach $memberaddgroups (split(/\, /, ${$uid.$username}{'addgroups'})) {
						chomp $memberaddgroups;
						if ($memberaddgroups eq $curgroup) { $iammod = 1; last; }
					}
					($thismodgrp, undef) = split(/\|/, $NoPost{$curgroup}, 2);
					$moderatorgroups{$curgroup} = $thismodgrp;
				}

				$showmodgroups = '';
				if    (scalar keys %moderatorgroups == 1) { $showmodgroups = qq~$boardindex_txt{'298a'}: ~; }
				elsif (scalar keys %moderatorgroups != 0) { $showmodgroups = qq~$boardindex_txt{'63a'}: ~; }
				while ($tmpa = each(%moderatorgroups)) {
					$showmodgroups .= qq~$moderatorgroups{$tmpa}, ~;
				}
				$showmodgroups =~ s/, \Z//;
				if ($showmodgroups eq "" && $showmods eq "") { $showmodgroups = qq~<br />~; }
				if ($showmodgroups ne "" && $showmods ne "") { $showmods .= qq~<br />~; }

				my $dlp = $yyuserlog{$curboard} ? $yyuserlog{$curboard} : 0;
				if ($max_log_days_old && ${$uid.$curboard}{'lastposttime'} ne $boardindex_txt{'470'} && !$iamguest && $dlp < $lastpostrealtime{$curboard} && ($dlp > $max_log_days_old * 86400 || $dlp == 0)) {
					my (undef, $boardperms, $boardview) = split(/\|/, $board{"$curboard"});
					if (&AccessCheck($curboard, '', $boardperms) eq "granted") {
						$new = qq~<img src="$imagesdir/on.gif" alt="$boardindex_txt{'333'}" border="0" />~;
					} else {
						$new = qq~<img src="$imagesdir/off.gif" alt="$boardindex_txt{'334'}" border="0" />~;
					}
				} else {
					$new = qq~<img src="$imagesdir/off.gif" alt="$boardindex_txt{'334'}" border="0" />~;
				}
				if (${$uid.$curboard}{'ann'} == 1)  { $new = qq~<img src="$imagesdir/ann.gif" alt="" border="0" />~; }
				if (${$uid.$curboard}{'rbin'} == 1) { $new = qq~<img src="$imagesdir/recycle.gif" alt="" border="0" />~; }

				$lastposter = ${$uid.$curboard}{'lastposter'};
				$lastposter =~ s~\AGuest-(.*)~$1~i;

				unless ($lastposterguest{$curboard} || ${$uid.$curboard}{'lastposter'} eq $boardindex_txt{'470'}) {
					&LoadUser($lastposter);
					$registrationdate = ${$uid.$lastposter}{'regtime'};

					$messagedate = ${$uid.$curboard}{'lastposttime'};

					if ((${$uid.$lastposter}{'regdate'} && $messagedate > $registrationdate) || ${$uid.$lastposter}{'status'} eq "Administrator" || ${$uid.$lastposter}{'status'} eq "Global Moderator") {
						$lastposter = qq~<a href="$scripturl?action=viewprofile;username=$lastposter">${$uid.$lastposter}{'realname'}</a>~;
					} else {
						$lastposter .= qq~ - $boardindex_txt{'470a'}~;
					}
				}
				${$uid.$curboard}{'lastposter'}   ||= $boardindex_txt{'470'};
				${$uid.$curboard}{'lastposttime'} ||= $boardindex_txt{'470'};

				if ($bdpic =~ /\//i) { $bdpic = qq~ <img src="$bdpic" alt="" border="0" align="middle" /> ~; }
				elsif ($bdpic) { $bdpic = qq~ <img src="$imagesdir/$bdpic" alt="" border="0" align="middle" /> ~; }

				my $templateblock = $boardblock;

				if (!$topiccut) { $topiccut = 15; }
				my $lasttopictxt = ${$uid.$curboard}{'lastsubject'};
				$lasttopictxt =~ s/\A\[m\]/$maintxt{'758'}/;

				# Censor the subject
				&LoadCensorList;
				$lasttopictxt = &Censor($lasttopictxt);
				$fulltopictext = qq~$lasttopictxt~;

				if (${$uid.$curboard}{'lastreply'} ne "") {
					$lastpostlink = qq~<a href="$scripturl?num=${$uid.$curboard}{'lastpostid'}/${$uid.$curboard}{'lastreply'}#${$uid.$curboard}{'lastreply'}">$img{'lastpost'}</a> $lastposttime{$curboard}~;
				} else {
					$lastpostlink = qq~$img{'lastpost'} $boardindex_txt{'470'}~;
				}

				$convertstr = $lasttopictxt;
				$convertcut = $topiccut;
				&FromHTML($convertstr);
				&CountChars;
				my $lasttopictxt = $convertstr;
				&ToChars($lasttopictxt);
				&ToChars($fulltopictext);

				if ($cliped) { $lasttopictxt .= "..."; }

				$lasttopictxt =~ s/  / \&nbsp;/g;
				$lasttopictxt =~ s/</&lt;/g;
				$lasttopictxt =~ s/>/&gt;/g;
				$lasttopictxt =~ s/\|/\&#124;/g;

				$fulltopictext =~ s/</&lt;/g;
				$fulltopictext =~ s/>/&gt;/g;
				$fulltopictext =~ s/\|/\&#124;/g;

				my $lasttopiclink = qq~<a href="$scripturl?num=${$uid.$curboard}{'lastpostid'}/${$uid.$curboard}{'lastreply'}#${$uid.$curboard}{'lastreply'}" title="$fulltopictext">$lasttopictxt</a>~;
				if (${$uid.$curboard}{'threadcount'} < 0)  { ${$uid.$curboard}{'threadcount'}  = 0; }
				if (${$uid.$curboard}{'messagecount'} < 0) { ${$uid.$curboard}{'messagecount'} = 0; }
				$templateblock =~ s/<yabb boardanchor>/$curboard/g;
				$templateblock =~ s/<yabb boardurl>/$scripturl\?board\=$curboard/g;
				$templateblock =~ s/<yabb new>/$new/g;
				$templateblock =~ s/<yabb boardpic>/$bdpic/g;
				$templateblock =~ s/<yabb boardname>/$boardname/g;
				$templateblock =~ s/<yabb boarddesc>/$bddescr/g;
				$templateblock =~ s/<yabb moderators>/$showmods$showmodgroups/g;
				$templateblock =~ s/<yabb threadcount>/${$uid.$curboard}{'threadcount'}/g;
				$templateblock =~ s/<yabb messagecount>/${$uid.$curboard}{'messagecount'}/g;
				$templateblock =~ s/<yabb lastpostlink>/$lastpostlink/g;
				$templateblock =~ s/<yabb lastposter>/$lastposter/g;
				$templateblock =~ s/<yabb lasttopiclink>/$lasttopiclink/g;

				$tmptemplateblock .= $templateblock;
			}
		}
		$tmptemplateblock .= $catfooter;
		++$catcount;
	}

	if (!$iamguest) {
		$ims = @immessages;

		if ($minnum > $numibox && $numibox ne "" && $enable_imlimit == 1) {
			$yymain .= qq~<script language="javascript" type="text/javascript"> if(confirm('$boardindex_imtxt{'11'} $minnum $boardindex_imtxt{'12'} $boardindex_txt{'316'}!\\n$numibox $boardindex_imtxt{'18'}')) { viewinstant(); } else cancel() </script>~;
			&Del_Max_IM;
		}

		if ($moutnum > $numobox && $numobox ne "" && $enable_imlimit == 1) {
			$yymain .= qq~<script language="javascript" type="text/javascript"> if(confirm('$boardindex_imtxt{'11'} $moutnum $boardindex_imtxt{'12'} $boardindex_txt{'320'}!\\n$numobox $boardindex_imtxt{'18'}')) { viewinstant(); } else cancel() </script>~;
			&Del_Max_IMOUT;
		}

		if ($storenum > $numstore && $numstore ne "" && $enable_imlimit == 1) {
			$yymain .= qq~<script language="javascript" type="text/javascript"> if(confirm('$boardindex_imtxt{'11'} $storenum $boardindex_imtxt{'12'} $boardindex_imtxt{'46'}!\\n$numstore $boardindex_imtxt{'18'}')) { viewinstant(); } else cancel() </script>~;
			&Del_Max_STORE;
		}

		$ims = qq~$boardindex_txt{'795'} <a href="$scripturl?action=im"><b>$ims</b></a> $boardindex_txt{'796'}~;
		if ($#immessages > 0) {
			if ($imnewcount == 1) {
				$ims .= qq~ $boardindex_imtxt{'24'} <a href="$scripturl?action=im"><b>$imnewcount</b></a> $boardindex_imtxt{'25'}.~;
			} else {
				$ims .= qq~ $boardindex_imtxt{'24'} <a href="$scripturl?action=im"><b>$imnewcount</b></a> $boardindex_imtxt{'26'}.~;
			}
		} else {
			$ims .= qq~.~;
		}

		if ($INFO{'catselect'} eq '') {
			if ($colbutton) {
				$collapselink = qq~$menusep<a href="$scripturl?action=collapse_all;status=0">$img{'collapse'}</a>~;
			}
			if (${$uid.$username}{'cathide'}) {
				$expandlink = qq~$menusep<a href="$scripturl?action=collapse_all;status=1">$img{'expand'}</a>~;
			}
			$markalllink = qq~$menusep<a href="$scripturl?action=markallasread">$img{'markallread'}</a>~;

		} else {
			$markalllink  = qq~$menusep<a href="$scripturl?action=markallasread;cat=$INFO{'catselect'}">$img{'markallread'}</a>~;
			$collapselink = "";
			$expandlink   = "";
		}
	}
	if ($INFO{'catselect'}) { &jumpto; }

	if ($totalt < 0) { $totalt = 0; }
	if ($totalm < 0) { $totalm = 0; }

	$guestson = qq~<span class="small">$boardindex_txt{'141'}: <b>$guests</b></span>~;
	$userson  = qq~<span class="small">$boardindex_txt{'142'}: <b>$numusers</b></span>~;

	$totalusers = $numusers + $guests;

	if (!-e ("$vardir/mostlog.txt")) {
		fopen(MOSTUSERS, ">$vardir/mostlog.txt");
		print MOSTUSERS "$numusers|$date\n";
		print MOSTUSERS "$guests|$date\n";
		print MOSTUSERS "$totalusers|$date\n";
		fclose(MOSTUSERS);
	}
	fopen(MOSTUSERS, "$vardir/mostlog.txt");
	@mostentries = <MOSTUSERS>;
	fclose(MOSTUSERS);
	($mostmemb,  $datememb)  = split(/\|/, $mostentries[0]);
	($mostguest, $dateguest) = split(/\|/, $mostentries[1]);
	($mostusers, $dateusers) = split(/\|/, $mostentries[2]);
	chomp $datememb;
	chomp $dateguest;
	chomp $dateusers;

	if ($numusers >= $mostmemb || $guests >= $mostguest || $totalusers >= $mostusers) {
		fopen(MOSTUSERS, ">$vardir/mostlog.txt");
		if ($numusers >= $mostmemb)    { $mostmemb  = $numusers;   $datememb  = $date; }
		if ($guests >= $mostguest)     { $mostguest = $guests;     $dateguest = $date; }
		if ($totalusers >= $mostusers) { $mostusers = $totalusers; $dateusers = $date; }
		print MOSTUSERS "$mostmemb|$datememb\n";
		print MOSTUSERS "$mostguest|$dateguest\n";
		print MOSTUSERS "$mostusers|$dateusers\n";
		fclose(MOSTUSERS);
	}
	$themostmembdate  = &timeformat($datememb);
	$themostguestdate = &timeformat($dateguest);
	$themostuserdate  = &timeformat($dateusers);

	$themostuser  = qq~$mostusers~;
	$themostmemb  = qq~$mostmemb~;
	$themostguest = qq~$mostguest~;

	my $shared_login;
	if ($iamguest) {
		require "$sourcedir/LogInOut.pl";
		$sharedLogin_title = "";
		$shared_login      = &sharedLogin;
	}

	$grpcolors = "";
	($title, undef, undef, $color, $noshow) = split(/\|/, $Group{'Administrator'}, 5);
	if ($color && $noshow != 1) { $grpcolors .= qq~<div class="small" style="float: left; width: 49%;"><span style="color: $color;"><b>lllll</b></span> $title</div>~; }
	($title, undef, undef, $color, $noshow) = split(/\|/, $Group{'Global Moderator'}, 5);
	if ($color && $noshow != 1) { $grpcolors .= qq~<div class="small" style="float: left; width: 49%;"><span style="color: $color;"><b>lllll</b></span> $title</div>~; }
	foreach $nopostamount (sort { $a <=> $b } keys %NoPost) {
		($title, undef, undef, $color, $noshow) = split(/\|/, $NoPost{$nopostamount}, 5);
		if ($color && $noshow != 1) { $grpcolors .= qq~<div class="small" style="float: left; width: 49%;"><span style="color: $color;"><b>lllll</b></span> $title</div>~; }
	}
	foreach $postamount (sort { $b <=> $a } keys %Post) {
		($title, undef, undef, $color, $noshow) = split(/\|/, $Post{$postamount}, 5);
		if ($color && $noshow != 1) { $grpcolors .= qq~<div class="small" style="float: left; width: 49%;"><span style="color: $color;"><b>lllll</b></span> $title</div>~; }
	}

	# Template it
	$boardindex_template =~ s/<yabb navigation>/$curforumurl/g;
	$boardindex_template =~ s/<yabb selecthtml>/$selecthtml/g;
	$boardindex_template =~ s/<yabb catsblock>/$tmptemplateblock/g;

	$boardhandellist     =~ s/<yabb collapse>/$collapselink/g;
	$boardhandellist     =~ s/<yabb expand>/$expandlink/g;
	$boardhandellist     =~ s/<yabb markallread>/$markalllink/g;
	$boardhandellist     =~ s/\Q$menusep//i;
	$boardindex_template =~ s/<yabb boardhandellist>/$boardhandellist/g;

	$boardindex_template =~ s/<yabb totaltopics>/$totalt/g;
	$boardindex_template =~ s/<yabb totalmessages>/$totalm/g;

	&LoadCensorList;

	if ($Show_RecentBar) {
		$lssub = &Censor($lssub);
		$lssub =~ s/\A\[m\]/$maintxt{'758'}/;
		&ToChars($lssub);
		$tmlsdatetime    = qq~($lsdatetime).<br />~;
		$lastpostlink    = qq~$boardindex_txt{'236'} <b><a href="$scripturl?num=$lspostid/$lsreply#$lsreply"><b>$lssub</b></a></b>~;
		$recentpostslink = qq~$boardindex_txt{'791'} <a href="$scripturl?action=recent;display=10">$boardindex_txt{'792'}</a> $boardindex_txt{'793'}~;
		$boardindex_template =~ s/<yabb lastpostlink>/$lastpostlink/g;
		$boardindex_template =~ s/<yabb recentposts>/$recentpostslink/g;
		$boardindex_template =~ s/<yabb lastpostdate>/$tmlsdatetime/g;
	} else {
		$boardindex_template =~ s/<yabb lastpostlink>//g;
		$boardindex_template =~ s/<yabb recentposts>//g;
		$boardindex_template =~ s/<yabb lastpostdate>//g;
	}
	$membercountlink = qq~<a href="$scripturl?action=ml"><b>$memcount</b></a>~;
	$boardindex_template =~ s/<yabb membercount>/$membercountlink/g;
	if ($showlatestmember) {
		&LoadUser($latestmember);
		$latestmemberlink = qq~$boardindex_txt{'201'} <a href="$scripturl?action=viewprofile;username=$useraccount{$latestmember}"><b>${$uid.$latestmember}{'realname'}</b></a>.<br />~;
		$boardindex_template =~ s/<yabb latestmember>/$latestmemberlink/g;
	} else {
		$boardindex_template =~ s/<yabb latestmember>//g;
	}
	$boardindex_template =~ s/<yabb ims>/$ims/g;
	$boardindex_template =~ s/<yabb guests>/$guestson/g;
	$boardindex_template =~ s/<yabb users>/$userson/g;
	$boardindex_template =~ s/<yabb onlineusers>/$users/g;
	$boardindex_template =~ s/<yabb onlineguests>/$guestlist/g;
	$boardindex_template =~ s/<yabb mostmembers>/$themostmemb/g;
	$boardindex_template =~ s/<yabb mostguests>/$themostguest/g;
	$boardindex_template =~ s/<yabb mostusers>/$themostuser/g;
	$boardindex_template =~ s/<yabb mostmembersdate>/$themostmembdate/g;
	$boardindex_template =~ s/<yabb mostguestsdate>/$themostguestdate/g;
	$boardindex_template =~ s/<yabb mostusersdate>/$themostuserdate/g;
	$boardindex_template =~ s/<yabb groupcolors>/$grpcolors/g;
	$boardindex_template =~ s/<yabb sharedlogin>/$shared_login/g;

	$yymain .= qq~$boardindex_template~;

#	if ( $snark_enable ) {
#		require "$sourcedir/Snark.pl" if not $loaded{'Snark.pl'};
#		$yymain .= 	qq(<div class="huntlog" ><div class="windowbg" ><div class="catbg"><a href="$scripturl?action=huntlog" >$snark_txt{'bi_huntlog'}</a></div>) .
#				join ( q(<br />), huntlog_get ( qr/(kill|revive|bomb|patrick|tristar|rlsaber|esca|boyan|giggle|watch)/, 5 ) ) .
#				q(</div></div>);
#		$yyinlinestyle .= qq(<link rel="stylesheet" href="$forumstylesurl/default/snark.css" type="text/css" />);
#	}

	if ($imnewcount > 0) {
		if ($imnewcount > 1) { $en = "s"; $en2 = "$boardindex_imtxt{'47'}"; }
		else { $en = ""; $en2 = "$boardindex_imtxt{'48'}"; }

		chomp(${$uid.$username}{'im_imspop'});
		chomp(${$uid.$username}{'im_popup'});

		if (${$uid.$username}{'im_popup'} eq "on") {
			if (${$uid.$username}{'im_imspop'} eq "on") {
				$yymain .= qq~
	<script language="JavaScript" type="text/javascript">
	function rimpu() { window.open("$scripturl?action=im") }
	function cancel () { }
	</script>~;
			} else {
				$yymain .= qq~
	<script language="JavaScript" type="text/javascript">
	function rimpu() { location.href = ("$scripturl?action=im") }
	function cancel () { }
	</script>~;
			}

			$yymain .= qq~
	<script language="JavaScript" type="text/javascript">
	<!-- BEGIN
		if (confirm("$boardindex_imtxt{'14'} $imnewcount$boardindex_imtxt{'15'}?")) { rimpu(); } else cancel()
	// END -->
	</script>
		~;
		}
	}

	if ($userimcfg[5] eq "on") {
		$yymain .= qq~<script language="javascript" type="text/javascript"> function viewinstant() { window.open("$scripturl?action=im") } </script>~;
	} else {
		$yymain .= qq~<script language="javascript" type="text/javascript"> function viewinstant() { location.href = ("$scripturl?action=im") } </script>~;
	}

	$yytitle = "$boardindex_txt{'18'}";
	&template;
	exit;
}

sub Collapse_Write {
	my @userhide;

	# rewrite the category hash for the user
	foreach my $key (@categoryorder) {
		my ($catname, $catperms, $catallowcol) = split(/\|/, $catinfo{$key});
		$access = &CatAccess($catperms);
		if ($catcol{$key} == 0 && $access) { push(@userhide, $key); }
	}
	${$uid.$username}{'cathide'} = join(",", @userhide);
	&UserAccount($username, "update");
	if (-e "$memberdir/$username.cat") { unlink "$memberdir/$username.cat"; }
}

sub Collapse_Cat {
	if ($iamguest) { &fatal_error($boardindex_exptxt{'4'}); }
	my $changecat = $INFO{'cat'};
	unless ($colloaded) { &Collapse_Load; }

	if ($catcol{$changecat} eq 1) {
		$catcol{$changecat} = 0;
	} else {
		$catcol{$changecat} = 1;
	}
	&Collapse_Write;
	$yySetLocation = qq~$scripturl~;
	&redirectexit;
}

sub Collapse_All {
	my ($state, @catstatus);
	$state = $INFO{'status'};

	if ($iamguest) { &fatal_error($boardindex_exptxt{'4'}); }
	if ($state != 1 && $state != 0) { &fatal_error($boardindex_exptxt{'7'}); }

	foreach my $key (@categoryorder) {
		my ($catname, $catperms, $catallowcol) = split(/\|/, $catinfo{$key});
		if ($catallowcol eq '1') {
			$catcol{$key} = $state;
		} else {
			$catcol{$key} = 1;
		}
	}
	&Collapse_Write;

	$yySetLocation = qq~$scripturl~;
	&redirectexit;
}

sub MarkAllRead {
	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }

  CAT: foreach my $catid (@categoryorder) {
		if ($INFO{'cat'} ne '') {
			if ($INFO{'cat'} eq $catid) {
				$boardlist = $cat{$catid};
				(@bdlist) = split(/\,/, $boardlist);
				($catname, $catperms) = split(/\|/, $catinfo{"$catid"});

				# Category Permissions Check
				$cataccess = &CatAccess($catperms);
				if (!$cataccess) { next; }
			  BOARD: foreach $curboard (@bdlist) {
					chomp $curboard;
					&modlog("$curboard--mark");
					&modlog($curboard);

					next BOARD;
				}
				last CAT;
			} else {
				next CAT;
			}
		} else {
			$boardlist = $cat{$catid};
			(@bdlist) = split(/\,/, $boardlist);
			($catname, $catperms) = split(/\|/, $catinfo{"$catid"});

			# Category Permissions Check
			$cataccess = &CatAccess($catperms);
			if (!$cataccess) { next; }
		  BOARD: foreach $curboard (@bdlist) {
				chomp $curboard;
				&modlog("$curboard--mark");
				&modlog($curboard);
				next BOARD;
			}
		}
	}
	&dumplog;
	$yySetLocation = qq~$scripturl~;
	&redirectexit;
}

sub gostRemove {
	$thecat    = $_[0];
	$gostboard = $_[1];
	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }
	(@gbdlist) = split(/\,/, $cat{$thecat});
	$tmp_master = "";
	foreach $item (@gbdlist) {
		if ($item ne $gostboard) {
			$tmp_master .= qq~$item,~;
		}
	}
	$tmp_master =~ s/,\Z//;
	$cat{$thecat} = qq~$tmp_master~;
	&Write_ForumMaster;
}

1;

