###############################################################################
# AdminEdit.pl                                                                #
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

$admineditplver = 'YaBB 2.1 $Revision: 1.13 $';
if ($action eq 'detailedversion') { return 1; }

use File::Find;
LoadLanguage("flood");
LoadLanguage("Register");

sub GmodSettings {
	&is_admin;

	if (!-e ("$vardir/gmodsettings.txt")) {
		&GmodSettings2;
	}

	fopen(MODACCESS, "$vardir/gmodsettings.txt");
	@scriptlines = <MODACCESS>;
	fclose(MODACCESS);

	$startread = 0;
	$counter   = 0;
	foreach $scriptline (@scriptlines) {
		chomp $scriptline;
		if (substr($scriptline, 0, 1) eq "'") {
			$scriptline =~ /\"(.*?)\"/;
			$allow = $1;
			$scriptline =~ /\'(.*?)\'/;
			$actionfound = $1;
			push(@actfound, $actionfound);
			push(@allowed,  $allow);
			$counter++;
		}
	}
	$column  = int($counter / 2);
	$counter = 0;
	$a       = 0;
	foreach $actfound (@actfound) {
		$selected = "";
		if ($allowed[$a] eq "on") {
			$selected = "checked";
		}
		$dismenu .= qq~<input type="checkbox" name="$actfound" $selected /><img src="$imagesdir/question.gif" align="middle" alt="$reftxt{'1a'} $refexpl_txt{$actfound}" title="$reftxt{'1a'} $refexpl_txt{$actfound}" border="0" /> $actfound<br />\n~;
		$counter++;
		$a++;
		if ($counter > $column + 1) {
			$dismenu .= qq~</td><td align="left" class="windowbg2" valign="top" width="50%">~;
			$counter = 0;
		}
	}
	$dismenu .= qq~</td>~;

	require "$vardir/gmodsettings.txt";

	if ($allow_gmod_admin) {
		$gmod_selected_a = "checked";
	}
	if ($allow_gmod_profile) {
		$gmod_selected_p = "checked";
	}

	$yymain .= qq~
<form action="$adminurl?action=gmodsettings2" method="POST">
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg" colspan="2">
<img src="$imagesdir/preferences.gif" alt="" border="0" /><b>$gmod_settings{'1'}</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2" colspan="2"><br />
<input type="checkbox" name="allow_gmod_admin" $gmod_selected_a /> $gmod_settings{'2'}<br />
<input type="checkbox" name="allow_gmod_profile" $gmod_selected_p /> $gmod_settings{'3'}
		 <br /><br />
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="catbg" colspan="2">
		<span class="small">$gmod_settings{'4'}</span>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2" valign="top" width="50%">
		$dismenu
	   </td>
     </tr>
     <tr valign="middle">
       <td align="center" class="catbg" colspan="2">
		<input type="submit" value="$reftxt{'4'}" />
	   </td>
     </tr>
   </table>
 </div>
</form>
~;
	$yytitle     = "$reftxt{'1'}";
	$action_area = "gmodaccess";
	&AdminTemplate;
	exit;
}

sub EditNews {
	&is_admin_or_gmod;
	my ($line);
	$yymain .= qq~
<form action="$adminurl?action=editnews2" method="post">
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg">
<img src="$imagesdir/xx.gif" alt="" border="0" /><b>$admin_txt{'7'}</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
	<span class="small">
	$admin_txt{'670'}
	</span><br /><br />
	   </td>
     </tr>
     <tr valign="middle">
       <td align="center" class="windowbg2"><br />
	<textarea type="text" cols="70" rows="8" name="news" style="width:98%">
~;
	fopen(NEWS, "$vardir/news.txt");
	while ($line = <NEWS>) { chomp $line; $yymain .= qq~$line\n~; }
	fclose(NEWS);
	$yymain .= qq~</textarea>
	<br /><br />
	   </td>
     </tr>
     <tr valign="middle">
       <td align="center" class="catbg">
		 <input type="submit" value="$admin_txt{'10'}" />
	   </td>
     </tr>
   </table>
 </div>
</form>
~;
	$yytitle     = "$admin_txt{'7'}";
	$action_area = "editnews";
	&AdminTemplate;
	exit;
}

sub EditNews2 {
	&is_admin_or_gmod;
	$FORM{'news'} =~ tr/\r//d;
	fopen(NEWS, ">$vardir/news.txt", 1);
	chomp $FORM{'news'};
	print NEWS "$FORM{'news'}";
	fclose(NEWS);
	$yySetLocation = qq~$adminurl~;
	&redirectexit;
}

sub SetCensor {
	&is_admin_or_gmod;
	my ($censorlanguage, $line);
	if ($FORM{'censorlanguage'}) { $censorlanguage = $FORM{'censorlanguage'} }
	else { $censorlanguage = $lang; }
	opendir(LNGDIR, $langdir);
	my @lfilesanddirs = readdir(LNGDIR);
	close(LNGDIR);
	foreach $fld (@lfilesanddirs) {

		if (-d "$langdir/$fld" && $fld =~ m^\A[0-9a-zA-Z_\#\%\-\:\+\?\$\&\~\,\@/]+\Z^ && -e "$langdir/$fld/Main.lng") {
			if ($censorlanguage eq $fld) { $drawnldirs .= qq~<option value="$fld" selected="selected">$fld</option>~; }
			else { $drawnldirs .= qq~<option value="$fld">$fld</option>~; }
		}
	}
	my (@censored, $i);
	fopen(CENSOR, "$langdir/$censorlanguage/censor.txt");
	@censored = <CENSOR>;
	fclose(CENSOR);
	foreach $i (@censored) {
		$i =~ tr/\r//d;
		$i =~ tr/\n//d;
	}
	$yymain .= qq~
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg">
		 <img src="$imagesdir/ban.gif" alt="" border="0" /><span class="legend"><b>$admin_txt{'135'}</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
		 $admin_txt{'136'}<br /><br />
	   </td>
     </tr>
     <tr align="center" valign="middle">
       <td align="left" class="windowbg2"><br />
	<form action="$adminurl?action=setcensor" method="post">
	$templs{'7'}
	<select name="censorlanguage" id="censorlanguage" size="1">
		$drawnldirs
	</select>
	<input type="submit" value="$admin_txt{'462'}" / >
	</form>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="center" class="windowbg2"><br />
	<span class="small" align="center">
	<form action="$adminurl?action=setcensor2" method="post">
	<input type="hidden" name="censorlanguage" value="$censorlanguage" />
	<textarea rows="15" cols="15" name="censored" style="width:90%">~;
	foreach $i (@censored) {
		unless ($i && $i =~ m/.+[\=~].+/) { next; }
		$yymain .= "$i\n";
	}
	$yymain .= qq~</textarea>
	<br /><br />
	   </td>
     </tr>
     <tr valign="middle">
       <td align="center" class="catbg">
<input type="submit" value="$admin_txt{'10'} $censorlanguage" />
		</form>
	   </td>
     </tr>
   </table>
 </div>
~;
	$yytitle     = "$admin_txt{'135'}";
	$action_area = "setcensor";
	&AdminTemplate;
	exit;
}

sub SetCensor2 {
	&is_admin_or_gmod;
	$FORM{'censored'} =~ tr/\r//d;
	$FORM{'censored'} =~ s~\A[\s\n]+~~;
	$FORM{'censored'} =~ s~[\s\n]+\Z~~;
	$FORM{'censored'} =~ s~\n\s*\n~\n~g;
	if ($FORM{'censorlanguage'}) { $censorlanguage = $FORM{'censorlanguage'}; }
	else { $censorlanguage = $lang; }
	my @lines = split(/\n/, $FORM{'censored'});
	fopen(CENSOR, ">$langdir/$censorlanguage/censor.txt", 1);

	foreach my $i (@lines) {
		$i =~ tr/\n//d;
		unless ($i && $i =~ m/.+[\=~].+/) { next; }
		print CENSOR "$i\n";
	}
	fclose(CENSOR);
	$yySetLocation = qq~$adminurl~;
	&redirectexit;
}

sub SetReserve {
	my (@reserved, @reservecfg, $i);
	&is_admin_or_gmod;
	fopen(RESERVE, "$vardir/reserve.txt");
	@reserved = <RESERVE>;
	fclose(RESERVE);
	fopen(RESERVECFG, "$vardir/reservecfg.txt");
	@reservecfg = <RESERVECFG>;
	fclose(RESERVECFG);
	for (my $i = 0; $i < @reservecfg; $i++) { chomp $reservecfg[$i]; }

	$yymain .= qq~
<form action="$adminurl?action=setreserve2" method="post">
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg">
<img src="$imagesdir/profile.gif" alt="" border="0" /><b>$admin_txt{'341'}</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
		 $admin_txt{'699'}<br /><br />
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
		 $admin_txt{'342'}<br /><br />
		 	<center>
	<textarea cols="40" rows="10" name="reserved" style="width:95%">
~;
	foreach $i (@reserved) {
		chomp $i;
		$i =~ s~\t~~g;
		if ($i !~ m~\A[\S|\s]*[\n\r]*\Z~) { next; }
		$yymain .= "$i\n";
	}
	$yymain .= qq~</textarea>
	</center>
<br /><br />
	<input type="checkbox" name="matchword" value="checked" $reservecfg[0] />
	$admin_txt{'726'}<br />
	<input type="checkbox" name="matchcase" value="checked" $reservecfg[1] />
	$admin_txt{'727'}<br />
	<input type="checkbox" name="matchuser" value="checked" $reservecfg[2] />
	$admin_txt{'728'}<br />
	<input type="checkbox" name="matchname" value="checked" $reservecfg[3] />
	$admin_txt{'729'}<br />
	   </td>
     </tr>
     <tr valign="middle">
       <td align="center" class="catbg">
		 <input type="submit" value="$admin_txt{'10'}" />
	   </td>
     </tr>
   </table>
 </div>
</form>
~;
	$yytitle     = "$admin_txt{'341'}";
	$action_area = "setreserve";
	&AdminTemplate;
	exit;
}

sub SetReserve2 {
	&is_admin_or_gmod;
	$FORM{'reserved'} =~ tr/\r//d;
	$FORM{'reserved'} =~ s~\A[\s\n]+~~;
	$FORM{'reserved'} =~ s~[\s\n]+\Z~~;
	$FORM{'reserved'} =~ s~\n\s*\n~\n~g;
	fopen(RESERVE, ">$vardir/reserve.txt", 1);
	my $matchword = $FORM{'matchword'} eq 'checked' ? 'checked="checked" ' : '';
	my $matchcase = $FORM{'matchcase'} eq 'checked' ? 'checked="checked" ' : '';
	my $matchuser = $FORM{'matchuser'} eq 'checked' ? 'checked="checked" ' : '';
	my $matchname = $FORM{'matchname'} eq 'checked' ? 'checked="checked" ' : '';
	print RESERVE $FORM{'reserved'};
	fclose(RESERVE);
	fopen(RESERVECFG, "+>$vardir/reservecfg.txt");
	print RESERVECFG "$matchword\n";
	print RESERVECFG "$matchcase\n";
	print RESERVECFG "$matchuser\n";
	print RESERVECFG "$matchname\n";
	fclose(RESERVECFG);
	$yySetLocation = qq~$adminurl~;
	&redirectexit;
}

sub ModifyAgreement {
	&is_admin_or_gmod;
	my ($agreementlanguage, $line);
	if ($FORM{'agreementlanguage'}) {
		$agreementlanguage = $FORM{'agreementlanguage'};
	} else {
		$agreementlanguage = $lang;
	}
	opendir(LNGDIR, $langdir);
	my @lfilesanddirs = readdir(LNGDIR);
	close(LNGDIR);
	foreach $fld (@lfilesanddirs) {
		if (-d "$langdir/$fld" && $fld =~ m^\A[0-9a-zA-Z_\#\%\-\:\+\?\$\&\~\,\@/]+\Z^ && -e "$langdir/$fld/Main.lng") {
			if ($agreementlanguage eq $fld) { $drawnldirs .= qq~<option value="$fld" selected="selected">$fld</option>~; }
			else { $drawnldirs .= qq~<option value="$fld">$fld</option>~; }
		}
	}

	my ($fullagreement, $line);
	fopen(AGREE, "$langdir/$agreementlanguage/agreement.txt");
	while ($line = <AGREE>) {
		$line =~ tr/[\r\n]//d;
		&FromHTML($line);
		$fullagreement .= qq~$line\n~;
	}
	fclose(AGREE);
	$yymain .= qq~

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg">
<img src="$imagesdir/xx.gif" alt="" border="0" /><b>$admin_txt{'764'}</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
		$admin_txt{'765'}<br /><br />
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
	<form action="$adminurl?action=modagreement" method="post">
	$templs{'8'}
	<select name="agreementlanguage" id="agreementlanguage" size="1">
		$drawnldirs
	</select>
	<input type="submit" value="$admin_txt{'462'}" />
	</form>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="center" class="windowbg2"><br />
	<form action="$adminurl?action=modagreement2" method="post">
	<input type="hidden" name="agreementlanguage" value="$agreementlanguage" />
	<textarea rows="40" cols="95" name="agreement" style="width:95%">$fullagreement</textarea><br /><br />
	   </td>
     </tr>
     <tr valign="middle">
       <td align="center" class="catbg">
		 <input type="submit" value="$admin_txt{'10'} $agreementlanguage" />
	   </td>
     </tr>
	</form>
   </table>
 </div>
~;
	$yytitle     = "$admin_txt{'764'}";
	$action_area = "modagreement";
	&AdminTemplate;
	exit;
}

sub ModifyAgreement2 {
	&is_admin_or_gmod;
	if ($FORM{'agreementlanguage'}) { $agreementlanguage = $FORM{'agreementlanguage'}; }
	else { $agreementlanguage = $lang; }
	$FORM{'agreement'} =~ tr/\r//d;
	$FORM{'agreement'} =~ s~\A\n~~;
	$FORM{'agreement'} =~ s~\n\Z~~;
	fopen(AGREE, ">$langdir/$agreementlanguage/agreement.txt");
	print AGREE $FORM{'agreement'};
	fclose(AGREE);
	$yySetLocation = qq~$adminurl~;
	&redirectexit;
}

sub ModifySettings {
	&is_admin_or_gmod;
	require "$vardir/Settings.pl";
	my ($mainchecked, $pflashchecked, $guestaccchecked, $forcechecked, $blankchecked, $agreechecked, $regdischecked, $mailpasschecked, $newpasschecked, $welchecked);
	my ($menuchecked, $ubbcchecked, $eclickchecked, $aluchecked, $dstchecked, $pbchecked, $insertchecked, $newschecked, $gpchecked, $notifchecked);
	my ($ahmchecked, $slmchecked, $srbarchecked, $smbarchecked, $smodchecked, $supicchecked, $sutextchecked, $stviewchecked, $strepchecked, $sgichecked);
	my ($snfchecked, $fls1, $fls2, $fls3, $truncchecked, $mts1, $mts2, $mts3, $tsl6, $tsl5, $tsl4, $tsl3, $tsl2, $tsl1);
	my ($gzc1, $gzc2, $gzc3, $gzchecked, $preregchecked, $bmd1, $bmd2, $defml1, $defml2, $defml3, $defml4);

	# figure out what to print
	if    (!$color{'fadertext'}) { $color{'fadertext'}  = '#000000'; }
	if    (!$color{'faderbg'})   { $color{'faderbg'}    = '#ffffff'; }
	if    ($debug)               { $debugchecked        = ' checked="checked" '; }
	if    ($nestedquotes)        { $nestedquoteschecked = ' checked="checked" '; }
	if    ($maintenance)         { $mainchecked         = ' checked="checked" '; }
	if    ($cachebehaviour)      { $cachechecked        = ' checked="checked" '; }
	if    ($preregister)         { $preregchecked       = ' checked="checked" '; }
	if    ($guestaccess == 0)    { $guestaccchecked     = ' checked="checked" '; }
	if    ($RegAgree)            { $agreechecked        = ' checked="checked" '; }
	if    ($regdisable)          { $regdischecked       = ' checked="checked" '; }
	if    ($smtp_auth_required)  { $smtp_auth_checked   = ' checked="checked" '; }
	if    ($emailpassword)       { $mailpasschecked     = ' checked="checked" '; }
	if    ($emailnewpass)        { $newpasschecked      = ' checked="checked" '; }
	if    ($emailwelcome)        { $welchecked          = ' checked="checked" '; }
	if    ($MenuType == 0)       { $menutype0           = ' selected="selected" '; }
	elsif ($MenuType == 1)       { $menutype1           = ' selected="selected" '; }
	elsif ($MenuType == 2)       { $menutype2           = ' selected="selected" '; }
	if    ($enable_ubbc)         { $ubbcchecked         = ' checked="checked" '; }
	if    ($parseflash)          { $pflashchecked       = ' checked="checked" '; }
	if    ($enableclicklog)      { $eclickchecked       = ' checked="checked" '; }
	if    ($autolinkurls)        { $aluchecked          = ' checked="checked" '; }
	if    ($dstoffset)           { $dstchecked          = ' checked="checked" '; }
	if    ($profilebutton)       { $pbchecked           = ' checked="checked" '; }
	if    ($enable_news)         { $newschecked         = ' checked="checked" '; }
	if    ($enable_guestposting) { $gpchecked           = ' checked="checked" '; }
	if    ($enable_notification) { $notifchecked        = ' checked="checked" '; }
	if    ($allow_hide_email)    { $ahmchecked          = ' checked="checked" '; }
	if    ($showlatestmember)    { $slmchecked          = ' checked="checked" '; }
	if    ($Show_RecentBar)      { $srbarchecked        = ' checked="checked" '; }
	if    ($showmodify)          { $smodchecked         = ' checked="checked" '; }
	if    ($ShowBDescrip)        { $bdescripchecked     = ' checked="checked" '; }
	if    ($showuserpic)         { $supicchecked        = ' checked="checked" '; }
	if    ($showusertext)        { $sutextchecked       = ' checked="checked" '; }
	if    ($showtopicviewers)    { $stviewchecked       = ' checked="checked" '; }
	if    ($showtopicrepliers)   { $strepchecked        = ' checked="checked" '; }
	if    ($showgenderimage)     { $sgichecked          = ' checked="checked" '; }
	if    ($shownewsfader)       { $snfchecked          = ' checked="checked" '; }

	if ($fadelinks)  { $fadlinkschecked = ' checked="checked" '; }
	if (!$maxsteps)  { $maxsteps        = '30'; }
	if (!$stepdelay) { $stepdelay       = '40'; }

	if    ($showyabbcbutt)  { $syabbcchecked    = ' checked="checked" '; }
	if    ($allowpics)      { $allowpicschecked = ' checked="checked" '; }
	if    ($use_flock == 0) { $fls1             = " selected=\"selected\" "; }
	elsif ($use_flock == 1) { $fls2             = " selected=\"selected\" "; }
	elsif ($use_flock == 2) { $fls3             = " selected=\"selected\" "; }
	$truncchecked = $faketruncation ? ' checked="checked" ' : '';
	if    ($mailtype == 0)     { $mts1 = ' selected="selected" '; }
	elsif ($mailtype == 1)     { $mts2 = ' selected="selected" '; }
	elsif ($mailtype == 2)     { $mts3 = ' selected="selected" '; }
	if    ($timeselected == 6) { $tsl6 = " selected=\"selected\" " }
	elsif ($timeselected == 5) { $tsl5 = " selected=\"selected\" " }
	elsif ($timeselected == 4) { $tsl4 = " selected=\"selected\" " }
	elsif ($timeselected == 3) { $tsl3 = " selected=\"selected\" " }
	elsif ($timeselected == 2) { $tsl2 = " selected=\"selected\" " }
	else { $tsl1 = " selected=\"selected\" " }
	if    ($gzcomp == 0) { $gzc1 = ' selected'; }
	elsif ($gzcomp == 1) { $gzc2 = ' selected'; }
	elsif ($gzcomp == 2) { $gzc3 = ' selected'; }
	$gzchecked = $gzforce ? ' checked' : '';
	$ddd       = (($timeoffset * 10) + 120);
	$del{$ddd} = ' selected="selected"';
	if ($barmaxdepend == 0) { $bmd1 = ' checked="checked"'; }
	else { $bmd2 = ' checked="checked"'; }
	if    ($defaultml eq 'regdate')  { $defml1 = ' selected="selected"'; }
	elsif ($defaultml eq 'posts')    { $defml2 = ' selected="selected"'; }
	elsif ($defaultml eq 'username') { $defml3 = ' selected="selected"'; }
	elsif ($defaultml eq 'position') { $defml4 = ' selected="selected"'; }
	if    ($Cookie_Length == 1)    { $clsel1    = " selected=\"selected\" "; }
	elsif ($Cookie_Length == 60)   { $clsel60   = " selected=\"selected\" "; }
	elsif ($Cookie_Length == 180)  { $clsel180  = " selected=\"selected\" "; }
	elsif ($Cookie_Length == 360)  { $clsel360  = " selected=\"selected\" "; }
	elsif ($Cookie_Length == 720)  { $clsel720  = " selected=\"selected\" "; }
	elsif ($Cookie_Length == 1440) { $clsel1440 = " selected=\"selected\" "; }
	if    ($smtp_auth_required == 0)  { $smtpsel0 = ' selected="selected"'; }
	elsif ($smtp_auth_required == 1)  { $smtpsel1 = ' selected="selected"'; }
	elsif ($smtp_auth_required == 2)  { $smtpsel2 = ' selected="selected"'; }
	elsif ($smtp_auth_required == 3)  { $smtpsel3 = ' selected="selected"'; }
	elsif ($smtp_auth_required == 4)  { $smtpsel4 = ' selected="selected"'; }

	$forumstart =~ m~(\d{2})\/(\d{2})\/(\d{2,4}).*?(\d{2})\:(\d{2})\:(\d{2})~is;
	$forumstart_month = $1;
	$forumstart_day = $2;
	$forumstart_year = $3;
	$forumstart_hour = $4;
	$forumstart_minute = $5;
	$forumstart_secund = $6;

	if($forumstart_month > 12) { $forumstart_month = 12; }
	if($forumstart_month < 1) { $forumstart_month = 1; }
	if($forumstart_day > 31) { $forumstart_day = 31; }
	if($forumstart_day < 1) { $forumstart_day = 1; }
	if(length($forumstart_year) > 2) { $forumstart_year = substr($forumstart_year , length($forumstart_year) - 2, 2); }
	if($forumstart_year < 90 && $forumstart_year > 20) { $forumstart_year = 90; }
	if($forumstart_year > 20 && $forumstart_year < 90) { $forumstart_year = 20; }
	if($forumstart_hour > 23) { $forumstart_hour = 23; }
	if($forumstart_minute > 59) { $forumstart_minute = 59; }
	if($forumstart_secund > 59) { $forumstart_secund = 59; }

	$sel_day = qq~
	<select name="forumstart_day">\n~;
	for($i = 1; $i <= 31; $i++) {
		$day_val = sprintf("%02d", $i);
		if($forumstart_day == $i) {
			$sel_day .= qq~<option value="$day_val" selected="selected">$i</option>\n~;
		}
		else {
			$sel_day .= qq~<option value="$day_val">$i</option>\n~;
		}
	}
	$sel_day .= qq~</select>\n~;

	$sel_month = qq~
	<select name="forumstart_month">\n~;
	for($i = 0; $i < 12; $i++) {
		$z = $i+1;
		$month_val = sprintf("%02d", $z);
		if($forumstart_month == $z) {
			$sel_month .= qq~<option value="$month_val" selected="selected">$months[$i]</option>\n~;
		}
		else {
			$sel_month .= qq~<option value="$month_val">$months[$i]</option>\n~;
		}
	}
	$sel_month .= qq~</select>\n~;

	$sel_year = qq~
	<select name="forumstart_year">\n~;
	for($i = 90; $i <= 120; $i++) {
		if($i < 100) { $z = $i; $year_pre = qq~19~; } else { $z = $i-100; $year_pre = qq~20~; }
		$year_val = sprintf("%02d", $z);
		$year_opt = qq~$year_pre$year_val~;
		if($forumstart_year == $z) {
			$sel_year .= qq~<option value="$year_val" selected="selected">$year_opt</option>\n~;
		}
		else {
			$sel_year .= qq~<option value="$year_val">$year_opt</option>\n~;
		}
	}
	$sel_year .= qq~</select>\n~;

	$time_sel = ${$uid.$username}{'timeselect'};
	if($time_sel == 1 || $time_sel == 4 || $time_sel == 5) { $all_date = qq~$sel_month $sel_day $sel_year~; }
	else { $all_date = qq~$sel_day $sel_month $sel_year~; }		

	$sel_hour = qq~
	<select name="forumstart_hour">\n~;
	for($i = 0; $i <= 23; $i++) {
		$hour_val = sprintf("%02d", $i);
		if($forumstart_hour == $i) {
			$sel_hour .= qq~<option value="$hour_val" selected="selected">$hour_val</option>\n~;
		}
		else {
			$sel_hour .= qq~<option value="$hour_val">$hour_val</option>\n~;
		}
	}
	$sel_hour .= qq~</select>\n~;

	$sel_minute = qq~
	<select name="forumstart_minute">\n~;
	for($i = 0; $i <= 59; $i++) {
		$minute_val = sprintf("%02d", $i);
		if($forumstart_minute == $i) {
			$sel_minute .= qq~<option value="$minute_val" selected="selected">$minute_val</option>\n~;
		}
		else {
			$sel_minute .= qq~<option value="$minute_val">$minute_val</option>\n~;
		}
	}
	$sel_minute .= qq~</select>\n~;

	$sel_secund = qq~<input type="hidden" value="$forumstart_secund" name="forumstart_secund" />~;

	$all_time = qq~$sel_hour $sel_minute $sel_secund~;

	$yymain .= qq~
<form action="$adminurl?action=modsettings2" method="post">

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg">
		&nbsp;<b>$admin_txt{'222'}</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
	$admin_txt{'347'}
<br /><br />
	   </td>
     </tr>
   </table>
 </div>

<br />

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg">
		<img src="$imagesdir/preferences.gif" alt="" border="0" />
&nbsp;<b>$admin_txt{'67'}</b>
	   </td>
     </tr>
     <tr align="center" valign="middle">
       <td align="left" class="catbg"><span class="small">$admin_txt{'67'}</span>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
		<div class="setting_cell">
			$admin_txt{'348'}
		</div>
		<div class="setting_cell2">
			<input type="checkbox" name="maintenance"$mainchecked />
		</div>
		<br />

		<div class="setting_cell">
			$admin_txt{'348Text'}
		</div>
		<div class="setting_cell2">
			<textarea cols="30" rows="5" name="maintenancetext" style="width: 98%">$maintenancetext</textarea>
		</div>
	   </td>
     </tr>
   </table>
 </div>

<br />


 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg">
		<img src="$imagesdir/preferences.gif" alt="" border="0" />
&nbsp;<b>$settop_txt{'4'}</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
		<div class="setting_cell">$admin_txt{'350'}</div>
		<div class="setting_cell2"><input type="text" name="mbname" size="35" value="$mbname" /></div>
	<br />
		<div class="setting_cell">$admin_txt{'350a'}</div>
		<div class="setting_cell2">$all_date $maintxt{'107'} $all_time</div>
		<div class="setting_cell">$admin_txt{'521'}</div>
		<div class="setting_cell2">
		<select name="menutype" size="1">
		<option value="0" $menutype0>$admin_txt{'521a'}</option>
		<option value="1" $menutype1>$admin_txt{'521b'}</option>
		<option value="2" $menutype2>$admin_txt{'521c'}</option>
		</select>
		</div>
	<br />
		<div class="setting_cell">$admin_txt{'523'}</div>
		<div class="setting_cell2"><input type="checkbox" name="profilebutton"$pbchecked /></div>
	<br />
		<div class="setting_cell">$admin_txt{'382'}</div>
		<div class="setting_cell2"><input type="checkbox" name="showlatestmember" $slmchecked /></div>
	<br />
		<div class="setting_cell">$admin_txt{'379'}</div>
		<div class="setting_cell2"><input type="checkbox" name="enable_news" $newschecked /></div>
	<br />
		<div class="setting_cell">$admin_txt{'387'}</div>
		<div class="setting_cell2"><input type="checkbox" name="shownewsfader" $snfchecked /></div>
	<br />
		<div class="setting_cell">$admintxt{'40'}</div>
		<div class="setting_cell2"><input type="checkbox" name="fadelinks"$fadlinkschecked /></div>
	<br />
		<div class="setting_cell">$admintxt{'41'}</div>
		<div class="setting_cell2"><input type="text" name="maxsteps" size="5" value="$maxsteps" /></div>
	<br />
		<div class="setting_cell">$admintxt{'42'}</div>
		<div class="setting_cell2"><input type="text" name="stepdelay" size="5" value="$stepdelay" /></div>
	<br />
		<div class="setting_cell">$admin_txt{'389'}</div>
		<div class="setting_cell2"><input type="text" name="fadertext" size="10" value="$color{'fadertext'}" /></div>
	<br />
		<div class="setting_cell">$admin_txt{'389a'}</div>
		<div class="setting_cell2"><input type="text" name="faderbg" size="10" value="$color{'faderbg'}" /></div>
	<br />
		<div class="setting_cell">$admin_txt{'509'}</div>
		<div class="setting_cell2"><input type="checkbox" name="showrecentbar" $srbarchecked /></div>
	<br />
		<div class="setting_cell">$admin_txt{'732'}</div>
		<div class="setting_cell2"><input type="checkbox" name="showbdescrip" $bdescripchecked /></div>
	<br />
		<div class="setting_cell">$admin_txt{'383'}</div>
		<div class="setting_cell2"><input type="checkbox" name="showmodify" $smodchecked /></div>
	<br />
		<div class="setting_cell">$admin_txt{'384'}</div>
		<div class="setting_cell2"><input type="checkbox" name="showuserpic" $supicchecked /></div>
	<br />
		<div class="setting_cell">$admin_txt{'385'}</div>
		<div class="setting_cell2"><input type="checkbox" name="showusertext" $sutextchecked /></div>
	<br />
		<div class="setting_cell">$admin_txt{'394'}<br /><span class="small">$admin_txt{'396'}</span></div>
		<div class="setting_cell2"><input type="checkbox" name="showtopicviewers" $stviewchecked /></div>
	<br />
		<div class="setting_cell">$admin_txt{'395'}<br /><span class="small">$admin_txt{'396'}</span></div>
		<div class="setting_cell2"><input type="checkbox" name="showtopicrepliers" $strepchecked /></div>
	<br />
		<div class="setting_cell">$admin_txt{'385a'}</div>
		<div class="setting_cell2"><input type="text" name="defaultusertxt" size="25" value="$defaultusertxt" /></div>
	<br />
		<div class="setting_cell">$admin_txt{'386'}</div>
		<div class="setting_cell2"><input type="checkbox" name="showgenderimage" $sgichecked /></div>
	<br />
		<div class="setting_cell">$admin_txt{'740'}</div>
		<div class="setting_cell2"><input type="checkbox" name="showyabbcbutt" $syabbcchecked /></div>
	<br />
		<div class="setting_cell">$admin_txt{'804'}</div>
		<div class="setting_cell2"><br /><input type="checkbox" name="parseflash" $pflashchecked /></div>
	<br />
		<div class="setting_cell">$admin_txt{'378'}</div>
		<div class="setting_cell2"><input type="checkbox" name="enable_ubbc"$ubbcchecked /></div>
	<br />
		<div class="setting_cell">$admin_txt{'378a'}</div>
		<div class="setting_cell2"><input type="checkbox" name="nestedquotes"$nestedquoteschecked /></div>
	<br />
		<div class="setting_cell">$admin_txt{'524'}</div>
		<div class="setting_cell2"><input type="checkbox" name="autolinkurls"$aluchecked /></div>
	<br />
		<div class="setting_cell">$admin_txt{'498'}</div>
		<div class="setting_cell2"><input type="text" name="maxmesslen" size="5" value="$MaxMessLen" /></div>
	<br />
		<div class="setting_cell">$admin_txt{'101'}</div>
		<div class="setting_cell2"><input type="text" name="maxfavs" size="4" value="$maxfavs" /></div>
	<br />
		<div class="setting_cell">$admin_txt{'499'}</div>
		<div class="setting_cell2"><input type="text" name="fontsizemin" size="4" value="$fontsizemin" /></div>
	<br />
		<div class="setting_cell">$admin_txt{'500'}</div>
		<div class="setting_cell2"><input type="text" name="fontsizemax" size="4" value="$fontsizemax" /></div>
	<br />
		<div class="setting_cell">$admin_txt{'587'}</div>
		<div class="setting_cell2">
		<select name="timeselect" size="1">
			<option value="1"$tsl1>$admin_txt{'480'}</option>
			<option value="5"$tsl5>$admin_txt{'484'}</option>
			<option value="4"$tsl4>$admin_txt{'483'}</option>
			<option value="2"$tsl2>$admin_txt{'481'}</option>
			<option value="3"$tsl3>$admin_txt{'482'}</option>
			<option value="6"$tsl6>$admin_txt{'485'}</option>
		</select>
		</div>
	<br />
		<div class="setting_cell">$admin_txt{'371'}</div>
		<div class="setting_cell2">
		<select name="timeoffset">
		<option value="">$time_zone_txt{'1'}</option>
		<option value="12"$del{'240'}>$time_zone_txt{'2'}</option>
		<option value="11"$del{'230'}>$time_zone_txt{'3'}</option>
		<option value="10"$del{'220'}>$time_zone_txt{'4'}</option>
		<option value="9.5"$del{'215'}>$time_zone_txt{'5'}</option>
		<option value="9"$del{'210'}>$time_zone_txt{'6'}</option>
		<option value="8"$del{'200'}>$time_zone_txt{'7'}</option>
		<option value="6.5"$del{'185'}>$time_zone_txt{'9'}</option>
		<option value="6"$del{'180'}>$time_zone_txt{'10'}</option>
		<option value="5.5"$del{'175'}>$time_zone_txt{'11'}</option>
		<option value="5"$del{'170'}>$time_zone_txt{'12'}</option>
		<option value="4"$del{'160'}>$time_zone_txt{'13'}</option>
		<option value="3.5"$del{'155'}>$time_zone_txt{'14'}</option>
		<option value="3"$del{'150'}>$time_zone_txt{'15'}</option>
		<option value="2"$del{'140'}>$time_zone_txt{'16'}</option>
		<option value="1"$del{'130'}>$time_zone_txt{'17'}</option>
		<option value="0"$del{'120'}>$time_zone_txt{'18'}</option>
		<option value="-1"$del{'110'}>$time_zone_txt{'19'}</option>
		<option value="-2"$del{'100'}>$time_zone_txt{'20'}</option>
		<option value="-3"$del{'90'}>$time_zone_txt{'21'}</option>
		<option value="-3.5"$del{'85'}>$time_zone_txt{'22'}</option>
		<option value="-4"$del{'80'}>$time_zone_txt{'23'}</option>
		<option value="-5"$del{'70'}>$time_zone_txt{'24'}</option>
		<option value="-6"$del{'60'}>$time_zone_txt{'25'}</option>
		<option value="-7"$del{'50'}>$time_zone_txt{'26'}</option>
		<option value="-8"$del{'40'}>$time_zone_txt{'27'}</option>
		<option value="-9"$del{'30'}>$time_zone_txt{'28'}</option>
		<option value="-10"$del{'20'}>$time_zone_txt{'29'}</option>
		<option value="-11"$del{'10'}>$time_zone_txt{'30'}</option>
		</select>
		</div>
	<br />
		<div class="setting_cell">$admin_txt{'371a'}</div>
		<div class="setting_cell2"><input type="checkbox" name="dstoffset"$dstchecked /></div>
	<br />
		<div class="setting_cell">$admin_txt{'371b'}</div>
		<div class="setting_cell2"><input type="text" name="timecorrection" size="5" value="$timecorrection" /></div>
	<br />
		<div class="setting_cell">$admin_txt{'373'}</div>
		<div class="setting_cell2"><input type="text" name="TopAmmount" size="5" value="$TopAmmount" /></div>
	<br />
		<div class="setting_cell">$admin_txt{'912'}</div>
		<div class="setting_cell2">
		<select name="defaultml" size="1">
		<option value="username"$defml3>$admin_txt{'914'}</option>
		<option value="position"$defml4>$admin_txt{'911'}</option>
		<option value="posts"$defml2>$admin_txt{'910'}</option>
		<option value="regdate"$defml1>$admin_txt{'909'}</option>
		</select>
		</div>
	<br />
		<div class="setting_cell">$admin_txt{'902'} $admin_txt{'107'}</div>
		<div class="setting_cell2">
		<input type="text" name="barmaxnumb" size="5" value="$barmaxnumb" /> $admin_txt{'904'} <input type="radio" name="barmaxdepend" value="0" $bmd1 />
		$admin_txt{'905'} <input type="radio" name="barmaxdepend" value="1" $bmd2 /> $admin_txt{'903'}
		</div>
	<br />
		<div class="setting_cell">$admin_txt{'842'}</div>
		<div class="setting_cell2"><input type="text" name="HotTopic" size="5" value="$HotTopic" /></div>
	<br />
		<div class="setting_cell">$admin_txt{'843'}</div>
		<div class="setting_cell2"><input type="text" name="VeryHotTopic" size="5" value="$VeryHotTopic" /></div>

<br /><br />
	   </td>
     </tr>
   </table>
 </div>

<br />

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg">
<img src="$imagesdir/preferences.gif" alt="" border="0" />
&nbsp;<b>$settop_txt{'2'}</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
		<div class="setting_cell">$admin_txt{'404'}</div>
		<div class="setting_cell2">
		<select name="mailtype" size="1">
			<option value="0"$mts1>$smtp_txt{'sendmail'}</option>
			<option value="1"$mts2>$smtp_txt{'smtp'}</option>
			<option value="2"$mts3>$smtp_txt{'net'}</option>
		</select></div>
	<br />
		<div class="setting_cell">$admin_txt{'354'}</div>
		<div class="setting_cell2"><input type="text" name="mailprog" size="20" value="$mailprog" /></div>
	<br />
		<div class="setting_cell">$admin_txt{'407'}</div>
		<div class="setting_cell2"><input type="text" name="smtp_server" size="20" value="$smtp_server" /></div>
	<br />
		<div class="setting_cell">$smtp_txt{'1'}<br /><span class="small">$smtp_txt{'2'}</span></div>
		<div class="setting_cell2">
		<select name="smtp_auth_required" size="1">
			<option value="4"$smtpsel4>$smtp_txt{'auto'}</option>
			<option value="3"$smtpsel3>$smtp_txt{'cram'}</option>
			<option value="2"$smtpsel2>$smtp_txt{'login'}</option>
			<option value="1"$smtpsel1>$smtp_txt{'plain'}</option>
			<option value="0"$smtpsel0>$smtp_txt{'off'}</option>
		</select></div>
	<br />
		<div class="setting_cell">$smtp_txt{'3'}</div>
		<div class="setting_cell2"><input type="text" name="authuser" size="20" value="$authuser" /></div>
	<br />
		<div class="setting_cell">$smtp_txt{'4'}</div>
		<div class="setting_cell2"><input type="password" name="authpass" size="20" value="$authpass" /></div>
	<br />
		<div class="setting_cell">$admin_txt{'355'}</div>
		<div class="setting_cell2"><input type="text" name="webmaster_email" size="35" value="$webmaster_email" /></div>
	<br />
		<div class="setting_cell">$admin_txt{'702'}</div>
		<div class="setting_cell2"><input type="checkbox" name="emailpassword"$mailpasschecked /></div>
	<br />
		<div class="setting_cell">$admin_txt{'639'}</div>
		<div class="setting_cell2"><input type="checkbox" name="emailnewpass"$newpasschecked /></div>
	<br />
		<div class="setting_cell">$admin_txt{'619'}</div>
		<div class="setting_cell2"><input type="checkbox" name="emailwelcome"$welchecked /></div>
	<br />
	   </td>
     </tr>
   </table>
 </div>

<br />

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg">
<img src="$imagesdir/preferences.gif" alt="" border="0" />
&nbsp;<b>$settop_txt{'3'}</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
		<div class="setting_cell">$admin_txt{'632'}</div>
		<div class="setting_cell2"><input type="checkbox" name="guestaccess"$guestaccchecked /></div>
	<br />
		<div class="setting_cell">$admin_txt{'380'}</div>
		<div class="setting_cell2"><input type="checkbox" name="enable_guestposting" $gpchecked /></div>
	<br />
		<div class="setting_cell">$admin_txt{'432'}</div>
		<div class="setting_cell2">
		<select name="cookielength">
		<option value="1"$clsel1>$admin_txt{'497c'}</option>
		<option value="60"$clsel60>1 $admin_txt{'497a'}</option>
		<option value="180"$clsel180>3 $admin_txt{'497b'}</option>
		<option value="360"$clsel360>6 $admin_txt{'497b'}</option>
		<option value="720"$clsel720>12 $admin_txt{'497b'}</option>
		<option value="1440"$clsel1440>24 $admin_txt{'497b'}</option>
		</select>
		</div>
	<br />
		<div class="setting_cell">$admin_txt{'352'}</div>
		<div class="setting_cell2"><input type="text" name="cookieusername" size="20" value="$cookieusername" /></div>
	<br />
		<div class="setting_cell">$admin_txt{'353'}</div>
		<div class="setting_cell2"><input type="text" name="cookiepassword" size="20" value="$cookiepassword" /></div>
	<br />
		<div class="setting_cell">$admin_txt{'353a'}</div>
		<div class="setting_cell2"><input type="text" name="cookiesession_name" size="20" value="$cookiesession_name" /></div>
	<br />
		<div class="setting_cell">$admin_txt{'585'}</div>
		<div class="setting_cell2"><input type="checkbox" name="regdisable"$regdischecked /></div>
	<br />
		<div class="setting_cell">$admin_txt{'584'}</div>
		<div class="setting_cell2"><input type="checkbox" name="regagree"$agreechecked /></div>
	<br />
		<div class="setting_cell">$prereg_txt{'7'}</div>
		<div class="setting_cell2"><input type="checkbox" name="preregister"$preregchecked /></div>
	<br />
		<div class="setting_cell">$prereg_txt{'11'}</div>
		<div class="setting_cell2"><input type="text" name="preregspan" size="5" value="$preregspan" /></div>
	<br />
		<div class="setting_cell">$admin_txt{'746'}</div>
		<div class="setting_cell2"><input type="checkbox" name="allowpics" $allowpicschecked /></div>
	<br />
		<div class="setting_cell">$admin_txt{'381'}</div>
		<div class="setting_cell2"><input type="checkbox" name="enable_notification" $notifchecked /></div>
	<br />
		<div class="setting_cell">$admin_txt{'723'}</div>
		<div class="setting_cell2"><input type="checkbox" name="allow_hide_email" $ahmchecked /></div>
	<br />
		<div class="setting_cell">$admin_txt{'476'}</div>
		<div class="setting_cell2"><input type="text" name="userpic_width" size="5" value="$userpic_width" /></div>
	<br />
		<div class="setting_cell">$admin_txt{'477'}</div>
		<div class="setting_cell2"><input type="text" name="userpic_height" size="5" value="$userpic_height" /></div>
	<br />
		<div class="setting_cell">$admin_txt{'689'}</div>
		<div class="setting_cell2"><input type="text" name="maxsiglen" size="5" value="$MaxSigLen" /></div>
	<br />
		<div class="setting_cell">$admin_txt{'408'}</div>
		<div class="setting_cell2"><input type="text" name="timeout" size="5" value="$timeout" /></div>
	<br />~;
	opendir(LNGDIR, $langdir);
	my @lfilesanddirs = readdir(LNGDIR);
	close(LNGDIR);

	foreach $fld (@lfilesanddirs) {
		if (-d "$langdir/$fld" && $fld =~ m^\A[0-9a-zA-Z_\#\%\-\:\+\?\$\&\~\,\@/]+\Z^ && -e "$langdir/$fld/Main.lng") {
			if ($lang eq $fld) { $drawnldirs .= qq~<option value="$fld" selected="selected">$fld</option>~; }
			else { $drawnldirs .= qq~<option value="$fld">$fld</option>~; }
		}
	}
	$yymain .= qq~
		<div class="setting_cell">$admin_txt{'816'}</div>
		<div class="setting_cell2"><select name="lang">$drawnldirs</select></div>
	<br />~;
	&CheckNewTemplates;
	unless ($templatesloaded == 1) {
		require "$vardir/template.cfg";
	}
	while (($curtemplate, $value) = each(%templateset)) {
		$selected = "";
		if ($curtemplate eq $default_template) { $selected = qq~ selected="selected"~; $akttemplate = $curtemplate; }
		$drawndirs .= qq~<option value="$curtemplate"$selected>$curtemplate</option>\n~;
	}
	$yymain .= qq~
		<div class="setting_cell">$admin_txt{'813'}</div>
		<div class="setting_cell2"><select name="default_template">$drawndirs</select></div>
	<br />
	   </td>
     </tr>
   </table>
 </div>

<br />

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg">
<img src="$imagesdir/preferences.gif" alt="" border="0" />
&nbsp;<b>$settop_txt{'5'}</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
		<div class="setting_cell">$gztxt{'1'}</div>
		<div class="setting_cell2">
		<select name="gzcomp" size="1">
			<option value="0"$gzc1>$gztxt{'3'}</option>
			<option value="1"$gzc2>$gztxt{'4'}</option>
		~;
	if (eval "require Compress::Zlib") {
		$yymain .= qq~  
			<option value="2"$gzc3>$gztxt{'5'}</option>
		~;
	}
	$yymain .= qq~  
		</select></div>
	<br />
		<div class="setting_cell">$gztxt{'2'}</div>
		<div class="setting_cell2"><input type="checkbox" name="gzforce"$gzchecked /></div>
	<br />
		<div class="setting_cell">$admin_txt{'802'}</div>
		<div class="setting_cell2"><br /><input type="checkbox" name="cachebehaviour" $cachechecked /></div>
	<br />
		<div class="setting_cell">$admin_txt{'803'}</div>
		<div class="setting_cell2"><br /><input type="checkbox" name="enableclicklog" $eclickchecked /></div>
	<br />
		<div class="setting_cell">$admin_txt{'690'}</div>
		<div class="setting_cell2"><input type="text" name="clicklogtime" size="5" value="$ClickLogTime" /></div>
	<br />
		<div class="setting_cell">$admin_txt{'376'}</div>
		<div class="setting_cell2"><input type="text" name="max_log_days_old" size="5" value="$max_log_days_old" /></div>
	<br />
		<div class="setting_cell">$floodtxt{'5'}</div>
		<div class="setting_cell2"><input type=text name="maxrecentdisplay" size="5" value="$maxrecentdisplay" /></div>
	<br />
		<div class="setting_cell">$floodtxt{'6'}</div>
		<div class="setting_cell2"><input type=text name="maxsearchdisplay" size="5" value="$maxsearchdisplay" /></div>
	<br />
		<div class="setting_cell">$admin_txt{'374'}</div>
		<div class="setting_cell2"><input type="text" name="maxdisplay" size="5" value="$maxdisplay" /></div>
	<br />
		<div class="setting_cell">$admin_txt{'375'}</div>
		<div class="setting_cell2"><input type="text" name="maxmessagedisplay" size="5" value="$maxmessagedisplay" /></div>
	<br />
	   </td>
     </tr>
   </table>
 </div>

<br />

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg">
<img src="$imagesdir/preferences.gif" alt="" border="0" />
&nbsp;<b>$settop_txt{'6'}</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
		<div class="setting_cell">$admin_txt{'391'}</div>
		<div class="setting_cell2">
		<select name="use_flock" size="1">
			<option value="0"$fls1>$admin_txt{'401'}</option>
			<option value="1"$fls2>$admin_txt{'402'}</option>
			<option value="2"$fls3>$admin_txt{'403'}</option>
		</select>
		</div>
	<br />
		<div class="setting_cell">$admin_txt{'999'}<br /><span class="small">$admin_txt{'999a'}</span></div>
		<div class="setting_cell2"><input type="checkbox" name="debug"$debugchecked /></div>
	<br />
		<div class="setting_cell">$admin_txt{'630'}</div>
		<div class="setting_cell2"><input type="checkbox" name="faketruncation"$truncchecked /></div>
	<br />
	   </td>
     </tr>
   </table>
 </div>

<br />

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="center" class="catbg" valign="center">
<input type="submit" value="$admin_txt{'10'}" />
	   </td>
     </tr>
   </table>
 </div>

</form>
~;
	$yytitle     = $admin_txt{'222'};
	$action_area = "modsettings";
	&AdminTemplate;
	exit;
}

# Gets our current absolute path. Needed for error messages.
sub GetDirPath {
	eval 'use Cwd; $cwd = cwd();';
	unless ($cwd) { $cwd = `pwd`; chomp $cwd; }
	unless ($cwd) { $cwd = $0 || $ENV{'PWD'} || $ENV{'CWD'} || ($ENV{'DOCUMENT_ROOT'} . '/' . $ENV{'SCRIPT_NAME'} || $ENV{'PATH_INFO'}); }
	$cwd =~ tr~\\~/~;
	$cwd =~ s~\A(.+)/\Z~$1~;
	$cwd =~ s~\A(.+)/YaBB\.\w+\Z~$1~i;
	return $cwd;
}

sub is_exe {
	my ($cmd, $name);
	foreach $cmd (@_) {
		$name = ($cmd =~ /^(\S+)/)[0];    # remove any options
		return ($cmd) if (-x $name and !-d $name and $name =~ m:/:);    # check for absolute or relative path
		if (defined $ENV{PATH}) {
			my $dir;
			foreach $dir (split(/:/, $ENV{PATH})) {
				return "$dir/$cmd" if (-x "$dir/$name" && !-d "$dir/$name");
			}
		}
	}
	0;
}

sub GmodSettings2 {
	&is_admin_or_gmod;

	my $filler  = q~                                                                               ~;
	my $setfile = << "EOF";
### Gmod Releated Setttings ###

\$allow_gmod_admin = "$FORM{'allow_gmod_admin'}"; #
\$allow_gmod_profile = "$FORM{'allow_gmod_profile'}"; #

### Areas Gmods can Access ### 

%gmod_access = (
'modsettings',"$FORM{'modsettings'}",
'flood_control',"$FORM{'flood_control'}",
'advsettings',"$FORM{'advsettings'}",
'smilies',"$FORM{'smilies'}",
'helpadmin',"$FORM{'helpadmin'}",
'setcensor',"$FORM{'setcensor'}",
'detailedversion',"$FORM{'detailedversion'}",
'managecats',"$FORM{'managecats'}",
'manageboards',"$FORM{'manageboards'}",
'editnews',"$FORM{'editnews'}",
'modagreement',"$FORM{'modagreement'}",
'modtemp',"$FORM{'modtemp'}",
'modcss',"$FORM{'modcss'}",
'referer_control',"$FORM{'referer_control'}",
'viewmembers',"$FORM{'viewmembers'}",
'modmemgr',"$FORM{'modmemgr'}",
'mailing',"$FORM{'mailing'}",
'ipban',"$FORM{'ipban'}",
'setreserve',"$FORM{'setreserve'}",
'clean_log',"$FORM{'clean_log'}",
'boardrecount',"$FORM{'boardrecount'}",
'membershiprecount',"$FORM{'membershiprecount'}",
'rebuildmemlist',"$FORM{'rebuildmemlist'}",
'deleteoldthreads',"$FORM{'deleteoldthreads'}",
'manageattachments',"$FORM{'manageattachments'}",
'stats',"$FORM{'stats'}",
'showclicks',"$FORM{'showclicks'}",
'errorlog',"$FORM{'errorlog'}",
'view_reglog',"$FORM{'view_reglog'}",
);

%gmod_access2 = (
admin => "on",
deleteattachment => "$FORM{'manageattachments'}",
manageattachments2 => "$FORM{'manageattachments'}",
removeoldattachments => "$FORM{'manageattachments'}",
removebigattachments => "$FORM{'manageattachments'}",

profile => "$FORM{'allow_gmod_profile'}",
profile => "$FORM{'allow_gmod_profile'}",
profile2 => "$FORM{'allow_gmod_profile'}",
profileAdmin => "$FORM{'allow_gmod_profile'}",
profileAdmin2 => "$FORM{'allow_gmod_profile'}",
profileContacts => "$FORM{'allow_gmod_profile'}",
profileContacts2 => "$FORM{'allow_gmod_profile'}",
profileIM => "$FORM{'allow_gmod_profile'}",
profileIM2 => "$FORM{'allow_gmod_profile'}",
profileOptions => "$FORM{'allow_gmod_profile'}",
profileOptions2 => "$FORM{'allow_gmod_profile'}",

delgroup => "$FORM{'modmemgr'}",
editgroup => "$FORM{'modmemgr'}",
editAddGroup2 => "$FORM{'modmemgr'}",
modmemgr2 => "$FORM{'modmemgr'}",
assigned => "$FORM{'modmemgr'}",
assigned2 => "$FORM{'modmemgr'}",

reordercats => "$FORM{'managecats'}",
modifycatorder => "$FORM{'managecats'}",
modifycat => "$FORM{'managecats'}",
createcat => "$FORM{'managecats'}",
catscreen => "$FORM{'managecats'}",
reordercats2 => "$FORM{'managecats'}",
addcat => "$FORM{'managecats'}",
addcat2 => "$FORM{'managecats'}",

modifyboard => "$FORM{'manageboards'}",
addboard => "$FORM{'manageboards'}",
addboard2 => "$FORM{'manageboards'}",
reorderboards2 => "$FORM{'manageboards'}",
boardscreen => "$FORM{'manageboards'}",

smilieput => "$FORM{'smilies'}",
smilieindex => "$FORM{'smilies'}",
smiliemove => "$FORM{'smilies'}",
addsmilies => "$FORM{'smilies'}",

addmember => "$FORM{'viewmembers'}",
addmember2 => "$FORM{'viewmembers'}",
deletemultimembers => "$FORM{'viewmembers'}",

mailmultimembers => "$FORM{'mailing'}",
mailing2 => "$FORM{'mailing'}",

del_regentry => "$FORM{'view_reglog'}",
clean_reglog => "$FORM{'view_reglog'}",

cleanerrorlog => "$FORM{'errorlog'}",
deleteerror => "$FORM{'errorlog'}",

do_clean_log => "$FORM{'clean_log'}",
modagreement2 => "$FORM{'modagreement'}",
modsettings2 => "$FORM{'modsettings'}",
advsettings2 => "$FORM{'advsettings'}",
ml => "$FORM{'mailing'}",
referer_control2 => "$FORM{'referer_control'}",
removeoldthreads => "$FORM{'deleteoldthreads'}",
ipban2 => "$FORM{'ipban'}",
setcensor2 => "$FORM{'setcensor'}",
setreserve2 => "$FORM{'setreserve'}",
editnews2 => "$FORM{'editnews'}",

flood_control2,"$FORM{'flood_control'}",
);

1;
EOF

	$setfile =~ s~(.+\;)\s+(\#.+$)~$1 . substr( $filler, 0, (70-(length $1)) ) . $2 ~gem;
	$setfile =~ s~(.{64,}\;)\s+(\#.+$)~$1 . "\n   " . $2~gem;
	$setfile =~ s~^\s\s\s+(\#.+$)~substr( $filler, 0, 70 ) . $1~gem;

	fopen(MODACCESS, ">$vardir/gmodsettings.txt");
	print MODACCESS $setfile;
	fclose(MODACCESS);

	$yySetLocation = qq~$adminurl~;
	&redirectexit;
}

sub ModifySettings2 {
	&is_admin_or_gmod;

	my @onoff = qw/
	  cachebehaviour debug nestedquotes preregister parseflash enableclicklog allowpics showyabbcbutt showbdescrip maintenance guestaccess insert_original enable_ubbc enable_news enable_guestposting enable_notification showlatestmember showrecentbar showmodify showuserpic showusertext showtopicviewers showtopicrepliers showgenderimage shownewsfader MenuType profilebutton autolinkurls dstoffset emailpassword RegAgree regdisable emailwelcome allow_hide_email faketruncation emailnewpass barmaxdepend fadelinks/;

	# Set as 0 or 1 if box was checked or not
	my $fi;
	map { $fi = lc $_; ${$_} = $FORM{$fi} eq 'on' ? 1 : 0; } @onoff;
	$guestaccess = $guestaccess ? 0 : 1;

	# If empty fields are submitted, set them to default-values to save yabb from crashing
	$maintenancetext = $FORM{'maintenancetext'} || "";
	&ToHTML($maintenancetext);
	$FORM{'timeout'}    =~ s~\D*~~g;
	$smtp_auth_required = $FORM{'smtp_auth_required'} || 0;
	$timeout = $FORM{'timeout'} || 5;
	$color{'fadertext'} =~ s~\s*~~g;
	$color{'fadertext'} = $FORM{'fadertext'} || '#000000';
	$color{'faderbg'}   =~ s~\s*~~g;
	$color{'faderbg'} = $FORM{'faderbg'} || '#ffffff';
	$defaultusertxt     = $FORM{'defaultusertxt'} || "";
	$timeselected       = $FORM{'timeselect'}     || 0;
	$FORM{'preregspan'} =~ s~\D*~~g;
	$preregspan = $FORM{'preregspan'} || 24;
	$timeoffset = $FORM{'timeoffset'} || 0;
	$timeoffset =~ tr/[0-9\+\-\.]//cd;
	$timecorrection = $FORM{'timecorrection'} || 0;
	$timecorrection =~ tr/[0-9\+\-\.]//cd;
	$timecorrection = int($timecorrection);
	$FORM{'TopAmmount'} =~ s~\D*~~g;
	$TopAmmount        = $FORM{'TopAmmount'} || 25;
	$FORM{'maxdisplay'} =~ s~\D*~~g;
	$maxdisplay        = $FORM{'maxdisplay'} || 20;
	$FORM{'maxfavs'} =~ s~\D*~~g;
	$maxfavs           = $FORM{'maxfavs'} || 10;
	$FORM{'fontsizemin'} =~ s~\D*~~g;
	$fontsizemin       = $FORM{'fontsizemin'} || 6;
	$FORM{'fontsizemax'} =~ s~\D*~~g;
	$fontsizemax       = $FORM{'fontsizemax'} || 72;
	$FORM{'maxrecentdisplay'} =~ tr/[0-9\+\-\.]//cd;
	$maxrecentdisplay  = $FORM{'maxrecentdisplay'} || 50;
	$FORM{'maxsearchdisplay'} =~ tr/[0-9\+\-\.]//cd;
	$maxsearchdisplay  = $FORM{'maxsearchdisplay'} || 25;
	$FORM{'maxmessagedisplay'} =~ s~\D*~~g;
	$maxmessagedisplay = $FORM{'maxmessagedisplay'} || 20;
	$FORM{'max_log_days_old'} =~ s~\D*~~g;
	$max_log_days_old  = $FORM{'max_log_days_old'} || 21;
	if ($max_log_days_old > 9999) { $max_log_days_old = 9999; }
	$FORM{'clicklogtime'} =~ s~\D*~~g;
	$clicklogtime = $FORM{'clicklogtime'} || 1440;
	if ($clicklogtime >= 1440) { $clicklogtime = 1439; }
	$use_flock          = $FORM{'use_flock'}          || 0;
	$Cookie_Length      = $FORM{'cookielength'}       || 60;
	$cookieusername     = $FORM{'cookieusername'}     || 'YaBBusername';
	$cookiepassword     = $FORM{'cookiepassword'}     || 'YaBBpassword';
	$cookiesession_name = $FORM{'cookiesession_name'} || 'YaBBSession';
	if ($cookieusername eq $cookiepassword || $cookieusername eq $cookiesession_name || $cookiepassword eq $cookiesession_name) { $cookieusername = 'YaBBusername'; $cookiepassword = 'YaBBpassword'; $cookiesession_name = 'YaBBSession'; }
	$FORM{'maxmesslen'} =~ s~\D*~~g;
	$maxmesslen = $FORM{'maxmesslen'} || 5000;
	$FORM{'maxsiglen'} =~ s~\D*~~g;
	$maxsiglen  = $FORM{'maxsiglen'}  || 200;
	$mbname     = $FORM{'mbname'}     || 'My Perl YaBB Forum';
	$mbname =~ s/\"/\'/g;
	$boardurl         = $FORM{'boardurl'}         || $boardurl;
	$lang             = $FORM{'lang'}             || "English";
	$default_template = $FORM{'default_template'} || "Forum default";
	$helpfile         = $FORM{'helpfile'}         || "$html_root/YaBBHelp/index.html";
	$mailprog         = $FORM{'mailprog'}         || &is_exe('/usr/lib/sendmail', '/usr/sbin/sendmail', '/usr/ucblib/sendmail', 'sendmail', 'mailx', 'Mail', 'mail');
	$smtp_server      = $FORM{'smtp_server'}      || '127.0.0.1';
	$webmaster_email  = $FORM{'webmaster_email'}  || 'webmaster@mysite.com';
	$mailtype         = $FORM{'mailtype'}         || 0;
	$faderpath        = $FORM{'faderpath'}        || "$boardurl/fader.js";
	$authuser         = $FORM{'authuser'}         || "";
	$authpass         = $FORM{'authpass'}         || "";
	if ($FORM{'userpic_width'} =~ /\d+/) { $userpic_width = $FORM{'userpic_width'}; }
	else { $userpic_width = 65; }
	if ($FORM{'userpic_height'} =~ /\d+/) { $userpic_height = $FORM{'userpic_height'}; }
	else { $userpic_height = 65; }
	$gzcomp       = $FORM{'gzcomp'}       || 0;
	$gzforce      = $FORM{'gzforce'}      || 0;
	$MenuType     = $FORM{'menutype'}     || 0;
	$FORM{'HotTopic'} =~ s~\D*~~g;
	$HotTopic     = $FORM{'HotTopic'}     || 15;
	$FORM{'VeryHotTopic'} =~ s~\D*~~g;
	$VeryHotTopic = $FORM{'VeryHotTopic'} || 25;
	$barmaxdepend = $FORM{'barmaxdepend'} || 0;
	if ($FORM{'barmaxnumb'} =~ /\d+/) { $barmaxnumb = $FORM{'barmaxnumb'}; }
	else { $barmaxnumb = 500; }
	$defaultml = $FORM{'defaultml'} || "regdate";
	$FORM{'maxsteps'} =~ s~\D*~~g;
	$maxsteps  = $FORM{'maxsteps'}  || 30;
	$FORM{'stepdelay'} =~ s~\D*~~g;
	$stepdelay = $FORM{'stepdelay'} || 40;

	$forumstart_month = $FORM{'forumstart_month'};
	$forumstart_day = $FORM{'forumstart_day'};
	$forumstart_year = $FORM{'forumstart_year'};
	$forumstart_hour = $FORM{'forumstart_hour'};
	$forumstart_minute = $FORM{'forumstart_minute'};
	$forumstart_secund = $FORM{'forumstart_secund'};

	if($forumstart_month == 4 || $forumstart_month == 6 || $forumstart_month == 9 || $forumstart_month == 11) {
		$max_days = 30;
	}
	elsif($forumstart_month == 2 && $forumstart_year % 4 == 0 && $forumstart_year != 0) {
		$max_days = 29;
	}
	elsif($forumstart_month == 2 && ($forumstart_year % 4 != 0 || $forumstart_year == 0)) {
		$max_days = 28;
	}
	else {
		$max_days = 31;
	}
	if($forumstart_day > $max_days) { $forumstart_day = $max_days; }

	$forumstart = qq~$forumstart_month/$forumstart_day/$forumstart_year $maintxt{'107'} $forumstart_hour:$forumstart_minute:$forumstart_secund~;

	my $filler  = q~                                                                               ~;
	my $setfile = << "EOF";
###############################################################################
# Settings.pl                                                                 #
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

########## Board Info ##########
# Note: these settings must be properly changed for YaBB to work

\$maintenance = $maintenance;				# Set to 1 to enable Maintenance mode
\$guestaccess = $guestaccess;				# Set to 0 to disallow guests from doing anything but login or register

\$mbname = q^$mbname^;					# The name of your YaBB forum
\$forumstart = "$forumstart";				# The start date of your YaBB Forum
\$Cookie_Length = $Cookie_Length;			# Default minutes to set login cookies to stay for
\$cookieusername = "$cookieusername";			# Name of the username cookie
\$cookiepassword = "$cookiepassword";			# Name of the password cookie
\$cookiesession_name = "$cookiesession_name";			# Name of the Session cookie

\$regdisable = $regdisable;				# Set to 1 to disable user registration (only admin can register)
\$RegAgree = $RegAgree;					# Set to 1 to display the registration agreement when registering
\$preregister = $preregister;				# Set to 1 to use pre-registration and account activation
\$preregspan = $preregspan;				# Time span in hours for users to account activation before cleanup.
\$emailpassword = $emailpassword;			# 0 - instant registration. 1 - password emailed to new members
\$emailnewpass = $emailnewpass;				# Set to 1 to email a new password to members if they change their email address
\$emailwelcome = $emailwelcome;				# Set to 1 to email a welcome message to users even when you have mail password turned off

\$lang = "$lang";					# Default Forum Language
\$default_template = "$default_template";		# Default Forum Template

\$mailprog = "$mailprog";				# Location of your sendmail program
\$smtp_server = "$smtp_server";				# Address of your SMTP-Server
\$smtp_auth_required = $smtp_auth_required;		# Set to 1 if the SMTP server requires Authorisation
\$authuser = q^$authuser^;				# Username for SMTP authorisation
\$authpass = q^$authpass^;				# Password for SMTP authorisation
\$webmaster_email = q^$webmaster_email^;		# Your email address. (eg: \$webmaster_email = q^admin\@host.com^;)
\$mailtype = $mailtype;					# Mail program to use: 0 = sendmail, 1 = SMTP, 2 = Net::SMTP

########## Layout ##########

\$maintenancetext = "$maintenancetext";			# User-defined text for Maintenance mode (leave blank for default text)
\$MenuType = $MenuType;					# 1 for text menu or anything else for images menu
\$profilebutton = $profilebutton;			# 1 to show view profile button under post, or 0 for blank
\$allow_hide_email = $allow_hide_email;			# Allow users to hide their email from public. Set 0 to disable
\$showlatestmember = $showlatestmember;			# Set to 1 to display "Welcome Newest Member" on the Board Index
\$shownewsfader = $shownewsfader;			# 1 to allow or 0 to disallow NewsFader javascript on the Board Index
							# If 0, you'll have no news at all unless you put <yabb news> tag
							# back into template.html!!!
\$Show_RecentBar = $showrecentbar;			# Set to 1 to display the Recent Post on Board Index
\$showmodify = $showmodify;				# Set to 1 to display "Last modified: Realname - Date" under each message
\$ShowBDescrip = $showbdescrip;				# Set to 1 to display board descriptions on the topic (message) index for each board
\$showuserpic = $showuserpic;				# Set to 1 to display each member's picture in the message view (by the ICQ.. etc.)
\$showusertext = $showusertext;				# Set to 1 to display each member's personal text in the message view (by the ICQ.. etc.)
\$showtopicviewers = $showtopicviewers;			# Set to 1 to display members viewing a topic
\$showtopicrepliers = $showtopicrepliers;		# Set to 1 to display members replying to a topic
\$showgenderimage = $showgenderimage;			# Set to 1 to display each member's gender in the message view (by the ICQ.. etc.)
\$showyabbcbutt = $showyabbcbutt;                       # Set to 1 to display the yabbc buttons on Posting and IM Send Pages
\$nestedquotes = $nestedquotes  ;                       # Set to 1 to allow quotes within quotes (0 will filter out quotes within a quoted message)
\$parseflash = $parseflash;				# Set to 1 to parse the flash tag
\$enableclicklog = $enableclicklog;                     # Set to 1 to track stats in Clicklog (this may slow your board down)


########## Feature Settings ##########

\$enable_ubbc = $enable_ubbc;				# Set to 1 if you want to enable UBBC (Uniform Bulletin Board Code)
\$enable_news = $enable_news;				# Set to 1 to turn news on, or 0 to set news off
\$allowpics = $allowpics;				# set to 1 to allow members to choose avatars in their profile
\$enable_guestposting = $enable_guestposting;		# Set to 0 if do not allow 1 is allow.
\$enable_notification = $enable_notification;		# Allow e-mail notification
\$autolinkurls = $autolinkurls;				# Set to 1 to turn URLs into links, or 0 for no auto-linking.

\$timeselected = $timeselected;				# Select your preferred output Format of Time and Date
\$timecorrection = $timecorrection;			# Set time correction for server time in seconds
\$timeoffset = $timeoffset;				# Time Offset to GMT/UTC (0 for GMT/UTC)
\$dstoffset = $dstoffset;				# Time Offset (for daylight savings time, 0 to disable DST)
\$TopAmmount = $TopAmmount;				# No. of top posters to display on the top members list
\$maxdisplay = $maxdisplay;				# Maximum of topics to display
\$maxfavs = $maxfavs;					# Maximum of favorite topics to save in a profile
\$maxrecentdisplay = $maxrecentdisplay;			# Maximum of topics to display on recent posts by a user (-1 to disable)
\$maxsearchdisplay = $maxsearchdisplay;			# Maximum of messages to display in a search query  (-1 to disable search)
\$maxmessagedisplay = $maxmessagedisplay;		# Maximum of messages to display
\$MaxMessLen = $maxmesslen;  				# Maximum Allowed Characters in a Posts
\$fontsizemin = $fontsizemin;  				# Minimum Allowed Font height in pixels
\$fontsizemax = $fontsizemax;  				# Maximum Allowed Font height in pixels
\$MaxSigLen = $maxsiglen;				# Maximum Allowed Characters in Signatures
\$ClickLogTime = $clicklogtime;				# Time in minutes to log every click to your forum (longer time means larger log file size)
\$max_log_days_old = $max_log_days_old;			# If an entry in the user's log is older than ... days remove it
							# Set to 0 if you want it disabled

\$maxsteps = $maxsteps;			# Number of steps to take to change from start color to endcolor
\$stepdelay = $stepdelay;		# Time in miliseconds of a single step
\$fadelinks = $fadelinks;		# Fade links as well as text?


\$color{'fadertext'}  = "$color{'fadertext'}";		# Color of text in the NewsFader (news color)
\$color{'faderbg'}  = "$color{'faderbg'}";		# Color of background in the NewsFader (news color)
\$defaultusertxt = qq~$defaultusertxt~;			# The dafault usertext visible in users posts
\$timeout = $timeout;					# Minimum time between 2 postings from the same IP
\$HotTopic = $HotTopic;					# Number of posts needed in a topic for it to be classed as "Hot"
\$VeryHotTopic = $VeryHotTopic;				# Number of posts needed in a topic for it to be classed as "Very Hot"

\$barmaxdepend = $barmaxdepend;				# Set to 1 to let bar-max-length depend on top poster or 0 to depend on a number of your choise
\$barmaxnumb = $barmaxnumb;				# Select number of post for max. bar-length in memberlist
\$defaultml = $defaultml;


########## MemberPic Settings ##########

\$userpic_width = $userpic_width;			# Set pixel size to which the selfselected userpics are resized, 0 disables this limit
\$userpic_height = $userpic_height;			# Set pixel size to which the selfselected userpics are resized, 0 disables this limit


########## File Locking ##########

\$gzcomp = $gzcomp;					# GZip compression: 0 = No Compression, 1 = External gzip, 2 = Zlib::Compress
\$gzforce = $gzforce;					# Don't try to check whether browser supports GZip
\$cachebehaviour = $cachebehaviour;			# Browser Cache Control: 0 = No Cache must revalidate, 1 = Allow Caching
\$use_flock = $use_flock;				# Set to 0 if your server doesn't support file locking,
							# 1 for Unix/Linux and WinNT, and 2 for Windows 95/98/ME

\$faketruncation = $faketruncation;			# Enable this option only if YaBB fails with the error:
							# "truncate() function not supported on this platform."
							# 0 to disable, 1 to enable.

\$debug = $debug;					# If set to 1 debug info is added to the template
							# tags are <yabb fileactions> and <yabb filenames>
1;
EOF

	$setfile =~ s~(.+\;)\s+(\#.+$)~$1 . substr( $filler, 0, (70-(length $1)) ) . $2 ~gem;
	$setfile =~ s~(.{64,}\;)\s+(\#.+$)~$1 . "\n   " . $2~gem;
	$setfile =~ s~^\s\s\s+(\#.+$)~substr( $filler, 0, 70 ) . $1~gem;

	fopen(SETTING, ">$vardir/Settings.pl");
	print SETTING $setfile;
	fclose(SETTING);

	&WriteLog;
	$yySetLocation = qq~$adminurl~;
	&redirectexit;
}

sub EditPaths {

	# Simple output of env variables, for troubleshooting
	if ($ENV{'SCRIPT_FILENAME'} ne "") {
		$support_env_path = $ENV{'SCRIPT_FILENAME'};

		# replace \'s with /'s for Windows Servers
		$support_env_path =~ s~\\~/~g;

		# Remove Setupl.pl and cgi - and also nph- for buggy IIS.
		$support_env_path =~ s~(nph-)?AdminIndex.(pl|cgi)~~ig;
	} elsif ($ENV{'PATH_TRANSLATED'} ne "") {
		$support_env_path = $ENV{'PATH_TRANSLATED'};

		# replace \'s with /'s for Windows Servers
		$support_env_path =~ s~\\~/~g;

		# Remove Setupl.pl and cgi - and also nph- for buggy IIS.
		$support_env_path =~ s~(nph-)?AdminIndex.(pl|cgi)~~ig;
	}

	$yymain .= qq~
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg">
		<b>$edit_paths_txt{'33'}</b>
	   </td>
     </tr>
     <tr align="center" valign="middle">
       <td align="left" class="catbg"><span class="small">$edit_paths_txt{'34'}</span>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">
			<br />
		  $support_env_path
			<br />
			<br />
	   </td>
     </tr>
	</table>
  </div>

<br />
<br />

<form action="$adminurl?action=editpaths2" method="POST">
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg">
		<img src="$imagesdir/preferences.gif" alt="" border="0" />
&nbsp;<b>$edit_paths_txt{'1'}</b>
	   </td>
     </tr>
     <tr align="center" valign="middle">
       <td align="left" class="catbg"><span class="small">$edit_paths_txt{'2'}</span>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
		<div class="setting_cell">
			$edit_paths_txt{'3'}
		</div>
		<div class="setting_cell2">
			<input type="text" name="boardurl" size="40" value="$boardurl" />
		</div>
		<br />
		<div class="setting_cell">
			$edit_paths_txt{'4'}
		</div>
		<div class="setting_cell2">
			<input type="text" name="boarddir" size="40" value="$boarddir" />
		</div>
		<br />
		<div class="setting_cell">
			$edit_paths_txt{'5'}
		</div>
		<div class="setting_cell2">
			<input type="text" name="boardsdir" size="40" value="$boardsdir" />
		</div>
		<br />
		<div class="setting_cell">
			$edit_paths_txt{'6'}
		</div>
		<div class="setting_cell2">
			<input type="text" name="datadir" size="40" value="$datadir" />
		</div>
		<br />
		<div class="setting_cell">
			$edit_paths_txt{'7'}
		</div>
		<div class="setting_cell2">
			<input type="text" name="memberdir" size="40" value="$memberdir" />
		</div>
		<br />
		<div class="setting_cell">
			$edit_paths_txt{'8'}
		</div>
		<div class="setting_cell2">
			<input type="text" name="sourcedir" size="40" value="$sourcedir" />
		</div>
		<br />
		<div class="setting_cell">
			$edit_paths_txt{'9'}
		</div>
		<div class="setting_cell2">
			<input type="text" name="admindir" size="40" value="$admindir" />
		</div>
		<br />
		<div class="setting_cell">
			$edit_paths_txt{'10'}
		</div>
		<div class="setting_cell2">
			<input type="text" name="vardir" size="40" value="$vardir" />
		</div>
		<br />
		<div class="setting_cell">
			$edit_paths_txt{'11'}
		</div>
		<div class="setting_cell2">
			<input type="text" name="langdir" size="40" value="$langdir" />
		</div>
		<br />
		<div class="setting_cell">
			$edit_paths_txt{'12'}
		</div>
		<div class="setting_cell2">
			<input type="text" name="helpfile" size="40" value="$helpfile" />
		</div>
		<br />
		<div class="setting_cell">
			$edit_paths_txt{'13'}
		</div>
		<div class="setting_cell2">
			<input type="text" name="templatesdir" size="40" value="$templatesdir" />
		</div>
		<br />
		<div class="setting_cell">
			$edit_paths_txt{'14'}
		</div>
		<div class="setting_cell2">
			<input type="text" name="forumstylesdir" size="40" value="$forumstylesdir" />
		</div>
		<br />
		<div class="setting_cell">
			$edit_paths_txt{'15'}
		</div>
		<div class="setting_cell2">
			<input type="text" name="adminstylesdir" size="40" value="$adminstylesdir" />
		</div>
		<br />
		<div class="setting_cell">
			$edit_paths_txt{'16'}
		</div>
		<div class="setting_cell2">
			<input type="text" name="htmldir" size="40" value="$htmldir" />
		</div>
		<br />
		<div class="setting_cell">
			$edit_paths_txt{'17'}
		</div>
		<div class="setting_cell2">
			<input type="text" name="facesdir" size="40" value="$facesdir" />
		</div>
		<br />
		<div class="setting_cell">
			$edit_paths_txt{'18'}
		</div>
		<div class="setting_cell2">
			<input type="text" name="smiliesdir" size="40" value="$smiliesdir" />
		</div>
		<br />
		<div class="setting_cell">
			$edit_paths_txt{'19'}
		</div>
		<div class="setting_cell2">
			<input type="text" name="modimgdir" size="40" value="$modimgdir" />
		</div>
		<br />
		<div class="setting_cell">
			$edit_paths_txt{'20'}
		</div>
		<div class="setting_cell2">
			<input type="text" name="uploaddir" size="40" value="$uploaddir" />
		</div>
		<br />

	   </td>
     </tr>
     <tr align="center" valign="middle">
       <td align="left" class="catbg"><span class="small">$edit_paths_txt{'21'}</span>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />

		<div class="setting_cell">
			$edit_paths_txt{'22'}
		</div>
		<div class="setting_cell2">
			<input type="text" name="forumstylesurl" size="40" value="$forumstylesurl" />
		</div>
		<br />
		<div class="setting_cell">
			$edit_paths_txt{'23'}
		</div>
		<div class="setting_cell2">
			<input type="text" name="adminstylesurl" size="40" value="$adminstylesurl" />
		</div>
		<br />
		<div class="setting_cell">
			$edit_paths_txt{'24'}
		</div>
		<div class="setting_cell2">
			<input type="text" name="ubbcjspath" size="40" value="$ubbcjspath" />
		</div>
		<br />
		<div class="setting_cell">
			$edit_paths_txt{'25'}
		</div>
		<div class="setting_cell2">
			<input type="text" name="faderpath" size="40" value="$faderpath" />
		</div>
		<br />
		<div class="setting_cell">
			$edit_paths_txt{'26'}
		</div>
		<div class="setting_cell2">
			<input type="text" name="yabbcjspath" size="40" value="$yabbcjspath" />
		</div>
		<br />
		<div class="setting_cell">
			$edit_paths_txt{'27'}
		</div>
		<div class="setting_cell2">
			<input type="text" name="postjspath" size="40" value="$postjspath" />
		</div>
		<br />
		<div class="setting_cell">
			$edit_paths_txt{'28'}
		</div>
		<div class="setting_cell2">
			<input type="text" name="html_root" size="40" value="$html_root" />
		</div>
		<br />
		<div class="setting_cell">
			$edit_paths_txt{'29'}
		</div>
		<div class="setting_cell2">
			<input type="text" name="facesurl" size="40" value="$facesurl" />
		</div>
		<br />
		<div class="setting_cell">
			$edit_paths_txt{'30'}
		</div>
		<div class="setting_cell2">
			<input type="text" name="smiliesurl" size="40" value="$smiliesurl" />
		</div>
		<br />
		<div class="setting_cell">
			$edit_paths_txt{'31'}
		</div>
		<div class="setting_cell2">
			<input type="text" name="modimgurl" size="40" value="$modimgurl" />
		</div>
		<br />
		<div class="setting_cell">
			$edit_paths_txt{'32'}
		</div>
		<div class="setting_cell2">
			<input type="text" name="uploadurl" size="40" value="$uploadurl" />
		</div>
		<br />
	   </td>
     </tr>
     <tr valign="middle">
       <td align="center" class="catbg">
		 <input type="hidden" name="lastsaved" value="$realname">
		 <input type="hidden" name="lastdate" value="$date">
		 <input type="submit" value="$admin_txt{'10'}" />
	   </td>
     </tr>
   </table>

	   </td>
     </tr>
   </table>
 </div>
</form>
~;

	$action_area = "editpaths";
	&AdminTemplate;

}

sub EditPaths2 {

	&LoadCookie;          # Load the user's cookie (or set to guest)
	&LoadUserSettings;
	if (!$iamadmin) { &admin_fatal_error("$maintxt{'1'}"); }

	$lastsaved      = $FORM{'lastsaved'};
	$lastdate       = $FORM{'lastdate'};
	$boardurl       = $FORM{'boardurl'};
	$boarddir       = $FORM{'boarddir'};
	$htmldir        = $FORM{'htmldir'};
	$uploaddir      = $FORM{'uploaddir'};
	$uploadurl      = $FORM{'uploadurl'};
	$html_root      = $FORM{'html_root'};
	$datadir        = $FORM{'datadir'};
	$boardsdir      = $FORM{'boardsdir'};
	$memberdir      = $FORM{'memberdir'};
	$sourcedir      = $FORM{'sourcedir'};
	$admindir       = $FORM{'admindir'};
	$vardir         = $FORM{'vardir'};
	$langdir        = $FORM{'langdir'};
	$helpfile       = $FORM{'helpfile'};
	$templatesdir   = $FORM{'templatesdir'};
	$forumstylesdir = $FORM{'forumstylesdir'};
	$forumstylesurl = $FORM{'forumstylesurl'};
	$adminstylesdir = $FORM{'adminstylesdir'};
	$adminstylesurl = $FORM{'adminstylesurl'};
	$facesdir       = $FORM{'facesdir'};
	$facesurl       = $FORM{'facesurl'};
	$smiliesdir     = $FORM{'smiliesdir'};
	$smiliesurl     = $FORM{'smiliesurl'};
	$modimgdir      = $FORM{'modimgdir'};
	$modimgurl      = $FORM{'modimgurl'};
	$ubbcjspath     = $FORM{'ubbcjspath'};
	$faderpath      = $FORM{'faderpath'};
	$yabbcjspath    = $FORM{'yabbcjspath'};
	$postjspath     = $FORM{'postjspath'};

	my $filler  = q~                                                                               ~;
	my $setfile = << "EOF";
###############################################################################
# Paths.pl                                                                    #
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
###############################################################################

\$lastsaved = "$lastsaved";
\$lastdate = "$lastdate";

########## Directories ##########

\$boardurl = "$boardurl";                              		# URL of your board's folder (without trailing '/')
\$boarddir = "$boarddir";                                       # The server path to the board's folder (usually can be left as '.')
\$boardsdir = "$boardsdir";                                     # Directory with board data files
\$datadir = "$datadir";                                         # Directory with messages
\$memberdir = "$memberdir";                                     # Directory with member files
\$sourcedir = "$sourcedir";                                     # Directory with YaBB source files
\$admindir = "$admindir";                                       # Directory with YaBB admin source files
\$vardir = "$vardir";                                           # Directory with variable files
\$langdir = "$langdir";                                         # Directory with Language files and folders
\$helpfile = "$helpfile";									# Directory with Help files and folders
\$templatesdir = "$templatesdir";                               # Directory with template files and folders
\$forumstylesdir = "$forumstylesdir";                               # Directory with forum style files and folders
\$adminstylesdir = "$adminstylesdir";                               # Directory with admin style files and folders
\$htmldir = "$htmldir";                              		# Base Path for all html/css files and folders
\$facesdir = "$facesdir";                              		# Base Path for all avatar files
\$smiliesdir = "$smiliesdir";                              	# Base Path for all smilie files
\$modimgdir = "$modimgdir";                              	# Base Path for all mod images
\$uploaddir = "$uploaddir";                              	# Base Path for all attachment files

########## URL's ##########

\$forumstylesurl = "$forumstylesurl";			  	# Default Forum Style Directory
\$adminstylesurl = "$adminstylesurl";			  	# Default Admin Style Directory
\$ubbcjspath = "$ubbcjspath";			  		# Default Location for the ubbc.js file
\$faderpath = "$faderpath";			  		# Default Location for the fader.js file
\$yabbcjspath = "$yabbcjspath";			 	# Default Location for the yabbc.js file
\$postjspath = "$postjspath";			  		# Default Location for the post.js file
\$html_root = "$html_root";                            		# Base URL for all html/css files and folders
\$facesurl = "$facesurl";                              		# Base URL for all avatar files
\$smiliesurl = "$smiliesurl";                            	# Base URL for all smilie files
\$modimgurl = "$modimgurl";                            	# Base URL for all mod images
\$uploadurl = "$uploadurl";        	                    	# Base URL for all attachment files

1;
EOF

	$setfile =~ s~(.+\;)\s+(\#.+$)~$1 . substr( $filler, 0, (70-(length $1)) ) . $2 ~gem;
	$setfile =~ s~(.{64,}\;)\s+(\#.+$)~$1 . "\n   " . $2~gem;
	$setfile =~ s~^\s\s\s+(\#.+$)~substr( $filler, 0, 70 ) . $1~gem;

	fopen(FILE, ">Paths.pl");
	print FILE $setfile;
	fclose(FILE);

	$yySetLocation = qq~$adminurl~;
	&redirectexit;
}

1;
