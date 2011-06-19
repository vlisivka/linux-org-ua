###############################################################################
# InstantMessage.pl                                                           #
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

$instantmessageplver = 'YaBB 2.1 $Revision: 1.6 $';
if ($action eq 'detailedversion') { return 1; }

LoadLanguage("InstantMessage");

sub CallBack {
	$receiver = "$INFO{'receiver'}";
	$rid      = "$INFO{'rid'}";
	chomp($rid);
	undef $nodel;

	fopen(FILE, "$memberdir/$receiver.msg");
	@rims = <FILE>;
	fclose(FILE);

	fopen(REVMSG, ">$memberdir/$receiver.msg");
	foreach $line (@rims) {
		chomp($line);
		($rusername, $rsub, $rdate, $rimmessage, $rmessageid, $rimip, $rnew) = split(/\|/, $line);
		chomp($rmessageid);
		chomp($rnew);
		if ($rmessageid != $rid) { print REVMSG "$line\n"; }
		elsif ($rnew != 1) { print REVMSG "$line\n"; $nodel = 1; }
	}
	fclose(REVMSG);

	fopen(UOB, "+<$memberdir/$username.outbox");
	seek UOB, 0, 0;
	@outbox = <UOB>;
	seek UOB, 0, 0;
	truncate UOB, 0;
	foreach $line (@outbox) {
		chomp($line);
		($rusername, $rsub, $rdate, $rimmessage, $rmessageid, $rimip, $rnew) = split(/\|/, $line);
		chomp($rmessageid);
		chomp($rnew);
		if ($rmessageid != $rid) { print UOB "$line\n"; }
		elsif ($rnew == 1) { print UOB "$line\n"; $nodel = 1; }
	}
	fclose(UOB);

	if ($nodel == 1) { &fatal_error("$inmes_imtxt{'72'}"); }
	else {
		open(FILE, ">$memberdir/$username.ims");
		print FILE "\$messages = " . $messages-- . "\;\n\$newmessages = " . $newmessages-- . "\;\n\$outmessages = $outmessages\;\n\$storedmessages = $storedmessages\;\n\n\1\;";
	}

	$yySetLocation = qq~$scripturl?action=imoutbox~;
	&redirectexit;

}

sub ModList {
	unlink("$vardir/modslist.txt");

	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }
	while (my ($key, $value) = each(%cat)) {
		my (@tmpboard) = split(/\,/, $value);
		push(@catinfo, @tmpboard);
	}
	foreach $curboard (@catinfo) {
		$curboard =~ s/[\n\r]//g;
		foreach (split(/\|/, ${$uid.$curboard}{'mods'})) {
			$a = 0;
			if ($a == 0) {
				fopen(FILE, ">$vardir/modslist.txt");
				print FILE "$_\n";
				fclose(FILE);
			}
		}
	}
}

sub Del_Some_IM {
	if ($iamguest) { &fatal_error($inmes_txt{'147'}); }

	if ($FORM{'imaction'} eq "$inmes_imtxt{'10'}") {
		if    ($INFO{'caller'} == 1) { fopen(FILE, "$memberdir/$username.msg"); }
		elsif ($INFO{'caller'} == 2) { fopen(FILE, "$memberdir/$username.outbox"); }
		elsif ($INFO{'caller'} == 3) { fopen(FILE, "$memberdir/$username.imstore"); }

		@messages = <FILE>;
		fclose(FILE);

		if    ($INFO{'caller'} == 1) { fopen(FILE, ">$memberdir/$username.msg",     1); }
		elsif ($INFO{'caller'} == 2) { fopen(FILE, ">$memberdir/$username.outbox",  1); }
		elsif ($INFO{'caller'} == 3) { fopen(FILE, ">$memberdir/$username.imstore", 1); }

		$b = 0;
		for ($a = 0; $a < @messages; $a++) {
			if ($FORM{"message$a"} != 1) { print FILE "$messages[$a]"; }
			else { $b++ }
		}

		fclose(FILE);

		if    ($INFO{'caller'} == 1) { $messages      = $messages - $b; }
		elsif ($INFO{'caller'} == 2) { $outmessages   = $outmessages - $b; }
		elsif ($INFO{'caller'} == 3) { $storemessages = $storemessages - $b; }

		fopen(FILE, ">$memberdir/$username.ims");
		print FILE qq~\$messages = $messages\;\n\$newmessages = $newmessages\;\n\$outmessages = $outmessages\;\n\$storedmessages = $storedmessages\;\n\n1\;~;
		fclose(FILE);

		if    ($INFO{'caller'} == 1) { $yySetLocation = qq~$scripturl?action=im~; }
		elsif ($INFO{'caller'} == 2) { $yySetLocation = qq~$scripturl?action=imoutbox~; }
		elsif ($INFO{'caller'} == 3) { $yySetLocation = qq~$scripturl?action=imstorage~; }
		&redirectexit;
	}

	if ($FORM{'imaction'} eq "$inmes_imtxt{'50'}") {
		my (@messages, $a, $musername, $msub, $mdate, $mmessage, $messageid, $mip);
		$source = $INFO{'caller'} == 1 ? "inbox" : "outbox";

		if    ($INFO{'caller'} == 1) { fopen(FILE, "$memberdir/$username.msg"); }
		elsif ($INFO{'caller'} == 2) { fopen(FILE, "$memberdir/$username.outbox"); }
		@messages = <FILE>;
		fclose(FILE);

		if    ($INFO{'caller'} == 1) { fopen(FILE, ">$memberdir/$username.msg",    1); }
		elsif ($INFO{'caller'} == 2) { fopen(FILE, ">$memberdir/$username.outbox", 1); }

		fopen(trANSFER, ">>$memberdir/$username.imstore", 1);
		for ($a = 0; $a < @messages; $a++) {
			chomp $messages[$a];
			($imusername, $imsub, $imdate, $mmessage, $imessageid, $mip, $imnew) = split(/\|/, $messages[$a]);
			$imdummy = "";
			if ($imnew eq "") { $imdummy = "|"; }
			if ($FORM{"message$a"} != 1) { print FILE "$messages[$a]\n"; }
			else { print trANSFER "$messages[$a]$imdummy|$source\n"; }
		}
		fclose(trANSFER);
		fclose(FILE);

		my $redirect = $INFO{'caller'} == 1 ? 'im' : 'imoutbox';
		$yySetLocation = qq~$scripturl?action=$redirect~;
		&redirectexit;
	}
}

sub DoShowIM {
	$yymain .= qq~
<script language="JavaScript1.2" src="$ubbcjspath" type="text/javascript"></script>

<div class="displaycontainer">
<table cellpadding="4" cellspacing="0" border="0" width="100%" class="bordercolor" align="center" style="table-layout: fixed;">
<tr>
	<td align="left" class="titlebg" width="140">
		<span class="text1">&nbsp;<b>$rectext</b></span>
	</td>
	<td align="left" class="titlebg">
		<span class="text1"><b>$inmes_txt{'118'}</b></span>
	</td>
</tr>

~;
	$mydate = &timeformat($mdate);
	if ($musername ne 'Guest' && !$yyUDLoaded{$musername} && -e ("$memberdir/$musername.vars")) {
		$sm = 1;
		&LoadUserDisplay($musername);
	}

	if ($yyUDLoaded{$musername}) {
		$displayname = ${$uid.$musername}{'realname'};
		$star        = $memberstar{$musername};
		$memberinfo  = "<b>$memberinfo{$musername}</b>";
		$memberinfo =~ s~\n~~g;
		$icqad = $icqad{$musername};
		$yimon = $yimon{$musername};
		if (!$iamguest) {
			# Allow instant message sending if current user is a member.
			$sendm = qq~$menusep<a href="$scripturl?action=imsend;to=$useraccount{$musername}">$img{'message_sm'}</a>~;
		}
		$postinfo = qq~$inmes_txt{'21'}: ${$uid.$musername}{'postcount'}<br />~;
		$memail   = ${$uid.$musername}{'email'};
		if ($disable_publicname != 1) {
			$usernamelink = qq~$link{$musername}~;
		} else {
			$usernamelink = qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$musername}"><b>$musername</b></a>~;
		}
	} else {
		$usernamelink = qq~<b>$musername</b>~;
	}
	$immessage = &Censor($immessage);
	$msub      = &Censor($msub);
	&ToChars($msub);
	$message = $immessage;
	&wrap;
	if ($enable_ubbc) {
		if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; }
		&DoUBBC;
	}
	&wrap2;
	&ToChars($message);

	$online = qq~(<i>$inmes_imtxt{'61'}</i>)~;
	foreach $lines (@logentries) {
		($name, $dummy) = split(/\|/, $lines);
		chomp $name;
		if ($name eq $musername) {
			$online = qq~(<i>$inmes_imtxt{'60'}</i>)~;
		}
	}

	$avstyle = "";
	if ($ENV{'HTTP_USER_AGENT'} !~ /MSIE/ || $ENV{'HTTP_USER_AGENT'} =~ /Opera/) {
		if ($userpic_width > 0 || $userpic_height > 0) {
			$avstyle = qq~ style="~;
			if ($userpic_width > 0)  { $avstyle .= qq~max-width: $userpic_width\px\; ~; }
			if ($userpic_height > 0) { $avstyle .= qq~max-height: $userpic_height\px\;~; }
			$avstyle .= qq~"~;
		}
	}

	$template_userpic = qq~${$uid.$musername}{'userpic'}~;

	if ($showuserpic && $allowpics) {
		if (${$uid.$musername}{'userownpic'}) {
			$avstyle = "";
			if ($ENV{'HTTP_USER_AGENT'} !~ /MSIE/ || $ENV{'HTTP_USER_AGENT'} =~ /Opera/) {
				if ($userpic_width > 0 || $userpic_height > 0) {
					$avstyle = qq~ style="~;
					if ($userpic_width > 0)  { $avstyle .= qq~max-width: $userpic_width\px\; ~; }
					if ($userpic_height > 0) { $avstyle .= qq~max-height: $userpic_height\px\;~; }
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

	$text = ${$uid.$musername}{'usertext'};
	if ($INFO{'caller'} == 2 || $INFO{'caller'} == 3) { $signature = ""; }
	else { $signature = qq~${$uid.$musername}{'signature'}~; }

	$usernamelink = qq~$usernamelink<br />~;

	$yymain .= qq~
<tr>
	<td align="left" class="windowbg" valign="top" width="140">
		$usernamelink
		<span class="small">
			$memberinfo<br />
			$star<br /><br />
			$avatar $text<br /><br />
			${$uid.$musername}{'gender'}
			$postinfo
		</span>
	</td>
	<td class="windowbg" align="left" valign="top">
		<div style="float: left; width: 99%; border-bottom: 1px #a7b8cc solid; padding-bottom: 2px; margin-bottom: 2px;">
		<span class="small" style="float: left; width: 99%;">
		<b>$inmes_txt{'70'}: $msub</b><br />
		&#171; <b>$inmes_txt{'317'}:</b> $mydate &#187;
		</span>
		</div>
		<div style="float: left; width: 99%;">
		<span class="message" style="float: left; width: 99%; overflow: auto;">
	        $message
		</span>
		</div>
	</td>
</tr>
<tr>
	<td class="windowbg" valign="bottom">
		&nbsp;
	</td>
	<td class="windowbg" align="right">
~;
	if ($iamadmin) {
		$yymain .= qq~
	<div style="float: left; width: 99%; padding-top: 5px; margin-top: 2px;">
	<span class="small" style="float: left; text-align: right; width: 99%;">
		<img src="$imagesdir/ip.gif" border="0" alt="" /> $imip
	</span>
	</div>
~;
	}
	if ($signature) {

		$yymain .= qq~
	<div style="float: left; width: 99%; border-top: 1px #a7b8cc solid; padding-top: 5px; margin-top: 2px;">
	<span class="small" style="float: left; text-align: left; width: 99%;">
	        $signature
	</span>
	</div>
~;
	} else {
		$yymain .= qq~&nbsp;~;
	}
	$yymain .= qq~
	</td>
</tr>
<tr>
	<td class="windowbg" align="left" valign="middle">
		&nbsp;
	</td>
        <td class="windowbg" align="left" valign="middle">
	<div style="float: left; width: 99%; border-top: 1px #a7b8cc solid; padding-top: 5px; margin-top: 2px;">
	<span class="small" style="float: left; width: 59%;">
~;
	if (${$uid.$musername}{'hidemail'} ne "checked" || $iamadmin || $iamgmod || $allow_hide_email ne 1) {
		$yymain .= qq~$profbutton${$uid.$musername}{'weburl'} <a href="mailto:$memail">$img{'email_sm'}</a>$sendm~;
	} else {
		$yymain .= qq~$profbutton${$uid.$musername}{'weburl'}$sendm~;
	}
	$yymain .= qq~
	${$uid.$musername}{'msn'} ${$uid.$musername}{'gtalk'} ${$uid.$musername}{'icq'} $icqad ${$uid.$musername}{'yim'} $yimon ${$uid.$musername}{'aim'}
	</span>
	<span class="small" style="float: left; text-align: right; width: 40%;">
        <a href="$scripturl?action=imsend;caller=$callvar;num=$counter;quote=1;to=$useraccount{$musername};id=$messageid">$img{'replyquote'}</a>$menusep<a href="$scripturl?action=imsend;caller=$callvar;num=$counter;reply=1;to=$useraccount{$musername};id=$messageid">$img{'reply_ims'}</a>$menusep<a href="$scripturl?action=imremove;caller=$callvar;id=$messageid" onclick="return confirm('$inmes_txt{'739'}')">$img{'im_remove'}</a>
	</span>
	</div>
	</td>
</tr>
</table>
</div>
	<script language="JavaScript1.2" type="text/javascript">
	<!-- //
	var userpic_width = $userpic_width;
	var userpic_height = $userpic_height;

	function ResizeAvatars(){
		if(navigator.appName == "Microsoft Internet Explorer" && navigator.appVersion.charAt(0) >= 4 && navigator.userAgent.indexOf("Opera") < 0) {
		for(var i=0; imgEle=document.getElementsByName('avatar')[i];i++) {
			if (userpic_width == 0) { tmpuserpic_width = imgEle.width; } else {tmpuserpic_width = userpic_width;}
			if (userpic_height == 0) { tmpuserpic_height = imgEle.height; } else {tmpuserpic_height = userpic_height;}
			var ratio = imgEle.width / imgEle.height;
			for(z=0;z<2;z++) { 
				if (imgEle.width > tmpuserpic_width) { imgEle.width = tmpuserpic_width; imgEle.height = parseInt(imgEle.width / ratio); }    
				if (imgEle.height > tmpuserpic_height) { imgEle.height = tmpuserpic_height; imgEle.width = parseInt(imgEle.height * ratio); }
			}
		}
		}
	}

	document.onload = ResizeAvatars();
	// -->
	</script>
~;
}

sub IMShow {
	if ($iamguest) { &fatal_error($maintxt{1}); }

	&jumpto;
	fopen(FILE, "$vardir/log.txt");
	@logentries = <FILE>;
	fclose(FILE);

	my (@messages);
	$yytitle = $inmes_txt{'143'};
	if ($INFO{'caller'} == 1) {
		$linktext = qq~<a href="$scripturl?action=im" class="nav">$inmes_txt{'316'}</a>~;
		$callvar  = "1";
		$rectext  = "$inmes_txt{'318'}";
		fopen(FILE, "$memberdir/$username.msg");
	} elsif ($INFO{'caller'} == 2) {
		$linktext = qq~<a href="$scripturl?action=imoutbox" class="nav">$inmes_txt{'320'}</a>~;
		$callvar  = "2";
		$rectext  = "$inmes_txt{'324'}";
		fopen(FILE, "$memberdir/$username.outbox");
	} elsif ($INFO{'caller'} == 3) {
		$linktext = qq~<a href="$scripturl?action=imstorage" class="nav">$inmes_imtxt{'46'}</a>~;
		$callvar  = "3";
		fopen(FILE, "$memberdir/$username.imstore");
	}
	@messages = <FILE>;
	fclose(FILE);

	if ($INFO{'id'} ne "all") {
		$messcount = 0;
		$messfound = 0;
		foreach $messagesim (@messages) {
			($musername, $msub, $mdate, $immessage, $messageid, $imip, $mnew, $imwhere) = split(/\|/, $messagesim);
			$messcount++;
			if ($messageid == $INFO{'id'}) { $messfound = 1; last; }
		}

		if($messfound == 0) { &fatal_error($maintxt{1}); }

		if ($INFO{'caller'} == 2 && $mnew != 1 && $INFO{'id'} ne "all") {
			$recall = qq~<span class="small">&#171; <a href="$scripturl?action=imcb;rid=$messageid;receiver=$musername" onclick="return confirm('$inmes_imtxt{'73'}')">$inmes_imtxt{'83'}</a> &#187;</span>~;
		}

		$nextid  = $messcount - 2;
		$previd  = $messcount;
		$counter = $messcount - 1;

		($pusername, $psub, $pdate, $pimmessage, $pmessageid, $pimip, $pmnew, $imwhere) = split(/\|/, $messages[$previd]);

		if ($pmessageid ne "") {
			$previd = qq~<a href="$scripturl?action=imshow;caller=$callvar;id=$pmessageid">$inmes_imtxt{'40'}</a>~;
		} else {
			$previd = "$inmes_imtxt{'39'}";
		}

		($nusername, $nsub, $ndate, $nimmessage, $nmessageid, $nimip, $nmnew, $imwhere) = split(/\|/, $messages[$nextid]);

		if ($nmessageid ne "" && $nextid >= 0) {
			$nextid = qq~<a href="$scripturl?action=imshow;caller=$callvar;id=$nmessageid">$inmes_imtxt{'41'}</a>~;
		} else {
			$nextid = "$inmes_imtxt{'39'}";
		}

		if (@messages != 1) {
			$allid = qq~<a href="$scripturl?action=imshow;caller=$callvar;id=all">$inmes_txt{'190'}</a>~;
		} else {
			$allid = qq~$inmes_txt{'190'}~;
		}
	}
	if ($INFO{'caller'} == 1) {
		fopen(FILE, ">$memberdir/$username.msg", 1);
		for ($a = 0; $a < @messages; $a++) {
			chomp $messages[$a];
			($imusername, $imsub, $imdate, $mmessage, $imessageid, $mip, $imnew) = split(/\|/, $messages[$a]);
			if ($imessageid ne "$INFO{'id'}") { print FILE "$messages[$a]\n"; }
			else {
				if ($imnew) {
					$newmessages--;
				}
				print FILE "$imusername|$imsub|$imdate|$mmessage|$imessageid|$mip\n";
			}
		}
		fclose(FILE);
	}
	if (-e ("$memberdir/$musername.vars")) {
		fopen(FILE, "$memberdir/$musername.outbox");
		@muoutmessages = <FILE>;
		fclose(FILE);
		fopen(FILE, ">$memberdir/$musername.outbox", 1);
		for ($a = 0; $a < @muoutmessages; $a++) {
			chomp $muoutmessages[$a];
			($muoutusername, $muoutsub, $muoutdate, $muoutmessage, $muoutmessageid, $muoutip, $muoutnew) = split(/\|/, $muoutmessages[$a]);
			if ($muoutmessageid ne "$INFO{'id'}") { print FILE "$muoutmessages[$a]\n"; }
			else { print FILE "$muoutusername|$muoutsub|$muoutdate|$muoutmessage|$muoutmessageid|$muoutip|1\n"; }
		}
		fclose(FILE);
	}
	$yymain .= qq~
<table cellspacing="1" cellpadding="4" width="100%" border="0" class="bordercolor"> 
        <tr> 
          <td class="catbg" valign="bottom" align="center" width="20%"><span class="small"><b><a href="$scripturl?action=im">$inmes_txt{316}</a></b></span></td> 
          <td class="catbg" valign="bottom" align="center" width="20%"><span class="small"><b><a href="$scripturl?action=imoutbox">$inmes_txt{320}</a></b></span></td> 
          <td class="catbg" valign="bottom" align="center" width="20%"><span class="small"><b><a href="$scripturl?action=imstorage">$inmes_imtxt{46}</a></b></span></td> 
          <td class="catbg" valign="bottom" align="center" width="20%"><span class="small"><b><a href="$scripturl?action=imsend">$inmes_txt{148}</a></b></span></td> 
          <td class="catbg" valign="bottom" align="center" width="20%"><span class="small"><b><a href="$scripturl?action=profileCheck;username=$username">$inmes_txt{765}</a></b></span></td>
	  </tr> 
</table><br />~;

	if ($INFO{'id'} ne "all") {
		&DoShowIM;
		$yymain .= qq~<table align="right" width="100%"><tr><td align="left" width="20%">$recall</td><td align="right"><span class="small">&#171; $previd | $allid | $nextid &#187;</span></td></tr></table><br /><br />
<table width="100%">
	<tr>
		<td align="right">$selecthtml
		</td>
	</tr>
</table>~;
	}

	if ($INFO{'id'} eq "all") {
		foreach $lines (@messages) {
			($musername, $msub, $mdate, $immessage, $messageid, $imip, $mnew, $imwhere) = split(/\|/, $lines);
			fopen(FILE, "$memberdir/$musername.outbox");
			@muoutmessages = <FILE>;
			fclose(FILE);

			fopen(FILE, ">$memberdir/$musername.outbox", 1);
			for ($a = 0; $a < @muoutmessages; $a++) {
				chomp $muoutmessages[$a];
				($muoutusername, $muoutsub, $muoutdate, $muoutmessage, $muoutmessageid, $muoutip, $muoutnew) = split(/\|/, $muoutmessages[$a]);
				if ($muoutmessageid ne "$messageid") { print FILE "$muoutmessages[$a]\n"; }
				else { print FILE "$muoutusername|$muoutsub|$muoutdate|$muoutmessage|$muoutmessageid|$muoutip|1\n"; }
			}
			fclose(FILE);
			&DoShowIM;
		}

		if ($INFO{'caller'} == 1) {
			fopen(FILE, ">$memberdir/$username.msg", 1);
			for ($a = 0; $a < @messages; $a++) {
				chomp $messages[$a];
				($imusername, $imsub, $imdate, $mmessage, $imessageid, $mip, $imnew) = split(/\|/, $messages[$a]);
				print FILE "$imusername|$imsub|$imdate|$mmessage|$imessageid|$mip\n";
			}
			fclose(FILE);
		}
	}

	fopen(FILE, ">$memberdir/$username.ims");
	print FILE qq~\$messages = $messages\;\n\$newmessages = $newmessages\;\n\$outmessages = $outmessages\;\n\$storedmessages = $storedmessages\;\n\n1\;~;
	fclose(FILE);

	&template;
	exit;
}

sub IMIndex {
	if ($iamguest) { &fatal_error($inmes_txt{147}); }
	if ($action eq "im") {
		$yymain .= qq~ <table cellspacing="1" cellpadding="4" width="100%" border="0" class="bordercolor"> 
        <tr> 
          <td class="titlebg" valign="bottom" align="center" width="16%"><span class="small"><b><a href="$scripturl?action=im">$inmes_txt{316}</a></b></span></td> 
          <td class="catbg" valign="bottom" align="center" width="16%"><span class="small"><b><a href="$scripturl?action=imoutbox">$inmes_txt{320}</a></b></span></td> 
          <td class="catbg" valign="bottom" align="center" width="16%"><span class="small"><b><a href="$scripturl?action=imstorage">$inmes_imtxt{46}</a></b></span></td> 
          <td class="catbg" valign="bottom" align="center" width="16%"><span class="small"><b><a href="$scripturl?action=imsend">$inmes_txt{148}</a></b></span></td> 
          <td class="catbg" valign="bottom" align="center" width="16%"><span class="small"><b><a href="$scripturl?action=markims">$inmes_txt{764}</a></b></span></td> 
          <td class="catbg" valign="bottom" align="center" width="16%"><span class="small"><b><a href="$scripturl?action=profileCheck;username=$username">$inmes_txt{765}</a></b></span></td>
        </tr> 
      </table><br />~;
		$PMTitleLogo = "<img src=\"$imagesdir/im_inbox.gif\" alt=\"$img_txt{'316'}\" border=\"0\" /> <b>$inmes_txt{316}</b>";
		$status      = "$inmes_imtxt{'23'}";
		$senderinfo  = "$inmes_txt{'318'}";
		$callerid    = "1";
		$boxtxt      = "$inmes_txt{'316'}";
		$movebutton  = qq~<td class="titlebg"  align="center"><input type="submit" name="imaction" value="$inmes_imtxt{'50'}" /></td>~;
		fopen(FILE, "$memberdir/$username.msg");
	}

	elsif ($action eq "imoutbox") {
		$yymain .= qq~ <table cellspacing="1" cellpadding="4" width="100%" border="0" class="bordercolor"> 
        <tr> 
          <td class="catbg" valign="bottom" align="center" width="20%"><span class="small"><b><a href="$scripturl?action=im">$inmes_txt{316}</a></b></span></td> 
          <td class="titlebg" valign="bottom" align="center" width="20%"><span class="small"><b><a href="$scripturl?action=imoutbox">$inmes_txt{320}</a></b></span></td> 
          <td class="catbg" valign="bottom" align="center" width="20%"><span class="small"><b><a href="$scripturl?action=imstorage">$inmes_imtxt{46}</a></b></span></td> 
          <td class="catbg" valign="bottom" align="center" width="20%"><span class="small"><b><a href="$scripturl?action=imsend">$inmes_txt{148}</a></b></span></td> 
          <td class="catbg" valign="bottom" align="center" width="20%"><span class="small"><b><a href="$scripturl?action=profileCheck;username=$username">$inmes_txt{765}</a></b></span></td>
        </tr> 
      </table><br />~;
		$PMTitleLogo = "<img src=\"$imagesdir/im_outbox.gif\" alt=\"$img_txt{'316'}\" border=\"0\" /> <b>$inmes_txt{320}</b>";
		$status      = "$inmes_imtxt{'23'}";
		$senderinfo  = "$inmes_txt{'324'}";
		$callerid    = "2";
		$boxtxt      = "$inmes_txt{'320'}";
		$movebutton  = qq~<td class="titlebg"  align="center"><input type="submit" name="imaction" value="$inmes_imtxt{'50'}" /></td>~;
		fopen(FILE, "$memberdir/$username.outbox");
	}

	elsif ($action eq "imstorage") {
		$yymain .= qq~ <table cellspacing="1" cellpadding="4" width="100%" border="0" class="bordercolor"> 
        <tr> 
          <td class="catbg" valign="bottom" align="center" width="20%"><span class="small"><b><a href="$scripturl?action=im">$inmes_txt{316}</a></b></span></td> 
          <td class="catbg" valign="bottom" align="center" width="20%"><span class="small"><b><a href="$scripturl?action=imoutbox">$inmes_txt{320}</a></b></span></td> 
          <td class="titlebg" valign="bottom" align="center" width="20%"><span class="small"><b><a href="$scripturl?action=imstorage">$inmes_imtxt{46}</a></b></span></td> 
          <td class="catbg" valign="bottom" align="center" width="20%"><span class="small"><b><a href="$scripturl?action=imsend">$inmes_txt{148}</a></b></span></td> 
          <td class="catbg" valign="bottom" align="center" width="20%"><span class="small"><b><a href="$scripturl?action=profileCheck;username=$username">$inmes_txt{765}</a></b></span></td>
        </tr> 
      </table><br />~;
		$PMTitleLogo = "<img src=\"$imagesdir/imstore.gif\" alt=\"$img_txt{'316'}\" border=\"0\" /> <b>$inmes_imtxt{46}</b>";
		$status      = "";
		$senderinfo  = "$inmes_txt{'318'} / $inmes_txt{'324'}";
		$callerid    = "3";
		$boxtxt      = "$inmes_imtxt{'46'}";
		$movebutton  = qq~<td class="titlebg"  align="center">&nbsp;</td>~;
		fopen(FILE, "$memberdir/$username.imstore");
	}

	@dimmessages = <FILE>;
	fclose(FILE);
	$mnum = @dimmessages;

	if (!@dimmessages && $action eq "im")        { unlink(FILE, "$memberdir/$username.msg"); }
	if (!@dimmessages && $action eq "imoutbox")  { unlink(FILE, "$memberdir/$username.outbox"); }
	if (!@dimmessages && $action eq "imstorage") { unlink(FILE, "$memberdir/$username.imstore"); }

	&LoadCensorList;

	# Fix moderator showing in info
	$sender = "im";
	$acount = 0;
	$yymain .= qq~$immenubar~;
	$yytitle = $inmes_txt{'143'};
	$yymain .= qq~
<script language="JavaScript1.2" type="text/javascript">
<!-- Begin
function changeBox(cbox) {
  box = eval(cbox);
  box.checked = !box.checked;
}
function checkAll() {
  for (var i = 0; i < document.searchform.elements.length; i++) {
    		document.searchform.elements[i].checked = true;
  }
}
function uncheckAll() {
  for (var i = 0; i < document.searchform.elements.length; i++) {
    		document.searchform.elements[i].checked = false;
  }
}
//-->
</script>
<script language="JavaScript1.2" src="$ubbcjspath" type="text/javascript"></script>
<form action="$scripturl?action=deletemultimessages;caller=$callerid" method="post" name="searchform">
<br />
<table border="0" width="100%" cellspacing="1" cellpadding="3" class="bordercolor">
  <tr>
	<td class="catbg" colspan="6">
	$PMTitleLogo
	</td>
  </tr>
  <tr>
    <td class="titlebg"  width="03%" align="center" height="21">&nbsp;<b>#</b></td>
    <td class="titlebg"  width="25%">&nbsp;<b>$inmes_txt{'317'}</b></td>
    <td class="titlebg"  width="15%"><b>$senderinfo</b></td>
    <td class="titlebg"  width="35%"><b>$inmes_txt{'70'}</b></td>
    <td class="titlebg"  width="07%" align="center"><b>$status</b></td>
    <td class="titlebg"  width="05%">&nbsp;</td>
  </tr>
~;
	unless (@dimmessages) {
		$yymain .= qq~
  <tr>
    <td class="windowbg" colspan="6" height="21">$inmes_txt{'151'}</td>
  </tr>
~;
	}
	$acount++;
	@bgcolors   = ($color{windowbg}, $color{windowbg2});
	@bgstyles   = qw~windowbg windowbg2~;
	$bgcolornum = scalar @bgcolors;
	$bgstylenum = scalar @bgstyles;

  boardcheck: for ($counter = 0; $counter < @dimmessages; $counter++) {
		$windowbg = $bgcolors[($counter % $bgcolornum)];
		chomp $dimmessages[$counter];
		($musername, $msub, $mdate, $immessage, $messageid, $mips, $imnew, $imwhere) = split(/\|/, $dimmessages[$counter]);
		if ($imwhere eq "inbox")  { $senderinfo2 = qq~<b>$inmes_txt{'318'}:</b>&nbsp;~; }
		if ($imwhere eq "outbox") { $senderinfo2 = qq~<b>$inmes_txt{'324'}:</b>&nbsp;~; }

		if ($musername ne 'Guest' && -e ("$memberdir/$musername.vars")) {
			&LoadUserDisplay($musername);
		}
		$rname = $musername;
		if ($yyUDLoaded{$musername}) { $musername = qq~<a href="$scripturl?action=viewprofile;username=$musername">${$uid.$musername}{'realname'}</a>~; }

		if ($messageid < 100) { $messageid = $counter; }
		$msub = &Censor($msub);
		&ToChars($msub);
		$mydate = &timeformat($mdate);
		$innum  = $mnum--;
		$yymain .= qq~
  <tr>
    <td class="windowbg" align="center" height="21">$innum</td>
    <td class="windowbg">$mydate</td>
    <td class="windowbg">$senderinfo2$musername</td>
    <td class="windowbg"><a href="$scripturl?action=imshow;caller=$callerid;id=$messageid">$msub</a></td>
    <td class="windowbg" align="center">
~;
		if ($action ne "imstorage") {
			if    ($imnew == 1 && $action eq "im") { $yymain .= qq~<a href="$scripturl?action=imshow;caller=$callerid;id=$messageid"><img src="$imagesdir/imclose.gif" border="0" alt="$inmes_imtxt{'07'}" /></a>~; }
			elsif ($imnew == 2 && $action eq "im") { $yymain .= qq~<a href="$scripturl?action=imshow;caller=$callerid;id=$messageid"><img src="$imagesdir/answered.gif" border="0" alt="$inmes_imtxt{'08'}" /></a>~; }
			elsif ($imnew eq "" && $action eq "im") { $yymain .= qq~<a href="$scripturl?action=imshow;caller=$callerid;id=$messageid"><img src="$imagesdir/imopen.gif" border="0" alt="$inmes_imtxt{'09'}" /></a>~; }
			elsif ($imnew == 1 && $action eq "imoutbox") { $yymain .= qq~<a href="$scripturl?action=imshow;caller=$callerid;id=$messageid"><img src="$imagesdir/imopen.gif" border="0" alt="$inmes_imtxt{'21'}" /></a>~; }
			elsif ($imnew eq "" && $action eq "imoutbox") { $yymain .= qq~<img src="$imagesdir/imclose.gif" border="0" alt="$inmes_imtxt{'22'}" /><br /><span class="small"><a href="$scripturl?action=imcb;rid=$messageid;receiver=$rname" onclick="return confirm('$inmes_imtxt{'73'}')">$inmes_imtxt{'83'}</a></span>~; }
		}
		undef $quotecount;
		undef $codecount;
		$quoteimg = "";
		$codeimg  = "";

		if ($immessage =~ /\[quote(.*?)\]/isg) {
			$quoteimg = qq~<img src=$imagesdir\/quote.gif alt="$inmes_imtxt{'69'}" \/>&nbsp;~;
			$immessage =~ s/\[quote(.*?)\](.+?)\[\/quote\]//ig;
		}
		if ($immessage =~ /\[code\]/isg) {
			$codeimg = qq~<img src=$imagesdir\/code1.gif alt="$inmes_imtxt{'84'}" \/>&nbsp;~;
			$immessage =~ s/\[code\](.+?)\[\/code\]//ig;
		}
		$immessage =~ s~<br />~&nbsp;~g;
		$immessage =~ s~&nbsp;&nbsp;~ ~g;
		&ToChars($immessage);
		$immessage =~ s~\[.*?\]~~g;
		&FromChars($immessage);
		$convertstr = $immessage;
		$convertcut = 100;
		&CountChars;
		my $immessage = $convertstr;
		&ToChars($immessage);
		if ($cliped) { $immessage .= "..."; }
		$immessage = qq~$quoteimg$codeimg $immessage~;

		$immessage = &Censor($immessage);

		if ($MenuType != 1) { $sepa = '&nbsp;|&nbsp;'; }
		else { $sepa = $menusep; }
		if ($action eq "im") { $quotemenu = qq~<a href="$scripturl?action=imsend;caller=$callerid;num=$counter;quote=1;to=$rname;id=$messageid">$inmes_txt{'145'}</a>$sepa<a href="$scripturl?action=imsend;caller=$callerid;num=$counter;reply=1;to=$rname;id=$messageid">$inmes_txt{'146'}</a>$sepa<a href="$scripturl?action=imremove;caller=$callerid;id=$messageid" onclick="return confirm('$inmes_txt{'739'}')">$inmes_txt{'31'}</a>~; }
		else { $quotemenu = qq~<a href="$scripturl?action=imremove;caller=$callerid;id=$messageid" onclick="return confirm('$inmes_txt{'739'}')">$inmes_txt{'31'}</a>~; }

		$yymain .= qq~
     </td>
    <td class="windowbg" align="center" rowspan="2"><input type="checkbox" name="message$counter" class="windowbg" value="1" style="cursor:hand;" /></td>
  </tr>
  <tr><td colspan="5" height="21" class="windowbg2">$immessage<br /><br />
<hr width="100%" size="1" class="hr" />
<span class="small"><b>$quotemenu</b></span></td></tr>
~;
		$acount++;
	}

	if ($enable_imlimit == 1) {
		$impercent = 0;
		$imbar     = 0;
		$imrest    = 0;

		if ($action eq "im") {
			if ($counter ne 0) {
				$impercent = int(100 / $numibox * $counter);
				$imbar     = int(200 / $numibox * $counter);
			}
			$intext = qq~($inmes_imtxt{'13'} $counter $inmes_imtxt{'01'} $numibox $inmes_imtxt{'19'})~;
		}

		elsif ($action eq "imoutbox") {
			if ($counter ne 0) {
				$impercent = int(100 / $numobox * $counter);
				$imbar     = int(200 / $numobox * $counter);
			}
			$intext = qq~($inmes_imtxt{'13'} $counter $inmes_imtxt{'01'} $numobox $inmes_imtxt{'20'})~;
		}

		elsif ($action eq "imstorage") {
			if ($counter ne 0) {
				$impercent = int(100 / $numstore * $counter);
				$imbar     = int(200 / $numstore * $counter);
			}
			$intext = qq~($inmes_imtxt{'13'} $counter $inmes_imtxt{'01'} $numstore $inmes_imtxt{'45'})~;
		}
		$imrest = 200 - $imbar;
		if ($imbar > 200) { $imbar  = 200; }
		if ($imrest <= 0) { $dorest = ""; }
		else { $dorest = qq~<img src="$imagesdir/usageempty.gif" height="8" width="$imrest" align="middle">~; }
		$imbargfx = qq~$inmes_imtxt{'67'}:&nbsp;<img src="$imagesdir/usage.gif" align="middle"><img src="$imagesdir/usagebar.gif" height="8" width="$imbar" align="middle">$dorest<img src="$imagesdir/usage.gif" align="middle">&nbsp;$impercent&nbsp;%&nbsp;~;
	} else {
		$intext   = qq~&nbsp;~;
		$imbargfx = qq~&nbsp;~;
	}

	if (@dimmessages != 0) {
		$yymain .= qq~<tr><td class="titlebg"  colspan="4" align="left" height="21"><span  class="small"><b>$imbargfx&nbsp;$intext</b></span></td>$movebutton
					  <td class="titlebg"  align="center"><input type="submit" name="imaction" value="$inmes_imtxt{'10'}" /></td></tr>~;
	}
	$yymain .= qq~
</table>~;
	if (@dimmessages > 1) { $yymain .= qq~<table align="right"><tr><td><i>$inmes_txt{'737'}</i>&nbsp;<input type="checkbox" onclick="if (this.checked) checkAll(); else uncheckAll();" /></td></tr></table><br /><br />~; }
	&jumpto;
	$yymain .= qq~</form>
<table width="100%">
	<tr>
		<td align="right">$selecthtml
		</td>
	</tr>
</table>~;
	&template;
	exit;
}

sub IMPost {
	if (${$uid.$username}{'postcount'} < $numposts && !$staff) {
		&fatal_error($inmes_imtxt{'74'});
	}

	if ($iamguest) { &fatal_error($inmes_txt{'147'}); }
	my ($mdate, $mip, $mmessage);
	if ($INFO{'num'} ne "") {
		if    ($INFO{'caller'} == 1) { fopen(FILE, "$memberdir/$username.msg"); }
		elsif ($INFO{'caller'} == 2) { fopen(FILE, "$memberdir/$username.outbox"); }
		elsif ($INFO{'caller'} == 3) { fopen(FILE, "$memberdir/$username.imstore"); }
		@messages = <FILE>;
		fclose(FILE);

		($mfrom, $sub, $mdate, $mmessage, $mnum, $mip, $imwhere) = split(/\|/, $messages[$INFO{'num'}]);
		$sub =~ s/Re: //g;

		if ($INFO{'quote'} == 1) {
			$message = $mmessage;
			$message =~ s~<br />~\n~g;
			$message =~ s~<br>~\n~ig;
			$message =~ s/ \&nbsp; \&nbsp; \&nbsp;/\t/ig;

			if (!$nestedquotes) {
				$message =~ s~\n{0,1}\[quote([^\]]*)\](.*?)\[/quote\]\n{0,1}~\n~isg;
				$message =~ s~\n*\[/*quote([^\]]*)\]\n*~~ig;
			}

			$mname ||= $musername || $inmes_txt{'470'};
			$quotestart = int($quotemsg / $maxmessagedisplay) * $maxmessagedisplay;
			$message    = qq~[quote author=$mfrom link=action=imshow;caller=$INFO{'caller'};id=$mnum date=$mdate\]$message\[/quote\]\n~;
			$msubject =~ s/\bre:\s+//ig;
			if ($message =~ /\#nosmileys/isg) { $message =~ s/\#nosmileys//isg; $nscheck = "checked"; }
			$sub = "Re: $sub";
		}
		if ($INFO{'reply'} == 1) { $sub = "Re: $sub"; }
	}

	$yymain .= qq~
	<table cellspacing="1" cellpadding="4" width="100%" border="0" class="bordercolor"> 
        <tr> 
          <td class="catbg" valign="bottom" align="center" width="20%"><span class="small"><b><a href="$scripturl?action=im">$inmes_txt{316}</a></b></span></td> 
          <td class="catbg" valign="bottom" align="center" width="20%"><span class="small"><b><a href="$scripturl?action=imoutbox">$inmes_txt{320}</a></b></span></td> 
          <td class="catbg" valign="bottom" align="center" width="20%"><span class="small"><b><a href="$scripturl?action=imstorage">$inmes_imtxt{46}</a></b></span></td> 
          <td class="titlebg" valign="bottom" align="center" width="20%"><span class="small"><b><a href="$scripturl?action=imsend">$inmes_txt{148}</a></b></span></td> 
          <td class="catbg" valign="bottom" align="center" width="20%"><span class="small"><b><a href="$scripturl?action=profileCheck;username=$username">$inmes_txt{765}</a></b></span></td>
        </tr> 
      </table><br />
~;
	$submittxt   = "$inmes_txt{'148'}";
	$destination = "imsend2";
	$waction     = "imsend";
	$is_preview  = 0;
	$post        = "imsend";
	$preview     = "previewim";
	$icon        = "xx";
	require "$sourcedir/Post.pl";
	$yytitle = $inmes_txt{'148'};
	&Postpage;
	&doshowims;
	&template;
	exit;
}

sub doshowims {
	my $tempdate;
	if ($INFO{'num'} ne "") {
		chomp $messages[$INFO{'num'}];
		($musername, $msub, $mdate, $message, $messageid, $mips, $imnew, $imwhere) = split(/\|/, $messages[$INFO{'num'}]);
		&LoadCensorList;
		&ToChars($msub);
		$yymain .= qq~
	<table cellspacing="1" cellpadding=0 width="90%" align="center" class="bordercolor"><tr><td>
	<table class="windowbg" cellspacing="0" cellpadding=2 width="100%" align=center>
	<tr><td class="titlebg"  colspan=2><b>$inmes_txt{'70'}: $msub</b></td></tr>
	~;
		$tempdate = &timeformat($mdate);
		$message  = &Censor($message);
		&wrap;

		if ($enable_ubbc) {
			if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; }
			&DoUBBC;
		}
		&wrap2;
		&ToChars($message);
		$yymain .= qq~
	<tr><td align="left" class="catbg"><span class="small">$inmes_txt{'318'}: $musername</span></td><td class="catbg" align="right"><span class="small">$inmes_txt{'30'}: $tempdate</span></td></tr>
	<tr><td class="windowbg2" colspan="2"><span class="small">$message</span></td></tr></table></td></tr></table>\n
	~;

	}
}

sub IMPost2 {
	if ($iamguest) { &fatal_error($inmes_txt{'147'}); }
	my (@ignore, $igname, $messageid, $subject, $message, @recipient, $ignored);

	$subject = $FORM{'subject'};
	$subject =~ s/\A\s+//;
	$subject =~ s/\s+\Z//;
	$tstsubject = $subject;
	if (!$subject) { $subject = "$inmes_txt{'767'}"; }
	$message = $FORM{'message'};

	# Check Message Length Precisely
	$mess_len = $message;
	$mess_len =~ s/[\r\ ]//g;
	if ($enable_maxlen == 0 || $enable_maxlen eq "") {
		if (length($mess_len) > $MaxMessLen) { &Preview($inmes_txt{'536'} . " " . (length($message) - $MaxMessLen) . " " . $inmes_txt{'537'}); }
	}

	$error = $inmes_txt{'752'} unless ($FORM{'to'});
	$error = $inmes_txt{'77'}  unless ($subject);
	$error = $inmes_txt{'78'}  unless ($message);

	if ($error) {
		require "$sourcedir/Post.pl";
		$FORM{'previewim'} = 1;
		&Preview($error);
	}

	&FromChars($message);

	$subject =~ s/&amp;/&/g;
	&FromChars($subject);
	$convertstr = $subject;
	$convertcut = 50;
	&CountChars;
	$subject = $convertstr;
	$subject =~ s/[\r\n]//g;

	$mmessage = $message;
	$msubject = $subject;

	&LoadCensorList;
	$mmessage = &Censor($mmessage);
	$msubject = &Censor($msubject);

	&ToHTML($message);
	$message =~ s/\t/ \&nbsp; \&nbsp; \&nbsp;/g;
	$message =~ s/\cM//g;
	$message =~ s/\n/<br \/>/g;

	if ($FORM{'ns'} eq "NS") { $message .= "#nosmileys"; }
	if ($FORM{'previewim'}) {
		require "$sourcedir/Post.pl";
		&Preview;
	}
	undef @multiple;
	fopen(MEMLIST, "$memberdir/memberlist.txt");
	@memlist = <MEMLIST>;
	$allmems = @memlist;
	fclose(MEMLIST);
	$FORM{'to'} =~ s/ //g;
	@multiple = split(/,/, $FORM{'to'});

	if ($imspam ne "off") {
		$memnums   = @multiple;
		$checkspam = 100 / $allmems * $memnums;
		if (@multiple == 1) { $checkspam = 0; }
		if ($checkspam > $imspam && !$iamadmin) { &fatal_error("$inmes_imtxt{'70'}"); }
	}
	$actlang = $language;
	foreach $db (@multiple) {
		$addnr++;
		chomp $db;
		$ignored = 0;

		$db =~ s/\A\s+//;
		$db =~ s/\s+\Z//;
		$db =~ s/[^0-9A-Za-z#%+,-\.@^_]//g;

		# Check Ignore-List
		&LoadUser($db);
		if (${$uid.$db}{'im_ignorelist'}) {

			# Build Ignore-List
			${$uid.$db}{'im_ignorelist'} =~ s/[\n\r]//g;
			${$uid.$db}{'im_notify'}     =~ s/[\n\r]//g;

			@ignore = split(/\|/, ${$uid.$db}{'im_ignorelist'});

			# If User is on Recipient's Ignore-List, show Error Message
			foreach $igname (@ignore) {

				# adds ignored user's name to array which error list will be built from later
				chomp $igname;
				if ($igname eq $username) { push(@nouser, $db); $ignored = 1; }
				if ($igname eq "*") { push(@nouser, "$inmes_txt{'761'} $db $inmes_txt{'762'};"); $ignored = 1; }
			}
		}
		if (!(-e ("$memberdir/$db.vars"))) { &fatal_error("$inmes_txt{'766'}"); }
		if (!(-e ("$memberdir/$db.vars"))) {

			# adds invalid user's name to array which error list will be built from later
			push(@nouser, $db);
			$ignored = 1;
		}

		if (!$ignored) {

			# Create unique Message ID
			$messageid = &getnewid;
			for ($i = 0; $i < $addnr; $i++) { $messageid++; }

			# Add message to outbox
			@outmessages = ();
			if (-e ("$memberdir/$username.outbox")) {
				fopen(OUTBOX, "$memberdir/$username.outbox");
				@outmessages = <OUTBOX>;
				fclose(OUTBOX);
			}
			fopen(OUTBOX, ">$memberdir/$username.outbox");
			print OUTBOX "$db|$subject|$date|$message|$messageid|$ENV{'REMOTE_ADDR'}\n";
			print OUTBOX @outmessages;
			fclose(OUTBOX);

			fopen(IMS, ">$memberdir/$username.ims");
			$outmessages = $outmessages + 1;
			print IMS "\$messages = $messages\;\n\$newmessages = $newmessages\;\n\$outmessages = $outmessages\;\n\$storedmessages = $storedmessages\;\n\n1\;";
			fclose(IMS);

			# Send message to user
			fopen(INBOX, "$memberdir/$db.msg");
			@inmessages = <INBOX>;
			fclose(INBOX);
			fopen(INBOX, ">$memberdir/$db.msg");
			print INBOX "$username|$subject|$date|$message|$messageid|$ENV{'REMOTE_ADDR'}|1\n";
			print INBOX @inmessages;
			fclose(INBOX);

			fopen(IMS, ">$memberdir/$db.ims");
			$messages    = $messages + 1;
			$newmessages = $newmessages + 1;
			print IMS "\$messages = $messages\;\n\$newmessages = $newmessages\;\n\$outmessages = $outmessages\;\n\$storedmessages = $storedmessages\;\n\n1\;";
			fclose(IMS);

			fopen(INBOX, "+<$memberdir/$username.msg");
			seek INBOX, 0, 0;
			@messages = <INBOX>;
			seek INBOX, 0, 0;
			truncate INBOX, 0;

			$id = "$INFO{'id'}";
			for ($a = 0; $a < @messages; $a++) {
				chomp $messages[$a];
				($imboxusername, $imboxsub, $imboxdate, $imboxmessage, $imboxmessageid, $imboxmip, $imboximnew) = split(/\|/, $messages[$a]);
				if ($imboxmessageid != $FORM{'info'}) { print INBOX "$messages[$a]\n"; }
				else { print INBOX "$imboxusername|$imboxsub|$imboxdate|$imboxmessage|$imboxmessageid|$imboxmip|2\n"; }
			}
			fclose(INBOX);

			# Send notification (Will only work if Admin has allowed the Email Notification)
			if (${$uid.$db}{'im_notify'} == 1 && $enable_notification == 1) {
### FIXME: to avoid vulnerability, user can get notifications in foreign language.
#				if (${$uid.$db}{'language'} ne $actlang) {
#					undef %inmes_txt;
#					$actlang = ${$uid.$db}{'language'};
#					if (-e "$langdir/$actlang/InstantMessage.lng") { require "$langdir/$actlang/InstantMessage.lng"; }
#					else { require "$langdir/$lang/InstantMessage.lng"; }
#					if (-e "$langdir/$actlang/InstantMessage.lng") { require "$langdir/$actlang/Main.lng"; }
#					else { require "$langdir/$lang/Main.lng"; }
#				}
				$mydate = &timeformat($date);
				${$uid.$db}{'email'} =~ s/[\n\r]//g;    # get email address
				if (${$uid.$db}{'email'} ne "") {
					if (!$tstsubject) { $msubject = "$inmes_txt{'767'}"; }
					$fromname = ${$uid.$username}{'realname'};
					&ToChars($msubject);

					$chmessage = $mmessage;
					&ToChars($chmessage);
					$chmessage =~ s~\[b\](.*?)\[/b\]~*$1*~isg;
					$chmessage =~ s~\[i\](.*?)\[/i\]~/$1/~isg;
					$chmessage =~ s~\[u\](.*?)\[/u\]~_$1_~isg;
					$chmessage =~ s~\[.*?\]~~g;

					$inmes_txt{'561'} =~ s~SUBJECT~$msubject~g;
					$inmes_txt{'561'} =~ s~SENDER~$fromname~g;
					$inmes_txt{'561'} =~ s~DATE~$mydate~g;
					$inmes_txt{'562'} =~ s~SUBJECT~$msubject~g;
					$inmes_txt{'562'} =~ s~MESSAGE~$chmessage~g;
					$inmes_txt{'562'} =~ s~SENDER~$fromname~g;
					$inmes_txt{'562'} =~ s~DATE~$mydate~g;
					&sendmail(${$uid.$db}{'email'}, $inmes_txt{'561'}, $inmes_txt{'562'});
				}
			}
		}
	}    #end foreach loop

	#if there were invalid usernames in the recipient list, these names are listed after all valid users have been IMed
	if (@nouser) {
		$badusers = join(" $inmes_txt{'763'} ", @nouser);
		$badusers =~ s/; $inmes_txt{'763'}/;/;
		&fatal_error("$badusers $inmes_txt{'747'}");
	}

	&UserAccount($username, "update", "lastim");
	&UserAccount($username, "update", "lastonline");
	$yySetLocation = qq~$scripturl?action=im~;
	&redirectexit;
}

sub IMRemove {
	if ($iamguest) { &fatal_error($inmes_txt{'147'}); }

	my (@messages, $a, $musername, $msub, $mdate, $mmessage, $messageid, $mip);
	if    ($INFO{'caller'} == 1) { fopen(FILE, "+<$memberdir/$username.msg"); }
	elsif ($INFO{'caller'} == 2) { fopen(FILE, "+<$memberdir/$username.outbox"); }
	elsif ($INFO{'caller'} == 3) { fopen(FILE, "+<$memberdir/$username.imstore"); }
	seek FILE, 0, 0;
	@messages = <FILE>;
	seek FILE, 0, 0;
	truncate FILE, 0;
	for ($a = 0; $a < @messages; $a++) {
		chomp $messages[$a];

		# ONLY delete MSG with correct ID
		($musername, $msub, $mdate, $mmessage, $messageid, $mip) = split(/\|/, $messages[$a]);

		# If Message-ID is < 100, user has used the old IM before
		if ($messageid < 100) {
			if ($a ne $INFO{'id'}) { print FILE "$messages[$a]\n"; }
		} else {
			if ($messageid ne "$INFO{'id'}") { print FILE "$messages[$a]\n"; }
		}
	}

	fclose(FILE);
	if    ($INFO{'caller'} == 1) { $redirect = "im"; }
	elsif ($INFO{'caller'} == 2) { $redirect = "imoutbox"; }
	elsif ($INFO{'caller'} == 3) { $redirect = "imstorage"; }
	$yySetLocation = qq~$scripturl?action=$redirect~;
	&redirectexit;

}

sub MarkAll {
	fopen(FILE, "+<$memberdir/$username.msg");
	seek FILE, 0, 0;
	@messages = <FILE>;
	seek FILE, 0, 0;
	truncate FILE, 0;
	for ($a = 0; $a < @messages; $a++) {
		chomp $messages[$a];
		($imusername, $imsub, $imdate, $mmessage, $imessageid, $mip, $imnew) = split(/\|/, $messages[$a]);
		if ($imnew != 2) { print FILE "$imusername|$imsub|$imdate|$mmessage|$imessageid|$mip\n"; }
		else { print FILE "$messages[$a]\n"; }
	}
	fclose(FILE);
	$yySetLocation = qq~$scripturl?action=im~;
	&redirectexit;
}
1;
