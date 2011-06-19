###############################################################################
# Post.pl                                                                     #
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

$postplver = 'YaBB 2.1 $Revision: 1.18 $';
if ($action eq 'detailedversion') { return 1; }

LoadLanguage("Post");
LoadLanguage("Display");
LoadLanguage("FA");
require "$sourcedir/Notify.pl";

$set_subjectMaxLength ||= 100;

sub Post {
	if ($iamguest && $enable_guestposting == 0) { &fatal_error($post_txt{'165'}); }
	if ($currentboard eq '') { &fatal_error($post_txt{'1'}); }
	my ($filetype_info, $filesize_info);
	my ($subtitle, $x, $mnum, $msub, $mname, $memail, $mdate, $mreplies, $musername, $micon, $mstate, $msubject, $mattach, $mip, $mmessage, $mns, $quotestart, $notify);
	my $quotemsg = $INFO{'quote'};
	$threadid = $INFO{'num'};

	($mnum, $msub, $mname, $memail, $mdate, $mreplies, $musername, $micon, $mstate) = split(/\|/, $yyThreadLine);
	if ($mstate =~ /l/i) { &fatal_error($post_txt{'90'}); }
	if ($mstate =~ /a/i && !$iamadmin && !$iamgmod) { &fatal_error($post_txt{'1'}); }

	# Determine category
	$curcat = ${$uid.$currentboard}{'cat'};
	&BoardTotals("load", $currentboard);

	# Figure out the name of the category
	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }
	($cat, $catperms) = split(/\|/, $catinfo{"$curcat"});
	&ToChars($cat);

	$pollthread = 0;
	$postthread = 0;
	$INFO{'title'} =~ tr/+/ /;

	if    ($INFO{'title'} eq 'CreatePoll') { $pollthread = 1; $t_title = "$post_polltxt{'1a'}"; }
	elsif ($INFO{'title'} eq 'AddPoll')    { $pollthread = 2; $t_title = "$post_polltxt{'2a'}"; }
	elsif ($INFO{'title'} eq 'PostReply')  { $postthread = 2; $t_title = "$display_txt{'116'}"; }
	else { $postthread = 1; $t_title = "$post_txt{'33'}"; }

	if ($pollthread == 2 && $useraddpoll == 0) { &fatal_error($post_txt{'1'}); }
	if ($postthread == 2 && $username ne "Guest") {
		$j           = 0;
		@tmprepliers = ();
		for ($i = 0; $i < @repliers; $i++) {
			chomp $repliers[$i];
			($reptime, $repuser, $isreplying) = split(/\|/, $repliers[$i]);
			$outtime = $date - $reptime;
			if ($outtime > 600) { next; }
			elsif ($repuser eq $username) { $tmprepliers[$j] = qq~$date|$repuser|1~; $isrep = 1; }
			else { $tmprepliers[$j] = qq~$reptime|$repuser|$isreplying~; }
			$j++;
		}
		if (!$isrep) {
			$thisreplier = qq~$date|$username|1~;
			push(@tmprepliers, $thisreplier);
		}
		@repliers = @tmprepliers;
		&MessageTotals("update", $curnum);
	}

	$name_field = $realname eq ''
	  ? qq~      <tr>
    <td class="windowbg" align="left" width="23%"><b>$post_txt{'68'}:</b></td>
    <td class="windowbg" align="left" width="77%"><input type="text" name="name" size="25" value="$FORM{'name'}" maxlength="25" tabindex="2" /></td>
      </tr>~
	  : qq~~;

	$email_field = $realemail eq ''
	  ? qq~      <tr>
    <td class="windowbg" width="23%"><b>$post_txt{'69'}:</b></td>
    <td class="windowbg" width="77%"><input type="text" name="email" size="25" value="$FORM{'email'}" maxlength="40" tabindex="3" /></td>
      </tr>~
	  : qq~~;

	$sub        = "";
	$settofield = "subject";
	if ($threadid ne '') {
		fopen(FILE, "$datadir/$threadid.txt") || &fatal_error("201 $post_txt{'106'}: $post_txt{'23'} $threadid.txt", 1);
		@messages = <FILE>;
		fclose(FILE);
		if ($quotemsg ne '') {
			($msubject, $mname, $memail, $mdate, $musername, $micon, $mattach, $mip, $mmessage, $mns) = split(/\|/, $messages[$quotemsg]);
			$message = $mmessage;
			$message =~ s~<br>~\n~ig;
			$message =~ s~<br />~\n~g;
			$message =~ s/ \&nbsp; \&nbsp; \&nbsp;/\t/ig;
			if (!$nestedquotes) {
				$message =~ s~\n{0,1}\[quote([^\]]*)\](.*?)\[/quote\]\n{0,1}~\n~isg;
				$message =~ s~\n*\[/*quote([^\]]*)\]\n*~~ig;
			}
			$mname ||= $musername || $post_txt{'470'};
			$quotestart = int($quotemsg / $maxmessagedisplay) * $maxmessagedisplay;
			$message    = qq~[quote author=$mname link=$threadid/$quotestart#$quotemsg date=$mdate\]$message\[/quote\]\n~;
			$msubject =~ s/\bre:\s+//ig;
			if ($mns eq "NS") { $nscheck = "checked"; }
		} else {
			($msubject, $mname, $memail, $mdate, $musername, $micon, $mattach, $mip, $mmessage, $mns) = split(/\|/, $messages[0]);
			$msubject =~ s/\bre:\s+//ig;
		}
		$sub        = "Re: $msubject";
		$set_subjectMaxLength += 4;
		$settofield = "message";
	}
	$submittxt   = "$post_txt{'105'}";
	$destination = "post2";
	$icon        = "xx";
	$is_preview  = 0;
	$post        = "post";
	$prevmain    = "";
	$preview     = "preview";
	$yytitle     = "$t_title";
	&Postpage;
	if ($pollthread != 2) { &doshowthread; }
	&template;
	exit;
}

sub Postpage {
	my $extra;
	my ($filetype_info, $filesize_info, $extensions);
	$extensions = join(" ", @ext);
	$filetype_info = $checkext == 1 ? qq~$fatxt{'2'} $extensions~ : qq~$fatxt{'2'} $fatxt{'4'}~;
	$filesize_info = $limit != 0    ? qq~$fatxt{'3'} $limit KB~   : qq~$fatxt{'3'} $fatxt{'5'}~;
	if ($is_preview) { $post_txt{'507'} = $post_txt{'771'}; }
	$normalquot = $post_txt{'599'};
	$simpelquot = $post_txt{'601'};
	$simpelcode = $post_txt{'602'};
	$edittext   = $post_txt{'603'};
	if (!$fontsizemax) { $fontsizemax = 72; }
	if (!$fontsizemin) { $fontsizemin = 6; }

	$message =~ s~<\/~\&lt\;/~isg;
	&ToChars($message);
	&ToChars($sub);

	# this defines what the top area of the post box will look like: option 1 ) IM area
	# option 2) all other post areas
	if ($post eq "imsend") {
		if (!$INFO{'to'}) { $INFO{'to'} = $FORM{'to'}; }
		if ($INFO{'to'}) { $settofield = "message"; }
		else { $settofield = "to"; }
		$idinfo = "$INFO{'id'}";
		$extra  = qq~
      <tr>
        <td class="windowbg" width="23%"><b>$post_txt{'150'}</b></td>
        <td class="windowbg" width="77%">
	<input type="text" name="to" value="$INFO{'to'}" size="20" maxlength="50" tabindex="2" />
	<span class="small">$post_txt{'748'}</span></td>
      </tr>
		~;

	} else {
		$extra = qq~
      <tr>
        <td class="windowbg" width="23%"><b>$post_txt{'71'}:</b></td>
        <td width="77%" class="windowbg">
        <select name="icon" onchange="showimage(); updatTopic();">
         <option value="xx"$ic1>$post_txt{'281'}</option>
         <option value="thumbup"$ic2>$post_txt{'282'}</option>
         <option value="thumbdown"$ic3>$post_txt{'283'}</option>
         <option value="exclamation"$ic4>$post_txt{'284'}</option>
         <option value="question"$ic5>$post_txt{'285'}</option>
         <option value="lamp"$ic6>$post_txt{'286'}</option>
         <option value="smiley"$ic7>$post_txt{'287'}</option>
         <option value="angry"$ic8>$post_txt{'288'}</option>
         <option value="cheesy"$ic9>$post_txt{'289'}</option>
         <option value="grin"$ic10>$post_txt{'290'}</option>
         <option value="sad"$ic11>$post_txt{'291'}</option>
         <option value="wink"$ic12>$post_txt{'292'}</option>
        </select>
        <img src="$imagesdir/$icon.gif" name="icons" border="0" hspace="15" alt="" /></td>
      </tr>
	 	~;
		if ($realname eq '' && $threadid ne '') { $settofield = "name"; }
	}

	# this shows on every post page. regardless of where it is called from
	$yymain .= qq~

	
~;
	$notify    = "";
	$hasnotify = "";

	if ($pollthread && $iamguest) { $guest_vote = 1; }
	if ($pollthread == 2) {
		$settofield = "question";
	} else {

		# this defines if the notify on reply is shown or not.
		if (!$enable_notification || $iamguest) {
			$notification = "";
		} else {

			# check if you are already being notified and if so we check the checkbox.
			# if the mail file exists then we have to check it otherwise we continue on
			$notifytext = qq~$post_txt{'750'}~;
			if (-e "$datadir/$threadid.mail") {
				&ManageThreadNotify("load", $threadid);
				if (exists $thethread{$username}) {
					$notify    = qq~ checked="checked"~;
					$hasnotify = 1;
				}
				undef %thethread;
			}
			if (-e "$boardsdir/$currentboard.mail") {
				&ManageBoardNotify("load", $currentboard);
				if (exists $theboard{$username}) {
					($memlang, $memtype, $memview) = split(/\|/, $theboard{$username});
					if ($memtype == 2) {
						$notify     = qq~ disabled="disabled" checked="checked"~;
						$hasnotify  = 1;
						$notifytext = qq~$post_txt{'132'}~;
					}
				}
				undef %theboard;
			}

			if ($post ne "imsend") {
				$notification = qq~
	      <tr>
                <td width="23%"><b>$post_txt{'131'}:</b></td>
                <td width="77%"><input type="checkbox" name="notify" value="x"$notify /> <span class="small">$notifytext</span></td>
              </tr>~;
			}
		}
	}

	if (!$sub) { $subtitle = "<i>$post_txt{'33'}</i>"; }
	else { $subtitle = "<i>$sub</i>"; }

	# this is shown every post page except the IM area.
	unless ($post eq "imsend") {

		if ($threadid) {
			$threadlink = qq~<a href="$scripturl?num=$threadid" class="nav">$subtitle</a>~;
		} else {
			$threadlink = "$subtitle";
		}
		&ToChars($boardname);
		&ToChars($cat);
		$yymain .= qq~
	<div style="width: 100%; margin-left: auto; margin-right: auto;">
    <span class="small"><b>		   
	    <a href="$scripturl" class="nav">$mbname</a> &rsaquo; 
          <a href="$scripturl?catselect=$catid" class="nav">$cat</a> &rsaquo; 
		     <a href="$scripturl?board=$currentboard" class="nav">$boardname</a> &rsaquo;
				 <span class="nav">$t_title</span> ( $threadlink )</b>
       </span>
	</div>
		~;
	}

	#this is the end of the upper area of the post page.

	$yymain .= qq~
<script language="JavaScript1.2" src="$postjspath" type="text/javascript"></script>
<script language="JavaScript1.2" type="text/javascript">
<!--
var postas = '$post';
var namefield = '$realname';
var mailfield = '$realemail';
function checkForm(theForm) {
if (navigator.appName == "Microsoft Internet Explorer") { theForm.message.createTextRange().execCommand("Copy"); }
if (theForm.subject.value == "") { alert("$post_txt{'77'}"); theForm.subject.focus(); return false }
if (postas == "imsend") { if (theForm.to.value == "") { alert("$post_txt{'752'}"); theForm.to.focus(); return false } }
else {
	if (namefield == "") {
		if (theForm.name.value == "" || theForm.name.value == "_" || theForm.name.value == " ") { alert("$post_txt{'75'}"); theForm.name.focus(); return false }
		if (theForm.name.value.length > 25)  { alert("$post_txt{'568'}"); theForm.name.focus(); return false }
	}
	if (mailfield == "") {
		if (theForm.email.value == "") { alert("$post_txt{'76'}"); theForm.email.focus(); return false }
		if (! checkMailaddr(theForm.email.value)) { alert("$post_txt{'500'}"); theForm.email.focus(); return false }
	}
}
if (theForm.message.value == "") { alert("$post_txt{'78'}"); theForm.message.focus(); return false }
return true
}
//-->
</script>

~;

	# if this is an IM from the admin or to groups declare where it goes.
	if ($INFO{'adminim'} || $INFO{'action'} eq "imgroups") {
		$yymain .= qq~<form action="$scripturl?action=imgroups" method="post" name="postmodify" onsubmit="return submitproc()">~;
	} else {
		if($curnum) { $thecurboard = qq~num=$curnum\;action=$destination~; }
		else { $thecurboard = qq~board=$currentboard\;action=$destination~; }
		if (&AccessCheck($currentboard, 4) eq "granted" && $allowattach && ${$uid.$currentboard}{'attperms'} == 1) {
			$yymain .= qq~<form action="$scripturl?$thecurboard" method="post" name="postmodify" enctype="multipart/form-data" onsubmit="if(!checkForm(this)) {return false} else {return submitproc()}">~;
		} else {
			$yymain .= qq~<form action="$scripturl?$thecurboard" method="post" name="postmodify" onsubmit="if(!checkForm(this)) {return false} else {return submitproc()}">~;
		}
	}

	# this declares the beginning of the UBBC section
	$yymain .= qq~

$prevmain

<div class="bordercolor" style="padding: 1px; width: 100%; margin-left: auto; margin-right: auto;">
<script language="JavaScript1.2" src="$ubbcjspath" type="text/javascript"></script>
<script language="JavaScript1.2" type="text/javascript">
<!--
var bver = parseFloat ( navigator.appVersion );
~;

	$moresmilieslist   = "";
	$more_smilie_array = "";
	$i                 = 0;
	if ($showadded eq 1) {
		while ($SmilieURL[$i]) {
			if ($SmilieURL[$i] =~ /\//i) { $tmpurl = $SmilieURL[$i]; }
			else { $tmpurl = qq~$imagesdir/$SmilieURL[$i]~; }
			$moresmilieslist .= qq~      document.write("<img src='$tmpurl' align='bottom' alt='$SmilieDescription[$i]' border='0' onclick='javascript:MoreSmilies($i)' style='cursor:hand' alt=''>$SmilieLinebreak[$i] ");\n~;
			$tmpcode = $SmilieCode[$i];
			$tmpcode =~ s/\&quot;/"+'"'+"/g;    #" Adding that because if not it'll screw up my syntax view'
			&FromHTML($tmpcode);
			$tmpcode =~ s/&#36;/\$/g;
			$tmpcode =~ s/&#64;/\@/g;
			$more_smilie_array .= qq~" $tmpcode", ~;
			$i++;
		}
	}

	if ($showsmdir eq 1) {
		opendir(DIR, "$smiliesdir");
		@contents = readdir(DIR);
		closedir(DIR);

		foreach $line (sort { uc($a) cmp uc($b) } @contents) {
			($name, $extension) = split(/\./, $line);
			if ($extension =~ /gif/i || $extension =~ /jpg/i || $extension =~ /jpeg/i || $extension =~ /png/i) {
				if ($line !~ /banner/i) {
					$moresmilieslist   .= qq~      document.write("<img src='$smiliesurl/$line' align='bottom' alt='$name' border='0' onclick='javascript:MoreSmilies($i)' style='cursor:hand'>$SmilieLinebreak[$i] ");\n~;
					$more_smilie_array .= qq~" [smiley=$line]", ~;
					$i++;
				}
			}
		}
	}

	$more_smilie_array .= qq~""~;

	$yymain .= qq~
moresmiliecode = new Array($more_smilie_array)

 function MoreSmilies(i) {
  AddTxt=moresmiliecode[i];
  AddText(AddTxt);
 }

~;

	# this is more stuff for the ubbc but it is specifically for smilies and the top area of the page.
	# including the title
	if ($smiliestyle eq 1) { $smiliewinlink = "$scripturl?action=smilieput"; }
	else { $smiliewinlink = "$scripturl?action=smilieindex"; }

	$yymain .= qq~
function smiliewin() {
  window.open("$smiliewinlink", 'list', 'width=$winwidth,height=$winheight, scrollbars=yes');
}

function showimage() {
   document.images.icons.src="$imagesdir/"+document.postmodify.icon.options[document.postmodify.icon.selectedIndex].value+".gif";
}

//-->
</script>
    <input type="hidden" name="threadid" value="$threadid" />
    <input type="hidden" name="postid" value="$postid" />
    <input type="hidden" name="info" value="$idinfo" />
    <input type="hidden" name="mename" value="$mename" />

    <table border="0" width="100%" cellpadding="3" cellspacing="0" class="windowbg" style="table-layout: fixed;">
      <tr>
        <td class="titlebg" height="18" width="100%"><span class="text1"><b>$yytitle</b></span></td>
      </tr>
~;

	if ($post ne "imsend") {
		$iammod = 0;
		if (scalar keys %moderators > 0) {
			while ($_ = each(%moderators)) {
				if ($username eq $_) { $iammod = 1; }
			}
		}
		if (scalar keys %moderatorgroups > 0) {
			&LoadUser($username);
			while ($_ = each(%moderatorgroups)) {
				if (${$uid.$username}{'position'} eq $_) { $iammod = 1; }
				foreach $memberaddgroups (split(/\, /, ${$uid.$username}{'addgroups'})) {
					chomp $memberaddgroups;
					if ($memberaddgroups eq $_) { $iammod = 1; last; }
				}
			}
		}

		$template_viewers = "";
		$topviewers       = 0;

		if ($postthread == 2 && $showtopicrepliers && (($iamadmin || $iamgmod || $iammod) && $sessionvalid == 1)) {
			foreach $thisreplier (@repliers) {
				chomp $thisreplier;
				(undef, $mrepuser, $misreplying) = split(/\|/, $thisreplier);
				if ($misreplying) {
					&LoadUser($mrepuser);
					$template_viewers .= qq~$link{$mrepuser}, ~;
					$topviewers++;
				}
			}
			$template_viewers =~ s/\, \Z/\./;

			if ($template_viewers) {
				$yymain .= qq~
			<tr>
				<td class="windowbg" valign="middle" align="left">
					$display_txt{'646'} ($topviewers): $template_viewers
				</td>
			</tr>
		~;
			}
		}
	}

	$yymain .= qq~

    </table>
    <table border="0" width="100%" cellpadding="3" cellspacing="0" class="windowbg" style="table-layout: fixed;">

	~;

	if ($pollthread) {
		$maxpq          ||= 60;
		$maxpo          ||= 50;
		$maxpc          ||= 0;
		$numpolloptions ||= 8;
		$vote_limit     ||= 0;

		if ($guest_vote)   { $gvchecked = " checked"; }
		if ($hide_results) { $hrchecked = " checked"; }
		if ($multi_choice) { $mcchecked = " checked"; }

		$yymain .= qq~
		<tr>
                <td width="23%" align="right" class="windowbg2"><b>$post_polltxt{'6'}:</b> &nbsp;</td>
                <td width="77%" align="left"  class="windowbg2">
			<input type="text" size="50" name="question" value="$poll_question" maxlength="$maxpq" />
			<input type="hidden" name="pollthread" value="$pollthread" />
		</td>
		</tr>~;

		for (my $i = 1; $i <= $numpolloptions; $i++) {
			$yymain .= qq~
                    <tr>
                      <td width="23%" align="right" class="windowbg2"> &nbsp; $post_polltxt{'7'} $i: &nbsp;</td>
                      <td width="77%" align="left" class="windowbg2"><input type="text" size="35" maxlength="$maxpo" name="option$i" value="$options[$i]" /></td>
                    </tr>~;
		}

		if ($maxpc > 0) {
		$yymain .= qq~
		<tr>
                <td valign=top class="windowbg2" width="23%"><b>$post_polltxt{'59'}:</b></td>
                <td class="windowbg2" width="77%"><textarea name="poll_comment" rows="3" cols="60" wrap="soft" onkeyup="if (document.postmodify.poll_comment.value.length > $maxpc) {document.postmodify.poll_comment.value = document.postmodify.poll_comment.value.substring(0,$maxpc)}">$poll_comment</textarea></td>
		</tr>~;
		}

		$yymain .= qq~
		<tr>
                <td width="23%" align="left"><b>$post_polltxt{'32'}</b></td>
                <td width="77%" align="left"><input type="checkbox" name="guest_vote" value="1"$gvchecked /> <span  class="small">$post_polltxt{'54'}</span></td>
              </tr><tr>
                <td width="23%" align="left"><b>$post_polltxt{'26'}</b></td>
                <td width="77%" align="left"><input type="checkbox" name="hide_results" value="1"$hrchecked /> <span  class="small">$post_polltxt{'55'}</span></td>
              </tr><tr>
                <td width="23%" align="left"><b>$post_polltxt{'58'}</b></td>
                <td width="77%" align="left"><input type="checkbox" name="multi_choice" value="1"$mcchecked /> <span  class="small">$post_polltxt{'56'}</span></td>
              </tr><tr>
                <td width="23%" align="left"><b>$post_polltxt{'60'}</b></td>
                <td width="77%" align="left"><input type="text" size="6" name="vote_limit" value="$vote_limit" /> <span  class="small">$post_polltxt{'61'}</span></td>
              </tr>
~;
	}

	if ($pollthread != 2) {
		$yymain .= qq~
      <tr>
        <td width="23%" class="windowbg2" valign="top">
	  <div id="SaveInfo" style="height: 16px;">
        <img name="prevwin" id="prevwin" src="$defaultimagesdir/cat_expand.gif" alt="$npf_txt{'01'}" border="0" style="cursor: pointer; cursor: hand;" onclick="enabPrev();" /> <b>$npf_txt{'04'}</b>
        </div>
        </td>
        <td width="77%" class="windowbg2">
        <div id="savetopic" style="position: relative; top: 0px; left:0px; height: 0px; font-weight: bold; visibility: hidden; overflow: auto;">&nbsp;</div>
        <div id="saveframe" class="message" style="position: relative; top: 0px; left:0px; height: 0px; border-top: 1px black solid; padding-top: 4px; vertical-align: top; visibility: hidden; overflow: auto;">&nbsp;</div>
        </td>
      </tr>
	~;
	}

	if ($pollthread != 2 || ($pollthread == 2 && $iamguest)) {
		if ($pollthread == 2) { $extra = ""; }
		else {
			$yymain .= qq~
		      <tr>
		        <td align="left" class="windowbg" width="23%"><b>$post_txt{'70'}:</b></td>
		        <td align="left" class="windowbg" width="77%"><input type="text" name="subject" value="$sub" size="50" maxlength="$set_subjectMaxLength" tabindex="1" onchange="updatTopic()" /></td>
		      </tr>
			~;
		}
		$yymain .= qq~
		$name_field
		$email_field
		$extra
	  	~;
	}

	if ($pollthread != 2) {
		# if not adding a poll to an existing thread, display standard post page inputs
		# this is for the topic status options for admin, gmods and mods
		$topicstatus_row = "";
		$stselect        = "";
		$lcselect        = "";
		$hdselect        = "";
		$threadclass     = 'thread';

		if ($postthread == 2) {
			($mnum, $msub, $mname, $memail, $mdate, $mreplies, $musername, $micon, $mstate) = split(/\|/, $yyThreadLine);
			$thestatus = $mstate;
			if    ($mreplies >= $VeryHotTopic) { $threadclass = 'veryhotthread'; }
			elsif ($mreplies >= $HotTopic)     { $threadclass = 'hotthread'; }
		} else {
			$thestatus = $FORM{'topicstatus'};
			$thestatus =~ s/\, //g;
		}

		if ($thestatus =~ /s/) { $stselect = qq~selected="selected"~; }
		if ($thestatus =~ /l/) { $lcselect = qq~selected="selected"~; }
		if ($thestatus =~ /h/) { $hdselect = qq~selected="selected"~; }
		$hidestatus = "";

		if ($currentboard ne $annboard && $post ne "imsend" && (($iamadmin || $iamgmod || $iammod) && $sessionvalid == 1)) {
			$yymain .= qq~
		<tr>
			<td class="windowbg" align="left" valign="top" width="23%"><b>$post_txt{'34'}:</b></td>
			<td class="windowbg" align="left" valign="middle" width="77%">
				<select multiple="multiple" name="topicstatus" size="3" style="vertical-align: middle;" onchange="showtpstatus()">
				<option value="s"$stselect>$post_txt{'35'}</option>
				<option value="l"$lcselect>$post_txt{'36'}</option>
				<option value="h"$hdselect>$post_txt{'37'}</option>
				</select>
			        <img src="$imagesdir/$threadclass.gif" name="thrstat" border="0" hspace="15" alt="" style="vertical-align: middle;" />
			</td>
		</tr>
		~;
		} else {
			$hidestatus = qq~<input type="hidden" value="$thestatus" name="topicstatus" />~; #/
		}

	}

	# Captcha for guests on posting
	if ($iamguest && $enable_guestposting && $regcheck) {
		require "$sourcedir/Decoder.pl";
		my @fields = newcaptcha ();
		while (@fields) {
			my $desc = shift @fields;
			my $cont = shift @fields;
			$yymain .= qq(
		<tr class="windowbg">
			<td><b>$desc</b></td>
			<td>$cont</td>
		</tr>);
		}
	}

	if ($enable_ubbc && $showyabbcbutt) {

		# this is for the ubbc buttons
		$yymain .= qq~
  <tr>
      <td class="windowbg2" width="23%"><b>$post_txt{'252'}:</b></td>
        <td valign="middle" class="windowbg2" width="77%">
		<div style="width: 484px; clear: both;">
		<div style="width: 391px; float:left;">
        <script language="JavaScript1.2" type="text/javascript">
        <!--
        if((navigator.appName == "Netscape" && bver >= 4) || (navigator.appName == "Microsoft Internet Explorer" && bver >= 4) || (navigator.appName == "Opera" && bver >= 4) || (navigator.appName == "WebTV Plus Receiver" && bver >= 3) || (navigator.appName == "Konqueror" && bver >= 2)) {
          HAND = "style='cursor: pointer; cursor: hand;'";
          document.write("<img src='$defaultimagesdir/url.gif' onclick='hyperlink();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'257'}' title='$post_txt{'257'}' border='0' />");
          document.write("<img src='$defaultimagesdir/ftp.gif' onclick='ftp();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'434'}' title='$post_txt{'434'}' border='0' />");
          document.write("<img src='$defaultimagesdir/img.gif' onclick='image();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'435'}' title='$post_txt{'435'}' border='0' />");
          document.write("<img src='$defaultimagesdir/email2.gif' onclick='emai1();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'258'}' title='$post_txt{'258'}' border='0' />");
          document.write("<img src='$defaultimagesdir/flash.gif' onclick='flash();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'433'}' title='$post_txt{'433'}' border='0' />");
          document.write("<img src='$defaultimagesdir/table.gif' onclick='table();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'436'}' title='$post_txt{'436'}' border='0' />");
          document.write("<img src='$defaultimagesdir/tr.gif' onclick='trow();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'449'}' title='$post_txt{'449'}' border='0' />");
          document.write("<img src='$defaultimagesdir/td.gif' onclick='tcol();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'437'}' title='$post_txt{'437'}' border='0' />");
          document.write("<img src='$defaultimagesdir/hr.gif' onclick='hr();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'531'}' title='$post_txt{'531'}' border='0' />");
          document.write("<img src='$defaultimagesdir/tele.gif' onclick='teletype();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'440'}' title='$post_txt{'440'}' border='0' />");
          document.write("<img src='$defaultimagesdir/code.gif' onclick='showcode();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'259'}' title='$post_txt{'259'}' border='0' />");
          document.write("<img src='$defaultimagesdir/quote2.gif' onclick='quote();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'260'}' title='$post_txt{'260'}' border='0' />");
          document.write("<img src='$defaultimagesdir/edit.gif' onclick='edit();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'603'}' title='$post_txt{'603'}' border='0' />");
          document.write("<img src='$defaultimagesdir/sup.gif' onclick='superscript();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'447'}' title='$post_txt{'447'}' border='0' />");
          document.write("<img src='$defaultimagesdir/sub.gif' onclick='subscript();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'448'}' title='$post_txt{'448'}' border='0' />");
          document.write("<img src='$defaultimagesdir/move.gif' onclick='move();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'439'}' title='$post_txt{'439'}' border='0' /></b>");
          document.write("<img src='$defaultimagesdir/timestamp.gif' onclick='timestamp($date);' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'245'}' title='$post_txt{'245'}' border='0' /><br />");
          document.write("<img src='$defaultimagesdir/bold.gif' onclick='bold();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'253'}' title='$post_txt{'253'}' border='0' />");
          document.write("<img src='$defaultimagesdir/italicize.gif' onclick='italicize();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'254'}' title='$post_txt{'254'}' border='0' />");
          document.write("<img src='$defaultimagesdir/underline.gif' onclick='underline();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'255'}' title='$post_txt{'255'}' border='0' />");
          document.write("<img src='$defaultimagesdir/strike.gif' onclick='strike();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'441'}' title='$post_txt{'441'}' border='0' />");
          document.write("<img src='$defaultimagesdir/highlight.gif' onclick='highlight();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'246'}' title='$post_txt{'246'}' border='0' /></b>");
          document.write('<select name="fontface" id="fontface" onchange="if(this.options[this.selectedIndex].value) fontfce(this.options[this.selectedIndex].value);" style="width: 93px; margin-top: 2px; margin-left: 2px; margin-right: 1px; font-size: 9px;">');
          document.write('<option value="">Verdana</option>');
          document.write('<option value="">\\-\\-\\-\\-\\-</option>');
          document.write('<option value="Sans-Serif" style="font-family: Sans-Serif">Sans-Serif</option>');
          document.write('<option value="Verdana" style="font-family: Verdana" selected="selected">Verdana</option>');
          document.write('<option value="Arial" style="font-family: Arial">Arial</option>');
          document.write('<option value="Serif" style="font-family: Serif">Serif</option>');
          document.write('<option value="Courier" style="font-family: Courier">Courier</option>');
          document.write('<option value="Courier New" style="font-family: Courier New">Courier New</option>');
          document.write('<option value="Fantasy" style="font-family: Fantasy">Fantasy</option>');
          document.write('<option value="monospace" style="font-family: monospace">Monospace</option>');
          document.write('</select>');
          document.write('<select name="fontsize" id="fontsize" onchange="if(this.options[this.selectedIndex].value) fntsize(this.options[this.selectedIndex].value);" style="width: 39px; margin-top: 2px; margin-left: 1px; margin-right: 2px; font-size: 9px;">');
          document.write('<option value="">11</option>');
          document.write('<option value="">\\-\\-</option>');
          document.write('<option value="6">6</option>');
          document.write('<option value="7">7</option>');
          document.write('<option value="8">8</option>');
          document.write('<option value="9">9</option>');
          document.write('<option value="10">10</option>');
          document.write('<option value="11" selected="selected">11</option>');
          document.write('<option value="12">12</option>');
          document.write('<option value="14">14</option>');
          document.write('<option value="16">16</option>');
          document.write('<option value="18">18</option>');
          document.write('<option value="20">20</option>');
          document.write('<option value="22">22</option>');
          document.write('<option value="24">24</option>');
          document.write('<option value="36">36</option>');
          document.write('<option value="48">48</option>');
          document.write('<option value="56">56</option>');
          document.write('<option value="72">72</option>');
          document.write('</select>');
          document.write("<img src='$defaultimagesdir/pre.gif' onclick='pre();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'444'}' title='$post_txt{'444'}' border='0' />");
          document.write("<img src='$defaultimagesdir/left.gif' onclick='left();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'445'}' title='$post_txt{'445'}' border='0' />");
          document.write("<img src='$defaultimagesdir/center.gif' onclick='center();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'256'}' title='$post_txt{'256'}' border='0' />");
          document.write("<img src='$defaultimagesdir/right.gif' onclick='right();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'446'}' title='$post_txt{'446'}' border='0' />");
          document.write("<img src='$defaultimagesdir/list.gif' onclick='list();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'261'}' title='$post_txt{'261'}' border='0' />");
          document.write("<img src='$defaultimagesdir/me.gif' onclick='me();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'604'}' title='$post_txt{'604'}' border='0' />");

          img1 = new Image();
          img1.src = "$defaultimagesdir/palette.gif";

        }
        else { document.write("<span class='small'>$post_txt{'215'}</span>"); }
        //-->
        </script>
        <noscript>
        <span class="small">$post_txt{'215'}</span>
        </noscript></div>
        <div style="height: 42px; width: 86px; overflow: auto; border: 1px; border-style: outset; float: right;">
        ~;
		for ($z = 0; $z < 256; $z += 51) {
			$c3 = sprintf("%02x", $z);
			for ($y = 0; $y < 256; $y += 51) {
				$c2 = sprintf("%02x", $y);
				for ($x = 0; $x < 256; $x += 51) {
					$c1 = sprintf("%02x", $x);
					$selcolor = qq~#$c1$c2$c3~;
					if ($ENV{'HTTP_USER_AGENT'} =~ /Safari/) { $yymain .= qq~<span style="background-color: $selcolor; width: 11px; height: 11px;"><img src="$defaultimagesdir/palette.gif" border="0" hspace="0" vspace="0" alt="" style="height: 11px; width: 11px; margin: 0px;" onclick="showcolor('$selcolor')" /></span>~; }
					else { $yymain .= qq~<span style="float: left; background-color: $selcolor; width: 9px; height: 9px; border: 1px outset; font-size: 5px;" onclick="showcolor('$selcolor')">&nbsp;</span>~; }
				}
				if ($ENV{'HTTP_USER_AGENT'} =~ /Safari/) { $yymain .= qq~<br />~; }
			}
		}
		$yymain .= qq~
        </div>
		</div>
        </td>
      </tr>
~;
	} else {
		$yymain .= qq~
      <!--<tr>
        <td colspan="2">
        <table width="100%" cellpadding="3" cellspacing="0" class="windowbg">-->
~;
	}
	$yymain .= qq~
      <tr>
        <td class="windowbg2" width="23%"><b>$post_txt{'297'}:</b></td>
        <td width="77%" valign="middle" class="windowbg2">
        <script language="JavaScript1.2" type="text/javascript">
        <!--
        if((navigator.appName == "Netscape" && bver >= 4) || (navigator.appName == "Microsoft Internet Explorer" && bver >= 4) || (navigator.appName == "Opera" && bver >= 4) || (navigator.appName == "Konqueror" && bver >= 2)) {
          HAND = "style='cursor: pointer; cursor: hand;'";
          document.write("<img src='$imagesdir/smiley.gif' onclick='smiley();' "+HAND+" align='bottom' alt='$post_txt{'287'}' title='$post_txt{'287'}' border='0'> ");
          document.write("<img src='$imagesdir/wink.gif' onclick='wink();' "+HAND+" align='bottom' alt='$post_txt{'292'}' title='$post_txt{'292'}' border='0'> ");
          document.write("<img src='$imagesdir/cheesy.gif' onclick='cheesy();' "+HAND+" align='bottom' alt='$post_txt{'289'}' title='$post_txt{'289'}' border='0'> ");
          document.write("<img src='$imagesdir/grin.gif' onclick='grin();' "+HAND+" align='bottom' alt='$post_txt{'293'}' title='$post_txt{'293'}' border='0'> ");
          document.write("<img src='$imagesdir/angry.gif' onclick='angry();' "+HAND+" align='bottom' alt='$post_txt{'288'}' title='$post_txt{'288'}' border='0'> ");
          document.write("<img src='$imagesdir/sad.gif' onclick='sad();' "+HAND+" align='bottom' alt='$post_txt{'291'}' title='$post_txt{'291'}' border='0'> ");
          document.write("<img src='$imagesdir/shocked.gif' onclick='shocked();' "+HAND+" align='bottom' alt='$post_txt{'294'}' title='$post_txt{'294'}' border='0'> ");
          document.write("<img src='$imagesdir/cool.gif' onclick='cool();' "+HAND+" align='bottom' alt='$post_txt{'295'}' title='$post_txt{'295'}' border='0'> ");
          document.write("<img src='$imagesdir/huh.gif' onclick='huh();' "+HAND+" align='bottom' alt='$post_txt{'296'}' title='$post_txt{'296'}' border='0'> ");
          document.write("<img src='$imagesdir/rolleyes.gif' onclick='rolleyes();' "+HAND+" align='bottom' alt='$post_txt{'450'}' title='$post_txt{'450'}' border='0'> ");
          document.write("<img src='$imagesdir/tongue.gif' onclick='tongue();' "+HAND+" align='bottom' alt='$post_txt{'451'}' title='$post_txt{'451'}' border='0'> ");
          document.write("<img src='$imagesdir/embarassed.gif' onclick='embarassed();' "+HAND+" align='bottom' alt='$post_txt{'526'}' title='$post_txt{'526'}' border='0'> ");
          document.write("<img src='$imagesdir/lipsrsealed.gif' onclick='lipsrsealed();' "+HAND+" align='bottom' alt='$post_txt{'527'}' title='$post_txt{'527'}' border='0'> ");
          document.write("<img src='$imagesdir/undecided.gif' onclick='undecided();' "+HAND+" align='bottom' alt='$post_txt{'528'}' title='$post_txt{'528'}' border='0'> ");
          document.write("<img src='$imagesdir/kiss.gif' onclick='kiss();' "+HAND+" align='bottom' alt='$post_txt{'529'}' title='$post_txt{'529'}' border='0'> ");
          document.write("<img src='$imagesdir/cry.gif' onclick='cry();' "+HAND+" align='bottom' alt='$post_txt{'530'}' title='$post_txt{'530'}' border='0'> ");$moresmilieslist
        }
        else { document.write("<span  class='small'>$post_txt{'215'}</span>"); }
        //-->
        </script>
~;
	if (($showadded == 3 && $showsmdir ne 2) || ($showsmdir eq 3 && $showadded ne 2)) {
		$yymain .= qq~
<a href=javascript:smiliewin()>$post_smiltxt{'1'}</a>
~;
	}
	$yymain .= qq~

        <noscript>
        <span class="small">$post_txt{'215'}</span>
        </noscript>
        </td>
      </tr><tr>
        <td valign="top" class="windowbg2" width="23%"><b>$post_txt{'72'}:</b>
        <br /><br />
	~;
	if ($showadded eq 2 || $showsmdir eq 2) {
		$yymain .= qq~
        <script language="JavaScript1.2" type="text/javascript">
        <!--
          function Smiliextra() {
            AddTxt=smiliecode[document.postmodify.smiliextra_list.value];
            AddText(AddTxt);
          }
	~;

		$smilieslist       = "";
		$smilie_url_array  = "";
		$smilie_code_array = "";
		$i                 = 0;
		if ($showadded eq 2) {
			while ($SmilieURL[$i]) {
				$smilieslist .= qq~           document.write("<option value='$i'>$SmilieDescription[$i]<\/option>");\n~;
				if ($SmilieURL[$i] =~ /\//i) { $tmpurl = $SmilieURL[$i]; }
				else { $tmpurl = qq~$imagesdir/$SmilieURL[$i]~; }
				$smilie_url_array .= qq~"$tmpurl", ~;
				$tmpcode = $SmilieCode[$i];
				$tmpcode =~ s/\&quot;/"+'"'+"/g;    # "
				&FromHTML($tmpcode);
				$tmpcode =~ s/&#36;/\$/g;
				$tmpcode =~ s/&#64;/\@/g;
				$smilie_code_array .= qq~" $tmpcode", ~;
				$i++;
			}
		}
		if ($showsmdir eq 2) {
			opendir(DIR, "$smiliesdir");
			@contents = readdir(DIR);
			closedir(DIR);
			foreach $line (sort { uc($a) cmp uc($b) } @contents) {
				($name, $extension) = split(/\./, $line);
				if ($extension =~ /gif/i || $extension =~ /jpg/i || $extension =~ /jpeg/i || $extension =~ /png/i) {
					if ($line !~ /banner/i) {
						$smilieslist       .= qq~           document.write("<option value='$i'>$name<\/option>");\n~;
						$smilie_url_array  .= qq~"$smiliesurl/$line", ~;
						$smilie_code_array .= qq~" [smiley=$line]", ~;
						$i++;
					}
				}
			}
		}
		$smilie_url_array  .= qq~""~;
		$smilie_code_array .= qq~""~;

		$yymain .= qq~

	smilieurl = new Array($smilie_url_array)
	smiliecode = new Array($smilie_code_array)

        if((navigator.appName == "Netscape" && bver >= 4) || (navigator.appName == "Microsoft Internet Explorer" && bver >= 4) || (navigator.appName == "Opera" && bver >= 4)) {

          document.write('<table class="bordercolor" height="120" width="120" border="0" cellpadding="2" cellspacing="1" align="center"><tr>');
          document.write('<td height="15" align="center" valign="middle" class="titlebg"><span class="small"><b>$post_smiltxt{'1'}</b></span></td>');
          document.write('</tr><tr>');
          document.write('<td height="20" align="center" valign="top" class="windowbg2"><select name="smiliextra_list" onchange="document.images.smiliextra_image.src= smilieurl[document.postmodify.smiliextra_list.value]" style="width:114px; font-size:7pt;">');
$smilieslist
          document.write('</select></td>');
          document.write('</tr><tr>');
          document.write('<td height="70" align="center" valign="middle" class="windowbg2"><img name="smiliextra_image" src="'+smilieurl[0]+'" alt="" border="0" onclick="javascript:Smiliextra()" style="cursor:hand"></td>');
          document.write('</tr><tr>');
          document.write('<td height="15" align="center" valign="middle" class="windowbg2"><span class="small"><a href="javascript:smiliewin()">$post_smiltxt{'17'}</a></span></td>');
          document.write('</tr></table>');
	}
        //-->
        </script>
        ~;
	}

	# this is the message area.
	if (!${$uid.$username}{'postlayout'} || ${$uid.$username}{'postlayout'} >= 100) { $pwidth = 90; }
	else { $pwidth = ${$uid.$username}{'postlayout'}; }
	$yymain .= qq~
        </td>
        <td width="77%" class="windowbg2">
        <textarea name="message" id="message" rows="8" cols="70" style="height: 166px; width: $pwidth%; font-family: Verdana; font-size: 11px; padding: 5px; margin: 0px; visibility: visible;" onclick="javascript:storeCaret(this);" onkeyup="javascript:storeCaret(this);" onchange="javascript:storeCaret(this);" tabindex="4">$message</textarea>
        <br /></td>
      </tr>
      <tr>
        <td width="23%" class="windowbg2"></td>
        <td width="77%" class="windowbg2">
        <img src="$defaultimagesdir/green1.gif" name="chrwarn" height="8" width="8" border="0" vspace="0" hspace="0" alt="" align="middle" />
        <span class="small">$npf_txt{'03'} <input value="$MaxMessLen" size="3" name="msgCL" class="windowbg2" style="border: 0px; font-size: 11px; width: 40px; padding: 1px" disabled="disabled" /></span>
        </td>
      </tr>

~;

	# File Attachment's Browse Box Code
	if (&AccessCheck($currentboard, 4) eq "granted") {
		if ($allowattach == 1 && ${$uid.$currentboard}{'attperms'} == 1 && $fa_ok == 1 && ($action eq 'post' || $action eq 'post2' || $action eq 'modify' || $action eq 'modify2') && (($allowguestattach == 0 && !$iamguest) || $allowguestattach == 1)) {
			$selnewatt = "";
			if ($action eq 'modify' && $isatt) {
				$selnewatt = qq~ onchange="selectNewattach();"~;
			}
			$yymain .= qq~
	<tr>
		<td width="23%" valign="top"><b>$fatxt{'6'}</b></td>
		<td width="77%"><input type="file" name="file" size="50"$selnewatt /></td>
	</tr>
	<tr>
		<td width="23%" align="right"></td>
		<td width="77%"><span class="small">$filetype_info<br />$filesize_info</span></td>
	</tr>
	~;
			if ($action eq 'modify' && (-e "$uploaddir/$isatt")) {
				if ($isatt ne "") {
					$oldattcheck = qq~selected="selected"~;
					$newattcheck = qq~~;
					$atistxt     = qq~$fatxt{'40'}: <a href="$uploadurl/$isatt">$isatt</a>~;
				} else {
					$newattcheck = qq~selected="selected"~;
					$oldattcheck = qq~~;
					$atistxt     = "";
				}
				$yymain .= qq~
	<tr>
		<td width="23%" valign="top"></td>
		<td width="77%"><font size="1">
		<select id="w_file" name="w_file" size="1">
		<option value="attachdel">$fatxt{'6c'}</option>
		<option value="attachnew" $newattcheck>$fatxt{'6b'}</option>
		<option value="attachold" $oldattcheck>$fatxt{'6a'}</option>
		</select>&nbsp;$atistxt</font></td>
	</tr>~;
			}
			if (($is_preview == 1) && $FORM{'file'}) {
				$yymain .= qq~
	<tr>
		<td width="23%" align="right"></td>
		<td width="77%"><b>$fatxt{'7'}</b><br /><br /></td>
	</tr>
	~;
			}

		}
	}
	# /File Attachment's Browse Box Code

	$yymain .= qq~
$notification
      <tr>
        <td class="windowbg" width="23%"><b>$post_txt{'276'}:</b><br /><br /></td>
        <td class="windowbg" width="77%"><input type="checkbox" name="ns" value="NS"$nscheck /> <span class="small"> $post_txt{'277'}</span><br /><br /></td>
      </tr>
$lastmod
~;

	#these are the buttons to submit
	$yymain .= qq~
      <tr>
        <td align="center" class="titlebg" colspan="2">
	$hidestatus
        <span class="small">$post_txt{'329'}</span><br />
		<input type="submit" name="$post" value="$submittxt" accesskey="s" tabindex="6" />
~;
	unless ($pollthread == 2) { $yymain .= qq~		<input type="submit" name="$preview" value="$post_txt{'507'}" accesskey="p" tabindex="7" />~; }
	unless ($is_preview)      { $yymain .= qq~       <input type="reset" value="$post_txt{'278'}" accesskey="r" tabindex="8" />~; }
	$yymain .= qq~
        </td>
      </tr>
</table>
</div>
</form>
~;
	unless ($pollthread == 2) {
		if ($currentboard ne $annboard && $post ne "imsend" && (($iamadmin || $iamgmod || $iammod) && $sessionvalid == 1)) {
			$yymain .= qq~
		<script language="JavaScript1.2" type="text/javascript">
		<!--

		function showtpstatus() {
			var z = 0;
			var x = 0;
			var theimg = '$threadclass';
			for(var i=0;i<document.postmodify.topicstatus.length;i++) {
				if (document.postmodify.topicstatus[i].selected) { z++; x += i; }
			}
			if(z == 1 && x == 0)  theimg = 'sticky';
			if(z == 1 && x == 1)  theimg = 'locked';
			if(z == 2 && x == 1)  theimg = 'stickylock';
			if(z == 1 && x == 2)  theimg = 'hide';
			if(z == 2 && x == 2)  theimg = 'hidesticky';
			if(z == 2 && x == 3)  theimg = 'hidelock';
			if(z == 3 && x == 3)  theimg = 'hidestickylock';

			document.images.thrstat.src="$imagesdir/"+theimg+".gif";
		}

		document.onload = showtpstatus();
		//-->
		</script>
		~;
		}


		if ($action eq "modify" || $action eq "modify2") {
			$displayname = qq~$mename~;
		} else {
			$displayname = ${$uid.$username}{'realname'};
		}

		require "$templatesdir/$usedisplay/Display.template";

		$yymain .= qq~
<script language="JavaScript1.2" src="$yabbcjspath" type="text/javascript"></script>
<script type="text/javascript" language="JavaScript"> <!--
var noalert = true, gralert = false, rdalert = false, clalert = false;
var prevsec = 5
var prevtxt
var cntsec = 0

function tick() {
  cntsec++
  calcCharLeft()
  timerID = setTimeout("tick()",1000)
}

var autoprev = false
var topicfirst = true;

function enabPrev() {
	if ( autoprev == false ) {
		autoprev = true
		topicfirst = true
		document.getElementById("saveframe").style.visibility = "visible";
		document.getElementById("saveframe").style.height = "180px";
		document.getElementById("saveframe").style.width = "100%";
		document.getElementById("savetopic").style.visibility = "visible";
		document.getElementById("savetopic").style.height = "25px";
		document.getElementById("savetopic").style.width = "100%";
		document.getElementById("SaveInfo").style.visibility = "visible";
		document.getElementById("SaveInfo").style.height = "205px";
		document.getElementById("SaveInfo").style.width = "100%";
		document.postmodify.message.focus();
		document.images.prevwin.alt = "$npf_txt{'02'}";
		document.images.prevwin.title = "$npf_txt{'02'}";
		document.images.prevwin.src="$defaultimagesdir/cat_collapse.gif";
		autoPreview();
	}
	else {
		autoprev = false;
		ubbstr = '';
		document.getElementById("saveframe").style.visibility = "hidden";
		document.getElementById("saveframe").style.height = "0px";
		document.getElementById("savetopic").style.visibility = "hidden";
		document.getElementById("savetopic").style.height = "0px";
		document.getElementById("SaveInfo").style.visibility = "visible";
		document.getElementById("SaveInfo").style.height = "16px";
		document.postmodify.message.focus();
		document.images.prevwin.alt = "$npf_txt{'01'}";
		document.images.prevwin.title = "$npf_txt{'01'}";
		document.images.prevwin.src="$defaultimagesdir/cat_expand.gif";
	}
	calcCharLeft()
}

function calcCharLeft() {
  clipped = false
  maxLength = $MaxMessLen
  if (document.postmodify.message.value.length > maxLength) {
	document.postmodify.message.value = document.postmodify.message.value.substring(0,maxLength)
	charleft = 0
	clipped = true
  } else {
	charleft = maxLength - document.postmodify.message.value.length
  }
  prevsec++
  if(autoprev && prevsec > 5 && prevtxt != document.postmodify.message.value) {
	autoPreview()
	prevtxt = document.postmodify.message.value
  }
  document.postmodify.msgCL.value = charleft
  if (charleft >= 100 && noalert) { noalert = false; gralert = true; rdalert = true; clalert = true; document.images.chrwarn.src="$defaultimagesdir/green1.gif"; }
  if (charleft < 100 && charleft >= 50 && gralert) { noalert = true; gralert = false; rdalert = true; clalert = true; document.images.chrwarn.src="$defaultimagesdir/green0.gif"; }
  if (charleft < 50 && charleft > 0 && rdalert) { noalert = true; gralert = true; rdalert = false; clalert = true; document.images.chrwarn.src="$defaultimagesdir/red0.gif" }
  if (charleft == 0 && clalert) { noalert = true; gralert = true; rdalert = true; clalert = false; document.images.chrwarn.src="$defaultimagesdir/red1.gif"; }
  return clipped
}

var codestr = '$simpelcode';
var quotstr = '$normalquot';
var squotstr = '$simpelquot';
var fontsizemax = '$fontsizemax';
var fontsizemin = '$fontsizemin';
var edittxt = '$edittext';
var dispname = '$displayname';
var scrpurl = '$scripturl';
var imgdir = '$defaultimagesdir';
var ubsmilieurl = '$smiliesurl';
var parseflash = '$parseflash';
var autolinkurl = '$autolinkurls';

function autoPreview() {
	if (topicfirst)  { updatTopic(); }
	var scrlto = parseInt(180) + 5;
	vismessage = document.postmodify.message.value;
	while ( c=vismessage.match(/date=(\\d+?)\\]/i) ) {
		var qudate=c[1];
		qudate=qudate * 1000;
		qdate=new Date()
		qdate.setTime(qudate);
		qdate=qdate.toLocaleString();
		vismessage=vismessage.replace(/(date=)\\d+?(\\])/i, "\$1"+qdate+"\$2");
	}
	if($enable_ubbc) {
		var ubbstr = jsDoUbbc(vismessage,codestr,quotstr,squotstr,edittxt,dispname,scrpurl,imgdir,ubsmilieurl,parseflash,fontsizemax,fontsizemin,autolinkurl);
	}
	else {
		var ubbstr = vismessage;
	}
	document.getElementById("saveframe").innerHTML=ubbstr;
	scrlto += parseInt(document.getElementById("saveframe").scrollTop) + parseInt(document.getElementById("saveframe").offsetHeight);
	document.getElementById("saveframe").scrollTop = scrlto;
	prevsec = 0
}

var visikon = '';

function updatTopic() {
	topicfirst = false;
	~;
		if ($post ne 'imsend') {
			$yymain .= qq~
	visicon = document.postmodify.icon.value;
	visicon=visicon.replace(/[^A-Za-z]/g, "");
	visicon=visicon.replace(/\\\\/g, "");
	visicon=visicon.replace(/\\//g, "");
	if (visicon != "xx" && visicon != "thumbup" && visicon != "thumbdown" && visicon != "exclamation") {
		if (visicon != "question" && visicon != "lamp" && visicon != "smiley" && visicon != "angry") {
			if (visicon != "cheesy" && visicon != "grin" && visicon != "sad" && visicon != "wink") {
				visicon = "xx";
			}
		}
	}
	visikon = "<img border='0' src='$defaultimagesdir/"+visicon+".gif' alt='"+visicon+"' \/> ";
	~;
		}
		$yymain .= qq~
	vistopic = document.postmodify.subject.value;
	var htmltopic = jsDoTohtml(vistopic);
	document.getElementById("savetopic").innerHTML=visikon+htmltopic;
	document.postmodify.message.focus();
}

document.postmodify.$settofield.focus();
tick();
//--> </script>
~;
	}
}

sub Preview {
	&clear_temp;
	my $error = $_[0];
	&ToHTML($e);

	# allows the following HTML-tags in error messages: <br /> <b>
	$error =~ s/&lt;br( \/)&gt;/<br \/>/ig;
	$error =~ s/&lt;(\/?)b&gt;/<$1b>/ig;
	$poll_question = $FORM{'question'};

	$maxpq          ||= 60;
	$maxpo          ||= 50;
	$maxpc          ||= 0;
	$numpolloptions ||= 8;
	$vote_limit     ||= 0;

	for (my $i = 1; $i <= $numpolloptions; $i++) {
		$options[$i] = $FORM{"option$i"};
		$options[$i] =~ s/&amp;/&/g;
		$options[$i] =~ s/&quot;/"/g;
		$options[$i] =~ s/&lt;/</g;
		$options[$i] =~ s/&gt;/>/g;
		&FromChars($options[$i]);
		$convertstr = $options[$i];
		$convertcut = $maxpo;
		&CountChars;
		$options[$i] = $convertstr;
		$options[$i] =~ s/"/&quot;/g;
		$options[$i] =~ s/</&lt;/g;
		$options[$i] =~ s/>/&gt;/g;
		&ToChars($options[$i]);
	}

	$guest_vote   = $FORM{'guest_vote'};
	$hide_results = $FORM{'hide_results'};
	$multi_choice = $FORM{'multi_choice'};
	$poll_comment = $FORM{'poll_comment'};
	$vote_limit   = $FORM{'vote_limit'};

	$pollthread = $FORM{'pollthread'} || 0;

	$poll_question =~ s/&amp;/&/g;
	$poll_question =~ s/&quot;/"/g;
	$poll_question =~ s/&lt;/</g;
	$poll_question =~ s/&gt;/>/g;
	&FromChars($poll_question);
	$convertstr = $poll_question;
	$convertcut = $maxpq;
	&CountChars;
	$poll_question = $convertstr;
	$poll_question =~ s/"/&quot;/g;
	$poll_question =~ s/</&lt;/g;
	$poll_question =~ s/>/&gt;/g;
	&ToChars($poll_question);

	$name  = $FORM{'name'};
	$email = $FORM{'email'};
	$sub   = $FORM{'subject'};
	$FORM{'message'} =~ s~\r~~g;
	$mess     = $FORM{'message'};
	$message  = $FORM{'message'};
	$icon     = $FORM{'icon'};
	$ns       = $FORM{'ns'};
	$threadid = $FORM{'threadid'};
	$notify   = $FORM{'notify'};
	$postid   = $FORM{'postid'};

	if (!$sub && $pollthread != 2) { $error = $post_txt{'77'}; }
	$sub =~ s/[\r\n]//g;
	my $testsub = $sub;
	$testsub =~ s/\&nbsp;//g;
	$testsub =~ s/ //g;

	$sub =~ s/&amp;/&/g;
	$sub =~ s/&quot;/"/g;
	$sub =~ s/&lt;/</g;
	$sub =~ s/&gt;/>/g;
	&FromChars($sub);
	$convertstr = $sub;
	$set_subjectMaxLength += 4 if ($threadid);
	$convertcut = $set_subjectMaxLength;
	&CountChars;
	$sub = $convertstr;
	$sub =~ s/"/&quot;/g;
	$sub =~ s/</&lt;/g;
	$sub =~ s/>/&gt;/g;

	my $testmessage = $mess;
	$testmessage =~ s/[\r\n\ ]//g;
	$testmessage =~ s/\&nbsp;//g;
	$testmessage =~ s~\[table\].*?\[tr\].*?\[td\]~~g;
	$testmessage =~ s~\[/td\].*?\[/tr\].*?\[/table\]~~g;
	$testmessage =~ s/\[.*?\]//g;
	if ($testmessage eq "" && $mess ne "" && $pollthread != 2) { fatal_error("$maintxt{'2'} $testmessage"); }
#	$message =~ s/\cM//g; # \r alredy removed
	$message =~ s~\[([^\]\[]{0,30})\n([^\]\[]{0,30})\]~\[$1$2\]~g;
	$message =~ s~\[/([^\]\[]{0,30})\n([^\]\[]{0,30})\]~\[/$1$2\]~g;
#	$message =~ s~(\w+://[^<>\s\n\"\]\[]+)\n([^<>\s\n\"\]\[]+)~$1$2~g;
	&FromChars($message);
	&ToHTML($message);
	$message =~ s/\t/ \&nbsp; \&nbsp; \&nbsp;/g;
	$message =~ s/\n/<br \/>/g;
	$message =~ s/([\000-\x09\x0b\x0c\x0e-\x1f\x7f])/\x0d/g;
	&CheckIcon;

	if    ($icon eq "xx")          { $ic1  = " selected=\"selected\" "; }
	elsif ($icon eq "thumbup")     { $ic2  = " selected=\"selected\" "; }
	elsif ($icon eq "thumbdown")   { $ic3  = " selected=\"selected\" "; }
	elsif ($icon eq "exclamation") { $ic4  = " selected=\"selected\" "; }
	elsif ($icon eq "question")    { $ic5  = " selected=\"selected\" "; }
	elsif ($icon eq "lamp")        { $ic6  = " selected=\"selected\" "; }
	elsif ($icon eq "smiley")      { $ic7  = " selected=\"selected\" "; }
	elsif ($icon eq "angry")       { $ic8  = " selected=\"selected\" "; }
	elsif ($icon eq "cheesy")      { $ic9  = " selected=\"selected\" "; }
	elsif ($icon eq "grin")        { $ic10 = " selected=\"selected\" "; }
	elsif ($icon eq "sad")         { $ic11 = " selected=\"selected\" "; }
	elsif ($icon eq "wink")        { $ic12 = " selected=\"selected\" "; }

	$name_field = $realname eq ''
	  ? qq~      <tr>
    <td class="windowbg" align="left" width="23%"><b>$post_txt{'68'}:</b></td>
    <td class="windowbg" align="left" width="77%"><input type="text" name="name" size="25" value="$FORM{'name'}" maxlength="25" tabindex="2" /></td>
      </tr>~
	  : qq~~;

	$email_field = $realemail eq ''
	  ? qq~      <tr>
    <td class="windowbg" width="23%"><b>$post_txt{'69'}:</b></td>
    <td class="windowbg" width="77%"><input type="text" name="email" size="25" value="$FORM{'email'}" maxlength="40" tabindex="3" /></td>
      </tr>~
	  : qq~~;
	if ($FORM{'notify'} eq "x")  { $notify  = qq~ checked="checked"~; }
	if ($FORM{'ns'}     eq 'NS') { $nscheck = qq~ checked="checked"~; }

	if ($iamguest) {
		$name .= "($post_txt{'772'})";
	}

	&wrap;
	if ($action eq "modify2") {
		$displayname = qq~$FORM{'mename'}~;
	} else {
		$displayname = ${$uid.$username}{'realname'};
	}
	if ($enable_ubbc) {
		if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; }
		&DoUBBC;
	}
	&wrap2;
	if ($FORM{'previewmodify'} || $FORM{'postmodify'}) {
		$submittxt   = "$post_txt{'10'}";
		$is_preview  = 1;
		$post        = "postmodify";
		$preview     = "previewmodify";
		$destination = 'modify2';
	} elsif ($FORM{'previewim'} || $FORM{'imsend'}) {
		$submittxt   = "$post_txt{'148'}";
		$destination = "imsend2";
		$is_preview  = 1;
		$post        = "imsend";
		$preview     = "previewim";
	} else {
		$notification = !$enable_notification || $iamguest ? '' : <<"~;";
    <tr>
      <td width="23%" class="windowbg"><b>$post_txt{'131'}:</b></td>
      <td width="77%" class="windowbg"><input type="checkbox" name="notify" value="x"$notify /> <span  class="small">$post_txt{'750'}</span></td>
    </tr>
~;
		$destination = 'post2';
		$submittxt   = $post_txt{'105'};
		$is_preview  = 1;
		$post        = "post";
		$preview     = "preview";
	}

	if ($INFO{'action'} eq "imgroups") { $destination = "imgroups"; }

	$csubject = $sub;
	&LoadCensorList;
	$csubject = &Censor($csubject);
	$message  = &Censor($message);
	&ToChars($csubject);
	&ToChars($message);
	require "$templatesdir/$usedisplay/Display.template";

	$prevmain .= qq~
<script language="JavaScript1.2" type="text/javascript" src="$ubbcjspath"></script>
<script language="JavaScript1.2" type="text/javascript">
<!--
function showimage() {
   document.images.icons.src="$imagesdir/"+document.postmodify.icon.options[document.postmodify.icon.selectedIndex].value+".gif";
}
//-->
</script>
<div class="bordercolor" style="padding: 1px; width: 100%; margin-left: auto; margin-right: auto;">
<table border="0" width="100%" cellpadding="3" cellspacing="0" class="windowbg" style="table-layout: fixed;">
  <tr>
    <td class="titlebg">
    <span class="text1"><img src="$imagesdir/$icon.gif" name="icons" border="0" alt="" /> $csubject</span>
    </td>
  </tr>
</table>
<table border="0" width="100%" cellpadding="3" cellspacing="0" class="windowbg" style="table-layout: fixed;">
  <tr>
    <td class="windowbg">
    <span class="message"><br />$message<br /><br /></span>
    </td>
  </tr>
</table>
</div>
<br /><br />
~;
	$message = $mess;
	&FromChars($message);
	&ToHTML($message);
	if ($error) { $csubject = $error; }
	$yytitle    = "$post_txt{'507'} - $csubject";
	$settofield = "message";
	$postthread = 2;
	&MessageTotals("load", $threadid);
	&Postpage;
	&template;
	exit;
}

sub Post2 {
	if ($iamguest && $enable_guestposting == 0) { &fatal_error($post_txt{'165'}); }
	my ($email, $ns, $notify, @memberlist, $i, $realname, $membername, $testname, @reserve, @reservecfg, $matchword, $matchcase, $matchuser, $matchname, $namecheck, $reserved, $reservecheck, @messages, $mnum, $msub, $mname, $memail, $mdate, $musername, $micon, $mstate, $pageindex, $tempname);

	&BoardTotals("load", $currentboard);

	# If poster is a Guest then evaluate the legality of name and email
	if (!${$uid.$username}{'email'}) {
		$FORM{'name'} =~ s/\A\s+//;
		$FORM{'name'} =~ s/\s+\Z//;
		&Preview($post_txt{'75'}) unless ($FORM{'name'} ne '' && $FORM{'name'} ne '_' && $FORM{'name'} ne ' ');
		&Preview($post_txt{'568'}) if (length($FORM{'name'}) > 25);
		&Preview("$post_txt{'76'}") if ($FORM{'email'} eq '');
		&Preview("$post_txt{'240'} $post_txt{'69'} $post_txt{'241'}") if ($FORM{'email'} !~ /[\w\-\.\+]+\@[\w\-\.\+]+\.(\w{2,4}$)/);
		&Preview("$post_txt{'500'}") if (($FORM{'email'} =~ /(@.*@)|(\.\.)|(@\.)|(\.@)|(^\.)|(\.$)/) || ($FORM{'email'} !~ /^.+@\[?(\w|[-.])+\.[a-zA-Z]{2,4}|[0-9]{1,4}\]?$/));
		&reg_banning($FORM{'name'}, $FORM{'email'});
	}

	# Get the form values
	$name       = $FORM{'name'};
	$email      = $FORM{'email'};
	$subject    = $FORM{'subject'};
	$message    = $FORM{'message'};
	$icon       = $FORM{'icon'};
	$ns         = $FORM{'ns'};
	$ann        = $FORM{'ann'};
	$threadid   = $FORM{'threadid'};
	$pollthread = $FORM{'pollthread'} || 0;
	if ($threadid =~ /\D/) { &fatal_error($post_txt{'337'}); }
	$notify    = $FORM{'notify'};
	$thestatus = $FORM{'topicstatus'};
	$thestatus =~ s/\, //g;

	# Permission checks for posting.
	if (!$threadid) {
		# Check for ability to post new threads
		unless (&AccessCheck($currentboard, 1) eq "granted" || $pollthread) { &fatal_error("$post_txt{'803'}"); }
	} else {
		# Check for ability to reply to threads
		unless (&AccessCheck($currentboard, 2) eq "granted") { &fatal_error("$post_txt{'804'}"); }
	}
	if ($pollthread) {
		# Check for ability to post polls
		unless (&AccessCheck($currentboard, 3) eq "granted") { &fatal_error("$post_txt{'805'}"); }
	}
	if ($FORM{'file'}) {
		# Check for ability to post attachments
		unless (&AccessCheck($currentboard, 4) eq "granted") { &fatal_error("$post_txt{'806'}"); }
	}
	# End Permission Checks

	if ($name && $email) {
		&ToHTML($name);
		$email =~ s/\|//g;
		&ToHTML($email);
		$tempname = $name;
		$name =~ s/\_/ /g;
	}

	&Preview($post_txt{'75'}) unless ($username || $name);
	&Preview($post_txt{'76'}) unless (${$uid.$username}{'email'} || $email);
	if ($pollthread != 2) {    # If user is NOT adding a Poll to an existing thread
		&Preview unless ($subject && $subject !~ m~\A[\s_.,]+\Z~);
		&Preview($post_txt{'78'}) unless ($message);

		# Check Message Length Precisely
		$mess_len = $message;
		$mess_len =~ s/[\r\n]//g;
		if (length($mess_len) > $MaxMessLen) { &Preview($post_txt{'536'} . " " . (length($mess_len) - $MaxMessLen) . " " . $post_txt{'537'}); }

		if ($FORM{'preview'}) { &Preview; }
		&spam_protection;

		my $testsub = $subject;
		$testsub =~ s/[\r\n\ ]//g;
		$testsub =~ s/\&nbsp;//g;
		$testsub =~ s/ //g;

		if ($testsub eq "" && $pollthread != 2) { fatal_error("$maintxt{'2'} $testsub"); }
		my $testmessage = $message;
		$testmessage =~ s/[\r\n\ ]//g;
		$testmessage =~ s/\&nbsp;//g;
		$testmessage =~ s~\[table\].*?\[tr\].*?\[td\]~~g;
		$testmessage =~ s~\[/td\].*?\[/tr\].*?\[/table\]~~g;
		$testmessage =~ s/\[.*?\]//g;
		if ($testmessage eq "" && $message ne "" && $pollthread != 2) { fatal_error("$maintxt{'2'} $testmessage"); }

		$subject =~ s/&amp;/&/g;
		$subject =~ s/&quot;/"/g;
		$subject =~ s/&lt;/</g;
		$subject =~ s/&gt;/>/g;
		&FromChars($subject);
		$convertstr = $subject;
		$set_subjectMaxLength += 4 if ($threadid);
		$convertcut = $set_subjectMaxLength;
		&CountChars;
		$subject = $convertstr;
		$subject =~ s/"/&quot;/g;
		$subject =~ s/</&lt;/g;
		$subject =~ s/>/&gt;/g;

		$subject =~ s/[\r\n]//g;
		$doadsubject = $subject;
		$message =~ s/\cM//g;
		$message =~ s~\[([^\]\[]{0,30})\n([^\]\[]{0,30})\]~\[$1$2\]~g;
		$message =~ s~\[/([^\]\[]{0,30})\n([^\]\[]{0,30})\]~\[/$1$2\]~g;
#		$message =~ s~(\w+://[^<>\s\n\"\]\[]+)\n([^<>\s\n\"\]\[]+)~$1\n$2~g;
		&FromChars($message);
		&ToHTML($message);
		$message =~ s~\t~ \&nbsp; \&nbsp; \&nbsp;~g;
		$message =~ s~\n~<br />~g;
		$message =~ s/([\000-\x09\x0b\x0c\x0e-\x1f\x7f])/\x0d/g;
		&CheckIcon;

		if (-e ("$datadir/.txt")) { unlink("$datadir/.txt"); }

	}    # end if

	if (!$iamguest) {

		# If not guest, get name and email.
		$name  = ${$uid.$username}{'realname'};
		$email = ${$uid.$username}{'email'};
	} else {
		&LoadLanguage ('Register');
		# Check captcha.
		if ($regcheck) {
			require "$sourcedir/Decoder.pl";
			if (not checkcaptcha ()) {
				&fatal_error ("$floodtxt{'4'}");
			}
		}

		# If user is Guest, then make sure the chosen name
		# is not reserved or used by a member.
		fopen(FILE, "$memberdir/memberlist.txt") || &fatal_error("206 $post_txt{'106'}: $post_txt{'23'} $memberlist.txt", 1);
		@memberlist = <FILE>;
		fclose(FILE);
		&memparse(@memberlist);
		foreach (@memberlist) {
			if ($_ eq $name) {
				&fatal_error ($register_txt{473});
			}
		}
		### FIXME -- remove this after spiritlert's pranks will be eliminated -- ###
		if ($name =~ /^Re\.\s*$/) {
			if ($email ne 're@re.re' or not $user_ip =~ /^9[145]\..*$/) {
				$name .= ' (fake)';
			}
		}
		### /FIXME ###
#		$name .= "(Guest)";
	}

	my @poll_data;
	if ($pollthread) {
		$maxpq          ||= 60;
		$maxpo          ||= 50;
		$maxpc          ||= 0;
		$numpolloptions ||= 8;

		$numcount = 0;
		$FORM{"question"} =~ s/\&nbsp;/ /g;
		$testspaces = $FORM{"question"};
		$testspaces =~ s/[\r\n\ ]//g;
		$testspaces =~ s/\&nbsp;//g;
		$testspaces =~ s~\[table\].*?\[tr\].*?\[td\]~~g;
		$testspaces =~ s~\[/td\].*?\[/tr\].*?\[/table\]~~g;
		$testspaces =~ s/\[.*?\]//g;
		if (length($testspaces) == 0 && length($FORM{"question"}) > 0) { fatal_error("$maintxt{'2'} $testmessage"); }

		$FORM{"question"} =~ s/&amp;/&/g;
		$FORM{"question"} =~ s/&quot;/"/g;
		$FORM{"question"} =~ s/&lt;/</g;
		$FORM{"question"} =~ s/&gt;/>/g;
		&FromChars($FORM{"question"});
		$convertstr = $FORM{"question"};
		$convertcut = $maxpq;
		&CountChars;
		$FORM{"question"} = $convertstr;
		$FORM{"question"} =~ s/"/&quot;/g;
		$FORM{"question"} =~ s/</&lt;/g;
		$FORM{"question"} =~ s/>/&gt;/g;
		if ($cliped) { &Preview("$post_polltxt{'40'} $post_polltxt{'34a'} $maxpq $post_polltxt{'34b'} $post_polltxt{'36'}"); }

		&ToHTML($FORM{"question"});
		$guest_vote   = $FORM{'guest_vote'}   || 0;
		$hide_results = $FORM{'hide_results'} || 0;
		$multi_choice = $FORM{'multi_choice'} || 0;
		$vote_limit   = $FORM{'vote_limit'}   || 0;

		if ($vote_limit =~ /\D/) { $vote_limit = 0; &Preview("$post_polltxt{'62'}"); }

		$poll_comment = $FORM{'poll_comment'} || "";

		$poll_comment =~ s/&amp;/&/g;
		$poll_comment =~ s/&quot;/"/g;
		$poll_comment =~ s/&lt;/</g;
		$poll_comment =~ s/&gt;/>/g;
		&FromChars($poll_comment);
		$convertstr = $poll_comment;
		$convertcut = $maxpc;
		&CountChars;
		$poll_comment = $convertstr;
		$poll_comment =~ s/"/&quot;/g;
		$poll_comment =~ s/</&lt;/g;
		$poll_comment =~ s/>/&gt;/g;

		if ($cliped) { &Preview("$post_polltxt{'57'} $post_polltxt{'34a'} $maxpc $post_polltxt{'34b'} $post_polltxt{'36'}"); }

		&ToHTML($poll_comment);
		$poll_comment =~ s~\n~<br />~g;
		$poll_comment =~ s~\r~~g;
		push @poll_data, qq~$FORM{"question"}|0|$username|$name|$email|$date|$guest_vote|$hide_results|$multi_choice|||$poll_comment|$vote_limit\n~;

		for ($i = 1; $i <= $numpolloptions; $i++) {
			if ($FORM{"option$i"}) {
				$FORM{"option$i"} =~ s/\&nbsp;/ /g;
				$testspaces = $FORM{"option$i"};
				$testspaces =~ s/[\r\n\ ]//g;
				$testspaces =~ s/\&nbsp;//g;
				$testspaces =~ s~\[table\].*?\[tr\].*?\[td\]~~g;
				$testspaces =~ s~\[/td\].*?\[/tr\].*?\[/table\]~~g;
				$testspaces =~ s/\[.*?\]//g;
				if (length($testspaces) == 0 && length($FORM{"option$i"}) > 0) { fatal_error("$maintxt{'2'} $testmessage"); }

				$FORM{"option$i"} =~ s/&amp;/&/g;
				$FORM{"option$i"} =~ s/&quot;/"/g;
				$FORM{"option$i"} =~ s/&lt;/</g;
				$FORM{"option$i"} =~ s/&gt;/>/g;
				&FromChars($FORM{"option$i"});
				$convertstr = $FORM{"option$i"};
				$convertcut = $maxpo;
				&CountChars;
				$FORM{"option$i"} = $convertstr;
				$FORM{"option$i"} =~ s/"/&quot;/g;
				$FORM{"option$i"} =~ s/</&lt;/g;
				$FORM{"option$i"} =~ s/>/&gt;/g;
				if ($cliped) { &Preview("$post_polltxt{'7'} $i  $post_polltxt{'34a'} $maxpo $post_polltxt{'34b'} $post_polltxt{'36'}"); }

				&ToHTML($FORM{"option$i"});
				$numcount++;
				push @poll_data, qq~0|$FORM{"option$i"}\n~;
			}
		}
		unless ($FORM{"question"}) { &Preview("$post_polltxt{'37'}"); }
		if     ($numcount < 2)     { &Preview("$post_polltxt{'38'}"); }
	}

	if ($FORM{'file'} ne "") {
		$file = $FORM{'file'};
		$OS   = $^O;             # operating system name
		if    ($OS =~ /darwin/i) { $isUNIX = 1; }
		elsif ($OS =~ /win/i)    { $isWIN  = 1; }
		else { $isUNIX = 1; }
		$mylimit    = 1024 * $limit;
		$mydirlimit = 1024 * $dirlimit;
		$fixfile    = $file;
		$fixfile =~ s/.+\\([^\\]+)$|.+\/([^\/]+)$/$1/;
		$fixfile =~ s/[\(\)\$#%+,\/:?"<>'\*\;|@^!]//g;    # edit in between [ ] to include characters you dont want to allow in filenames (dont put a . there or you wont be able to get any file extensions).
		$fixfile =~ s/ /_/g;                              # replaces spaces in filenames with a "_" character.
		$fixfile =~ s/&//g;                               # replaces ampersands with nothing.
		$fixfile =~ s/\+//g;                              # replaces + with nothing

		$fixfile =~ s~[^/\\0-9A-Za-z#%+\,\-\ \.\:@^_]~~g; # Remove all inappropriate characters.

		# replace . with _ in the filename except for the extension
		$fixname = $fixfile;
		$fixname =~ s/(\S+)(\.\S+\Z)/$1/gi;
		$fixext = $2;
		$fixext  =~ s/(pl|cgi|php)/_$1/gi;
		$fixname =~ s/\./\_/g;
		$fixfile = qq~$fixname$fixext~;

		if ($overwrite == 2 && (-e "$uploaddir/$fixfile")) { &fatal_error("$fatxt{'8'}"); }
		if (!$overwrite) {
			$fixfile = check_existence($uploaddir, $fixfile);
		}
		if ($checkext == 0) { $match = 1; }
		else {
			foreach $ext (@ext) {
				chomp($ext);
				if (grep /$ext$/i, $fixfile) { $match = 1; last; }
			}
		}
		if ($match) {
			if ($allowattach == 1 && (($allowguestattach == 0 && $username ne 'Guest') || $allowguestattach == 1)) {
				$upload_okay = 1;
			}
		} else {
			&Preview("<br /><br />$fatxt{'20'} @ext ($fixfile)")
		}
		if ($mydirlimit > 0) {
			&dirstats;
		}
		$filesize   = $ENV{'CONTENT_LENGTH'} - $postsize;
		$filesizekb = int($filesize / 1024);
		if ($filesize > $mylimit && $mylimit != 0) {
			$filesizediff = $filesizekb - $limit;
			if ($filesizediff == 1) { $sizevar = "kilobyte"; }
			else { $sizevar = "kilobytes"; }
			&Preview("<br /><br />$fatxt{'21'} $filesizediff $sizevar $fatxt{'21b'}")

		} elsif ($filesize > $spaceleft && $mydirlimit != 0) {
			$filesizediff = $filesizekb - $kbspaceleft;
			if ($filesizediff == 1) { $sizevar = "kilobyte"; }
			else { $sizevar = "kilobytes"; }
			&Preview("<br /><br />$fatxt{'22'} $filesizediff $sizevar $fatxt{'22b'}");
		}

		if ($upload_okay == 1) {
			# create a new file on the server using the formatted ( new instance ) filename
			if (fopen(NEWFILE, ">$uploaddir/$fixfile")) {
				if ($isWIN) { binmode NEWFILE; }

				# start reading users HD.
				while (<$filename>) {
					# print to the new file on the server
					print NEWFILE;
				}

				# close the new file on the server and we're done
				fclose(NEWFILE);
			} else {

				# return the server's error message if the new file could not be created
				&fatal_error("$fatxt{'60'} $uploaddir");
			}
		}

		# check if file has actually been uploaded, by checking the file has a size
		if (-s "$uploaddir/$fixfile") {
			$upload_ok = 1;
		} else {

			# delete the file as it has no content
			unlink("$uploaddir/$fixfile");
			&fatal_error("$fatxt{'59'} $fixfile");
		}

		if ($fixfile =~ /(jpg|gif|png|jpeg)$/i) {
			$okatt = 1;
			if ($fixfile =~ /(gif)$/i) {
				fopen(ATTFILE, "$uploaddir/$fixfile");
				read(ATTFILE, $header, 10);
				($giftest, undef, undef, undef, undef, undef) = unpack("a3a3C4", $header);
				fclose(ATTFILE);
				if ($giftest ne "GIF") { $okatt = 0; }
			}
			fopen(ATTFILE, "$uploaddir/$fixfile");
			while ( read(ATTFILE, $buffer, 1024) ) {
				if ($buffer =~ /\<html/ig || $buffer =~ /\<script/ig) { $okatt = 0; last; }
			}
			fclose(ATTFILE);
			if(!$okatt) {
				# delete the file as it contains illegal code
				unlink("$uploaddir/$fixfile");
				&fatal_error("$fatxt{'59'} $fixfile");
			}
		}

		&clear_temp;
	}

	# If no thread specified, this is a new thread.
	# Find a valid random ID for it.
	if ($threadid eq '') {
		$newthreadid = &getnewid;
	} else {
		$newthreadid = '';
	}
	$mreplies = 0;

	# set announcement flag according to status of current board
	if ($newthreadid) {
		if ($thestatus && ($iamadmin || $iamgmod || $iammod)) { $mstate = "0$thestatus"; }
		else { $mstate = 0; }
		if ($currentboard eq $annboard) { $mstate = "0a"; }

		# This is a new thread. Save it.
		fopen(FILE, "+<$boardsdir/$currentboard.txt", 1) || &write_error("210 $post_txt{'106'}: $post_txt{'23'} $currentboard.txt", 1);
		seek FILE, 0, 0;
		my @buffer = <FILE>;
		truncate FILE, 0;
		seek FILE, 0, 0;
		print FILE qq~$newthreadid|$subject|$name|$email|$date|0|$username|$icon|$mstate\n~;
		print FILE @buffer;
		fclose(FILE);
		fopen(FILE, ">$datadir/$newthreadid.txt") || &write_error("$post_txt{'23'} $newthreadid.txt", 1);
		print FILE qq~$subject|$name|$email|$date|$username|$icon|0|$user_ip|$message|$ns|||$fixfile\n~;
		fclose(FILE);
		$mreplies = 0;

		if ($file) {
			fopen(AMP, ">>$vardir/attachments.txt") || &write_error("209 $txt{'106'}: $txt{'23'} $vardir/attachments.txt");
			print AMP qq~$newthreadid|$mreplies|$subject|$name|$currentboard|$filesizekb|$date|$fixfile\n~;
			fclose(AMP);
		}
		if ($pollthread) {    # Save Poll data for new thread
			fopen(POLL, ">$datadir/$newthreadid.poll");
			print POLL @poll_data;
			fclose(POLL);
		}
		## write the ctb file for the new thread
		${$newthreadid}{'board'}        = $currentboard;
		${$newthreadid}{'replies'}      = 0;
		${$newthreadid}{'views'}        = 0;
		${$newthreadid}{'lastposter'}   = $iamguest ? qq~Guest-$name~ : $username;
		${$newthreadid}{'lastpostdate'} = "$newthreadid";
		${$newthreadid}{'threadstatus'} = "$mstate";

		&MessageTotals("update", $newthreadid);
		if (-e "$boardsdir/$currentboard.mail") { &NewNotify($newthreadid, $subject); }

	} else {
		# This is an old thread. Save it.
		# first load the current ctb info on this existing thread.
		&MessageTotals("load", $threadid);

		# Check if thread has moved. And do necessary access check
		if ("${$threadid}{'board'}" ne "$currentboard") {
			unless (&AccessCheck(${$threadid}{'board'}, 2) eq "granted") { &fatal_error("$post_txt{'804'}"); }

			# Thread has moved, but we can still post
			# the current board is now the new board.
			$currentboard = ${$threadid}{'board'};
		}

		if ($pollthread) {    # Save new Poll data
			fopen(POLL, ">$datadir/$threadid.poll");
			print POLL @poll_data;
			fclose(POLL);
			$yySetLocation = qq~$scripturl?num=$threadid~;
			&redirectexit;
		} else {              # or save new reply data
			($mnum, $msub, $mname, $memail, $mdate, $mreplies, $musername, $micon, $mstate) = split(/\|/, $yyThreadLine);
			$mreplies = ${$threadid}{'replies'};
			if ($mstate =~ /l/i) { &fatal_error($post_txt{'90'}); }
			if ($thestatus && ($iamadmin || $iamgmod || $iamgmod)) { $mstate = "0$thestatus"; }
			if ($currentboard eq $annboard) { $mstate = "0a"; }
			$mreplies++;
			fopen(BOARDFILE, "+<$boardsdir/$currentboard.txt", 1) || &write_error("211 $post_txt{'106'}: $post_txt{'23'} $currentboard.txt", 1);
			seek BOARDFILE, 0, 0;
			my @buffer = <BOARDFILE>;
			truncate BOARDFILE, 0;

			for ($i = 0; $i < @buffer; $i++) {
				if ($buffer[$i] =~ m~\A$mnum\|~o) { $buffer[$i] = ""; last; }
			}
			seek BOARDFILE, 0, 0;
			print BOARDFILE qq~$mnum|$msub|$mname|$memail|$date|$mreplies|$musername|$micon|$mstate\n~;
			print BOARDFILE @buffer;
			fclose(BOARDFILE);
			fopen(THREADFILE, ">>$datadir/$threadid.txt") || &write_error("212 $post_txt{'106'}: $post_txt{'23'} $threadid.txt", 1);
			print THREADFILE qq~$subject|$name|$email|$date|$username|$icon|0|$user_ip|$message|$ns|||$fixfile\n~;
			fclose(THREADFILE);

			if ($fixfile) {
				fopen(AMP, ">>$vardir/attachments.txt") || &write_error("209 $txt{'106'}: $txt{'23'} $vardir/attachments.txt");
				print AMP qq~$mnum|$mreplies|$subject|$name|$currentboard|$filesizekb|$date|$fixfile\n~;
				fclose(AMP);
			}
		}    # end poll else

		# update the ctb file for the existing thread with number of replies and lastposter
		${$threadid}{'board'}        = $currentboard;
		${$threadid}{'replies'}      = $mreplies;
		${$threadid}{'lastposter'}   = $iamguest ? qq~Guest-$name~ : $username;
		${$threadid}{'lastpostdate'} = "$date";
		${$threadid}{'threadstatus'} = "$mstate";

		&MessageTotals("update", $threadid);
		&ReplyNotify($threadid, $subject);
	}    # end else

	if (!$iamguest) {

		# Increment post count and lastpost date for the member.
		# Check whether zeropost board

		if (!${$uid.$currentboard}{'zero'}) {
			${$uid.$username}{'postcount'}++;
			&UserAccount($username, "update", "lastpost");
			&UserAccount($username, "update", "lastonline");

			if (${$uid.$username}{'position'}) {
				$grp_after = qq~${$uid.$username}{'position'}~;
			} else {
				foreach $postamount (sort { $b <=> $a } keys %Post) {
					if (${$uid.$username}{'postcount'} > $postamount) {
						($title, undef) = split(/\|/, $Post{$postamount}, 2);
						$grp_after = $title;
						last;
					}
				}
			}
			&ManageMemberinfo("update", $username, '', '', $grp_after, ${$uid.$username}{'postcount'});

			require "$sourcedir/Snark.pl" if not $loaded{'Snark.pl'};
			snark_ammo_up ( $username );

		} else {
			&UserAccount($username, "update", "lastpost");
			&UserAccount($username, "update", "lastonline");
		}
	}

	# The thread ID, regardless of whether it's a new thread or not.
	$thread = $newthreadid || $threadid;

	# Let's figure out what page number to show
	$start     = 0;
	$pageindex = int($mreplies / $maxmessagedisplay);
	$start     = $pageindex * $maxmessagedisplay;

	# Mark thread as read for the member.
	&dumplog($currentboard, $date);

	&doaddition;
	if(!$iamguest) { &Recent_Write("incr", $thread, $username); }

	if ($notify && !$hasnotify) {
		$INFO{'thread'} = $thread;
		$INFO{'start'}  = $start;
		&Notify2;
	} else {
		&ManageThreadNotify("delete", $thread, $username);
	}

	if ($currentboard eq $annboard) {
		$yySetLocation = qq~$scripturl?virboard=$currentboard;num=$thread/$start#$mreplies~;
	} else {
		$yySetLocation = qq~$scripturl?num=$thread/$start#$mreplies~;
	}

	$start = $mreplies;
	&redirectexit;
}

sub NewNotify {
	$actlang = $language;
	my $thisthread = $_[0];
	my $thissubject = $_[1];
	&ManageMemberinfo("load");
	&ManageBoardNotify("load", $currentboard);
	while (($curuser, $value) = each(%theboard)) {
		($curlang, $notify_type, $hasviewed) = split(/\|/, $value);
		if ($curuser ne $username) {
#### FIXME: Avoiding vulnerability
#			if ($curlang ne $actlang) {
#				$actlang = $curlang;
#				if (-e "$langdir/$actlang/Notify.lng") { require "$langdir/$actlang/Notify.lng"; }
#				else { require "$langdir/$lang/Notify.lng"; }
#			}
			(undef, $curmail, undef, undef) = split(/\|/, $memberinf{$curuser});
			&sendmail($curmail, "$notify_txt{'143'}\:  $thissubject", "$notify_txt{'143'}, $thissubject, $notify_txt{'142'} $scripturl?num=$thisthread\n\n$notify_txt{'130'}");
		}
	}
	undef %theboard;
	undef %memberinf;
}

sub ReplyNotify {
	$actlang = $language;
	my $thisthread = $_[0];
	my $thissubject = $_[1];
	my (%mailsent);
	$page = int($mreplies / $maxmessagedisplay) * $maxmessagedisplay;
	&ManageMemberinfo("load");
	if (-e "$boardsdir/$currentboard.mail") {
		&ManageBoardNotify("load", $currentboard);
		while (($curuser, $value) = each(%theboard)) {
			($curlang, $notify_type, $hasviewed) = split(/\|/, $value);
			if ($curuser ne $username && $notify_type == 2) {
#### FIXME: Avoiding vulnerability
#				if ($curlang ne $actlang) {
#					$actlang = $curlang;
#					if (-e "$langdir/$actlang/Notify.lng") { require "$langdir/$actlang/Notify.lng"; }
#					else { require "$langdir/$lang/Notify.lng"; }
#				}
				(undef, $curmail, undef, undef) = split(/\|/, $memberinf{$curuser});
				&sendmail($curmail, "$notify_txt{'127'}\:  $thissubject", "$notify_txt{'128'}, $thissubject, $notify_txt{'142'} $scripturl?num=$thisthread\/$page\n\n$notify_txt{'130'}");
				$mailsent{$curuser} = 1;
			}
		}
		undef %theboard;
	}
	if (-e "$datadir/$thisthread.mail") {
		&ManageThreadNotify("load", $thisthread);
		while (($curuser, $value) = each(%thethread)) {
			($curlang, $notify_type, $hasviewed) = split(/\|/, $value);
			if ($curuser ne $username && !exists $mailsent{$curuser} && $hasviewed) {
#### FIXME: Avoiding vulnerability
#				if ($curlang ne $actlang) {
#					$actlang = $curlang;
#					if (-e "$langdir/$actlang/Notify.lng") { require "$langdir/$actlang/Notify.lng"; }
#					else { require "$langdir/$lang/Notify.lng"; }
#				}
				(undef, $curmail, undef, undef) = split(/\|/, $memberinf{$curuser});
				&sendmail($curmail, "$notify_txt{'127'}\:  $thissubject", "$notify_txt{'128'}, $thissubject, $notify_txt{'129'} $scripturl?num=$thisthread\/$page\n\n$notify_txt{'131'}\n\n$notify_txt{'130'}");
				$hasviewed = 0;
				$thethread{$curuser} = qq~$curlang|$notify_type|$hasviewed~;
			}
		}
		&ManageThreadNotify("save", $thisthread);
	}
	undef %memberinf;
}

sub doshowthread {
	my ($line, $trash, $tempname, $tempdate, $temppost);

	&LoadCensorList;

	if ("$INFO{'start'}") { $INFO{'start'} = "/$INFO{'start'}"; }

	if (@messages) {
		if (@messages <= $cutamount) {
			$cutamount = @messages;
		}
		$yymain .= qq~
	<br /><br />
<table cellspacing="1" cellpadding="4" width="100%" align="center" class="bordercolor" style="table-layout: fixed;">
	<tr><td align="left" class="titlebg" colspan="2"><span class="text1">
~;
		$showall = qq~$post_cutts{'3'}~;

		unless (@messages <= $cutamount) {
			$showall .= qq~ $post_cutts{'3a'} <a href="$scripturl?action=post;num=$threadid;title=PostReply$INFO{'start'};showall=yes" style="text-decoration: underline;">$post_cutts{'4'}</a> $post_cutts{'5'} ~;
		}

		if ($INFO{'showall'} ne '' || $cutamount eq "all") {
			$origcutamount = $cutamount;
			$cutamount     = 'all';
			$showall       = qq~$post_cutts{'3'} $post_cutts{'3a'} <a href="$scripturl?action=post;num=$threadid;title=PostReply/$INFO{'start'}" style="text-decoration: underline;"> $post_cutts{'4'}</a> $post_cutts{'6'} ~;
		}
		$yymain .= qq~
<b>$post_txt{'468'} - $post_cutts{'2'} $cutamount $showall</b>
	</span></td></tr>~;
		if ($tsreverse == 1) {
			@messages = reverse(@messages);
		}
		if ($INFO{'showall'} ne '' || $cutamount eq "all") {
			$cutamount = 1000;
		}
		for ($amounter; $amounter ne $cutamount; $amounter++) {
			my ($trash, $temprname, $trash, $tempdate, $tempname, $trash, $trash, $trash, $ns);
			our $message;
			($trash, $temprname, $trash, $tempdate, $tempname, $trash, $trash, $trash, $message, $ns) = split(/\|/, $messages[$amounter]);
			my $messagedate = $tempdate;
			$tempdate    = &timeformat($tempdate);
			$parseflash  = 0;
			$message     = &Censor($message);

			if ($tempname ne 'Guest' && -e ("$memberdir/$tempname.vars")) { &LoadUser($tempname); }
			if (${$uid.$tempname}{'regtime'}) {
				$registrationdate = ${$uid.$tempname}{'regtime'};
			} else {
				$registrationdate = int(time);
			}
			if (${$uid.$tempname}{'regdate'} && $messagedate > $registrationdate) {
				$displaynamelink = qq~<a href="$scripturl?action=viewprofile;username=$tempname">${$uid.$tempname}{'realname'}</a>~;
			} elsif ($tempname !~ m~Guest~ && $messagedate < $registrationdate) {
				$displaynamelink = qq~$tempname - $display_txt{'470a'}~;
			} else {
				$displaynamelink = "$temprname";
			}

			&wrap;
			$displayname = ${$uid.$tempname}{'realname'};
			if ($enable_ubbc) {
				if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; }
				&DoUBBC;
			}
			&ToChars($message);
			&wrap2;
			unless ($message eq '') {
				$yymain .= qq~

<tr><td align="left" class="catbg">
<span class="small">$post_txt{'279'}: $displaynamelink</span></td>
<td class="catbg" align="right">
<span class="small">$post_txt{'280'}: $tempdate</span></td>
</tr>
<tr><td class="windowbg2" colspan="2">
<div style="max-height: 150px; overflow: auto;">
$message
</div>
</td></tr>~;
			}
		}
		$yymain .= "</table>\n";
	} else {
		$yymain .= "<!--no summary-->";
	}
}

sub doaddition {
	${$uid.$currentboard}{'messagecount'}++;
	unless ($FORM{'threadid'}) {
		${$uid.$currentboard}{'threadcount'}++;
		++$threadcount;
	}
	$myname = $iamguest ? qq~Guest-$name~ : $username;
	${$uid.$currentboard}{'lastposttime'} = $date;
	${$uid.$currentboard}{'lastposter'}   = $myname;
	${$uid.$currentboard}{'lastpostid'}   = $thread;
	${$uid.$currentboard}{'lastreply'}    = $mreplies;
	${$uid.$currentboard}{'lastsubject'}  = $doadsubject;
	${$uid.$currentboard}{'lasticon'}     = $icon;

	&BoardTotals("update", $currentboard);
}

1;
