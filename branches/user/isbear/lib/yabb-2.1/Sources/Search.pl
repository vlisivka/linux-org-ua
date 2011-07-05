###############################################################################
# Search.pl                                                                   #
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

$searchplver = 'YaBB 2.1 $Revision: 1.2 $';
if ($action eq 'detailedversion') { return 1; }

LoadLanguage("Search");


sub plushSearch1 {
	# generate error if admin has disabled search options
	if ($maxsearchdisplay < 0) { &fatal_error($floodtxt{'8'}); }
	my (@categories, $curcat, %catname, %cataccess, %catboards, $openmemgr, @membergroups, $tmpa, %openmemgr, $curboard, @threads, @boardinfo, $counter);

	&LoadCensorList;
	if (!$iamguest) {
		&Collapse_Load;
	}
	$searchpageurl = qq~<a href="$scripturl?action=search" class="nav">$search_txt{'182'}</a>~;
	$yymain .= qq~
<script language="JavaScript1.2" src="$ubbcjspath" type="text/javascript"></script>
<span class="small"><b><a href="$scripturl" class="nav">$mbname</a> &rsaquo; $searchpageurl</b></span>
<form action="$scripturl?action=search2" method="post" name="searchform" onsubmit="return submitproc()">
<table width="100%" align="center" border="0" cellpadding="4" cellspacing="1" class="bordercolor" >
  <tr>
    <td align="left" colspan="2" class="catbg">
		<img src="$imagesdir/search.gif" alt="" /> <span class="text1"><b>$search_txt{'183'}</b></span>
    </td>
  </tr><tr>
        <td class="windowbg" width="50%"><b>$search_txt{'582'}:</b></td>
        <td class="windowbg2" width="50%">
        <input type="text" size="30" name="search" />&nbsp;
        <select name="searchtype">
         <option value="allwords" selected="selected">$search_txt{'343'}</option>
         <option value="anywords">$search_txt{'344'}</option>
         <option value="asphrase">$search_txt{'345'}</option>
         <option value="aspartial">$search_txt{'345a'}</option>
        </select>
       </td>
      </tr><tr>
        <td class="windowbg"><b>$search_txt{'583'}:</b></td>
        <td class="windowbg2">
        <input type="text" size="30" name="userspec" />&nbsp;
        <select name="userkind">
         <option value="any">$search_txt{'577'}</option>
         <option value="starter">$search_txt{'186'}</option>
         <option value="poster">$search_txt{'187'}</option>
         <option value="noguests" selected="selected">$search_txt{'346'}</option>
         <option value="onlyguests">$search_txt{'572'}</option>
        </select>
        </td>
      </tr><tr>
        <td class="windowbg" valign="top"><b>$search_txt{'189'}:</b><br />$search_txt{'190'}</td>
        <td class="windowbg2" >~;
	$allselected = 0;
	$isselected  = 0;
	$boardscheck = "";
	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }

	foreach $catid (@categoryorder) {
		$boardlist = $cat{$catid};
		(@bdlist) = split(/\,/, $boardlist);
		($catname, $catperms) = split(/\|/, $catinfo{"$catid"});
		$cataccess = &CatAccess($catperms);
		if (!$cataccess) { next; }

		foreach $curboard (@bdlist) {
			($boardname, $boardperms, $boardview) = split(/\|/, $board{"$curboard"});
			&ToChars($boardname);
			my $access = &AccessCheck($curboard, '', $boardperms);
			if (!$iamadmin && $access ne "granted") { next; }

			# Checks to see if category is expanded or collapsed
			if ($username ne "Guest") {
				if ($catcol{$catid}) {
					$selected = qq~selected="selected"~;
					$isselected++;
				} else {
					$selected = "";
				}
			} else {
				$selected = qq~selected="selected"~;
				$isselected++;
			}
			$allselected++;
			$checklist .= qq~<option value="$curboard" $selected>$boardname</option>\n          ~;
		}
	}
	if ($isselected == $allselected) { $boardscheck = qq~ checked="checked"~; }
	$yymain .= qq~
          <select multiple="multiple" name="searchboards" size="5" onchange="selectnum();">
          $checklist</select>
		<input type="checkbox" name="srchAll" id="srchAll"$boardscheck onclick="if (this.checked) searchAll(true); else searchAll(false);" /> <label for="srchAll">$search_txt{'737'}</label>
		<script language="JavaScript1.2" type="text/javascript">
		<!-- //
		function searchAll(_v) {
			for(var i=0;i<document.searchform.searchboards.length;i++)
			document.searchform.searchboards[i].selected=_v;
		}

		function selectnum() {
			document.searchform.srchAll.checked = true;
			for(var i=0;i<document.searchform.searchboards.length;i++) {
				if (! document.searchform.searchboards[i].selected) { document.searchform.srchAll.checked = false; }
			}
		}
		// -->
		</script>
        </td>
      </tr><tr>
        <td class="windowbg"><b>$search_txt{'573'}:</b></td>
        <td class="windowbg2">
		  <input type="checkbox" name="subfield" id="subfield" value="on" checked="checked" /><label for="subfield"> $search_txt{'70'}</label> &nbsp;
          <input type="checkbox" name="msgfield" id="msgfield" value="on" checked="checked" /><label for="msgfield"> $search_txt{'72'}</label>
        </td>
	</tr><tr>
        <td class="windowbg"><b>$search_txt{'1'}</b></td>
        <td class="windowbg2">
		<select name="age">
          <option value="7" selected="selected">$search_txt{'2'}</option>
          <option value="31">$search_txt{'3'}</option>
          <option value="92">$search_txt{'4'}</option>
          <option value="365">$search_txt{'5'}</option>
          <option value="0">$search_txt{'6'}</option>
		</select>
        </td>
      </tr><tr>
        <td class="windowbg" ><b>$search_txt{'191'}</b></td>
        <td class="windowbg2" >
        <input type="text" size="5" name="numberreturned" maxlength="5" value="$maxsearchdisplay" /></td>
      </tr><tr>
        <td class="windowbg"><label for="oneperthread"><b>$search_txt{'191a'}</b></label></td>
        <td class="windowbg2">
        <input type="checkbox" name="oneperthread" id="oneperthread" value="1"/></td>
      </tr><tr>
        <td class="catbg" colspan="2" height="50" valign="middle" align="center">
        <input type="hidden" name="action" value="dosearch" />
        <input type="submit" name="submit" value="$search_txt{'182'}" />
       </td>
   </tr>
</table>
</form>
<script type="text/javascript" language="JavaScript"> <!--
	document.searchform.search.focus();
//--> </script>
~;
	$yytitle = $search_txt{'183'};
	&template;
	exit;
}

sub plushSearch2 {

	# generate error if admin has disabled search options
	if ($maxsearchdisplay < 0) { &fatal_error($floodtxt{'8'}); }
	&spam_protection;
	my $forumage = &stringtotime($forumstart);
	$forumage = int(($date - $forumage) / 86400);
	my $maxage = $FORM{'age'} || $forumage;

	my $display = $FORM{'numberreturned'} || 25;
	if ($maxage  =~ /\D/) { &fatal_error($search_txt{'337'}); }
	if ($display =~ /\D/) { &fatal_error($search_txt{'337'}); }

	# restrict flooding using form abuse
	if ($display > $maxsearchdisplay) { &fatal_error($floodtxt{'7'}); }

	my $userkind = $FORM{'userkind'};
	my $userspec = $FORM{'userspec'};
	if    ($userkind eq 'starter')    { $userkind = 1; }
	elsif ($userkind eq 'poster')     { $userkind = 2; }
	elsif ($userkind eq 'noguests')   { $userkind = 3; }
	elsif ($userkind eq 'onlyguests') { $userkind = 4; }
	else { $userkind = 0; $userspec = ''; }
	if ($userspec =~ m~/~)  { &fatal_error($search_txt{'224'}); }
	if ($userspec =~ m~\\~) { &fatal_error($search_txt{'225'}); }
	$userspec =~ s/\A\s+//;
	$userspec =~ s/\s+\Z//;
	$userspec =~ s/[^0-9A-Za-z#%+,-\.@^_]//g;

	my $searchtype = $FORM{'searchtype'};
	my $search     = $FORM{'search'};
	&FromChars($search);
	my $one_per_thread = $FORM{'oneperthread'} || 0;
	if    ($searchtype eq 'anywords')  { $searchtype = 2; }
	elsif ($searchtype eq 'asphrase')  { $searchtype = 3; }
	elsif ($searchtype eq 'aspartial') { $searchtype = 4; }
	else { $searchtype = 1; }
	if ($search eq "" || $search eq " ") { &fatal_error($search_txt{'754'}); }
	if ($search =~ m~/~)  { &fatal_error($search_txt{'397'}); }
	if ($search =~ m~\\~) { &fatal_error($search_txt{'397'}); }
	my $searchsubject = $FORM{'subfield'} eq 'on';
	my $searchmessage = $FORM{'msgfield'} eq 'on';
	require "$sourcedir/Decoder.pl";
	&scrambled($search);

	$search =~ s/\A\s+//;
	$search =~ s/\s+\Z//;
	&ToHTML($search);
	$search =~ s/\t/ \&nbsp; \&nbsp; \&nbsp;/g;
	$search =~ s/\cM//g;
	$search =~ s/\n/<br \/>/g;
	if ($searchtype != 3) { @search = split(/\s+/, lc $search); }
	else { @search = (lc $search); }

	my ($curboard, @threads, $curthread, $tnum, $tsub, $tname, $temail, $tdate, $treplies, $tusername, $ticon, $tstate, $ttime, @messages, $curpost, $mtime, $mname, $memail, $mdate, $musername, $micon, $mattach, $mip, $mns, $subfound, $msgfound, $numfound, %data, $i, $board, $curcat, @categories, %catname, %catid, %boardname, %cataccess, %openmemgr, @membergroups, %cats, @boardinfo, %boardinfo, @boards, $counter, $msgnum);
	my $curtime = time + (3600 * ${$uid.$tusername}{'timeoffset'});
	my $maxtime     = $curtime - (($maxage * 86400) + 1);
	my $oldestfound = "01/10/37 $search_txt{'107'} 00:00:00";

	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }
	foreach $catid (@categoryorder) {
		$boardlist = $cat{$catid};
		(@bdlist) = split(/\,/, $boardlist);
		($catname, $catperms) = split(/\|/, $catinfo{"$catid"});
		$cataccess = &CatAccess($catperms);
		if (!$cataccess) { next; }

		foreach $cboard (@bdlist) {
			($bname, $bperms, $bview) = split(/\|/, $board{"$cboard"});
			$catname{$cboard} = $catname;
			$catid{$cboard} = $catid;
		}
	}

	@boards = split(/\,\ /, $FORM{'searchboards'});
  boardcheck: foreach $curboard (@boards) {
		($boardname{$curboard}, $boardperms, $boardview) = split(/\|/, $board{"$curboard"});

		my $access = &AccessCheck($curboard, '', $boardperms);
		if (!$iamadmin && $access ne "granted") { next; }

		fopen(FILE, "$boardsdir/$curboard.txt") || next;
		@threads = <FILE>;
		fclose(FILE);

	  threadcheck: foreach $curthread (@threads) {
			chomp $curthread;

			($tnum, $tsub, $tname, $temail, $tdate, $treplies, $tusername, $ticon, $tstate) = split(/\|/, $curthread);

			if ($tsttate =~ /m/i || (!$iamadmin && !$iamgmod && $tstate =~ /h/i)) {
				next threadcheck;
			}
			if ($userkind == 1) {
				if ($tusername eq 'Guest') {
					if ($tname !~ m~\A\Q$userspec\E\Z~i) { next threadcheck; }
				} else {
					if ($tusername !~ m~\A\Q$userspec\E\Z~i) { next threadcheck; }
				}
			}
			$ttime = $tdate;
			unless ($ttime > $maxtime) { next threadcheck; }
			fopen(FILE, "$datadir/$tnum.txt") || next;
			@messages = <FILE>;
			fclose(FILE);

		  postcheck: for ($msgnum = @messages; $msgnum >= 0; $msgnum--) {
				$curpost = $messages[$msgnum];
				chomp $curpost;

				($msub, $mname, $memail, $mdate, $musername, $micon, $mattach, $mip, $message, $mns) = split(/\|/, $curpost);
				$mtime = $mdate;
				if ($numfound >= $display && $mtime <= $oldestfound) { next postcheck; }
				if ($musername eq 'Guest') {
					if ($userkind == 3 || ($userkind == 2 && $mname !~ m~\A\Q$userspec\E\Z~i)) { next postcheck; }
				} else {
					if ($userkind == 4 || ($userkind == 2 && $musername !~ m~\A\Q$userspec\E\Z~i)) { next postcheck; }
				}

				if ($searchsubject) {
					if ($searchtype == 2 || $searchtype == 4) {
						$subfound = 0;
						foreach (@search) {
							if ($searchtype == 4 && $msub =~ m~\Q$_\E~i) { $subfound = 1; last; }
							elsif ($msub =~ m~(^|\W|_)\Q$_\E(?=$|\W|_)~i) { $subfound = 1; last; }
						}
					} else {
						$subfound = 1;
						foreach (@search) {
							if ($msub !~ m~(^|\W|_)\Q$_\E(?=$|\W|_)~i) { $subfound = 0; last; }
						}
					}
				}
				if ($searchmessage && !$subfound) {
					if ($searchtype == 2 || $searchtype == 4) {
						$msgfound = 0;
						foreach (@search) {
							if ($searchtype == 4 && $message =~ m~\Q$_\E~i) { $msgfound = 1; last; }
							elsif ($message =~ m~(^|\W|_)\Q$_\E(?=$|\W|_)~i) { $msgfound = 1; last; }
						}
					} else {
						$msgfound = 1;
						foreach (@search) {
							if ($message !~ m~(^|\W|_)\Q$_\E(?=$|\W|_)~i) { $msgfound = 0; last; }
						}
					}
				}
				unless ($msgfound || $subfound) { next postcheck; }
				$data{$mtime} = [$curboard, $tnum, $msgnum, $tusername, $tname, $msub, $mname, $memail, $mdate, $musername, $micon, $mattach, $mip, $message, $mns, $tstate];
				if ($mtime < $oldestfound) { $oldestfound = $mtime; }
				++$numfound;
				if ($one_per_thread) { last postcheck; }
			}
		}
	}

	@messages = sort { $b <=> $a } keys %data;
	if (@messages) {
		if (@messages > $display) { $#messages = $display - 1; }
		$counter = 1;
		&LoadCensorList;
	} else {
		$yymain .= qq~<hr class="hr" /><b>$search_txt{'170'}</b><hr />~;
	}
	$search = &Censor($search);

	# Search for censored or uncencored search string and remove duplicate words
	my @tmpsearch;
	if ($searchtype == 3) { @tmpsearch = (lc $search); }
	else { @tmpsearch = split(/\s+/, lc $search); }
	push @tmpsearch, @search;
	undef %found;
	@search = grep(!$found{$_}++, @tmpsearch);

	for ($i = 0; $i < @messages; $i++) {
		($board, $tnum, $msgnum, $tusername, $tname, $msub, $mname, $memail, $mdate, $musername, $micon, $mattach, $mip, $message, $mns, $tstate) = @{ $data{ $messages[$i] } };
		$displayname = $mname;

		if ($tusername ne 'Guest' && -e ("$memberdir/$tusername.vars")) { &LoadUser($tusername); }
		if (${$uid.$tusername}{'regtime'}) {
			$registrationdate = ${$uid.$tusername}{'regtime'};
		} else {
			$registrationdate = int(time);
		}
		if (${$uid.$tusername}{'regdate'} && $tnum > $registrationdate) {
			$tname = qq~<a href="$scripturl?action=viewprofile;username=$tusername">${$uid.$tusername}{'realname'}</a>~;
		} elsif ($tusername !~ m~Guest~ && $tnum < $registrationdate) {
			$tname = qq~$tusername - $maintxt{'470a'}~;
		} else {
			$tname .= " ($maintxt{'28'})";
		}

		if ($musername ne 'Guest' && -e ("$memberdir/$musername.vars")) { &LoadUser($musername); }
		if (${$uid.$musername}{'regtime'}) {
			$registrationdate = ${$uid.$musername}{'regtime'};
		} else {
			$registrationdate = int(time);
		}
		if (${$uid.$musername}{'regdate'} && $mdate > $registrationdate) {
			$mname = qq~<a href="$scripturl?action=viewprofile;username=$musername">${$uid.$musername}{'realname'}</a>~;
		} elsif ($musername !~ m~Guest~ && $mdate < $registrationdate) {
			$mname = qq~$musername - $maintxt{'470a'}~;
		} else {
			$mname .= " ($maintxt{'28'})";
		}

		$mdate = &timeformat($mdate);

		$message = &Censor($message);
		$msub    = &Censor($msub);

		# Highlight search strings in Subject heading
		foreach $tmp (@search) {
			if ($searchtype == 4) { $msub =~ s~(\Q$tmp\E)~<span class="highlight"><b>$1</b></span>~ig; }
			else { $msub =~ s~(^|\W|_)(\Q$tmp\E)(?=$|\W|_)~$1<span class="highlight"><b>$2</b></span>$3~ig; }
		}

		&wrap;

		if ($enable_ubbc) {
			$ns = $mns;
			if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; }
			&DoUBBC;
		}
		&wrap2;

		if ($enable_notification) {
			$notify = qq~$menusep<a href="$scripturl?board=$board;action=notify;thread=$tnum/$msgnum#$msgnum">$img{'notify'}</a>~;
		}
		&ToChars($msub);
		&ToChars($message);
		&ToChars($catname{$board});
		&ToChars($boardname{$board});

		# Change [m] to Moved:
#		$msub =~ s/\A\[m\]/$maintxt{'758'}/;

		$yymain .= qq~
<table border="0" width="100%" cellspacing="1" class="bordercolor" style="table-layout: fixed;">
  <tr>
    <td align="center" width="5%" class="titlebg"><span class="text1">&nbsp;$counter&nbsp;</span></td>
    <td align="left" width="95%" class="titlebg"><a href="$scripturl?catselect=$catid{$board}">&nbsp;$catname{$board}</a> / <a href="$scripturl?board=$board">$boardname{$board}</a> / <a href="$scripturl?num=$tnum/$msgnum#$msgnum">$msub</a><br />
    &nbsp;<span class="small">$search_txt{'30'}: $mdate</span></td>
  </tr><tr>
    <td align="left" colspan="2" class="catbg"><span class="catbg">$search_txt{'109'} $tname | $search_txt{'105'} $search_txt{'525'} $mname</span></td>
  </tr><tr>
    <td align="left" height="80" colspan="2" class="windowbg2" valign="top"><span class="message">$message</span></td>
  </tr><tr>
    <td align="right" colspan="2" class="catbg">&nbsp;
~;
		if ($tstate != 1) {
			$yymain .= qq~<a href="$scripturl?board=$board;action=post;num=$tnum/$msgnum#$msgnum;title=PostReply">$img{'reply'}</a>$menusep<a href="$scripturl?board=$board;action=post;num=$tnum;quote=$msgnum;title=PostReply">$img{'recentquote'}</a>$notify &nbsp;~;
		}
		$yymain .= qq~
    </td>
  </tr>
</table><br />
~;
		++$counter;
	}

	$yymain .= qq~
$search_txt{'167'}<hr class="hr" />
<span class="small"><a href="$scripturl">$search_txt{'236'}</a> $search_txt{'237'}<br /></span>~;
	$yytitle = $search_txt{'166'};
	&template;
	exit;
}

1;
