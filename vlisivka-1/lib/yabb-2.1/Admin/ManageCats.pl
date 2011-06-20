###############################################################################
# ManageCats.pl                                                               #
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

$managecatsplver = 'YaBB 2.1 $Revision: 1.3 $';
if ($action eq 'detailedversion') { return 1; }

sub DoCats {
	&is_admin_or_gmod;
	$i = 1;
	while ($_ = each(%FORM)) {
		if ($_ ne 'baction' and $FORM{$_} == 1) { $editcats[$i] = $_; }
		$i++;
	}

	if    ($FORM{'baction'} eq "edit")  { &AddCats(@editcats); }
	elsif ($FORM{'baction'} eq "delme") {
		foreach $catid (@editcats) {
			if ($catid eq "") { next; }
			unless ($mloaded == 1) { require "$boardsdir/forum.master"; }
			##Check if category has any boards, and if it does remove them.
			$boardlist = $cat{$catid};
			if ($boardlist ne "") { require "$admindir/ManageBoards.pl"; &DeleteBoards($boardlist); }

			delete $cat{"$catid"};
			delete $catinfo{"$catid"};

			$x = 0;
			foreach $categoryid (@categoryorder) {
				if ($catid eq $categoryid) { splice(@categoryorder, $x, 1); last; }
				$x++;
			}
			&Write_ForumMaster;

			$yymain .= qq~$admin_txt{'830'} <i>$catid</i> $admin_txt{'831'}<br />~;
		}
		$action_area = "managecats";
		&AdminTemplate;
		exit;
	}
}

sub AddCats {
	my @editcats = @_;
	&is_admin_or_gmod;
	if ($INFO{"action"} eq "catscreen") { $FORM{"amount"} = $#editcats; }

	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }

	$yymain .= qq~
<form action="$adminurl?action=addcat2" method="post">
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
<table border="0" align="center" cellspacing="1" cellpadding="4" width="100%">
  <tr>
    <td class="titlebg" colspan="5" align="left">
    <img src="$imagesdir/cat.gif" alt="" border="0" />
    <b>$admin_txt{'3'}</b></td>
  </tr><tr>
      <td class="windowbg2" colspan="5" align="left"><br />$admin_txt{'43'}<br /><br /></td>
  </tr>
</table>
</div><br />
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
<table border="0" align="center" cellspacing="1" cellpadding="4" width="100%">
~;

	# Start Looping through and repeating the board adding wherever needed
	for ($i = 1; $i != $FORM{'amount'} + 1; $i++) {
		if ((!$editcats[$i] && $INFO{"action"} eq "catscreen") || ($editcats[$i] eq "" && $INFO{"action"} eq "catscreen")) { next; }
		if ($INFO{"action"} eq "catscreen") {
			$id = $editcats[$i];
			foreach $catid (@categoryorder) {
				$boardlist = $cat{$catid};
				unless ($id eq $catid) { next; }
				(@bdlist) = split(/\,/, $boardlist);
				($curcatname, $catperms, $catallowcol) = split(/\|/, $catinfo{"$catid"});
				&ToChars($curcatname);
				if ($catallowcol eq '1') { $allowChecked = " CHECKED "; }
				else { $allowChecked = ''; }
				if ($catallowcol eq '') { $catallowcol = 0; $allowChecked = ' CHECKED '; }
				$cattext = $curcatname;
			}
		} else {
			$cattext = "$admin_txt{'44'} $i:";
		}
		require "$admindir/ManageBoards.pl";
		$catperms = &DrawPerms($catperms, 0);
		$yymain .= qq~
  <tr>
    <td class="catbg" width="100%" colspan="4" align="left"> <b>$cattext</b></td>
  </tr><tr>
    <td class="windowbg" colspan="2" width="50%">&nbsp;</td>
    <td class="windowbg" width="40%" align="center"><b>$admin_txt{'45'}</b></td>
    <td class="windowbg" width="10%" align="center"><b>$exptxt{'6'}</b></td>
  </tr><tr>
    <td class="windowbg" width="10%" align="right" valign="middle"><b>ID:</b></td>
    <td class="windowbg2" width="40%" valign="middle">~;
		if ($INFO{"action"} eq "catscreen") {
			$yymain .= qq~<br /><input type="hidden" name="theid$i" value="$id" />$id<br /><br />~;
		} else {
			$yymain .= qq~<br /><input type="text" name="theid$i" value="$id" /><br /><br />~;
		}
		$yymain .= qq~
    </td>
    <td class="windowbg2" align="center" width="40%" rowspan="2"><select multiple="multiple" name="catperms$i" size="5">$catperms</td>
    <td class="windowbg2" align="center" width="10%" rowspan="2"><input type="checkbox" $allowChecked name="allowcol$i" /></td>
  </tr><tr>
    <td class="windowbg" width="10%" align="right" valign="middle"><b>$admin_txt{'68'}:</b></td>
    <td class="windowbg2" width="40%"><br /><input type="text" name="name$i" value="$curcatname" size="40" /><br /><br /></td>
  </tr>
    ~;
	}
	$yymain .= qq~<tr>
      <td class="catbg" width="100%" colspan="4" align="center"> <input type="hidden" name="amount" value=\"$FORM{"amount"}\" /><input type="hidden" name="screenornot" value="$INFO{'action'}" /><input type="submit" value="$admin_txt{'10'}" /></td>
  </tr>
</table>
</div>
</form>~;
	$yytitle     = "$admin_txt{'3'}";
	$action_area = "managecats";
	&AdminTemplate;
	exit;
}

sub AddCats2 {
	&is_admin_or_gmod;
	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }

	for ($i = 1; $i <= $FORM{'amount'}; $i++) {
		if ($FORM{"theid$i"} eq "") { next; }
		$id = $FORM{"theid$i"};
		&admin_fatal_error("$admin_txt{'240'} $admin_txt{'44'} $admin_txt{'241'}") if ($id !~ /^[0-9A-Za-z#%+-\.@^_]+$/);
		if ($FORM{'screenornot'} ne "catscreen") {
			if ($catinfo{"$id"}) { &admin_fatal_error("$admin_txt{'46'}"); }
			else { $cat{"$id"} = ""; }
			push(@categoryorder, $id);
		}
		if (!$FORM{"name$i"}) { $FORM{"name$i"} = $id; }

		$cname = $FORM{"name$i"};
		$cname =~ s/\"/&quot;/g;
		&FromChars($cname);

		if ($FORM{"allowcol$i"} eq 'on') { $FORM{"allowcol$i"} = 1; }
		else { $FORM{"allowcol$i"} = 0; }
		$catinfo{"$id"} = qq~$cname|$FORM{"catperms$i"}|$FORM{"allowcol$i"}~;

		&Write_ForumMaster;

		$yymain .= qq~$admin_txt{'830'} <i>$id</i> $admin_txt{'48'}<br />~;
	}
	$action_area = "managecats";
	&AdminTemplate;
	exit;
}

sub ReorderCats {
	&is_admin_or_gmod;
	unless ($mloaded == 1)       { require "$boardsdir/forum.master"; }
	if     ($#categoryorder > 0) {
		$catcnt = @categoryorder;
		$catnum = $catcnt;
		if ($catcnt < 4) { $catcnt = 4; }
		$categorylist = qq~<select name="selectcats" size="$catcnt" style="width: 190px;">~;
		foreach $category (@categoryorder) {
			chomp $category;
			($categoryname, undef) = split(/\|/, $catinfo{$category});
			if ($category eq $INFO{"thecat"}) {
				$categorylist .= qq~<option value="$category" selected="selected">$categoryname</option>~;
			} else {
				$categorylist .= qq~<option value="$category">$categoryname</option>~;
			}
		}
		$categorylist .= qq~</select>~;
	}
	$yymain .= qq~
<br /><br />
<form action="$adminurl?action=reordercats2" method="POST">
<table border="0" width="525" cellspacing="1" cellpadding="4" class="bordercolor" align="center">
  <tr>
    <td class="titlebg"><img src="$imagesdir/board.gif" style="vertical-align: middle;" /> <b>$admin_txt{'829'}</b></td>
  </tr>
  <tr>
    <td class="windowbg" valign="middle" align="left">
~;
	if ($catnum > 1) {
		$yymain .= qq~
    <div style="float: left; width: 280px; text-align: left; margin-bottom: 4px;" class="small">$admin_txt{'738'}</div>
    <div style="float: left; width: 230px; text-align: center; margin-bottom: 4px;">$categorylist</div>
    <div style="float: left; width: 280px; text-align: left; margin-bottom: 4px;" class="small">$admin_txt{'738a'}</div>
    <div style="float: left; width: 230px; text-align: center; margin-bottom: 4px;">
	<input type="submit" value="$admin_txt{'739a'}" name="moveup" style="font-size: 11px; width: 95px;" /><input type="submit" value="$admin_txt{'739b'}" name="movedown" style="font-size: 11px; width: 95px;" />
    </div>
~;
	} else {
		$yymain .= qq~
    <div class="small" style="text-align: center; margin-bottom: 4px;">$admin_txt{'738b'}</div>
~;
	}
	$yymain .= qq~
    </td>
  </tr>
</table>
</form>
~;
	$yytitle     = "$admin_txt{'829'}";
	$action_area = "managecats";
	&AdminTemplate;
	exit;
}

sub ReorderCats2 {
	&is_admin_or_gmod;
	my $moveitem = $FORM{'selectcats'};
	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }
	if     ($moveitem)     {
		if ($FORM{'moveup'}) {
			for ($i = 0; $i < @categoryorder; $i++) {
				if ($categoryorder[$i] eq $moveitem && $i > 0) {
					$j                 = $i - 1;
					$categoryorder[$i] = $categoryorder[$j];
					$categoryorder[$j] = $moveitem;
					last;
				}
			}
		} elsif ($FORM{'movedown'}) {
			for ($i = 0; $i < @categoryorder; $i++) {
				if ($categoryorder[$i] eq $moveitem && $i < $#categoryorder) {
					$j                 = $i + 1;
					$categoryorder[$i] = $categoryorder[$j];
					$categoryorder[$j] = $moveitem;
					last;
				}
			}
		}
		&Write_ForumMaster;
	}
	$yySetLocation = qq~$adminurl?action=reordercats;thecat=$moveitem~;
	&redirectexit;
}

1;
