###############################################################################
# MemberGroups.pl                                                             #
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

$membergroupsplver = 'YaBB 2.1 $Revision: 1.1 $';
if ($action eq 'detailedversion') { return 1; }

require "$vardir/membergroups.txt";

sub EditMemberGroups {
	&is_admin_or_gmod;
	my ($MemStatAdmin, $MemStarNumAdmin, $MemStarPicAdmin, $MemTypeColAdmin, $noshowAdmin, $viewpermsAdmin, $topicpermsAdmin, $replypermsAdmin, $pollpermsAdmin, $attachpermsAdmin) = split(/\|/, $Group{"Administrator"});
	my ($MemStatGMod,  $MemStarNumGMod,  $MemStarPicGMod,  $MemTypeColGMod,  $noshowGMod,  $viewpermsGMod,  $topicpermsGMod,  $replypermsGMod,  $pollpermsGMod,  $attachpermsGMod)  = split(/\|/, $Group{"Global Moderator"});
	my ($MemStatMod,   $MemStarNumMod,   $MemStarPicMod,   $MemTypeColMod,   $noshowMod,   $viewpermsMod,   $topicpermsMod,   $replypermsMod,   $pollpermsMod,   $attachpermsMod)   = split(/\|/, $Group{"Moderator"});
	my $noshowAdmin = ($noshowAdmin == 1) ? "No" : "Yes";
	my $noshowGMod  = ($noshowGMod == 1)  ? "No" : "Yes";
	my $noshowMod   = ($noshowMod == 1)   ? "No" : "Yes";
	my $adminpi = &permImage($viewpermsAdmin, $topicpermsAdmin, $replypermsAdmin, $pollpermsAdmin, $attachpermsAdmin);
	my $gmodpi  = &permImage($viewpermsGMod,  $topicpermsGMod,  $replypermsGMod,  $pollpermsGMod,  $attachpermsGMod);
	my $modpi   = &permImage($viewpermsMod,   $topicpermsMod,   $replypermsMod,   $pollpermsMod,   $attachpermsMod);

	$yymain .= qq~
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg">
<img src="$imagesdir/guest.gif" alt="" border="0" />&nbsp;<b>$admin_txt{'8'}</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
		$admin_txt{'11'}<br /><br />
	   </td>
     </tr>
   </table>
 </div>

<br />


 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg" colspan="6">
<img src="$imagesdir/guest.gif" alt="" border="0" />&nbsp;<b>$admin_txt{'12'}</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="center" class="catbg" width="25%"><b>$amgtxt{'03'}</b></td>
       <td align="center" class="catbg" width="15%"><b>$amgtxt{'19'}</b></td>
       <td align="center" class="catbg" width="10%"><b>$amgtxt{'08'}</b></td>
       <td align="center" class="catbg" width="25%"><b>$amgtxt{'01'}</b></td>
       <td align="center" class="catbg" width="10%"><b>$admin_txt{'53'}</b></td>
       <td align="center" class="catbg" width="15%"><b>&nbsp;</b></td>
     </tr>
     <tr valign="middle">
       <td align="center" class="windowbg2">$MemStatAdmin</td>
       <td align="center" class="windowbg2"><img src="$imagesdir/$MemStarPicAdmin" /> x $MemStarNumAdmin</td>
	~;
	if ($MemTypeColAdmin) {
		$thecolname = &hextoname($MemTypeColAdmin);
		$yymain .= qq~<td align="center" class="windowbg2"><span style="color:$MemTypeColAdmin">$thecolname</span></td>~;
	} else {
		$yymain .= qq~<td align="center" class="windowbg2" width="10%">&nbsp;</td>~;
	}
	$yymain .= qq~
       <td align="center" class="windowbg2">$noshowAdmin</td>
       <td align="center" class="windowbg2"><a href="$adminurl?action=editgroup;group=Administrator">$admin_txt{'53'}</a></td>
       <td align="center" class="windowbg2">&nbsp;</td>
     </tr>
     <tr valign="middle">
       <td align="center" class="windowbg2">$MemStatGMod</td>
       <td align="center" class="windowbg2"><img src="$imagesdir/$MemStarPicGMod" /> x $MemStarNumGMod</td>
	~;
	if ($MemTypeColGMod) {
		$thecolname = &hextoname($MemTypeColGMod);
		$yymain .= qq~<td align="center" class="windowbg2"><span style="color:$MemTypeColGMod">$thecolname</span></td>~;
	} else {
		$yymain .= qq~<td align="center" class="windowbg2" width="10%">&nbsp;</td>~;
	}
	$yymain .= qq~
       <td align="center" class="windowbg2">$noshowGMod</td>
       <td align="center" class="windowbg2"><a href="$adminurl?action=editgroup;group=Global Moderator">$admin_txt{'53'}</a></td>
       <td align="center" class="windowbg2">&nbsp;</td>
     </tr>
     <tr valign="middle">
       <td align="center" class="windowbg2">$MemStatMod</td>
       <td align="center" class="windowbg2"><img src="$imagesdir/$MemStarPicMod" /> x $MemStarNumMod</td>
	~;
	if ($MemTypeColMod) {
		$thecolname = &hextoname($MemTypeColMod);
		$yymain .= qq~<td align="center" class="windowbg2"><span style="color:$MemTypeColMod">$thecolname</span></td>~;
	} else {
		$yymain .= qq~<td align="center" class="windowbg2" width="10%">&nbsp;</td>~;
	}
	$yymain .= qq~
       <td align="center" class="windowbg2">$noshowMod</td>
       <td align="center" class="windowbg2"><a href="$adminurl?action=editgroup;group=Moderator">$admin_txt{'53'}</a></td>
       <td align="center" class="windowbg2">&nbsp;</td>
     </tr>
   </table>
 </div>

<br />

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg" colspan="6">
<img src="$imagesdir/guest.gif" alt="" border="0" />&nbsp;<b>$amgtxt{'37'} (<a href="$adminurl?action=editgroup">$admintxt{'18c'}</a>)</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="center" class="catbg" width="25%"><b>$amgtxt{'03'}</b></td>
       <td align="center" class="catbg" width="15%"><b>$amgtxt{'19'}</b></td>
       <td align="center" class="catbg" width="10%"><b>$amgtxt{'08'}</b></td>
       <td align="center" class="catbg" width="25%"><b>$amgtxt{'01'}</b></td>
       <td align="center" class="catbg" width="10%"><b>$admin_txt{'53'}</b></td>
       <td align="center" class="catbg" width="15%"><b>$admin_txt{'54'}</b></td>
     </tr>
~;
	$count = 0;
	foreach (sort { $a <=> $b } keys %NoPost) {
		if (!$_) {
			delete $NoPost{$_};
			fopen(FILE, ">$vardir/membergroups.txt", 1);
			foreach my $key (keys %Group) {
				my $value = $Group{$key};
				print FILE qq~\$Group{'$key'} = '$value';\n~;
			}
			foreach my $key (keys %NoPost) {
				my $value = $NoPost{$key};
				print FILE qq~\$NoPost{'$key'} = '$value';\n~;
			}
			foreach my $key (keys %Post) {
				my $value = $Post{$key};
				print FILE qq~\$Post{'$key'} = '$value';\n~;
			}
			print FILE qq~\n1;~;
			fclose(FILE);
			next;
		}
		($title, $stars, $starpic, $color, $noshow, $viewperms, $topicperms, $replyperms, $pollperms, $attachperms) = split(/\|/, $NoPost{$_});
		$permimage = "";
		$permimage = &permImage($viewperms, $topicperms, $replyperms, $pollperms, $attachperms);
		$noshow    = ($noshow == 1) ? "No" : "Yes";
		if (!$stars) { $stars = "0"; }
		$yymain .= qq~
	<tr>
       <td align="center" class="windowbg2" width="25%">$title</td>
       <td align="center" class="windowbg2" width="15%"><img src="$imagesdir/$starpic" /> x $stars</td>
	~;

		if ($color) {
			$thecolname = &hextoname($color);
			$yymain .= qq~<td align="center" class="windowbg2" width="10%"><span style="color:$color">$thecolname</span></td>~;
		} else {
			$yymain .= qq~<td align="center" class="windowbg2" width="10%">&nbsp;</td>~;
		}
		$yymain .= qq~
       <td align="center" class="windowbg2" width="25%">$noshow</td>
       <td align="center" class="windowbg2" width="10%"><a href="$adminurl?action=editgroup;group=NP|$_">$admin_txt{'53'}</a></td>
       <td align="center" class="windowbg2" width="15%"><a href="$adminurl?action=delgroup;group=NP|$_">$admin_txt{'54'}</a></td>
   	</tr>~;
		$count++;
	}
	if ($count == 0) {
		$yymain .= qq~
	<tr>
       <td align="center" class="windowbg2" colspan="6">$amgtxt{'35'}</td>
	</tr>~;
	}

	$yymain .= qq~
</table>
</div>

<br />

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg" colspan="6">
<img src="$imagesdir/guest.gif" alt="" border="0" />&nbsp;<b>$amgtxt{'40'}&nbsp;(<a href="$adminurl?action=editgroup1">$admintxt{'18c'}</a>)</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="center" class="catbg" width="25%"><b>$amgtxt{'03'}</b></td>
       <td align="center" class="catbg" width="15%"><b>$amgtxt{'19'}</b></td>
       <td align="center" class="catbg" width="10%"><b>$amgtxt{'08'}</b></td>
       <td align="center" class="catbg" width="25%"><b>$admin_txt{'21'}</b></td>
       <td align="center" class="catbg" width="10%"><b>$admin_txt{'53'}</b></td>
       <td align="center" class="catbg" width="15%"><b>$admin_txt{'54'}</b></td>
     </tr>

~;
	my $count = 0;
	foreach (sort { $b <=> $a } keys %Post) {
		if (!$_) {
			delete $Post{$_};
			fopen(FILE, ">$vardir/membergroups.txt", 1);
			foreach my $key (keys %Group) {
				my $value = $Group{$key};
				print FILE qq~\$Group{'$key'} = '$value';\n~;
			}
			foreach my $key (keys %NoPost) {
				my $value = $NoPost{$key};
				print FILE qq~\$NoPost{'$key'} = '$value';\n~;
			}
			foreach my $key (keys %Post) {
				my $value = $Post{$key};
				print FILE qq~\$Post{'$key'} = '$value';\n~;
			}
			print FILE qq~\n1;~;
			fclose(FILE);
			next;
		}
		my ($title, $stars, $starpic, $color, $noshow, $viewperms, $topicperms, $replyperms, $pollperms, $attachperms) = split(/\|/, $Post{$_});

		$permimage = "";
		$permimage = &permImage($viewperms, $topicperms, $replyperms, $pollperms, $attachperms);
		$noshow    = ($noshow == 1) ? "No" : "Yes";
		if (!$stars) { $stars = "0"; }
		$yymain .= qq~
	<tr>
       <td align="center" class="windowbg2" width="25%">$title</td>
       <td align="center" class="windowbg2" width="15%"><img src="$imagesdir/$starpic" /> x $stars</td>
	~;
		if ($color) {
			$thecolname = &hextoname($color);
			$yymain .= qq~<td align="center" class="windowbg2" width="10%"><span style="color:$color">$thecolname</span></td>~;
		} else {
			$yymain .= qq~<td align="center" class="windowbg2" width="10%">&nbsp;</td>~;
		}
		$yymain .= qq~
       <td align="center" class="windowbg2" width="25%">$_</td>
       <td align="center" class="windowbg2" width="10%"><a href="$adminurl?action=editgroup;group=P|$_">$admin_txt{'53'}</a></td>
       <td align="center" class="windowbg2" width="15%"><a href="$adminurl?action=delgroup;group=P|$_">$admin_txt{'54'}</a></td>
   	</tr>~;
		$count++;
	}
	if ($count == 0) {
		$yymain .= qq~
	<tr>
	  <td class="windowbg2" colspan="6">$amgtxt{'36'}</td>
	</tr>~;
	}
	$yymain .= qq~
   </table>
  </div>
~;

	$yytitle     = $admin_txt{'8'};
	$action_area = "modmemgr";
	&AdminTemplate;
	exit;
}

sub hextoname {
	$colorname = $_[0];
	$colorname =~ s~\#deb887~$amgtxt{'75'}~i;
	$colorname =~ s~\#ffd700~$amgtxt{'76'}~i;
	$colorname =~ s~\#ffa500~$amgtxt{'77'}~i;
	$colorname =~ s~\#a0522d~$amgtxt{'78'}~i;
	$colorname =~ s~\#87ceeb~$amgtxt{'79'}~i;
	$colorname =~ s~\#6a5acd~$amgtxt{'80'}~i;
	$colorname =~ s~\#4682B4~$amgtxt{'81'}~i;
	$colorname =~ s~\#9acd32~$amgtxt{'82'}~i;
	return lc $colorname;
}

sub editAddGroup() {
	&is_admin_or_gmod;
	if ($INFO{'group'}) {
		$viewtitle = $admintxt{'18a'};
		($type, $element) = split(/\|/, $INFO{'group'});
		if ($element ne "") {
			if ($type eq "P") {
				$posts = $element;
				($title, $stars, $starpic, $color, $noshow, $viewperms, $topicperms, $replyperms, $pollperms, $attachperms) = split(/\|/, $Post{$element});
			} else {
				$noposts = $element;
				($title, $stars, $starpic, $color, $noshow, $viewperms, $topicperms, $replyperms, $pollperms, $attachperms) = split(/\|/, $NoPost{$element});
			}
		} else {
			($title, $stars, $starpic, $color, $noshow, $viewperms, $topicperms, $replyperms, $pollperms, $attachperms) = split(/\|/, $Group{ $INFO{'group'} });
		}
	} else {
		$viewtitle = $admintxt{'18b'};
		$title     = "";
		$stars     = "";
		$starpic   = "";
		$color     = "";
		$posts     = "";
		$noposts   = 1;
		foreach (sort { $a <=> $b } keys %NoPost) {
			$noposts = $_ + 1;
		}
	}

	$otherdisable = qq~disabled="disabled"~;

	# Get star selected if needed.
	if    ($starpic eq "staradmin.gif")  { $stars1 = "selected=\"selected\"" }
	elsif ($starpic eq "stargmod.gif")   { $stars2 = "selected=\"selected\"" }
	elsif ($starpic eq "starmod.gif")    { $stars3 = "selected=\"selected\"" }
	elsif ($starpic eq "starblue.gif")   { $stars4 = "selected=\"selected\"" }
	elsif ($starpic eq "starsilver.gif") { $stars5 = "selected=\"selected\"" }
	elsif ($starpic eq "stargold.gif")   { $stars6 = "selected=\"selected\"" }
	elsif ($starpic eq "")               { $stars1 = "selected=\"selected\"" }
	else { $stars7 = "selected=\"selected\""; $pick = $starpic; $otherdisable = ""; }

	# Get color selected, if needed...
	if    ($color eq "aqua")    { $colors1  = "selected=\"selected\""; }
	elsif ($color eq "black")   { $colors2  = "selected=\"selected\""; }
	elsif ($color eq "blue")    { $colors3  = "selected=\"selected\""; }
	elsif ($color eq "fuchsia") { $colors4  = "selected=\"selected\""; }
	elsif ($color eq "gray")    { $colors5  = "selected=\"selected\""; }
	elsif ($color eq "green")   { $colors6  = "selected=\"selected\""; }
	elsif ($color eq "lime")    { $colors7  = "selected=\"selected\""; }
	elsif ($color eq "maroon")  { $colors8  = "selected=\"selected\""; }
	elsif ($color eq "navy")    { $colors9  = "selected=\"selected\""; }
	elsif ($color eq "olive")   { $colors10 = "selected=\"selected\""; }
	elsif ($color eq "purple")  { $colors11 = "selected=\"selected\""; }
	elsif ($color eq "red")     { $colors12 = "selected=\"selected\""; }
	elsif ($color eq "silver")  { $colors13 = "selected=\"selected\""; }
	elsif ($color eq "teal")    { $colors14 = "selected=\"selected\""; }
	elsif ($color eq "white")   { $colors15 = "selected=\"selected\""; }
	elsif ($color eq "yellow")  { $colors16 = "selected=\"selected\""; }
	elsif ($color eq "#deb887") { $colors17 = "selected=\"selected\""; }
	elsif ($color eq "#ffd700") { $colors18 = "selected=\"selected\""; }
	elsif ($color eq "#ffa500") { $colors19 = "selected=\"selected\""; }
	elsif ($color eq "#a0522d") { $colors20 = "selected=\"selected\""; }
	elsif ($color eq "#87ceeb") { $colors21 = "selected=\"selected\""; }
	elsif ($color eq "#6a5acd") { $colors22 = "selected=\"selected\""; }
	elsif ($color eq "#4682B4") { $colors23 = "selected=\"selected\""; }
	elsif ($color eq "#9acd32") { $colors24 = "selected=\"selected\""; }
	else { $colors0 = "selected=\"selected\""; }

	$pc = qq~ checked="checked"~;
	$pd = "";
	$pt = "";

	if ($noshow) { $pc = ""; }

	if ($posts eq "" && $action ne "editgroup1") { $post2 = qq~ checked="checked"~; $pt = qq~ disabled="disabled"~; }
	else { $post1 = qq~ checked="checked"~; $pd = qq~ disabled="disabled"~; }

	if ($viewperms == 1)   { $vc  = "checked=\"checked\""; }
	if ($topicperms == 1)  { $tc  = "checked=\"checked\""; }
	if ($replyperms == 1)  { $rc  = "checked=\"checked\""; }
	if ($pollperms == 1)   { $poc = "checked=\"checked\""; }
	if ($attachperms == 1) { $ac  = "checked=\"checked\""; }

	$yymain .= qq~

<form name="groups" action="$adminurl?action=editAddGroup2" method="POST">
<input type="hidden" name="original" value="$INFO{'group'}" />
<input type="hidden" name="origin" value="$action" />

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg" colspan="2">
<img src="$imagesdir/preferences.gif" alt="" border="0" /> <b>$viewtitle</b>
	   </td>
     </tr>
     <tr valign="middle">
	  <td class="windowbg" width="40%">$amgtxt{'51'}:</td>
	  <td class="windowbg2" width="60%"><input type="text" name="title" value="$title" /></td>
	</tr><tr>
	  <td class="windowbg">$amgtxt{'05'}:</td>
	  <td class="windowbg2"><input type="text" name="numstars" size="2" value="$stars" /></td>
	</tr><tr>
	  <td class="windowbg">$amgtxt{'38'}:</td>
	  <td class="windowbg2">
	    <select name="starsadmin" onchange="stars(this.value)">
		<option value="staradmin.gif" $stars1>$amgtxt{'20'}</option>
		<option value="stargmod.gif" $stars2>$amgtxt{'21'}</option>
		<option value="starmod.gif" $stars3>$amgtxt{'22'}</option>
		<option value="starblue.gif" $stars4>$amgtxt{'23'}</option>
		<option value="starsilver.gif" $stars5>$amgtxt{'24'}</option>
		<option value="stargold.gif" $stars6>$amgtxt{'25'}</option>
		<option value="other" $stars7>$amgtxt{'26'}</option>
	    </select>
	    &nbsp;
	    <b>$amgtxt{'26'}</b> <input type="text" name="otherstar" id="otherstar" value="$pick"$otherdisable />
	  </td>
	</tr><tr>
	  <td class="windowbg">$amgtxt{'08'}:</td>
	  <td class="windowbg2" >
	    <select name="color" id="color" onchange="if(this.options[this.selectedIndex].value) { viscolor(this.options[this.selectedIndex].value); }">
		<option value="" $colors0></option>
		<option value="aqua" $colors1>$amgtxt{'56'}</option>
		<option value="black" $colors2>$amgtxt{'57'}</option>
		<option value="blue" $colors3>$amgtxt{'58'}</option>
		<option value="fuchsia" $colors4>$amgtxt{'59'}</option>
		<option value="gray" $colors5>$amgtxt{'60'}</option>
		<option value="green" $colors6>$amgtxt{'61'}</option>
		<option value="lime" $colors7>$amgtxt{'62'}</option>
		<option value="maroon" $colors8>$amgtxt{'63'}</option>
		<option value="navy" $colors9>$amgtxt{'64'}</option>
		<option value="olive" $colors10>$amgtxt{'65'}</option>
		<option value="purple" $colors11>$amgtxt{'66'}</option>
		<option value="red" $colors12>$amgtxt{'67'}</option>
		<option value="silver" $colors13>$amgtxt{'68'}</option>
		<option value="teal" $colors14>$amgtxt{'69'}</option>
		<option value="white" $colors15>$amgtxt{'70'}</option>
		<option value="yellow" $colors16>$amgtxt{'71'}</option>
		<option value="#deb887" $colors17>$amgtxt{'75'}</option>
		<option value="#ffd700" $colors18>$amgtxt{'76'}</option>
		<option value="#ffa500" $colors19>$amgtxt{'77'}</option>
		<option value="#a0522d" $colors20>$amgtxt{'78'}</option>
		<option value="#87ceeb" $colors21>$amgtxt{'79'}</option>
		<option value="#6a5acd" $colors22>$amgtxt{'80'}</option>
		<option value="#4682B4" $colors23>$amgtxt{'81'}</option>
		<option value="#9acd32" $colors24>$amgtxt{'82'}</option>
	    </select> &nbsp;
		<span name="grpcolor" id="grpcolor" style="color: $color;"><b>$amgtxt{'08'}</b></span>
	  </td>
	</tr>
~;
	unless (exists $Group{ $INFO{'group'} }) {
		$yymain .= qq~
	<tr>
	  <td class="windowbg">$amgtxt{'39a'}</td>
	  <td class="windowbg2">
		<input type="radio" name="postdepend" value="No" $post2 class="windowbg2" style="border: 0px; vertical-align: middle;" onclick="depend(this.value)" />&nbsp;
		<b>$amgtxt{'42'}</b> <b><a class="link" style='cursor: help;' title="$amgtxt{'43'}">(?)</a></b>
		<input type="checkbox" name="viewpublic" id="viewpublic" value="1"$pc$pd style="vertical-align: middle;" />
		<input type="hidden" name="noposts" id="noposts" value="$noposts" />
	  </td>
	</tr><tr>
	  <td class="windowbg">$amgtxt{'39'}</td>
	  <td class="windowbg2">
		<input type="radio" name="postdepend" value="Yes" $post1 class="windowbg2" style="border: 0px; vertical-align: middle;" onclick="depend(this.value)" />&nbsp;
		<b>$amgtxt{'04'}:</b> <input type="text" name="posts" id="posts" size="5" value="$posts"$pt style="vertical-align: middle;" />
	  </td>
	</tr>~;
	} else {
		$yymain .= qq~
	<tr>
	  <td class="windowbg"><b>$amgtxt{'42'}</b> <b><a class="link" style='cursor: help;' title="$amgtxt{'43'}">(?)</a></b></td>
	  <td class="windowbg2">
		<input type="checkbox" name="viewpublic" id="viewpublic" value="1"$pc$pd style="vertical-align: middle;" />
	  </td>
	</tr>
~;
	}
	unless ($INFO{'group'} eq "Administrator") {
		$yymain .= qq~
   </table>
 </div>
<br />
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg" colspan="5">
<img src="$imagesdir/preferences.gif" alt="" border="0" /><b>$amgtxt{'44'}</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="center" class="catbg" width="20%"><span class="small">$amgtxt{'45'} $amgtxt{'46'}</span></td>
       <td align="center" class="catbg" width="20%"><span class="small">$amgtxt{'45'} $amgtxt{'47'}</span></td>
       <td align="center" class="catbg" width="21%"><span class="small">$amgtxt{'45'} $amgtxt{'48'}</span></td>
       <td align="center" class="catbg" width="19%"><span class="small">$amgtxt{'45'} $amgtxt{'49'}</span></td>
       <td align="center" class="catbg" width="20%"><span class="small">$amgtxt{'45'} $amgtxt{'50'}</span></td>
     </tr>
     <tr valign="middle">
       <td align="center" class="windowbg2" width="20%"><span class="small"><input type="checkbox" name="view" value="1"$vc /></span></td>
       <td align="center" class="windowbg2" width="20%"><span class="small"><input type="checkbox" name="topics" value="1"$tc /></span></td>
       <td align="center" class="windowbg2" width="21%"><span class="small"><input type="checkbox" name="reply" value="1"$rc /></span></td>
       <td align="center" class="windowbg2" width="19%"><span class="small"><input type="checkbox" name="polls" value="1"$poc /></span></td>
       <td align="center" class="windowbg2" width="20%"><span class="small"><input type="checkbox" name="attach" value="1"$ac /></span></td>
     </tr>
~;
	}

	$yymain .= qq~
     <tr valign="middle">
       <td align="center" class="catbg" colspan="5">
	     <input type="submit" value="Submit" />
	   </td>
     </tr>
   </table>
 </div>
</form>

<script language="JavaScript">
<!--
function viscolor(value) {
	document.getElementById('grpcolor').style.color = value;
}

function stars(value)
{
	if (value == "other") document.getElementById('otherstar').disabled = false;
	else document.getElementById('otherstar').disabled = true;
}

function depend(value)
{
	if (value == "Yes") {
		document.getElementById('posts').disabled = false;
		document.getElementById('viewpublic').checked = true;
		document.getElementById('viewpublic').disabled = true;
	}
	else{
		document.getElementById('posts').disabled = true;
		document.getElementById('viewpublic').disabled = false;
	}
}
//-->
</script>

~;
	$yytitle     = $admin_txt{'8'};
	$action_area = "modmemgr";
	&AdminTemplate;
	exit;
}

sub editAddGroup2() {
	&is_admin_or_gmod;

	# Additional checks are:
	# If post independent -> post dependent, then need to kill off post independent
	# If post dependent -> post independent, then need to kill off post dependent.
	# If post dependent -> NEW post dependent, then need to kill off OLD post dependent.
	$newpostdep = 0;

	if (!$FORM{'title'}) { &admin_fatal_error("$amgtxt{'53'}"); }
	$name = $FORM{'title'};

	$name =~ s~\&amp\;~\&~g;
	$name =~ s~\'~&#39;~g;

	$star       = ($FORM{'starsadmin'} eq "other") ? $FORM{'otherstar'} : $FORM{'starsadmin'};
	$color      = $FORM{'color'};
	$postdepend = $FORM{'postdepend'};
	if ($FORM{'posts'} !~ /\d+/ && $postdepend eq "Yes") { &admin_fatal_error("$amgtxt{'54'}"); }
	else { $posts = $FORM{'posts'} }
	if ($postdepend eq "No") { $noposts = $FORM{'noposts'}; }

	if ($FORM{'viewpublic'}) { $viewpublic = 0 }
	else { $viewpublic = 1 }
	$view   = $FORM{'view'}   || 0;
	$topics = $FORM{'topics'} || 0;
	$reply  = $FORM{'reply'}  || 0;
	$polls  = $FORM{'polls'}  || 0;
	$attach = $FORM{'attach'} || 0;
	$original = $FORM{'original'};

	# all the checks.
	if ($original ne '') {
		($type, $element) = split(/\|/, $original);

		# Ignoring Administrative groups.
		if ($element ne "") {
			if ($type eq "P") {
				if ($element != $posts || $postdepend eq "No") {
					delete $Post{$element};
					$newpostdep = 1;
					$noposts    = 1;
					foreach (sort { $a <=> $b } keys %NoPost) {
						$noposts = $_ + 1;
					}
				}
			} elsif ($type eq "NP") {
				if ($element != $noposts || $postdepend eq "Yes") {
					delete $NoPost{$element};
				}
			}
		}
	}

	$lcname = lc($name);

	# Check Post Independent
	foreach my $key (keys %NoPost) {
		if ($type eq "NP" && $key eq $element) { next; }
		($value, undef) = split(/\|/, $NoPost{$key}, 2);
		$lcvalue = lc($value);
		if ($lcname eq $lcvalue) { &admin_fatal_error("$amgtxt{'73'}"); }
	}

	# Check Post Dependent
	foreach my $key (keys %Post) {
		if ($type eq "P" && $key eq $element) { next; }
		($value, undef) = split(/\|/, $Post{$key}, 2);
		$lcvalue = lc($value);
		if ($lcname eq $lcvalue) { &admin_fatal_error("$amgtxt{'73'}"); }
	}

	# Now, we must deliberate on what type of thing this group is, and add/readd(when editing) it.
	# First, using original variable, we check to see it's not a perma-group.
	($type, $element) = split(/\|/, $original);
	if ($element eq "" && $original ne "") {
		# We have a perma-group! $type is now equal to the perma group or key for the hash.
		# add in code to actually set the line.
		$Group{"$type"} = "$name|$FORM{'numstars'}|$star|$color|$viewpublic|$view|$topics|$reply|$polls|$attach";
	} else {
		if ($postdepend eq "Yes") {

			# post dependent group.
			foreach my $key (keys %Post) {
				if ($posts == $key && ($FORM{'origin'} eq "editgroup1" || $original ne "P|$posts")) {
					&admin_fatal_error("$amgtxt{'72'} ($posts)");
				}
			}

			$Post{$posts} = "$name|$FORM{'numstars'}|$star|$color|0|$view|$topics|$reply|$polls|$attach";
			$newpostdep = 1;
		} else {

			# no post group
			$NoPost{$noposts} = "$name|$FORM{'numstars'}|$star|$color|$viewpublic|$view|$topics|$reply|$polls|$attach";
		}
	}

	# Write new data to the file.
	fopen(FILE, ">$vardir/membergroups.txt", 1);
	foreach my $key (keys %Group) {
		my $value = $Group{$key};
		print FILE qq~\$Group{'$key'} = '$value';\n~;
	}

	foreach my $key (keys %NoPost) {
		my $value = $NoPost{$key};
		print FILE qq~\$NoPost{'$key'} = '$value';\n~;
	}

	foreach my $key (keys %Post) {
		my $value = $Post{$key};
		print FILE qq~\$Post{'$key'} = '$value';\n~;
	}
	print FILE qq~\n1;~;
	fclose(FILE);
	if ($newpostdep) { &MemberIndex("rebuild"); }
	$yySetLocation = qq~$adminurl?action=modmemgr~;
	&redirectexit;
}

sub permImage() {
	my $viewperms, $topicperms, $replyperms, $pollperms, $attachperms;

	$viewperms   = ($_[0] != 1) ? "<img src=\"$imagesdir/open.gif\" />"        : "";
	$topicperms  = ($_[1] != 1) ? "<img src=\"$imagesdir/new_thread.gif\" />"  : "";
	$replyperms  = ($_[2] != 1) ? "<img src=\"$imagesdir/reply.gif\" />"       : "";
	$pollperms   = ($_[3] != 1) ? "<img src=\"$imagesdir/poll_create.gif\" />" : "";
	$attachperms = ($_[4] != 1) ? "<img src=\"$imagesdir/paperclip.gif\" />"   : "";

	return "$viewperms $topicperms $replyperms $pollperms $attachperms";
}

sub deleteGroup() {
	if ($INFO{'group'}) {
		($type, $element) = split(/\|/, $INFO{'group'});
		if ($element ne "") {
			if ($type eq "P") {
				delete $Post{$element};
			} elsif ($type eq "NP") {
				delete $NoPost{$element};
				&KillModeratorGroup($element);
			}
		}
	} else {
		&admin_fatal_error("");
	}

	# Write new data to the file.
	fopen(FILE, ">$vardir/membergroups.txt", 1);
	foreach my $key (keys %Group) {
		my $value = $Group{$key};
		print FILE qq~\$Group{'$key'} = '$value';\n~;
	}
	foreach my $key (keys %NoPost) {
		my $value = $NoPost{$key};
		print FILE qq~\$NoPost{'$key'} = '$value';\n~;
	}
	foreach my $key (keys %Post) {
		my $value = $Post{$key};
		print FILE qq~\$Post{'$key'} = '$value';\n~;
	}
	print FILE qq~\n1;~;
	fclose(FILE);
	&MemberIndex("rebuild");
	$yySetLocation = qq~$adminurl?action=modmemgr~;
	&redirectexit;
}

1;
