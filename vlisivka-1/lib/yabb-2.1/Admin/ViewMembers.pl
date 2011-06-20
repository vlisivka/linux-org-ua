###############################################################################
# ViewMembers.pl                                                              #
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

$viewmembersplver = 'YaBB 2.1 $Revision: 1.3 $';
if ($action eq 'detailedversion') { return 1; }

LoadLanguage("Main");

if ($iamguest) { &admin_fatal_error("$ml_txt{'223'}"); }

my ($sortmode, $sortorder);

$MembersPerPage = $TopAmmount;
$maxbar         = 100;

if (!$barmaxnumb) { $barmaxnumb = 500; }
if ($barmaxdepend == 1) {
	$barmax = 1;
	&ManageMemberinfo("load");
	while (($key, $value) = each(%memberinf)) {
		(undef, undef, undef, $memposts) = split(/\|/, $value);
		if ($memposts > $barmax) { $barmax = $memposts; }
	}
	undef %memberinf;
} else {
	$barmax = $barmaxnumb;
}

if ($FORM{'sortform'} eq "username" || $INFO{'sort'} eq "mlletter" || $INFO{'sort'} eq "username") {
	$page     = "a";
	$showpage = "A";
	while ($page ne "z") {
		$LetterLinks .= qq(<a href="$adminurl?action=memlist;sort=mlletter;letter=$page">$showpage&nbsp;</a> );
		$page++;
		$showpage++;
	}
	$LetterLinks .= qq~<a href="$adminurl?action=memlist;sort=mlletter;letter=z">Z</a>  <a href="$adminurl?action=memlist;sort=mlletter;letter=other">$ml_txt{'800'}</a> ~;
}

if ($INFO{'start'} eq "") { $start = 0; }
else { $start = "$INFO{'start'}"; }
if ($FORM{'sortform'} eq "posts"      || $INFO{'sort'} eq "posts")      { $selPost     .= qq~ selected="selected"~; }
if ($FORM{'sortform'} eq "regdate"    || $INFO{'sort'} eq "regdate")    { $selReg      .= qq~ selected="selected"~; }
if ($FORM{'sortform'} eq "position"   || $INFO{'sort'} eq "position")   { $selPos      .= qq~ selected="selected"~; }
if ($FORM{'sortform'} eq "lastonline" || $INFO{'sort'} eq "lastonline") { $selLastOn   .= qq~ selected="selected"~; }
if ($FORM{'sortform'} eq "lastpost"   || $INFO{'sort'} eq "lastpost")   { $selLastPost .= qq~ selected="selected"~; }
if ($FORM{'sortform'} eq "lastim"     || $INFO{'sort'} eq "lastim")     { $selLastIm   .= qq~ selected="selected"~; }
if ($INFO{'sort'} eq "" || $INFO{'sort'} eq "mlletter" || $INFO{'sort'} eq "username") { $selUser .= qq~ selected="selected"~; }
if ($INFO{'reversed'} || $FORM{'reversed'}) { $selReversed = qq~checked='checked'~; $sortorder = ";order=on"; }

if    ($INFO{'sort'}     ne "") { $sortmode = ";sort=" . $INFO{'sort'}; }
elsif ($FORM{'sortform'} ne "") { $sortmode = ";sort=" . $FORM{'sortform'}; }

$TableHeader .= qq~
<table border="0" width="100%" cellspacing="1" cellpadding="3" class="bordercolor">
  <tr>
    <td width="100%" valign="middle" class="titlebg">
    <span style="float: left;"><img src="$imagesdir/register.gif" alt="" border="0" style="vertical-align: middle;" /><b> $admintxt{'17'}</b></span>
    <span style="float: right;">
    <b>$ml_txt{'1'}</b>
    <form action="$adminurl?action=memlist" method="post" name="selsort" style="display: inline">
    <select name="sortform" style="font-size: 9pt;" onchange="submit()">
    <option value="username"$selUser>$ml_txt{'35'}</option>
    <option value="position"$selPos>$ml_txt{'87'}</option>
    <option value="posts"$selPost>$ml_txt{'21'}</option>
    <option value="regdate"$selReg>$ml_txt{'233'}</option>
    <option value="lastonline"$selLastOn>$amv_txt{'9'}</option>
    <option value="lastpost"$selLastPost>$amv_txt{'10'}</option>
    <option value="lastim"$selLastIm>$amv_txt{'11'}</option>
    </select>
    <b>$admintxt{'37'}</b>
    <input type="checkbox" onclick="submit()" name="reversed" id="reversed" class="titlebg" style="border: 0;" $selReversed />
    </form>
    </span>
	</td>
  </tr>
</table>
<script language="JavaScript1.2" src="$ubbcjspath" type="text/javascript"></script>
<script language="JavaScript1.2" type="text/javascript">
<!--
if (document.selsort.sortform.options[document.selsort.sortform.selectedIndex].value == 'username') {
document.selsort.reversed.disabled = true;
}
//-->
</script>

<form name="adv_memberview" action="$adminurl?action=deletemultimembers;$sortmode$sortorder" method="POST" style="display: inline" onSubmit="return submitproc()">
<input type="hidden" name="button" value="0" />
<table border="0" width="100%" cellspacing="1" cellpadding="3" class="bordercolor">
<tr>
	<td class="catbg" width="19%" align="center"><b>$ml_txt{'35'}</b></td>
	<td class="catbg" width="19%" align="center"><b>$ml_txt{'87'}</b></td>
	<td class="catbg" width="19%" align="center" colspan="2"><b>$ml_txt{'21'}</b></td>
	<td class="catbg" width="19%" align="center"><b>$ml_txt{'234'}</b></td>
	<td class="catbg" width="19%" align="center" colspan="3"><b>$amv_txt{'4'}</b><br /><span class="small" style="float: left; text-align: center; width: 34%;">$amv_txt{'5'}</span><span class="small" style="float: left; text-align: center; width: 33%;">$amv_txt{'6'}</span><span class="small" style="float: left; text-align: center; width: 33%;">$amv_txt{'7'}</span></td>
	<td class="catbg" width="5%" align="center"><b>$admintxt{'38'}</b></td>
</tr>
~;

if ($LetterLinks ne "") {
	$TableHeader .= qq~<tr>
		<td class="catbg" colspan="9"><b>$LetterLinks</b></td>
	</tr>
	~;
}

$TableFooter = qq~</table>~;

if ($FORM{'sortform'} eq "posts"      || $INFO{'sort'} eq "posts")      { &MLTop; }
if ($FORM{'sortform'} eq "regdate"    || $INFO{'sort'} eq "regdate")    { &MLDate; }
if ($FORM{'sortform'} eq "position"   || $INFO{'sort'} eq "position")   { &MLPosition; }
if ($FORM{'sortform'} eq "lastonline" || $INFO{'sort'} eq "lastonline") { &MLLastOnline; }
if ($FORM{'sortform'} eq "lastpost"   || $INFO{'sort'} eq "lastpost")   { &MLLastPost; }
if ($FORM{'sortform'} eq "lastim"     || $INFO{'sort'} eq "lastim")     { &MLLastIm; }
if ($INFO{'sort'} eq "" || $INFO{'sort'} eq "mlletter" || $INFO{'sort'} eq "username") { &MLByLetter; }

sub MLLastPost {
	if ($iamguest) { &admin_fatal_error("$ml_txt{'223'}"); }
	$yymain .= qq~$TableHeader~;
	%TopMembers = ();
	&ManageMemberinfo("load");
	while (($membername, $value) = each(%memberinf)) {
		&LoadUser($membername);
		$TopMembers{$membername} = ${$uid.$membername}{'lastpost'};
		undef %{ $uid . $membername };
	}
	undef %memberinf;

	my @toplist = sort { $TopMembers{$b} <=> $TopMembers{$a} } keys %TopMembers;
	undef %TopMembers;

	$memcount = @toplist;

	$start = $start > $memcount - 1 ? $memcount - 1 : $start;
	$start = (int($start / $MembersPerPage)) * $MembersPerPage;

	$b         = $start;
	$numshown  = 0;
	$actualnum = 0;

	if ($FORM{'reversed'} || $INFO{'reversed'}) {
		@toplist = reverse @toplist;
	}

	while (($numshown < $MembersPerPage)) {
		&showRows($toplist[$b]);
		$numshown++;
		$b++;
	}
	undef @toplist;

	$yymain .= qq~$TableFooter~;
	&buildPages;
	$yytitle     = "$ml_txt{'313'} $TopAmmount $ml_txt{'314'}";
	$action_area = "viewmembers";
	&AdminTemplate;
	exit;
}

sub MLLastIm {
	if ($iamguest) { &admin_fatal_error("$ml_txt{'223'}"); }
	$yymain .= qq~$TableHeader~;
	%TopMembers = ();

	&ManageMemberinfo("load");
	while (($membername, $value) = each(%memberinf)) {
		&LoadUser($membername);
		$TopMembers{$membername} = ${$uid.$membername}{'lastim'};
		undef %{ $uid . $membername };
	}
	undef %memberinf;

	my @toplist = sort { $TopMembers{$b} <=> $TopMembers{$a} } keys %TopMembers;
	undef %TopMembers;

	$memcount = @toplist;

	$start = $start > $memcount - 1 ? $memcount - 1 : $start;
	$start = (int($start / $MembersPerPage)) * $MembersPerPage;

	$b         = $start;
	$numshown  = 0;
	$actualnum = 0;

	if ($FORM{'reversed'} || $INFO{'reversed'}) {
		@toplist = reverse @toplist;
	}

	while (($numshown < $MembersPerPage)) {
		&showRows($toplist[$b]);
		$numshown++;
		$b++;
	}
	undef @toplist;

	$yymain .= qq~$TableFooter~;
	&buildPages;
	$yytitle     = "$ml_txt{'313'} $TopAmmount $ml_txt{'314'}";
	$action_area = "viewmembers";
	&AdminTemplate;
	exit;
}

sub MLLastOnline {
	if ($iamguest) { &admin_fatal_error("$ml_txt{'223'}"); }
	$yymain .= qq~$TableHeader~;
	%TopMembers = ();

	&ManageMemberinfo("load");
	while (($membername, $value) = each(%memberinf)) {
		&LoadUser($membername);
		$TopMembers{$membername} = ${$uid.$membername}{'lastonline'};
		undef %{ $uid . $membername };
	}
	undef %memberinf;

	my @toplist = sort { $TopMembers{$b} <=> $TopMembers{$a} } keys %TopMembers;
	undef %TopMembers;

	$memcount = @toplist;

	$start = $start > $memcount - 1 ? $memcount - 1 : $start;
	$start = (int($start / $MembersPerPage)) * $MembersPerPage;

	$b         = $start;
	$numshown  = 0;
	$actualnum = 0;

	if ($FORM{'reversed'} || $INFO{'reversed'}) {
		@toplist = reverse @toplist;
	}

	while (($numshown < $MembersPerPage)) {
		&showRows($toplist[$b]);
		$numshown++;
		$b++;
	}
	undef @toplist;

	$yymain .= qq~$TableFooter~;
	&buildPages;
	$yytitle     = "$ml_txt{'313'} $TopAmmount $ml_txt{'314'}";
	$action_area = "viewmembers";
	&AdminTemplate;
	exit;
}

sub MLByLetter {
	if ($iamguest) { &admin_fatal_error("$ml_txt{'223'}"); }
	$yymain .= qq~$TableHeader~;

	$letter = lc($INFO{'letter'});

	&ManageMemberinfo("load");
	while (($membername, $value) = each(%memberinf)) {
		($memrealname, $mememail, undef, undef) = split(/\|/, $value);

		$memrealname ||= $membername;
		if ($letter) {
			$SearchName = lc(substr($memrealname, 0, 1));
			if ($SearchName eq $letter) {
				$BigSort{$membername} = $memrealname;
			} elsif ($letter eq "other" && (($SearchName lt "a") || ($SearchName gt "z"))) {
				$BigSort{$membername} = $memrealname;
			}
		} else {
			$BigSort{$membername} = $memrealname;
		}
	}
	undef %memberinf;

	$memcount = @ToShow;
	if ($memcount) {
		@ToShow = sort { uc($a) cmp uc($b) } @ToShow;

	} else {
		@ToShow = sort { lc $BigSort{$a} cmp lc $BigSort{$b} } keys %BigSort;
		undef %BigSort;
		$memcount = @ToShow;

	}
	$start = $start > $memcount - 1 ? $memcount - 1 : $start;
	$start = (int($start / $MembersPerPage)) * $MembersPerPage;

	$b         = $start;
	$numshown  = 0;
	$actualnum = 0;

	if ($memcount) {
		while (($numshown < $MembersPerPage)) {
			&showRows($ToShow[$b]);
			$numshown++;
			$b++;
		}
	} else {
		if ($letter) { $yymain .= qq~ <td class="windowbg" colspan="8" align="center"><br /><b>$ml_txt{'760'}</b><br /><br /></td>~; }
	}
	undef @ToShow;

	$yymain .= qq~$TableFooter~;
	&buildPages;
	$yytitle     = "$ml_txt{'312'}";
	$action_area = "viewmembers";
	&AdminTemplate;
	exit;
}

sub MLTop {
	if ($iamguest) { &admin_fatal_error("$ml_txt{'223'}"); }
	%top_list = ();

	&ManageMemberinfo("load");
	while (($membername, $value) = each(%memberinf)) {
		($memrealname, undef, undef, $memposts) = split(/\|/, $value);
		$memposts = sprintf("%06d", (999999 - $memposts));
		$top_list{$membername} = qq~$memposts|$memrealname~;
	}
	undef %memberinf;

	my @toplist = sort { lc $top_list{$a} cmp lc $top_list{$b} } keys %top_list;

	if ($FORM{'reversed'} || $INFO{'reversed'}) {
		@toplist = reverse @toplist;
	}

	$memcount = @toplist;

	$yymain .= qq~$TableHeader~;

	$b         = $start;
	$numshown  = 0;
	$actualnum = 0;

	while ($numshown < $MembersPerPage) {
		&showRows($toplist[$b]);
		$numshown++;
		$b++;
	}
	undef @toplist;
	$yymain .= qq~$TableFooter~;
	&buildPages;
	$yytitle     = "$ml_txt{'313'} $TopAmmount $ml_txt{'314'}";
	$action_area = "viewmembers";
	&AdminTemplate;
	exit;
}

sub MLPosition {
	if ($iamguest) { &admin_fatal_error("$ml_txt{'223'}"); }

	%TopMembers = ();

	&ManageMemberinfo("load");
	while (($membername, $value) = each(%memberinf)) {
		($memberrealname, undef, $memposition, $memposts) = split(/\|/, $value);
		$pstsort    = 99999999 - $memposts;
		$sortgroups = "";
		$j          = 0;

		foreach my $key (keys %Group) {
			if ($memposition eq $key) {
				if    ($key eq "Administrator")    { $sortgroups = "aaa.$pstsort.$memberrealname"; }
				elsif ($key eq "Global Moderator") { $sortgroups = "bbb.$pstsort.$memberrealname"; }
			}
		}
		if (!$sortgroups) {
			foreach (sort { $a <=> $b } keys %NoPost) {
				if ($memposition eq $_) {
					($thismemgrp, undef) = split(/\|/, $NoPost{$_}, 2);
					$sortgroups = "ddd.$thismemgrp.$pstsort.$memberrealname";
				}
			}
		}
		if (!$sortgroups) {
			$sortgroups = "eee.$pstsort.$memposition.$memberrealname";
		}
		$TopMembers{$membername} = $sortgroups;
	}
	undef %memberinf;

	my @toplist = sort { lc $TopMembers{$a} cmp lc $TopMembers{$b} } keys %TopMembers;

	if ($FORM{'reversed'} || $INFO{'reversed'}) {
		@toplist = reverse @toplist;
	}

	$memcount = @toplist;

	$yymain .= qq~$TableHeader~;

	$start = $start > $memcount - 1 ? $memcount - 1 : $start;
	$start = (int($start / $MembersPerPage)) * $MembersPerPage;

	$b         = $start;
	$numshown  = 0;
	$actualnum = 0;

	while ($numshown < $MembersPerPage) {
		&showRows($toplist[$b]);
		$numshown++;
		$b++;
	}
	$yymain .= qq~$TableFooter~;
	&buildPages;
	$yytitle     = "$ml_txt{'313'} $ml_txt{'4'} $ml_txt{'87'}";
	$action_area = "viewmembers";
	&AdminTemplate;
	exit;
}


sub MLDate {
	if ($iamguest) { &admin_fatal_error("$ml_txt{'223'}"); }

	fopen(MEMBERLISTREAD, "$memberdir/memberlist.txt");
	@tempmemlist = <MEMBERLISTREAD>;
	fclose(MEMBERLISTREAD);
	if ($FORM{'reversed'} || $INFO{'reversed'}) {
		@tempmemlist = reverse @tempmemlist;
	}
	$memcount = @tempmemlist;

	$yymain .= qq~$TableHeader~;

	$start = $start > $memcount - 1 ? $memcount - 1 : $start;
	$start = (int($start / $MembersPerPage)) * $MembersPerPage;

	$b = $start;
	$numshown = 0;
	$actualnum = 0;

	while ($numshown < $MembersPerPage) {
		($membername, undef) = split(/\t/, $tempmemlist[$b], 2);
		&showRows($membername);
		$numshown++;
		$b++;
	}

	$yymain .= qq~$TableFooter~;
	&buildPages;
	$yytitle     = "$ml_txt{'313'} $ml_txt{'4'} $ml_txt{'233'}";
	$action_area = "viewmembers";
	&AdminTemplate;
	exit;
}


sub showRows {
	my ($user) = $_[0];
	if ($user ne "") {
		&LoadUser($user);
		$date2 = $date;

		unless ($user eq "admin") {
			$date1 = &stringtotime(${$uid.$user}{'regdate'});
			&calcdifference;
			$days_reg = $result;

			my $userlastonline = ${$uid.$user}{'lastonline'};
			my $userlastpost   = ${$uid.$user}{'laspost'};
			my $userlastim     = ${$uid.$user}{'lastim'};

			if ($userlastonline eq "") { $userlastonline = "-"; $tmpa = $days_reg; }
			else { $date1 = $userlastonline; &calcdifference; $userlastonline = $result; $tmpa = $userlastonline; }
			if ($userlastpost eq "") { $userlastpost = "-"; $tmpb = $days_reg; }
			else { $date1 = $userlastpost; &calcdifference; $userlastpost = $result; $tmpb = $userlastpost; }
			if ($userlastim eq "") { $userlastim = "-"; $tmpc = $days_reg; }
			else { $date1 = $userlastim; &calcdifference; $userlastim = $result; $tmpc = $userlastim; }

			$tmp_postcount = ${$uid.$user}{'postcount'};
			$CheckingAll .= qq~"$days_reg|$tmp_postcount|$tmpa|$tmpb|$tmpc|$user", ~;

		}
	}

	if (${$uid.$user}{'realname'} ne "") {
		$barchart = ${$uid.$user}{'postcount'};
		$bartemp  = (${$uid.$user}{'postcount'} * $maxbar);
		$barwidth = ($bartemp / $barmax);
		$barwidth = ($barwidth + 0.5);
		$barwidth = int($barwidth);
		if ($barwidth > $maxbar) { $barwidth = $maxbar }

		if ($barchart < 1) { $Bar = ""; }
		else {
			$Bar = qq~<img src="$imagesdir/bar.gif" width="$barwidth" height="10" alt="" border="0" />~;
		}
		if ($Bar eq "") { $Bar = "&nbsp;"; }
		if (${$uid.$user}{'postcount'} > 100000) { ${$uid.$user}{'postcount'} = "$ml_txt{'683'}"; }

		$dr_regdate = &timeformat(${$uid.$user}{'regtime'});
		$dr_regdate =~ s~(.*)(, 1?[0-9]):[0-9][0-9].*~$1~;

		my $memberinfo = "&nbsp;";
		if (${$uid.$user}{'position'} eq "" && $showallgroups) {
			foreach $postamount (sort { $b <=> $a } keys %Post) {
				if (${$uid.$user}{'postcount'} > $postamount) {
					($memberinfo, $stars, $starpic, $color, $noshow, $viewperms, $topicperms, $replyperms, $pollperms, $attachperms) = split(/\|/, $Post{$postamount});
					last;
				}
			}
		} elsif (${$uid.$user}{'position'} ne "") {
			$tempgroups = 0;
			foreach (keys %Group) {
				if (${$uid.$user}{'position'} eq $_) {
					($memberinfo, $stars, $starpic, $color, $noshow, $viewperms, $topicperms, $replyperms, $pollperms, $attachperms) = split(/\|/, $Group{$_});
					$tempgroups = 1;
					last;
				}
			}
			if (!$tempgroups) {
				foreach (sort { $a <=> $b } keys %NoPost) {
					if (${$uid.$user}{'position'} eq $_) {
						($memberinfo, $stars, $starpic, $color, $noshow, $viewperms, $topicperms, $replyperms, $pollperms, $attachperms) = split(/\|/, $NoPost{$_});
						$tempgroups = 1;
						last;
					}
				}
			}
			if (!$tempgroups) {
				$memberinfo = ${$uid.$user}{'position'};
			}
		}

		$yymain .= qq~
	<tr>
		<td class="windowbg" width="19%">$link{$user}</td>
		~;

		if ($user eq "admin") {
			$addel = qq~&nbsp;~;
		} else {
			$addel = qq~<input type="checkbox" name="member$numshown" value="$user" class="windowbg" style="border: 0; vertical-align: middle;" />~;
			$actualnum++;
		}

		my $userlastonline = ${$uid.$user}{'lastonline'};
		my $userlastpost   = ${$uid.$user}{'lastpost'};
		my $userlastim     = ${$uid.$user}{'lastim'};

		if ($userlastonline eq "") { $userlastonline = "-"; $tmpa = $days_reg; }
		else { $date1 = $userlastonline; &calcdifference; $userlastonline = $result; $tmpa = $userlastonline; }
		if ($userlastpost eq "") { $userlastpost = "-"; $tmpb = $days_reg; }
		else { $date1 = $userlastpost; &calcdifference; $userlastpost = $result; $tmpb = $userlastpost; }
		if ($userlastim eq "") { $userlastim = "-"; $tmpc = $days_reg; }
		else { $date1 = $userlastim; &calcdifference; $userlastim = $result; $tmpc = $userlastim; }

		$yymain .= qq~
		<td class="windowbg" width="19%">$memberinfo</td>
		<td class="windowbg2" width="5%" align="center">${$uid.$user}{'postcount'}</td>
		<td class="windowbg" width="14%">$Bar</td>
		<td class="windowbg" width="19%" >$dr_regdate &nbsp;</td>
		<td class="windowbg2" width="7%" align="center">$userlastonline</td>
		<td class="windowbg2" width="6%" align="center">$userlastpost</td>
		<td class="windowbg2" width="6%" align="center">$userlastim</td>
		<td class="windowbg" width="5%" align="center">$addel</td>
	</tr>~;
	}
}

sub buildPages {

	unless ($memcount == 0) {
		if ($FORM{'sortform'} eq "") { $FORM{'sortform'} = $INFO{'sort'}; }
		if (!$FORM{'reversed'}) { $FORM{'reversed'} = $INFO{'reversed'}; }

		# Build the page links list.
		$postdisplaynum = 3;     # max number of pages to display
		$max            = $memcount;
		$start          = $start > $memcount - 1 ? $memcount - 1 : $start;
		$start          = (int($start / $MembersPerPage)) * $MembersPerPage;
		$tmpa           = 1;
		$tmpx           = int($max / $MembersPerPage);
		if ($start >= (($postdisplaynum - 1) * $MembersPerPage)) { $startpage = $start - (($postdisplaynum - 1) * $MembersPerPage); $tmpa = int($startpage / $MembersPerPage) + 1; }
		if ($max >= $start + ($postdisplaynum * $MembersPerPage)) { $endpage = $start + ($postdisplaynum * $MembersPerPage); }
		else { $endpage = $max }
		if ($startpage > 0) { $pageindex = qq~<a href="$adminurl?action=memlist;sort=$FORM{'sortform'};letter=$letter;reversed=$FORM{'reversed'}">1</a>&nbsp;...&nbsp;~; }
		if ($startpage == $MembersPerPage) { $pageindex = qq~<a href="$adminurl?action=memlist;sort=$FORM{'sortform'};letter=$letter;reversed=$FORM{'reversed'}">1</a>&nbsp;~; }

		for ($counter = $startpage; $counter < $endpage; $counter += $MembersPerPage) {
			$pageindex .= $start == $counter ? qq~<b>$tmpa</b>&nbsp;~ : qq~<a href="$adminurl?action=memlist;sort=$FORM{'sortform'};letter=$letter;reversed=$FORM{'reversed'};start=$counter">$tmpa</a>&nbsp;~;
			$tmpa++;
		}
		$tmpx    = $max - $MembersPerPage;
		$outerpn = int($tmpx / $MembersPerPage) + 0;
		$lastpn  = int($memcount / $MembersPerPage) + 1;
		$lastptn = ($lastpn - 1) * $MembersPerPage;
		if ($endpage < $max - ($MembersPerPage)) { $pageindexadd = qq~&nbsp;...&nbsp;~; }
		if ($endpage != $max) { $pageindexadd .= qq~&nbsp;<a href="$adminurl?action=memlist;sort=$FORM{'sortform'};letter=$letter;reversed=$FORM{'reversed'};start=$lastptn">$lastpn</a>~; }
		$pageindex .= $pageindexadd;

		$yymain .= qq~
    <table border="0" width="100%" cellpadding="3" cellspacing="1" class="bordercolor">
    <tr>
      <td class="catbg">
	  <span class="small"><b>$admin_txt{'139'}: $pageindex</b></span>
      </td>
    </tr>
    </table>
    <table border="0" width="100%" cellpadding="3" cellspacing="1" class="bordercolor">
<script language="JavaScript1.2" type="text/javascript">
<!-- 
    document.write('<tr>');
    document.write('<td class="titlebg" align="right"><b>$amv_txt{'38'}</b> ');
    document.write('<select name="field2">');
    document.write('<option value="0">$amv_txt{'35'}</option>');
    document.write('<option value="1">$amv_txt{'36'}</option>');
    document.write('<option value="2" selected>$amv_txt{'37'}</option>');
    document.write('</select> ');
    document.write('<input type="text" size="5" name="number" value="30" maxlength="5" onkeydown="javascript: if(navigator.appName == '+"'Microsoft Internet Explorer'"+') {if ((self.event.keyCode < 46 && self.event.keyCode != 8) || self.event.keyCode > 58 ) {return false;}}" /> ');
    document.write('<select name="field1">');
    document.write('<option value="0">$amv_txt{'30'}</option>');
    document.write('<option value="1">$amv_txt{'31'}</option>');
    document.write('<option value="2" selected>$amv_txt{'32'}</option>');
    document.write('<option value="3">$amv_txt{'33'}</option>');
    document.write('<option value="4">$amv_txt{'34'}</option>');
    document.write('</select> ');
    document.write('</td>');
    document.write('<td class="titlebg" align="center" width="5%"><input type="checkbox" name="check_all" value="1" class="titlebg" style="border: 0;" onclick="javascript: if (this.checked) checkAll(true); else checkAll(false);" /></td>');
    document.write('</tr>');
//-->
</script>
        <tr>
          <td class="windowbg2" colspan="2" align="left">
                <span class="small">$amv_txt{'45'}: <input type="checkbox" name="del_mail" value="1" class="windowbg2" style="border: 0; vertical-align: middle;" /></span>
          </td>
        </tr>
        <tr>
          <td class="windowbg" colspan="2" align="center">
                <input type="submit" value="$amv_txt{'15'}" onclick="javascript:window.document.adv_memberview.button.value = '2'; return confirm('$amv_txt{'20'}')" />
          </td>
        </tr>
	</table>
  </form>
<script language="JavaScript1.2" type="text/javascript">
<!-- 
mem_data = new Array ( "", $CheckingAll"" );

function checkAll(ticked) {

  if(navigator.appName == "Microsoft Internet Explorer") {var alt_pressed = self.event.altKey; var ctrl_pressed = self.event.ctrlKey;}
  else {var alt_pressed = false; var ctrl_pressed = false;}

  var limit = document.adv_memberview.number.value; 
  for (var i = 1; i <= $actualnum; i++) {
    var check = 0;
    var value1 = eval(mem_data[i].split("|")[document.adv_memberview.field1.value]);
    if (document.adv_memberview.field2.value == "0" && value1 < limit) { check = 1;}
    if (document.adv_memberview.field2.value == "1" && value1 == limit) { check = 1;}
    if (document.adv_memberview.field2.value == "2" && value1 > limit) { check = 1;}
    if (ctrl_pressed == true) {check = 0;}
    if (alt_pressed == true) {check = 1;}
    if (check == 1) {document.adv_memberview.elements[i].checked = ticked;}
  }
}
//-->
</script>
	~;
	}
}

1;
