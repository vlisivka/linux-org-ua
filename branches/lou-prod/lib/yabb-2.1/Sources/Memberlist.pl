###############################################################################
# Memberlist.pl                                                               #
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

$memberlistplver = 'YaBB 2.1 $Revision: 1.2 $';
if ($action eq 'detailedversion') { return 1; }

if ($iamguest) { &fatal_error("$ml_txt{'223'}"); }

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

if ($INFO{'sort'} eq "" && $FORM{'sortform'} eq "") { $INFO{'sort'} = $defaultml; $FORM{'sortform'} = $defaultml }

if ($FORM{'sortform'} eq "username" || $INFO{'sort'} eq "mlletter" || $INFO{'sort'} eq "username") {
	$page     = "a";
	$showpage = "A";
	while ($page ne "z") {
		$LetterLinks .= qq(<a href="$scripturl?action=ml;sort=mlletter;letter=$page"><b>$showpage&nbsp;</b></a> );
		$page++;
		$showpage++;
	}
	$LetterLinks .= qq(<a href="$scripturl?action=ml;sort=mlletter;letter=z"><b>Z</b></a>  <a href="$scripturl?action=ml;sort=mlletter;letter=other"><b>$ml_txt{'800'}</b></a> );
}

if ($INFO{'start'} eq "") { $start = 0; }
else { $start = "$INFO{'start'}"; }
if ($FORM{'sortform'} eq "posts" || $INFO{'sort'} eq "posts") { $selcPost .= qq( selected="selected"); $selPost .= qq(class="windowbg"); }
else { $selPost .= qq(class="windowbg2"); }
if ($FORM{'sortform'} eq "regdate" || $INFO{'sort'} eq "regdate") { $selcReg .= qq( selected="selected"); $selReg .= qq(class="windowbg"); }
else { $selReg .= qq(class="windowbg2"); }
if ($FORM{'sortform'} eq "position" || $INFO{'sort'} eq "position") { $selcPos .= qq( selected="selected"); $selPos .= qq(class="windowbg"); }
else { $selPos .= qq(class="windowbg2"); }
if ($FORM{'sortform'} eq "username" || $INFO{'sort'} eq "mlletter" || $INFO{'sort'} eq "username") { $selcUser .= qq( selected="selected"); $selUser .= qq(class="windowbg"); }
else { $selUser .= qq(class="windowbg2"); }

$NavHeader .= qq(
<table width="100%" cellpadding="3" cellspacing="0">
  <tr>
    <td align="left" width="100%"><span class="small"><b>
     <a href="$scripturl" class="nav">$mbname</a> &rsaquo;
      $ml_txt{'331'}</b></span>
    </td>
  </tr>
</table>
	<table border="0" width="100%" cellspacing="1" cellpadding="3" class="bordercolor">
);

$SortJump .= qq(
    <form action="$scripturl?action=ml" method="post" style="display: inline;">
    <select name="sortform" onchange="submit()">
    <option value="username"$selcUser>$ml_txt{'35'}</option>
    <option value="position"$selcPos>$ml_txt{'87'}</option>
    <option value="posts"$selcPost>$ml_txt{'21'}</option>
    <option value="regdate"$selcReg>$ml_txt{'233'}</option>
    </select>
    </form>
);

$TableHeader .= qq(
<tr>
	<td $selUser onclick="location.href='$scripturl?action=ml;sort=username';" width="23%" align="center" style="border: 1px; border-style: outset; cursor: pointer;"><b>$ml_txt{'35'}</b></td>
	<td class="catbg" width="4%" align="center"><img src="$imagesdir/email.gif" border="0" alt="$ml_txt{'307'}" /></td>
	<td class="catbg" width="4%" align="center"><img src="$imagesdir/www.gif" border="0" alt="$ml_txt{'96'}" /></td>
	<td $selPos onclick="location.href='$scripturl?action=ml;sort=position';" width="23%" align="center" style="border: 1px; border-style: outset; cursor: pointer;"><b>$ml_txt{'87'}</b></td>
	<td $selPost onclick="location.href='$scripturl?action=ml;sort=posts';" width="23%" colspan="2" align="center" style="border: 1px; border-style: outset; cursor: pointer;"><b>$ml_txt{'21'}</b></td>
	<td $selReg onclick="location.href='$scripturl?action=ml;sort=regdate';" width="23%" align="center" style="border: 1px; border-style: outset; cursor: pointer;"><b>$ml_txt{'234'}</b></td>
</tr>
);

if ($LetterLinks ne "") {
	$TableHeader .= qq(<tr>
		<td class="catbg" colspan="7"><span class="small">$LetterLinks</span></td>
	</tr>
	);
}

if ($FORM{'sortform'} eq "posts"    || $INFO{'sort'} eq "posts")    { &MLTop; }
if ($FORM{'sortform'} eq "regdate"  || $INFO{'sort'} eq "regdate")  { &MLDate; }
if ($FORM{'sortform'} eq "position" || $INFO{'sort'} eq "position") { &MLPosition; }
if ($INFO{'sort'} eq "" || $INFO{'sort'} eq "mlletter" || $INFO{'sort'} eq "username") { &MLByLetter; }

sub MLByLetter {
	if ($iamguest) { &fatal_error("$ml_txt{'223'}"); }
	$letter = lc($INFO{'letter'});
	$i      = 0;
	&ManageMemberinfo("load");
	foreach $membername (sort { lc $memberinf{$a} cmp lc $memberinf{$b} } keys %memberinf) {
		($memrealname, $mememail, undef, undef) = split(/\|/, $memberinf{$membername});
		if ($letter) {
			$SearchName = lc(substr($memrealname, 0, 1));
			if ($SearchName eq $letter) { $ToShow[$i] = $membername; $i++; }
			elsif ($letter eq "other" && (($SearchName lt "a") || ($SearchName gt "z"))) { $ToShow[$i] = $membername; $i++; }
		} else {
			$ToShow[$i] = $membername;
			$i++;
		}
	}
	undef %memberinf;
	$memcount = @ToShow;
	if (!$memcount && $letter) {
		$pageindex1 = qq~<span class="small" style="float: left; height: 21px; margin: 0px; margin-top: 2px;"><img src="$imagesdir/index_togl.gif" border="0" alt="" style="vertical-align: middle;" /></span>~;
		$pageindex2 = qq~<span class="small" style="float: left; height: 21px; margin: 0px; margin-top: 2px;"><img src="$imagesdir/index_togl.gif" border="0" alt="" style="vertical-align: middle;" /></span>~;
	} else {
		&buildIndex;
	}
	&buildPages(1);
	$b        = $start;
	$numshown = 0;
	if ($memcount) {
		while ($numshown < $MembersPerPage) {
			&showRows($ToShow[$b]);
			$numshown++;
			$b++;
		}
	} else {
		if ($letter) { $yymain .= qq~<tr><td class="windowbg" colspan="7" align="center"><br /><b>$ml_txt{'760'}</b><br /><br /></td></tr>~; }
	}
	undef @ToShow;
	&buildPages(0);
	$yytitle = "$ml_txt{'312'} $numshow";
	&template;
	exit;
}

sub MLTop {
	if ($iamguest) { &fatal_error("$ml_txt{'223'}"); }
	%top_list = ();
	&ManageMemberinfo("load");
	while (($membername, $value) = each(%memberinf)) {
		($memrealname, undef, undef, $memposts) = split(/\|/, $value);
		$memposts = sprintf("%06d", (999999 - $memposts));
		$top_list{$membername} = qq~$memposts|$memrealname~;
	}
	undef %memberinf;
	my @toplist = sort { lc $top_list{$a} cmp lc $top_list{$b} } keys %top_list;
	$memcount = @toplist;
	&buildIndex;
	&buildPages(1);
	$b        = $start;
	$numshown = 0;

	while ($numshown < $MembersPerPage) {
		&showRows($toplist[$b]);
		$numshown++;
		$b++;
	}
	undef @toplist;
	&buildPages(0);
	$yytitle = "$ml_txt{'313'} $ml_txt{'314'} $numshow";
	&template;
	exit;
}

sub MLPosition {
	%TopMembers = ();
	&ManageMemberinfo("load");
	while (($membername, $value) = each(%memberinf)) {
		($memberrealname, undef, $memposition, $memposts) = split(/\|/, $value);
		$pstsort    = 99999999 - $memposts;
		$sortgroups = "";
		foreach my $key (keys %Group) {
			if ($memposition eq $key) {
				if    ($key eq "Administrator")    { $sortgroups = "aaa.$pstsort.$memberrealname"; }
				elsif ($key eq "Global Moderator") { $sortgroups = "bbb.$pstsort.$memberrealname"; }
			}
		}
		if (!$sortgroups) {
			foreach (sort { $a <=> $b } keys %NoPost) {
				if ($memposition eq $_) {
					$sortgroups = "ddd.$memposition.$pstsort.$memberrealname";
				}
			}
		}
		if (!$sortgroups) {
			$sortgroups = "eee.$pstsort.$memposition.$memberrealname";
		}
		$TopMembers{$membername} = $sortgroups;
	}
	my @toplist = sort { lc $TopMembers{$a} cmp lc $TopMembers{$b} } keys %TopMembers;
	$memcount = @toplist;
	&buildIndex;
	&buildPages(1);
	$b        = $start;
	$numshown = 0;
	while ($numshown < $MembersPerPage) {
		&showRows($toplist[$b]);
		$numshown++;
		$b++;
	}
	undef @toplist;
	undef %memberinf;
	&buildPages(0);
	$yytitle = "$ml_txt{'313'} $ml_txt{'4'} $ml_txt{'87'} $numshow";
	&template;
	exit;
}

sub MLDate {
	if ($iamguest) { &fatal_error("$ml_txt{'223'}"); }
	($memcount, $temp) = &MembershipGet;
	&buildIndex;
	&buildPages(1);
	fopen(MEMBERLISTREAD, "$memberdir/memberlist.txt");
	$counter = 0;
	while ($counter < $start && ($buffer = <MEMBERLISTREAD>)) { $counter++; }
	for ($counter = 0; $counter < $MembersPerPage && ($buffer = <MEMBERLISTREAD>); $counter++) {
		chomp $buffer;
		if ($buffer) {
			($membername, undef) = split(/\t/, $buffer, 2);
			&showRows($membername);
		}
	}
	fclose(MEMBERLISTREAD);
	&buildPages(0);
	$yytitle = "$ml_txt{'313'} $ml_txt{'4'} $ml_txt{'233'} $numshow";
	&template;
	exit;
}

sub showRows {
	my ($user) = $_[0];
	my ($wwwshow);
	if ($user ne "") {
		&LoadUser($user);
		if (${$uid.$user}{'realname'} eq "") { ${$uid.$user}{'realname'} = $user; }
		if (${$uid.$user}{'weburl'}) { $wwwshow = qq~<a href="${$uid.$user}{'weburl'}" target="_blank"><img src="$imagesdir/www.gif" border="0" alt="${$uid.$user}{'webtitle'}" /></a>~; }
		$barchart = ${$uid.$user}{'postcount'};
		$bartemp  = (${$uid.$user}{'postcount'} * $maxbar);
		$barwidth = ($bartemp / $barmax);
		$barwidth = ($barwidth + 0.5);
		$barwidth = int($barwidth);
		if ($barwidth > $maxbar) { $barwidth = $maxbar }
		if ($barchart < 1)       { $Bar      = ""; }
		else {
			$Bar = qq~<img src="$imagesdir/bar.gif" width="$barwidth" height="10" alt="" border="0" />~;
		}
		if ($Bar eq "") { $Bar = "&nbsp;"; }
		if (${$uid.$user}{'postcount'} > 100000) { ${$uid.$user}{'postcount'} = "$ml_txt{'683'}"; }
		$dr_regdate = &timeformat(${$uid.$user}{'regtime'});
		$dr_regdate =~ s~(.*)(, 1?[0-9]):[0-9][0-9].*~$1~;
		$yymain .= qq~
		<tr>
		<td class="windowbg">$link{$user}</td>
		~;
		if (${$uid.$user}{'hidemail'} eq "checked" && !$iamadmin && $allow_hide_email eq 1) {
			$yymain .= qq~
			<td align="center" class="windowbg2"><img src="$imagesdir/lockmail.gif" alt="Hidden Email" /></td>
		~;
		} else {
			$yymain .= qq~
			<td align="center" class="windowbg2"><a href="$scripturl?action=mailto;user=$user" target="_blank"><img src="$imagesdir/email.gif" border="0" alt="${$uid.$user}{'email'}" /></a></td>
		~;
		}
		$yymain .= qq~
		<td align="center" class="windowbg2">$wwwshow</td>
		<td class="windowbg">$memberinfo{$user}&nbsp;</td>
		<td class="windowbg2" width="5%" align="center">${$uid.$user}{'postcount'}&nbsp;</td>
		<td class="windowbg" width="18%">$Bar</td>
		<td class="windowbg">$dr_regdate &nbsp;</td>
		</tr>~;
	}
}

sub buildIndex {
	unless ($memcount == 0) {
		if (!$iamguest) {
			($dummy, $dummy, $usermemberpage) = split(/\|/, ${$uid.$username}{'pageindex'});
		}

		# Build the page links list.
		my ($pagetxtindex, $pagetextindex, $pagedropindex1, $pagedropindex2, $all, $allselected);
		$indexdisplaynum = 3;
		$dropdisplaynum  = 10;
		if ($FORM{'sortform'} eq "") { $FORM{'sortform'} = $INFO{'sort'}; }
		$postdisplaynum = 3;
		$startpage      = 0;
		$max            = $memcount;
		if ($INFO{'start'} eq "all") { $MembersPerPage = $max; $all = 1; $allselected = qq~ selected="selected"~; $start = 0 }
		else { $start = $INFO{'start'} || 0; }
		$start    = $start > $memcount - 1 ? $memcount - 1 : $start;
		$start    = (int($start / $MembersPerPage)) * $MembersPerPage;
		$tmpa     = 1;
		$pagenumb = int(($memcount - 1) / $MembersPerPage) + 1;

		if ($start >= (($postdisplaynum - 1) * $MembersPerPage)) {
			$startpage = $start - (($postdisplaynum - 1) * $MembersPerPage);
			$tmpa = int($startpage / $MembersPerPage) + 1;
		}
		if ($memcount >= $start + ($postdisplaynum * $MembersPerPage)) { $endpage = $start + ($postdisplaynum * $MembersPerPage); }
		else { $endpage = $memcount }
		$lastpn     = int(($memcount - 1) / $MembersPerPage) + 1;
		$lastptn    = ($lastpn - 1) * $MembersPerPage;
		$pageindex1 = qq~<span class="small" style="float: left; height: 21px; margin: 0px; margin-top: 2px;"><img src="$imagesdir/index_togl.gif" border="0" alt="" style="vertical-align: middle;" /> $ml_txt{'139'}: $pagenumb</span>~;
		$pageindex2 = qq~<span class="small" style="float: left; height: 21px; margin: 0px; margin-top: 2px;"><img src="$imagesdir/index_togl.gif" border="0" alt="" style="vertical-align: middle;" /> $ml_txt{'139'}: $pagenumb</span>~;
		if ($pagenumb > 1 || $all) {

			if ($usermemberpage == 1 || $iamguest) {
				$pagetxtindexst = qq~<span class="small" style="float: left; height: 21px; margin: 0px; margin-top: 2px;">~;
				if (!$iamguest) { $pagetxtindexst .= qq~<a href="$scripturl?sort=$FORM{'sortform'};letter=$letter;start=$start;action=memberpagedrop"><img src="$imagesdir/index_togl.gif" border="0" alt="$ml_txt{'19'}" style="vertical-align: middle;" /></a> $ml_txt{'139'}: ~; }
				else { $pagetxtindexst .= qq~<img src="$imagesdir/xx.gif" border="0" alt="" style="vertical-align: middle;" /> $ml_txt{'139'}: ~; }
				if ($startpage > 0) { $pagetxtindex = qq~<a href="$scripturl?action=ml;sort=$FORM{'sortform'};letter=$letter" style="font-weight: normal;">1</a>&nbsp;...&nbsp;~; }
				if ($startpage == $MembersPerPage) { $pagetxtindex = qq~<a href="$scripturl?action=ml;sort=$FORM{'sortform'};letter=$letter" style="font-weight: normal;">1</a>&nbsp;~; }
				for ($counter = $startpage; $counter < $endpage; $counter += $MembersPerPage) {
					$pagetxtindex .= $start == $counter ? qq~<b>$tmpa</b>&nbsp;~ : qq~<a href="$scripturl?action=ml;sort=$FORM{'sortform'};letter=$letter;start=$counter" style="font-weight: normal;">$tmpa</a>&nbsp;~;
					$tmpa++;
				}
				if ($endpage < $memcount - $MembersPerPage) { $pageindexadd = qq~...&nbsp;~; }
				if ($endpage != $memcount) { $pageindexadd .= qq~<a href="$scripturl?action=ml;sort=$FORM{'sortform'};letter=$letter;start=$lastptn" style="font-weight: normal;">$lastpn</a>~; }
				$pagetxtindex .= qq~$pageindexadd~;
				$pageindex1 = qq~$pagetxtindexst$pagetxtindex</span>~;
				$pageindex2 = qq~$pagetxtindexst$pagetxtindex</span>~;
			} else {
				$pagedropindex1 = qq~<span style="float: left; width: 320px; margin: 0px; margin-top: 2px; border: 0px;">~;
				$pagedropindex1 .= qq~<span style="float: left; height: 21px; margin: 0; margin-right: 4px;"><a href="$scripturl?sort=$FORM{'sortform'};letter=$letter;start=$start;action=memberpagetext"><img src="$imagesdir/index_togl.gif" border="0" alt="$ml_txt{'19'}" /></a></span>~;
				$pagedropindex2 = $pagedropindex1;
				$tstart         = $start;
				if (substr($INFO{'start'}, 0, 3) eq "all") { ($tstart, $start) = split(/\-/, $INFO{'start'}); }
				$d_indexpages = $pagenumb / $dropdisplaynum;
				$i_indexpages = int($pagenumb / $dropdisplaynum);
				if ($d_indexpages > $i_indexpages) { $indexpages = int($pagenumb / $dropdisplaynum) + 1; }
				else { $indexpages = int($pagenumb / $dropdisplaynum) }
				$selectedindex = int(($start / $MembersPerPage) / $dropdisplaynum);

				if ($pagenumb > $dropdisplaynum) {
					$pagedropindex1 .= qq~<span style="float: left; height: 21px; margin: 0;"><select size="1" name="decselector1" id="decselector1" style="font-size: 9px; border: 2px inset;" onchange="if(this.options[this.selectedIndex].value) SelDec(this.options[this.selectedIndex].value, 'xx')">\n~;
					$pagedropindex2 .= qq~<span style="float: left; height: 21px; margin: 0;"><select size="1" name="decselector2" id="decselector2" style="font-size: 9px; border: 2px inset;" onchange="if(this.options[this.selectedIndex].value) SelDec(this.options[this.selectedIndex].value, 'xx')">\n~;
				}
				for ($i = 0; $i < $indexpages; $i++) {
					$indexpage  = ($i * $dropdisplaynum) * $MembersPerPage;
					$indexstart = ($i * $dropdisplaynum) + 1;
					$indexend   = $indexstart + ($dropdisplaynum - 1);
					if ($indexend > $pagenumb)    { $indexend   = $pagenumb; }
					if ($indexstart == $indexend) { $indxoption = qq~$indexstart~; }
					else { $indxoption = qq~$indexstart-$indexend~; }
					$selected = "";
					if ($i == $selectedindex) {
						$selected    = qq~ selected="selected"~;
						$pagejsindex = qq~$indexstart|$indexend|$MembersPerPage|$indexpage~;
					}
					if ($pagenumb > $dropdisplaynum) {
						$pagedropindex1 .= qq~<option value="$indexstart|$indexend|$MembersPerPage|$indexpage"$selected>$indxoption</option>\n~;
						$pagedropindex2 .= qq~<option value="$indexstart|$indexend|$MembersPerPage|$indexpage"$selected>$indxoption</option>\n~;
					}
				}
				if ($pagenumb > $dropdisplaynum) {
					$pagedropindex1 .= qq~</select>\n</span>~;
					$pagedropindex2 .= qq~</select>\n</span>~;
				}
				$pagedropindex1 .= qq~<span id="ViewIndex1" class="droppageindex" style="height: 14px; visibility: hidden">&nbsp;</span>~;
				$pagedropindex2 .= qq~<span id="ViewIndex2" class="droppageindex" style="height: 14px; visibility: hidden">&nbsp;</span>~;
				$tmpMembersPerPage = $MembersPerPage;
				if (substr($INFO{'start'}, 0, 3) eq "all") { $MembersPerPage = $MembersPerPage * $dropdisplaynum; }
				$prevpage          = $start - $tmpMembersPerPage;
				$nextpage          = $start + $MembersPerPage;
				$pagedropindexpvbl = qq~<img src="$imagesdir/index_left0.gif" height="14" width="13" border="0" alt="" style="margin: 0px; display: inline; vertical-align: middle;" />~;
				$pagedropindexnxbl = qq~<img src="$imagesdir/index_right0.gif" height="14" width="13" border="0" alt="" style="margin: 0px; display: inline; vertical-align: middle;" />~;
				if ($start < $MembersPerPage) { $pagedropindexpv .= qq~<img src="$imagesdir/index_left0.gif" height="14" width="13" border="0" alt="" style="display: inline; vertical-align: middle;" />~; }
				else { $pagedropindexpv .= qq~<img src="$imagesdir/index_left.gif" border="0" height="14" width="13" alt="$pidtxt{'02'}" style="display: inline; vertical-align: middle; cursor: pointer;" onclick="location.href=\\'$scripturl?action=ml;sort=$FORM{'sortform'};letter=$letter;start=$prevpage\\'" ondblclick="location.href=\\'$scripturl?action=ml;sort=$FORM{'sortform'};letter=$letter;start=0\\'" />~; }
				if ($nextpage > $lastptn) { $pagedropindexnx .= qq~<img src="$imagesdir/index_right0.gif" border="0" height="14" width="13" alt="" style="display: inline; vertical-align: middle;" />~; }
				else { $pagedropindexnx .= qq~<img src="$imagesdir/index_right.gif" height="14" width="13" border="0" alt="$pidtxt{'03'}" style="display: inline; vertical-align: middle; cursor: pointer;" onclick="location.href=\\'$scripturl?action=ml;sort=$FORM{'sortform'};letter=$letter;start=$nextpage\\'" ondblclick="location.href=\\'$scripturl?action=ml;sort=$FORM{'sortform'};letter=$letter;start=$lastptn\\'" />~; }
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
			else pagedropindex += '<td height="14" class="droppages"><a href="$scripturl?action=ml;sort=$FORM{'sortform'};letter=$letter;start=' + pagstart + '">' + i + '</a></td>';
			pagstart += maxpag;
		}
		if (vistart != viend) {
			if(visel == 'all') pagedropindex += '<td class="titlebg" height="14" style="height: 14px; padding-left: 1px; padding-right: 1px; font-size: 9px; font-weight: normal;"><b>$pidtxt{"01"}</b></td>';
			else pagedropindex += '<td height="14" class="droppages"><a href="$scripturl?action=ml;sort=$FORM{'sortform'};letter=$letter;start=all-' + allpagstart + '">$pidtxt{"01"}</a></td>';
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
	}

	sub buildPages {
		$numbegin = ($start + 1);
		$numend   = ($start + $MembersPerPage);
		if ($numend > $memcount) { $numend  = $memcount; }
		if ($memcount == 0)      { $numshow = ""; }
		else { $numshow = qq~($numbegin - $numend $ml_txt{'309'} $memcount)~; }
		if ($_[0]) {
			$yymain .= qq~
		<table width="100%" cellpadding="3" cellspacing="0">
		<tr>
		<td align="left" width="100%">
		<span class="nav"><a href="$scripturl" class="nav">$mbname</a> &rsaquo; $ml_txt{'331'} $numshow</span>
		</td>
		</tr>
		</table>
		<table border="0" width="100%" cellspacing="1" cellpadding="3" class="bordercolor">
		<tr>
		<td class="catbg" colspan="7" width="100%" align="left" valign="middle">
		<div style="float: left; width: 50%; text-align: left;">$pageindex1</div>
		<div class="small" style="float: left; width: 49%; text-align: right;"><b>$ml_txt{'1'}</b> $SortJump</div>
		</td>
		</tr>
		$TableHeader
		~;
		} else {
			$yymain .= qq~
		<tr>
		<td class="catbg" colspan="7" width="100%" align="left" valign="middle">
		<div style="float: left; width: 50%; text-align: left;">$pageindex2</div>
		$pageindexjs
		</td>
		</tr>
		</table>
		~;
		}
	}
}

1;
