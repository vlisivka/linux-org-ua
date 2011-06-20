###############################################################################
# ManageBoards.pl                                                             #
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

$manageboardsplver = 'YaBB 2.1 $Revision: 1.6 $';
if ($action eq 'detailedversion') { return 1; }

require "$vardir/membergroups.txt";

sub ManageBoards {
	&is_admin_or_gmod;
	&LoadBoardControl;
	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }
	if ($INFO{"action"} eq "managecats") {
		$colspan     = qq~colspan="2"~;
		$add         = "$admin_txt{'47'}";
		$act         = "catscreen";
		$manage      = qq~<a href="$adminurl?action=reordercats"><img src="$imagesdir/reorder.gif" alt="$admin_txt{'829'}" border="0" style="vertical-align: middle;" /></a> &nbsp;<b>$admin_txt{'49'}</b>~;
		$managedescr = qq~$admin_txt{'678'}~;
		$act2        = "addcat";
		$action_area = "managecats";
	} else {
		$colspan     = qq~colspan="4"~;
		$add         = "$admin_txt{'50'}";
		$act         = "boardscreen";
		$manage      = qq~<img src="$imagesdir/cat.gif" alt="" border="0" style="vertical-align: middle;" /> &nbsp;<b>$admin_txt{'51'}</b>~;
		$managedescr = qq~$admin_txt{'677'}~;
		$act2        = "addboard";
		$action_area = "manageboards";
	}
	$yymain .= qq~
<script language="JavaScript1.2" type="text/javascript">
	<!--
		function checkSubmit(where){ 
			var something_checked = false;
			for (i=0; i<where.elements.length; i++){
				if(where.elements[i].type == "checkbox"){
					if(where.elements[i].checked == true){
						something_checked = true;
					}
				}
			}
			if(something_checked == true){
				if (where.baction[1].checked == false){
					return true;
				}
				if (confirm("$admin_txt{'617'}")) {
					return true;
				} else {
					return false; 
				}
			} else {
				alert("$admin_txt{'5'}");
				return false;
			}
		}
	//-->
</script>
<form name="whattodo" action="$adminurl?action=$act" onSubmit="return checkSubmit(this);" method="post">
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg" $colspan>
		 $manage
	   </td>
     </tr>
     <tr align="center" valign="middle">
       <td align="left" class="windowbg2" $colspan><br />
		  $managedescr<br /><br />
	   </td>
     </tr>
~;
	foreach $catid (@categoryorder) {
		$boardlist = $cat{$catid};
		(@bdlist) = split(/\,/, $boardlist);
		($curcatname, $catperms) = split(/\|/, $catinfo{"$catid"});
		&ToChars($curcatname);

		if ($INFO{"action"} eq "managecats") {
			$tempcolspan = "";
			$tempclass   = "windowbg2";
		} else {
			$tempcolspan = qq~colspan="4"~;
			$tempclass   = "catbg";
		}

		$yymain .= qq~
     <tr valign="middle">
       <td align="left" height="25" class="$tempclass" valign="middle" $tempcolspan>
		<a href="$adminurl?action=reorderboards;item=$catid"><img src="$imagesdir/reorder.gif" alt="$admin_txt{'832'}" border="0" style="vertical-align: middle;" /></a> &nbsp;<b>$curcatname</b>
	   </td>
~;
		if ($INFO{"action"} eq "managecats") {
			$yymain .= qq~
    	<td class="windowbg" height="25" width="10%" align="center"><input type="checkbox" name="$catid" value="1" /></td>~;
		}

		$yymain .= qq~
     </tr>~;
		unless ($INFO{"action"} eq "managecats") {
			foreach $curboard (@bdlist) {
				($boardname, $boardperms, $boardview) = split(/\|/, $board{"$curboard"});
				$boardname =~ s/\&quot\;/&#34;/g;
				&ToChars($boardname);
				$descr = ${$uid.$curboard}{'description'};
				$descr =~ s~\<br />~\n~g;
				my $bicon = "";
				if (${$uid.$curboard}{'ann'} == 1)  { $bicon = qq~ <img src="$imagesdir/ann.gif" alt="$admin_txt{'64g'}" border="0" />~; }
				if (${$uid.$curboard}{'rbin'} == 1) { $bicon = qq~ <img src="$imagesdir/admin_rem.gif" alt="$admin_txt{'64i'}" border="0" />~; }
				$convertstr = $descr;
				$convertcut = 60;
				&CountChars;
				my $descr = $convertstr;
				&ToChars($descr);
				if ($cliped) { $descr .= "..."; }
				$yymain .= qq~
  <tr>
    <td class="windowbg" width="25%" align="left">$boardname</td>
    <td class="windowbg" width="65%" align="left">$descr</td>
    <td class="windowbg" width="5%" align="center">$bicon</td>
    <td class="titlebg" width="5%" align="center"><input type="checkbox" name="$curboard" value="1" /></td>
  </tr>
~;
			}
		}
	}

	$yymain .= qq~
  	<tr>
      <td class="catbg" width="100%" align="center" valign="middle" $colspan> $admin_txt{'52'}
    	<input type="radio" name="baction" value="edit" checked="checked" /> $admin_txt{'53'} 
    	<input type="radio" name="baction" value="delme" /> $admin_txt{'54'} 
    	<input type="submit" value="$admin_txt{'32'}" /></td>
  	 </tr>
</table>
</div>
</form>
<br />
<form name="diff" action="$adminurl?action=$act2" method="post">
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
  <tr>
    <td class="catbg" align="center" valign="middle"><b>$add: </b>
	<input type="text" name="amount" value="3" size="2" maxlength="2" /> 
	<input type="submit" value="$admintxt{'45'}" />
	</td>
  </tr>
   </table>
 </div>
</form>
~;
	$yytitle = "$manage";
	&AdminTemplate;
	exit;
}

sub BoardScreen {
	&is_admin_or_gmod;
	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }
	$i = 1;
	while ($_ = each(%FORM)) {
		if ($_ ne 'baction' and $FORM{$_} == 1) { $editboards[$i] = $_; $i++; }
	}
	$i = 1;
	foreach $thiscat (@categoryorder) {
		(@theboards) = split(/\,/, $cat{$thiscat});
		for ($z = 0; $z < @theboards; $z++) {
			for ($j = 0; $j < @editboards; $j++) {
				if ($editboards[$j] eq $theboards[$z]) {
					$editbrd[$i] = $theboards[$z];
					$i++;
				}
			}
		}
	}
	if    ($FORM{'baction'} eq "edit")  { &AddBoards(@editbrd); }
	elsif ($FORM{'baction'} eq "delme") {
		foreach $board (@editboards) {
			if ($board eq "") { next; }

			# Remove Board form category it belongs to
			$category = ${$uid.$board}{'cat'};
			unless ($mloaded == 1) { require "$boardsdir/forum.master"; }
			(@bdlist) = split(/\,/, $cat{"$category"});
			$c = 0;
			foreach $bd (@bdlist) {
				if ($bd eq $board) { splice(@bdlist, $c, 1); last; }
				$c++;
			}
			my @brdlist = &undupe(@bdlist);
			$boardlist = join(',', @brdlist);
			$cat{"$category"} = "$boardlist";
			delete $board{"$board"};
			&Write_ForumMaster;
			$yymain .= qq~$admin_txt{'55'}$board <br />~;
		}

		# Actual deleting
		$editboards = join(',', @editboards);
		&DeleteBoards($editboards);
	} else {
		&admin_fatal_error("$admin_txt{'56'} $FORM{'baction'}");
	}
	$action_area = "manageboards";
	&AdminTemplate;
	exit;
}

sub DeleteBoards {
	my ($editboards) = @_;
	&is_admin_or_gmod;
	(@killboards) = split(/\,/, $editboards);
	fopen(FORUMCONTROL, "+<$boardsdir/forum.control") || die $!;
	seek FORUMCONTROL, 0, 0;
	my @oldcontrols = <FORUMCONTROL>;
	my ($oldboard);
	foreach $board (@killboards) {
		fopen(BOARDDATA, "$boardsdir/$board.txt");
		@messages = <BOARDDATA>;
		fclose(BOARDDATA);
		foreach $curmessage (@messages) {
			($id, $dummy) = split(/\|/, $curmessage);
			unlink("$datadir/$id\.txt");
			unlink("$datadir/$id\.mail");
			unlink("$datadir/$id\.ctb");
			unlink("$datadir/$id\.data");
			unlink("$datadir/$id\.poll");
			unlink("$datadir/$id\.polled");
		}
		for (my $cnt = 0; $cnt <= $#oldcontrols; $cnt++) {
			($dummy, $oldboard, $dummy, $dummy, $dummy, $dummy, $dummy, $dummy, $dummy, $dummy, $dummy, $dummy, $dummy, $dummy, $dummy) = split(/\|/, $oldcontrols[$cnt]);
			$yydebug .= "$cnt   $oldboard \n";
			if ($oldboard eq $board) {
				$oldcontrols[$cnt] = "";
				$yydebug .= "\$board{\"$oldboard\"}";
				delete $board{"$board"};
				last;
			} else {
				next;
			}
		}
		unlink("$boardsdir/$board.txt");
		unlink("$boardsdir/$board.ttl");
		unlink("$boardsdir/$board.poster");
		unlink("$boardsdir/$board.mail");
		fopen(AMV, "$vardir/attachments.txt");
		my @attachments = <AMV>;
		fclose(AMV);
		fopen(AMV, ">$vardir/attachments.txt");

		foreach $row (@attachments) {
			chomp $row;
			my ($amthreadid, $amreplies, $amthreadsub, $amposter, $amcurrentboard, $amkb, $amdate, $amfn) = split(/\|/, $row);
			if ($amcurrentboard ne $board) {
				print AMV qq~$amthreadid|$amreplies|$amthreadsub|$amposter|$amcurrentboard|$amkb|$amdate|$amfn\n~;
			} else {
				if (-e ("$upload_dir/$amfn")) {
					unlink("$upload_dir/$amfn");
				}
			}
		}
		fclose(AMV);
	}
	&Write_ForumMaster;
	seek FORUMCONTROL, 0, 0;
	truncate FORUMCONTROL, 0;
	push(@boardcontrol, @oldcontrols);
	@boardcontrol = sort(@boardcontrol);
	print FORUMCONTROL @boardcontrol;
	fclose(FORUMCONTROL);
	fopen(FORUMCONTROL, "$boardsdir/forum.control");
	@forum_control = <FORUMCONTROL>;
	fclose(FORUMCONTROl);
}

sub AddBoards {
	my @editboards = @_;
	&is_admin_or_gmod;
	if ($INFO{"action"} eq "boardscreen") { $FORM{"amount"} = $#editboards; }
	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }
	$yymain .= qq~
<form name="boardsadd" action="$adminurl?action=addboard2" method="post">
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
<table border="0" align="center" cellspacing="1" cellpadding="4" width="100%">
  <tr>
    <td class="titlebg" colspan="5" align="left">
    <img src="$imagesdir/cat.gif" alt="" border="0" />
    <b>$admin_txt{'50'}</b></td>
  </tr><tr>
      <td class="windowbg2" colspan="5" align="left"><br />$admin_txt{'57'}<br /><br /></td>
  </tr>
</table>
</div>
<br />
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
<table border="0" align="center" cellspacing="1" cellpadding="4" width="100%">
~;

	# Check if and which board are set for announcements or recycle bin
	# Start Looping through and repeating the board adding wherever needed
	$istart    = 0;
	$annexist  = "";
	$rbinexist = "";

	for ($i = 1; $i != $FORM{'amount'} + 1; $i++) {

		# differentiate between edit or add boards
		if ($editboards[$i] eq "" && $INFO{"action"} eq "boardscreen") { next; }
		if ($INFO{"action"} eq "boardscreen") {
			$id = $editboards[$i];
		} else {
			$boardtext = "$admin_txt{'58'} $i:";
		}
		foreach $catid (@categoryorder) {
			$boardlist = $cat{$catid};
			(@bdlist) = split(/\,/, $boardlist);
			($curcatname, $catperms) = split(/\|/, $catinfo{"$catid"});
			my $boardcat = ${$uid.$editboards[$i]}{'cat'};
			if ($INFO{"action"} eq "boardscreen") {
				if ($catid eq $boardcat) { $selected = qq~selected="selected" ~; }
				else { $selected = ""; }
			}
			$catsel{$i} .= qq~<option value="$catid"$selected>$curcatname</option>~;
		}
		$catsel .= qq~</select>~;
		if ($istart == 0) { $istart = $i; }

		($boardname, $boardperms, $boardview) = split(/\|/, $board{"$id"});
		&ToChars($boardname);
		if ($INFO{"action"} eq "boardscreen") { $boardtext = $boardname; }
		$boardpic    = ${$uid.$editboards[$i]}{'pic'};
		$description = ${$uid.$editboards[$i]}{'description'};
		$description =~ s~<br />~\n~g;
		&ToChars($description);
		$moderators      = ${$uid.$editboards[$i]}{'mods'};
		$moderatorgroups = ${$uid.$editboards[$i]}{'modgroups'};
		$boardminage     = ${$uid.$editboards[$i]}{'minageperms'};
		$boardmaxage     = ${$uid.$editboards[$i]}{'maxageperms'};
		$boardgender     = ${$uid.$editboards[$i]}{'genderperms'};
		$genselect       = qq~<select name="gender$i">~;
		$gentag[0]       = "";
		$gentag[1]       = "M";
		$gentag[2]       = "F";
		$gentag[3]       = "B";
		foreach $genlabel (@gentag) {
			$gentext = "99";
			$gentext .= $genlabel;
			if ($genlabel eq $boardgender) {
				$genselect .= qq~<option value="$genlabel" selected="selected">$admin_txt{$gentext}</option>~;
			} else {
				$genselect .= qq~<option value="$genlabel">$admin_txt{$gentext}</option>~;
			}
		}
		$genselect .= qq~</select>~;

		# Retrieve Optional Details
		$ann      = "";
		$rbin     = "";
		$zeroch   = "";
		$attch    = "";
		$showpriv = "";
		$brdpic   = "";
		if ($boardview == 1)              { $showpriv = qq~ checked="checked"~; }
		if (${$uid.$id}{'zero'} == 1)     { $zeroch   = qq~ checked="checked"~; }
		if (${$uid.$id}{'attperms'} == 1) { $attch    = qq~ checked="checked"~; }

		if (${$uid.$id}{'ann'} == 1) {
			$annch = qq~ checked="checked"~;
			$brdpic   = qq~ disabled="disabled"~;
		} elsif ($annboard ne "") {
			$annch    = qq~ disabled="disabled"~;
			$annexist = 1;
		}
		if (${$uid.$id}{'rbin'} == 1) {
			$rbinch = qq~ checked="checked"~;
			$brdpic   = qq~ disabled="disabled"~;
		} elsif ($binboard ne "") {
			$rbinch    = qq~ disabled="disabled"~;
			$rbinexist = 1;
		}

		#Get Board permissions here
		$startperms = &DrawPerms(${$uid.$id}{'topicperms'}, 0);
		$replyperms = &DrawPerms(${$uid.$id}{'replyperms'}, 1);
		$viewperms  = &DrawPerms($boardperms, 0);
		$pollperms  = &DrawPerms(${$uid.$id}{'pollperms'},  0);
		$yymain .= qq~
  <tr>
	<td class="titlebg" width="100%" colspan="5" align="left"> <b>$boardtext</b></td>
  </tr><tr>
	<td class="catbg"  colspan="4"><b>$admin_txt{'59'}:</b> $admin_txt{'60'}</td>
  </tr><tr>
	<td class="windowbg" width="25%" align="left"><b>$admin_txt{'61'}:</b></td>~;
		if ($id ne "") {
			$yymain .= qq~
    <td class="windowbg2" width="75%" colspan="3" align="left"><input type="hidden" name="id$i" value="$id" />$id</td>~;
		} else {
			$yymain .= qq~
    <td class="windowbg2" width="75%" colspan="3" align="left"><input type="text" name="id$i" /></td>~;
		}
		$yymain .= qq~
  </tr><tr>
    <td class="windowbg"  width="25%" align="left"><b>$admin_txt{'68'}:</b></td>
    <td class="windowbg2" width="75%" colspan="3" align="left"><input type="text" name="name$i" value="$boardname" size="50" maxlength="100" /></td>
  </tr><tr>
    <td class="windowbg" width="25%" align="left"><b>$admin_txt{'62'}:</b></td>
    <td class="windowbg2" width="75%" colspan="3" align="left"><textarea name="description$i" rows="5" cols="30" style="width:98%; height:60px">$description</textarea></td>
  </tr><tr>
    <td class="windowbg" width="25%" align="left"><b>$admin_txt{'63'}:</b></td>
    <td class="windowbg2" width="75%" colspan="3" align="left"><input type="text" name="moderators$i" value="$moderators" size="50" maxlength="100" />
  </tr><tr>
    <td class="windowbg" width="25%" align="left"><b>$admin_txt{'13'}:</b></td>
	<td class="windowbg2"  width="75%" colspan="3">
~;

		# Allows admin to select entire membergroups to be a board moderator
		$k = 0;
		my $box = "";
		foreach (sort { $a <=> $b } keys %NoPost) {
			@groupinfo = split(/\|/, $NoPost{$_});
			$box .= qq~<option value="$_"~;
			@a = split(/\, /, $moderatorgroups);
			foreach $line (@a) {
				($lineinfo, undef) = split(/\|/, $NoPost{$line});
				if ($lineinfo eq $groupinfo[0]) {
					$box .= qq~ selected="selected" ~;
				}
			}
			$box .= qq~>$groupinfo[0]</option>~;
			$k++;
		}
		if ($k > 5) { $k = 5; }
		if ($k > 0) {
			$yymain .= qq~<select multiple="multiple" name="moderatorgroups$i" size="$k">$box</select> $admin_txt{'14'}~;
		} else {
			$yymain .= qq~$admin_txt{'15'}~;
		}
		$yymain .= qq~
	</td>
  </tr><tr>
    <td class="windowbg" width="25%" align="left"><b>$admin_txt{'44'}:</b></td>
    <td class="windowbg2" width="75%" colspan="3" align="left"><select name="cat$i">$catsel{$i}</td>
  </tr><tr>
    <td class="catbg"  colspan="4"><b>$admin_txt{'64'}</b> $admin_txt{'64a'} </td>
  </tr><tr>
    <td class="windowbg" width="25%" align="left"><b>$admin_txt{'64b'}:</b></td>
    <td class="windowbg2" width="75%" colspan="3" align="left"><input type="text" id="pic$i" name="pic$i" value="$boardpic" size="50" maxlength="255"$brdpic /></td>
  </tr><tr>
    <td class="windowbg" width="25%" align="left"><b>$admin_txt{'64c'}</b></td>
    <td class="windowbg2" width="75%" colspan="3" align="left"><input type="checkbox" name="zero$i" value="1"$zeroch /> $admin_txt{'64d'}</td>
  </tr><tr>
    <td class="windowbg" width="25%" align="left"><b>$admin_txt{'64e'}</b></td>
    <td class="windowbg2" width="75%" colspan="3" align="left"><input type="checkbox" name="show$i" value="1"$showpriv /> $admin_txt{'64f'}</td>
  </tr><tr>
    <td class="windowbg" width="25%" align="left"><b>$admin_txt{'64k'}</b></td>
    <td class="windowbg2" width="75%" colspan="3" align="left"><input type="checkbox" name="att$i" value="1"$attch /> $admin_txt{'64l'}</td>
  </tr><tr>
    <td class="windowbg" width="25%" align="left"><b>$admin_txt{'64g'}:</b></td>
    <td class="windowbg2" width="75%" colspan="3" align="left"><input type="checkbox" id="ann$i" name="ann$i" value="1" $annch onclick="javascript: if (this.checked) checkann(true, '$i'); else checkann(false, '$i');" /> $admin_txt{'64h'}</td>
  </tr><tr>
    <td class="windowbg" width="25%" align="left"><b>$admin_txt{'64i'}:</b></td>
    <td class="windowbg2" width="75%" colspan="3" align="left"><input type="checkbox" id="rbin$i" name="rbin$i" value="1" $rbinch onclick="javascript: if (this.checked) checkbin(true, '$i'); else checkbin(false, '$i');" /> $admin_txt{'64j'}</td>
  </tr><tr>
    <td class="catbg"  colspan="4"><b>$admin_txt{'100'}:</b> $admin_txt{'100a'}</td>
  </tr><tr>
    <td class="windowbg" width="25%" align="left"><b>$admin_txt{'95'}:</b></td>
    <td class="windowbg2" width="75%" colspan="3" align="left"><input type="text" size="3" name="minage$i" value="$boardminage" /> $admin_txt{'96'}</td>
  </tr><tr>
    <td class="windowbg" width="25%" align="left"><b>$admin_txt{'95a'}:</b></td>
    <td class="windowbg2" width="75%" colspan="3" align="left"><input type="text" size="3" name="maxage$i" value="$boardmaxage" /> $admin_txt{'96a'}</td>
  </tr><tr>
    <td class="windowbg" width="25%" align="left"><b>$admin_txt{'97'}:</b></td>
    <td class="windowbg2" width="75%" colspan="3" align="left">$genselect $admin_txt{'98'}</td>
  </tr><tr>
    <td class="catbg"  colspan="4"><b>$admin_txt{'65'}:</b> $admin_txt{'65a'}</td>
  </tr><tr>
    <td class="titlebg" width="25%" align="center"><b>$admin_txt{'65b'}:</b></td>
    <td class="titlebg" width="25%" align="center"><b>$admin_txt{'65c'}:</b></td>
    <td class="titlebg" width="25%" align="center"><b>$admin_txt{'65d'}:</b></td>
    <td class="titlebg" width="25%" align="center"><b>$admin_txt{'65e'}:</b></td>
  </tr><tr>
    <td class="windowbg2" width="25%" align="center"><select multiple="multiple" name="topicperms$i" size="8">$startperms</td>
    <td class="windowbg2" width="25%" align="center"><select multiple="multiple" name="replyperms$i" size="8">$replyperms</td>
    <td class="windowbg2" width="25%" align="center"><select multiple="multiple" name="viewperms$i" size="8">$viewperms</td>
    <td class="windowbg2" width="25%" align="center"><select multiple="multiple" name="pollperms$i" size="8">$pollperms</td>
  </tr>
</table>
</div>
<br /><br />
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
<table border="0" align="center" cellspacing="1" cellpadding="4" width="100%">
~;
	}
	$yymain .= qq~
  <tr>
      <td class="catbg" width="100%" colspan="5" align="center"> <input type="hidden" name="amount" value=\"$FORM{"amount"}\" /><input type="hidden" name="screenornot" value="$INFO{'action'}" /><input type="submit" value="$admin_txt{'10'}" /></td>
  </tr>
</table>
</div>
</form>

<script language="JavaScript1.2" type="text/javascript">
<!--
var numboards = "$FORM{'amount'}";
var annexist = "$annexist";
var rbinexist = "$rbinexist";
var istart = "$istart";

function checkann(acheck, awho) {
	var adischeck = acheck;
	var adisuncheck = acheck;
	for (var i = istart; i <= numboards; i++) {
		if(i != awho) {
			if(document.getElementById('rbin'+i).checked == true) {
				adischeck = true;
				document.getElementById('ann'+i).disabled = true;
			}
			else {
				document.getElementById('ann'+i).disabled = acheck;
			}
		}
	}
	if(document.getElementById('ann'+awho).checked == true) adischeck = true;
	document.getElementById('rbin'+awho).disabled = adischeck;
	document.getElementById('pic'+awho).disabled = adisuncheck;
	if(rbinexist == '1') document.getElementById('rbin'+awho).disabled = true;
}

function checkbin(bcheck, bwho) {
	var bdischeck = bcheck;
	var bdisuncheck = bcheck;
	for (var i = istart; i <= numboards; i++) {
		if(i != bwho) {
			if(document.getElementById('ann'+i).checked == true) {
				bdischeck = true;
				document.getElementById('rbin'+i).disabled = true;
			}
			else document.getElementById('rbin'+i).disabled = bcheck;
		}
	}
	if(document.getElementById('rbin'+bwho).checked == true) bdischeck = true;
	document.getElementById('ann'+bwho).disabled = bdischeck;
	document.getElementById('pic'+bwho).disabled = bdisuncheck;
	if(annexist == '1') document.getElementById('ann'+bwho).disabled = true;
}
//-->
</script>

	~;
	$yytitle     = "Add Board";
	$action_area = "manageboards";
	&AdminTemplate;
	exit;
}

sub DrawPerms {
	my ($permissions) = @_[0];
	my ($permstype)   = @_[1];
	my $count, @perms, $foundit, %found, $groupsel, $groupsel2, $name;
	%found = ();
	if ($permissions eq "") { $permissions = "xk8yj56ndkal"; }
	(@perms) = split(/\, /, $permissions);
	$groupsel  = "\n";
	$groupsel2 = "";
	$adchk     = "";
	$gmchk     = "";
	$nwbchk    = "";
	$count     = 0;
	foreach $perm (@perms) {
		$foundit = 0;
		chomp $perm;
		if ($permstype == 1) {
			$name = qq~$admin_txt{'65f'}~;
			if ($perm eq "Topic Starter") {
				$foundit = 1;
				$found{$name} = 1;
				$groupsel .= qq~<option value="Topic Starter" selected="selected">$name</option>\n~;
			}
			if ($count == $#perms && $found{$name} != 1) { $groupsel2 .= qq~<option value="Topic Starter">$name</option>\n~; }
		}

		($name, $t, $t, $t) = split(/\|/, $Group{"Administrator"});
		if ($perm eq "Administrator") {
			$foundit = 1;
			$found{$name} = 1;
			$groupsel .= qq~<option value="Administrator" selected="selected">$name</option>\n~;
		}
		if ($count == $#perms && $found{$name} != 1) { $groupsel2 .= qq~<option value="Administrator">$name</option>\n~; }
		($name, $t, $t, $t) = split(/\|/, $Group{"Global Moderator"});
		if ($perm eq "Global Moderator") {
			$foundit = 1;
			$found{$name} = 1;
			$groupsel .= qq~<option value="Global Moderator" selected="selected">$name</option>\n~;
		}
		if ($count == $#perms && $found{$name} != 1) { $groupsel2 .= qq~<option value="Global Moderator">$name</option>\n~; }
		if ($foundit != 1 || $count == $#perms) {
			$j = 0;
			foreach (sort { $a <=> $b } keys %NoPost) {
				($name, $t, $t, $t) = split(/\|/, $NoPost{$_});
				if ($perm eq $_) {
					$foundit = 1;
					$found{$_} = 1;
					$groupsel .= qq~<option value="$_" selected="selected">$name</option>\n~;
				}
				if ($found{$_} != 1 && $count == $#perms) { $groupsel2 .= qq~<option value="$_">$name</option>\n~; }
				$j++;
			}
			if ($foundit != 1 || $count == $#perms) {
				foreach (sort { $b <=> $a } keys %Post) {
					($name, $t, $t, $t) = split(/\|/, $Post{$_});
					if ($perm eq $name) {
						$foundit = 1;
						$found{$name} = 1;
						$groupsel .= qq~<option value="$name" selected="selected">$name</option>\n~;
					}
					if ($count == $#perms && ($found{$name} != 1 || $found{$name} eq "")) { $groupsel2 .= qq~<option value="$name">$name</option>\n~; }
				}
			}
		}
		$count++;
	}
	$groupsel .= $groupsel2;
	$groupsel .= "</select>";
	return $groupsel;
}

sub AddBoards2 {
	&is_admin_or_gmod;
	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }
	$anncount  = 0;
	$rbincount = 0;
	for (my $i = 1; $i != $FORM{'amount'} + 1; $i++) {
		if ($FORM{"pic$i"} ne "" && $FORM{"pic$i"} !~ m~^[0-9a-zA-Z_\.\#\%\-\:\+\?\$\&\~\.\,\@/]+\.(gif|png|bmp|jpg)$~) { &admin_fatal_error("$admin_txt{'16'}"); }
		##### Dealing with Required Info here #####
		if ($FORM{"id$i"} eq "") { next; }
		$id = $FORM{"id$i"};
		if ($FORM{"ann$i"})  { $anncount++; }
		if ($FORM{"rbin$i"}) { $rbincount++; }
		&admin_fatal_error("$admin_txt{'850'}")                                    if ($anncount > 1);
		&admin_fatal_error("$admin_txt{'851'}")                                    if ($rbincount > 1);
		&admin_fatal_error("$admin_txt{'240'} $admin_txt{'61'} $admin_txt{'241'}") if ($id !~ /\A[0-9A-Za-z#%+-\.@^_]+\Z/);

		if ($FORM{'screenornot'} ne "boardscreen") {
			# adding a board
			# make sure no board already exists with that id
			&admin_fatal_error("$admin_txt{'674'} '$id' $admin_txt{'675'}") if (exists $board{"$id"});

			my (@bdlist) = split(/\,/, $cat{"$FORM{\"cat$i\"}"});
			push(@bdlist, "$id");
			my ($bdlist) = join(',', @bdlist);
			$cat{ $FORM{"cat$i"} } = $bdlist;
			fopen(BOARDINFO, ">$boardsdir/$id.txt");
			print BOARDINFO '';
			fclose(BOARDINFO);
		}
		if ($FORM{'screenornot'} eq "boardscreen") {
			# editing a board
			my $category = ${$uid.$id}{'cat'};

			# move category of board
			if ($category ne $FORM{"cat$i"}) {
				${$uid.$id}{'cat'} = qq~$FORM{"cat$i"}~;
				my (@bdlist) = split(/\,/, $cat{$category});

				# Remove Board from old Category
				my $k = 0;
				foreach $bd (@bdlist) {
					if ($id eq $bd) { splice(@bdlist, $k, 1); }
					$k++;
				}
				my $boardlist = join(',', @bdlist);
				$cat{"$category"} = $boardlist;

				# Add Category to new Category
				my $ncat   = $FORM{"cat$i"};
				my $newcat = $cat{$ncat};
				if ($newcat ne "") { $newcat .= ",$id"; }
				else { $newcat .= "$id"; }
				$cat{$ncat} = $newcat;
			}
		}

		$bname = $FORM{"name$i"};
		$bname =~ s/\"/&quot;/g;
		&FromChars($bname);

		# If someone has the bright idea of starting a membergroup with a $
		# We need to escape it for them, to prevent us interpreting it as a var...
		$FORM{"viewperms$i"} =~ s~\$~\\\$~g;

		$board{"$id"} = "$bname|$FORM{\"viewperms$i\"}|$FORM{\"show$i\"}";
		$bdescription = $FORM{"description$i"};
		&FromChars($bdescription);
		$bdescription         =~ s/\r//g;
		$bdescription         =~ s~\n~<br \/>~g;
		$FORM{"moderators$i"} =~ s/\s*,\s*/,/g;
		$FORM{"moderators$i"} =~ s/ /,/g;
		$FORM{"moderators$i"} =~ s/\s*,\s*/, /g;
		if ($FORM{"zero$i"} eq '') { $FORM{"zero$i"} = 0; }
		$FORM{"minage$i"} =~ tr/[0-9]//cd;    ## remove non numbers
		$FORM{"maxage$i"} =~ tr/[0-9]//cd;    ## remove non numbers
		if ($FORM{"minage$i"} < 0)   { $FORM{"minage$i"} = ""; }
		if ($FORM{"maxage$i"} < 0)   { $FORM{"maxage$i"} = ""; }
		if ($FORM{"minage$i"} > 180) { $FORM{"minage$i"} = ""; }
		if ($FORM{"maxage$i"} > 180) { $FORM{"maxage$i"} = ""; }
		if ($FORM{"maxage$i"} && $FORM{"maxage$i"} < $FORM{"minage$i"}) { $FORM{"maxage$i"} = $FORM{"minage$i"}; }

		push(@boardcontrol, "$FORM{\"cat$i\"}|$id|$FORM{\"pic$i\"}|$bdescription|$FORM{\"moderators$i\"}|$FORM{\"moderatorgroups$i\"}|$FORM{\"topicperms$i\"}|$FORM{\"replyperms$i\"}|$FORM{\"pollperms$i\"}|$FORM{\"zero$i\"}|$FORM{\"membergroups$i\"}|$FORM{\"ann$i\"}|$FORM{\"rbin$i\"}|$FORM{\"att$i\"}|$FORM{\"minage$i\"}|$FORM{\"maxage$i\"}|$FORM{\"gender$i\"}\n");
		push(@changes,      $id);
		$yymain .= qq~<i>'$FORM{"name$i"}'</i> $admin_txt{'48'} <br />~;
	}
	&Write_ForumMaster;
	fopen(FORUMCONTROL, "+<$boardsdir/forum.control");
	seek FORUMCONTROL, 0, 0;
	my @oldcontrols = <FORUMCONTROL>;
	my ($oldboard, $oldcontrol, $changedboard,);
	for (my $cnt = 0; $cnt <= $#oldcontrols; $cnt++) {
		($dummy, $oldboard, $dummy, $dummy, $dummy, $dummy, $dummy, $dummy, $dummy, $dummy, $dummy, $dummy, $dummy, $dummy, $dummy, $dummy, $dummy, $dummy) = split(/\|/, $oldcontrols[$cnt]);
		foreach $changedboard (@changes) {
			chomp $changedboard;
			if ($changedboard eq $oldboard) {
				$oldcontrols[$cnt] = "";
			}
		}
	}
	seek FORUMCONTROL, 0, 0;
	truncate FORUMCONTROL, 0;
	push(@boardcontrol, @oldcontrols);
	@boardcontrol = sort(@boardcontrol);
	print FORUMCONTROL @boardcontrol;
	fclose(FORUMCONTROL);
	$action_area = "manageboards";
	&AdminTemplate;
	exit;
}

sub ReorderBoards {
	&is_admin_or_gmod;
	unless ($mloaded == 1)       { require "$boardsdir/forum.master"; }
	if     ($#categoryorder > 0) {
		foreach $category (@categoryorder) {
			chomp $category;
			($categoryname, undef) = split(/\|/, $catinfo{$category});
			&ToChars($categoryname);
			if ($category eq $INFO{"item"}) {
				$categorylistsel = qq~<option value="$category" selected="selected">$categoryname</option>~;
			} else {
				$categorylist .= qq~<option value="$category">$categoryname</option>~;
			}
		}
	}
	(@bdlist) = split(/\,/, $cat{ $INFO{"item"} });
	$bdcnt = @bdlist;
	$bdnum = $bdcnt;
	if ($bdcnt < 4) { $bdcnt = 4; }
	($curcatname, $catperms) = split(/\|/, $catinfo{ $INFO{"item"} });
	&ToChars($curcatname);

	# Prepare the list of current boards to be put in the select box
	$boardslist = qq~<select name="selectboards" size="$bdcnt" style="width: 190px;">~;
	foreach $board (@bdlist) {
		chomp $board;
		($boardname, undef) = split(/\|/, $board{$board}, 2);
		&ToChars($boardname);
		if ($board eq $INFO{'theboard'}) {
			$boardslist .= qq~<option value="$board" selected="selected">$boardname</option>~;
		} else {
			$boardslist .= qq~<option value="$board">$boardname</option>~;
		}
	}
	$boardslist .= qq~</select>~;

	$yymain .= qq~
<br /><br />
<form action="$adminurl?action=reorderboards2;item=$INFO{'item'}" method="POST">
<table border="0" width="525" cellspacing="1" cellpadding="4" class="bordercolor" align="center">
  <tr>
    <td class="titlebg"><img src="$imagesdir/board.gif" alt="" style="vertical-align: middle;" /> <b>$admin_txt{'832'} ($curcatname)</b></td>
  </tr>
  <tr>
    <td class="windowbg" valign="middle" align="left">
~;
	if ($bdnum) {
		$yymain .= qq~
    <div style="float: left; width: 280px; text-align: left; margin-bottom: 4px;" class="small">$admin_txt{'739'}</div>
    <div style="float: left; width: 230px; text-align: center; margin-bottom: 4px;">$boardslist</div>
    <div style="float: left; width: 280px; text-align: left; margin-bottom: 4px;" class="small">$admin_txt{'739d'}</div>
    <div style="float: left; width: 230px; text-align: center; margin-bottom: 4px;">
	<input type="submit" value="$admin_txt{'739a'}" name="moveup" style="font-size: 11px; width: 95px;" /><input type="submit" value="$admin_txt{'739b'}" name="movedown" style="font-size: 11px; width: 95px;" />
    </div>
~;
		if ($#categoryorder > 0) {
			$yymain .= qq~
    <div class="small" style="float: left; width: 280px; text-align: left; margin-bottom: 4px;">$admin_txt{'739c'}</div>
    <div style="float: left; width: 230px; text-align: center; margin-bottom: 4px;">
	<select name="selectcategory" style="width: 190px;" onchange="submit();">
	$categorylistsel
	$categorylist
	</select>
    </div>
~;
		}
	} else {
		$yymain .= qq~
    <div class="small" style="text-align: center; margin-bottom: 4px;">$admin_txt{'739e'}</div>
~;
	}
	$yymain .= qq~
    </td>
  </tr>
</table>
</form>
~;
	$yytitle     = "$admin_txt{'46'}";
	$action_area = "manageboards";
	&AdminTemplate;
	exit;
}

sub ReorderBoards2 {
	&is_admin_or_gmod;
	my $tmp_master = "";
	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }
	@itemorder = split(/\,/, $cat{ $INFO{"item"} });
	my $moveitem = $FORM{'selectboards'};
	my $category = $INFO{"item"};
	if ($moveitem) {
		if ($FORM{'moveup'} || $FORM{'movedown'}) {
			if ($FORM{'moveup'}) {
				for ($i = 0; $i < @itemorder; $i++) {
					if ($itemorder[$i] eq $moveitem && $i > 0) {
						$j             = $i - 1;
						$itemorder[$i] = $itemorder[$j];
						$itemorder[$j] = $moveitem;
						last;
					}
				}
			} elsif ($FORM{'movedown'}) {
				for ($i = 0; $i < @itemorder; $i++) {
					if ($itemorder[$i] eq $moveitem && $i < $#itemorder) {
						$j             = $i + 1;
						$itemorder[$i] = $itemorder[$j];
						$itemorder[$j] = $moveitem;
						last;
					}
				}
			}
			foreach $item (@itemorder) {
				if ($item) {
					$tmp_master .= qq~$item,~;
				}
			}
			$tmp_master =~ s/,\Z//;
			$cat{$category} = qq~$tmp_master~;
		} else {
			if ($category ne $FORM{"selectcategory"}) {
				${$uid.$moveitem}{'cat'} = qq~$FORM{'selectcategory'}~;
				my (@bdlist) = split(/\,/, $cat{$category});
				my $k = 0;
				foreach $bd (@bdlist) {
					if ($moveitem eq $bd) { splice(@bdlist, $k, 1); }
					$k++;
				}
				my $boardlist = join(',', @bdlist);
				$cat{"$category"} = $boardlist;
				my $ncat   = $FORM{"selectcategory"};
				my $newcat = $cat{$ncat};
				if ($newcat ne "") { $newcat .= ",$moveitem"; }
				else { $newcat .= "$moveitem"; }
				$newcat =~ s/,\Z//;
				$cat{$ncat} = $newcat;
				$category = qq~$FORM{"selectcategory"}~;
			}

		}
		&Write_ForumMaster;


		fopen(FORUMCONTROL, "+<$boardsdir/forum.control");
		seek FORUMCONTROL, 0, 0;
		my @oldcontrols = <FORUMCONTROL>;
		my ($oldboard, $oldcontrol, $changedboard,);
		for (my $cnt = 0; $cnt <= $#oldcontrols; $cnt++) {
			($dummy, $oldboard,$pic,$bdescription,$moderators,$moderatorgroups,$topicperms,$replyperms,$pollperms,$zero,$membergroups,$ann,$rbin,$att,$minage,$maxage,$gender) = split(/\|/, $oldcontrols[$cnt]);
			chomp $changedboard;
			if ($moveitem eq $oldboard) {
				$oldcontrols[$cnt] = "";
				push(@boardcontrol, qq~$category|$moveitem|$pic|$bdescription|$moderators|$moderatorgroups|$topicperms|$replyperms|$pollperms|$zero|$membergroups|$ann|$rbin|$att|$minage|$maxage|$gender~);
			}
		}
		seek FORUMCONTROL, 0, 0;
		truncate FORUMCONTROL, 0;
		push(@boardcontrol, @oldcontrols);
		@boardcontrol = sort(@boardcontrol);
		print FORUMCONTROL @boardcontrol;
		fclose(FORUMCONTROL);

	}
	$yySetLocation = qq~$adminurl?action=reorderboards;item=$category;theboard=$moveitem~;
	&redirectexit;
}

sub ConfRemBoard {
	$yymain .= qq~
<table border="0" width="100%" cellspacing="1" class="bordercolor">
<tr>
	<td class="titlebg"><b>$admin_txt{'31'} - '$FORM{'boardname'}'?</b></td>
</tr>
<tr>
	<td class="windowbg" >
$admin_txt{'617'}<br />
<b><a href="$adminurl?action=modifyboard;cat=$FORM{'cat'};id=$FORM{'id'};moda=$admin_txt{'31'}2">$admin_txt{'163'}</a> - <a href="$adminurl?action=manageboards">$admin_txt{'164'}</a></b>
</td>
</tr>
</table>
~;
	$yytitle     = "$admin_txt{'31'} - '$FORM{'boardname'}'?";
	$action_area = "manageboards";
	&AdminTemplate;
	exit;
}
1;
