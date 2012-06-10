###############################################################################
# AdvSettings.pl                                                              #
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

$advsettingsplver = 'YaBB 2.1 $Revision: 1.1 $';
if ($action eq 'detailedversion') { return 1; }

&LoadLanguage("Sessions");

require "$vardir/advsettings.txt";

sub AdvSettings {
	&is_admin_or_gmod;
	my ($mdadchecked, $mdglchecked, $mdmochecked);
	my ($uapchecked, $upchecked);
	my ($tsrchecked);
	my ($tlnomodflagchecked);
	my ($tlnodelflagchecked);
	my ($tllastmodflagchecked);
	my ($ol_gmod_checked, $ol_admin_checked);

	# figure out what to print
	$extlist = join(" ", @ext);
	$extlist =~ s~\s+$~~;
	$extlist =~ s~^\s+~~;
	if    ($checkext == 1)         { $checkextcheck         = ' checked="checked" '; }
	if    ($amdisplaypics == 1)    { $amdisplaypicscheck    = ' checked="checked" '; }
	if    ($allowattach == 1)      { $allowattachcheck      = ' checked="checked" '; }
	if    ($allowguestattach == 1) { $allowguestattachcheck = ' checked="checked" '; }
	if    ($overwrite == 0)        { $tmpax0                = ' selected="selected" '; }
	elsif ($overwrite == 1)        { $tmpax1                = ' selected="selected" '; }
	elsif ($overwrite == 2)        { $tmpax2                = ' selected="selected" '; }
	if    ($sessions)              { $sessionschecked       = ' checked="checked"'; }
	if    ($stealthurl)            { $stluchecked           = ' checked="checked"'; }
	if    ($referersecurity)       { $refsecchecked         = ' checked="checked"'; }
	if    ($regcheck)              { $regcheck              = ' checked="checked"'; }
	if    ($translayer)            { $transcheck            = ' checked="checked"'; }
	if    ($tlnomodflag)           { $tlnomodflagchecked    = ' checked="checked"'; }
	if    ($tlnodelflag)           { $tlnodelflagchecked    = ' checked="checked"'; }
	if    ($tllastmodflag)         { $tllastmodflagchecked  = ' checked="checked"'; }
	if    ($tsreverse)             { $tsrchecked            = ' checked="checked"'; }
	if    ($elenable)              { $elchecked             = ' checked="checked"'; }
	if    ($elrotate)              { $elrotation            = ' checked="checked"'; }
	if    ($mdadmin)               { $mdadchecked           = ' checked="checked"'; }
	if    ($adminbin)              { $adminbinchecked       = ' checked="checked"'; }
	if    ($mdglobal)              { $mdglchecked           = ' checked="checked"'; }
	if    ($mdmod)                 { $mdmochecked           = ' checked="checked"'; }
	if    ($adminview == 0)        { $am1                   = ' selected="selected"'; }
	elsif ($adminview == 1)        { $am2                   = ' selected="selected"'; }
	elsif ($adminview == 2)        { $am3                   = ' selected="selected"'; }
	elsif ($adminview == 3)        { $am4                   = ' selected="selected"'; }
	if    ($gmodview == 0)         { $gm1                   = ' selected="selected"'; }
	elsif ($gmodview == 1)         { $gm2                   = ' selected="selected"'; }
	elsif ($gmodview == 2)         { $gm3                   = ' selected="selected"'; }
	elsif ($gmodview == 3)         { $gm4                   = ' selected="selected"'; }
	if    ($modview == 0)          { $m1                    = ' selected="selected"'; }
	elsif ($modview == 1)          { $m2                    = ' selected="selected"'; }
	elsif ($modview == 2)          { $m3                    = ' selected="selected"'; }
	elsif ($modview == 3)          { $m4                    = ' selected="selected"'; }
	if    ($showallgroups)         { $showallgroupschecked  = 'checked="checked"' }
	if    (!$OnlineLogTime)        { $OnlineLogTime         = '15' }
	if    ($show_online_ip_admin)  { $ol_admin_checked      = ' checked="checked"'; }
	if    ($show_online_ip_gmod)   { $ol_gmod_checked       = ' checked="checked"'; }

	$maxpq          ||= 60;
	$maxpo          ||= 50;
	$maxpc          ||= 0;
	$numpolloptions ||= 8;
	if ($useraddpoll) { $uapchecked = ' checked="checked"' }
	if ($ubbcpolls)   { $upchecked  = ' checked="checked"' }
	if ($imspam eq "off") { $imspam = ""; }
	if ($enable_imlimit) { $senableimlimit        = 'checked="checked"' }
	if ($send_welcomeim) { $send_welcomeimchecked = 'checked="checked"' }
	if ($popup_on)       { $popup_onchecked       = 'checked="checked"' }
	$imtext    =~ s/\<br \/\>/\n/ig;
	$imtext    =~ s/\<br>/\n/ig;
	$imtext    =~ s/\&\&/\n/g;
	$imtext    =~ s/\&lt;/</g;
	$imtext    =~ s/\&gt;/>/g;
	$imsubject =~ s/\&\&/\n/g;
	$imsubject =~ s/\&lt;/</g;
	$imsubject =~ s/\&gt;/>/g;

	$yymain .= qq~
<form action="$adminurl?action=advsettings2" method="post">
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg">
		 <img src="$imagesdir/preferences.gif" alt="" border="0" /><b>$admin_txt{'223'}</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
		  $admin_txt{'347'}<br /><br />
	   </td>
     </tr>
   </table>
 </div>

<br />

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg">
		 <img src="$imagesdir/preferences.gif" alt="" border="0" /><b>$mdintxt{'5'}</b>
	   </td>
     </tr>
     <tr align="center" valign="middle">
       <td align="left" class="catbg"><span class="small">$modtxt{'1'} $modtxt{'2'}</span>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
		 <div class="setting_cell">
			$mdintxt{'1'}<br /><span class="small">$mdintxt{'2'}</span>
		 </div>
		 <div class="setting_cell2">
			<input type="checkbox" name="mdadmin" value="1"$mdadchecked />&nbsp;
			<input type="checkbox" name="mdglobal" value="1"$mdglchecked />&nbsp;
			<input type="checkbox" name="mdmod" value="1"$mdmochecked />
		 </div>
	   <br />
		 <div class="setting_cell">
			$mdintxt{'4'}
		 </div>
		 <div class="setting_cell2">
			<input type="checkbox" name="adminbin" value="1"$adminbinchecked /><br /><br />
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
		 <img src="$imagesdir/preferences.gif" alt="" border="0" /><b>$matxt{'8'}</b>
	   </td>
     </tr>
     <tr align="center" valign="middle">
       <td align="left" class="catbg"><span class="small">$modtxt{'1'} $modtxt{'2'}</span>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
		 <div class="setting_cell">
			$matxt{'5'}
		 </div>
		 <div class="setting_cell2">
			<select name="adminview" size="1">
			<option value="0"$am1>$matxt{'1'}</option>
			<option value="1"$am2>$matxt{'2'}</option>
			<option value="2"$am3>$matxt{'3'}</option>
			<option value="3"$am4>$matxt{'4'}</option>
			</select>
		 </div>
	   <br />
		 <div class="setting_cell">
			$matxt{'6'}
		 </div>
		 <div class="setting_cell2">
			<select name="gmodview" size="1">
			<option value="0"$gm1>$matxt{'1'}</option>
			<option value="1"$gm2>$matxt{'2'}</option>
			<option value="2"$gm3>$matxt{'3'}</option>
			<option value="3"$gm4>$matxt{'4'}</option>
			</select>
		 </div><br />
		 <div class="setting_cell">
			$matxt{'7'}
		 </div>
		 <div class="setting_cell2">
			<select name="modview" size="1">
			<option value="0"$m1>$matxt{'1'}</option>
			<option value="1"$m2>$matxt{'2'}</option>
			<option value="2"$m3>$matxt{'3'}</option>
			<option value="3"$m4>$matxt{'4'}</option>
			</select><br /><br />
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
		 <img src="$imagesdir/preferences.gif" alt="" border="0" /><b>$amv_txt{'18'}</b>
	   </td>
     </tr>
     <tr align="center" valign="middle">
       <td align="left" class="catbg"><span class="small">$modtxt{'1'} $modtxt{'4'}</span>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
		 <div class="setting_cell">
			$amv_txt{'12'}
		 </div>
		 <div class="setting_cell2">
			<input type="checkbox" name="showallgroups"$showallgroupschecked />
		 </div>
	   <br />
		 <div class="setting_cell">
			$amv_txt{'13'}
		 </div>
		 <div class="setting_cell2">
			<input type="text" name="OnlineLogTime" size="5" value="$OnlineLogTime" /><br /><br />
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
		 <img src="$imagesdir/preferences.gif" alt="" border="0" /><b>$polltxt{'64'}</b>
	   </td>
     </tr>
     <tr align="center" valign="middle">
       <td align="left" class="catbg"><span class="small">$modtxt{'1'} $modtxt{'4'}</span>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
		 <div class="setting_cell">
			$polltxt{'28'}
		 </div>
		 <div class="setting_cell2">
			<input type="text" name="numpolloptions" size="5" value="$numpolloptions" />
		 </div>
	   	 <br />
		 <div class="setting_cell">
			$polltxt{'61'}
		 </div>
		 <div class="setting_cell2">
			<input type="text" name="maxpq" size="5" value="$maxpq" />
		 </div>
		 <div class="setting_cell">
			$polltxt{'62'}
		 </div>
		 <div class="setting_cell2">
			<input type="text" name="maxpo" size="5" value="$maxpo" />
		 </div>
	   	 <br />
		 <div class="setting_cell">
			$polltxt{'63'}
		 </div>
		 <div class="setting_cell2">
			<input type="text" name="maxpc" size="5" value="$maxpc" />
		 </div>
	   	 <br />
		 <div class="setting_cell">
			$polltxt{'29'}
		 </div>
		 <div class="setting_cell2">
			<input type="checkbox" name="useraddpoll"$uapchecked />
		 </div>
	   	 <br />
		 <div class="setting_cell">
			$polltxt{'60'}
		 </div>
		 <div class="setting_cell2">
			<input type="checkbox" name="ubbcpolls"$upchecked /><br /><br />
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
		 <img src="$imagesdir/preferences.gif" alt="" border="0" /><b>$imtxt{'25'}</b>
	   </td>
     </tr>
     <tr align="center" valign="middle">
       <td align="left" class="catbg"><span class="small">$modtxt{'1'} $modtxt{'5'}</span>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
		 <div class="setting_cell">
			$imtxt{'75'}
		 </div>
		 <div class="setting_cell2">
			<input type="text" name="numposts" size="5" value="$numposts" />
		 </div>
	   	 <br />
		 <div class="setting_cell">
			$imtxt{'52'}
		 </div>
		 <div class="setting_cell2">
			<input type="text" name="imspam" size="5" value="$imspam" maxlength="2" />
		 </div>
		 <div class="setting_cell">
			$imtxt{'06'}
		 </div>
		 <div class="setting_cell2">
			<input type="checkbox" name="enable_imlimit" $senableimlimit />
		 </div>
	   	 <br />
		 <div class="setting_cell">
			$imtxt{'03'} $imtxt{'85'}
		 </div>
		 <div class="setting_cell2">
			<input type="text" name="numobox" size="5" value="$numobox" />
		 </div>
	   	 <br />
		 <div class="setting_cell">
			$imtxt{'03'} $imtxt{'84'}
		 </div>
		 <div class="setting_cell2">
			<input type="text" name="numibox" size="5" value="$numibox" />
		 </div>
	   	 <br />
		 <div class="setting_cell">
			$imtxt{'03'} $imtxt{'46'}
		 </div>
		 <div class="setting_cell2">
			<input type="text" name="numstore" size="5" value="$numstore" />
		 </div>
	   	 <br />
		 <div class="setting_cell">
			$imtxt{'33'}
		 </div>
		 <div class="setting_cell2">
			<input type="checkbox" name="send_welcomeim" $send_welcomeimchecked />
		 </div>
	   	 <br />
		 <div class="setting_cell">
			$imtxt{'34'}
		 </div>
		 <div class="setting_cell2">
			<input type="text" name="sendname" size="35" value="$sendname" />
		 </div>
	   	 <br />
		 <div class="setting_cell">
			$imtxt{'36'}
		 </div>
		 <div class="setting_cell2">
			<input type="text" name="imsubject" size="35" value="$imsubject" />
		 </div>
	   	 <br />
		 <div class="setting_cell">
			$imtxt{'35'}
		 </div>
		 <div class="setting_cell2">
			<textarea name="imtext" cols="35" rows="5">$imtext</textarea><br /><br />
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
		 <img src="$imagesdir/preferences.gif" alt="" border="0" /><b>$cutts{'8'}</b>
	   </td>
     </tr>
     <tr align="center" valign="middle">
       <td align="left" class="catbg"><span class="small">$modtxt{'1'} $modtxt{'2'}</span>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
		 <div class="setting_cell">
			$cutts{'7'}
		 </div>
		 <div class="setting_cell2">
			<input type="checkbox" name="tsreverse" value="1"$tsrchecked />
		 </div>
	   	 <br />
		 <div class="setting_cell">
			$cutts{'1'}
		 </div>
		 <div class="setting_cell2">
			<input type="text" name="cutamount" size="10" value="$cutamount" /><br /><br />
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
		 <img src="$imagesdir/preferences.gif" alt="" border="0" /><b>$timelocktxt{'01'}</b>
	   </td>
     </tr>
     <tr align="center" valign="middle">
       <td align="left" class="catbg"><span class="small">$modtxt{'1'} $modtxt{'3'}</span>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
		 <div class="setting_cell">
			$timelocktxt{'03'}
		 </div>
		 <div class="setting_cell2">
			<input type=checkbox name="tlnomodflag" $tlnomodflagchecked />
		 </div>
	   	 <br />
		 <div class="setting_cell">
			$timelocktxt{'04'}
		 </div>
		 <div class="setting_cell2">
			<input type=text name="tlnomodtime" size="3" value="$tlnomodtime" />
		 </div>
	   	 <br />
		 <div class="setting_cell">
			$timelocktxt{'07'}
		 </div>
		 <div class="setting_cell2">
			<input type=checkbox name="tlnodelflag" $tlnodelflagchecked />
		 </div>
	   	 <br />
		 <div class="setting_cell">
			$timelocktxt{'08'}
		 </div>
		 <div class="setting_cell2">
			<input type=text name="tlnodeltime" size="3" value="$tlnodeltime" />
		 </div>
	   	 <br />
		 <div class="setting_cell">
			$timelocktxt{'05'}
		 </div>
		 <div class="setting_cell2">
			<input type=checkbox name="tllastmodflag" $tllastmodflagchecked />
		 </div>
	   	 <br />
		 <div class="setting_cell">
			$timelocktxt{'06'}
		 </div>
		 <div class="setting_cell2">
			<input type=text name="tllastmodtime" size="3" value="$tllastmodtime" /><br /><br />
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
		 <img src="$imagesdir/preferences.gif" alt="" border="0" /><b>$fatxt{'57'}</b>
	   </td>
     </tr>
     <tr align="center" valign="middle">
       <td align="left" class="catbg"><span class="small">$modtxt{'1'} $modtxt{'6'} $modtxt{'8'} $modtxt{'3'}</span>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
		 <div class="setting_cell">
			$fatxt{'53'}
		 </div>
		 <div class="setting_cell2">
			<select name="overwrite" size="1">
			<option value="0"$tmpax0>$fatxt{'54r'}</option>
			<option value="1"$tmpax1>$fatxt{'54o'}</option>
			<option value="2"$tmpax2>$fatxt{'54n'}</option>
			</select>
		 </div>
	   	 <br />
		 <div class="setting_cell">
			$fatxt{'12'}
		 </div>
		 <div class="setting_cell2">
			<input type=text name="limit" size="5" value="$limit" />
		 </div>
	   	 <br />
		 <div class="setting_cell">
			$fatxt{'13'}
		 </div>
		 <div class="setting_cell2">
			<input type=text name="dirlimit" size="5" value="$dirlimit" />
		 </div>
	   	 <br />
		 <div class="setting_cell">
			$fatxt{'14'}
		 </div>
		 <div class="setting_cell2">
			<input type=text name="extensions" size="35" value="$extlist" />
		 </div>
	   	 <br />
		 <div class="setting_cell">
			$fatxt{'15'}
		 </div>
		 <div class="setting_cell2">
			<input type=checkbox name="checkext" value="1"$checkextcheck />
		 </div>
	   	 <br />
		 <div class="setting_cell">
			$fatxt{'16'}
		 </div>
		 <div class="setting_cell2">
			<input type=checkbox name="amdisplaypics" value="1"$amdisplaypicscheck />
		 </div>
	   	 <br />
		 <div class="setting_cell">
			$fatxt{'17'}
		 </div>
		 <div class="setting_cell2">
			<input type=checkbox name="allowattach" value="1"$allowattachcheck />
		 </div>
	   	 <br />
		 <div class="setting_cell">
			$fatxt{'18'}
		 </div>
		 <div class="setting_cell2">
			<input type=checkbox name="allowguestattach" value="1"$allowguestattachcheck /><br /><br />
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
		 <img src="$imagesdir/preferences.gif" alt="" border="0" /><b>$errorlog{'25'}</b>
	   </td>
     </tr>
     <tr align="center" valign="middle">
       <td align="left" class="catbg"><span class="small">$modtxt{'1'} $modtxt{'7'}</span>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
		 <div class="setting_cell">
			$errorlog{'22'}
		 </div>
		 <div class="setting_cell2">
			<input type="checkbox" name="elenable" value="1"$elchecked />
		 </div>
	   	 <br />
		 <div class="setting_cell">
			$errorlog{'23'}
		 </div>
		 <div class="setting_cell2">
			<input type="checkbox" name="elrotate" value="1"$elrotation />
		 </div>
	   	 <br />
		 <div class="setting_cell">
			$errorlog{'24'}
		 </div>
		 <div class="setting_cell2">
			<input type="text" name="elmax" size="4" value="$elmax" /><br /><br />
		 </div>
	   </td>
     </tr>
   </table>
 </div>

<br />

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="center" class="catbg">
		 <input type="submit" value="$admin_txt{'10'}" />
	   </td>
     </tr>
   </table>
 </div>
</form>
~;
	$yytitle     = $admin_txt{'222'};
	$action_area = "advsettings";
	&AdminTemplate;
	exit;
}

sub AdvSettings2 {
	&is_admin_or_gmod;

	my @onoff = qw/tlnomodflag tlnodelflag tllastmodflag mdadmin mdglobal mdmod useraddpoll ubbcpolls pollcomments enable_imlimit numibox numobox send_welcomeim enable_rim numposts tsreverse elenable elrotate/;

	# Set as 0 or 1 if box was checked or not
	my $fi;
	map { $fi = lc $_; ${$_} = $FORM{$fi} eq 'on' ? 1 : 0; } @onoff;
	$guestaccess   = $guestaccess           ? 0 : 1;
	$showallgroups = $FORM{'showallgroups'} ? 1 : 0;

	# If empty fields are submitted, set them to default-values to save yabb from crashing
	$overwrite = $FORM{'overwrite'} || 0;
	$extensions = $FORM{'extensions'};
	$extensions =~ s~\s+$~~;
	$limit = $FORM{'limit'} || 0;
	$limit =~ s~[^\d]~~g;
	$dirlimit = $FORM{'dirlimit'} || 0;
	$dirlimit =~ s~[^\d]~~g;
	$checkext         = $FORM{'checkext'}         || 0;
	$amdisplaypics    = $FORM{'amdisplaypics'}    || 0;
	$allowattach      = $FORM{'allowattach'}      || 0;
	$allowguestattach = $FORM{'allowguestattach'} || 0;
	$mdadmin          = $FORM{'mdadmin'}          || 0;
	$mdglobal         = $FORM{'mdglobal'}         || 0;
	$mdmod            = $FORM{'mdmod'}            || 0;
	$adminbin         = $FORM{'adminbin'}         || 0;
	$adminview        = $FORM{'adminview'}        || 0;
	$gmodview         = $FORM{'gmodview'}         || 0;
	$modview          = $FORM{'modview'}          || 0;
	$OnlineLogTime    = $FORM{'OnlineLogTime'}    || 15;
	$OnlineLogTime =~ s~[^\d]~~g;
	if ($OnlineLogTime >= 1440) { $OnlineLogTime = 1439; }
	$numpolloptions = $FORM{'numpolloptions'} || 8;
	$numpolloptions =~ s~[^\d]~~g;
	$maxpq = $FORM{'maxpq'} || 60;
	$maxpq =~ s~[^\d]~~g;
	$maxpo = $FORM{'maxpo'} || 50;
	$maxpo =~ s~[^\d]~~g;
	$maxpc = $FORM{'maxpc'} || 0;
	$maxpc =~ s~[^\d]~~g;
	$numposts = $FORM{'numposts'} || 0;
	$numposts =~ s~[^\d]~~g;
	$numibox = $FORM{'numibox'} || 20;
	$numibox =~ s~[^\d]~~g;
	$numobox = $FORM{'numobox'} || 20;
	$numobox =~ s~[^\d]~~g;
	$numstore = $FORM{'numstore'} || 20;
	$numstore =~ s~[^\d]~~g;
	$sendname  = $FORM{'sendname'}  || admin;
	$imspam    = $FORM{'imspam'}    || off;
	$tsreverse = $FORM{'tsreverse'} || 0;
	$cutamount = $FORM{'cutamount'} || 15;
	$cutamount =~ s~[^\d]~~g;
	$elenable = $FORM{'elenable'} || 0;
	$elrotate = $FORM{'elrotate'} || 0;
	$elmax    = $FORM{'elmax'}    || 50;
	$elmax          =~ s~[^\d]~~g;
	$FORM{'imtext'} =~ s~\n~\<br \/\>~g;
	$imtext = $FORM{'imtext'} || "Welcome in our community";
	$imtext =~ s~\A\s+~~;
	$imtext =~ s~\s+\Z~~;
	$imtext =~ s~[\n\r]~~g;
	$imtext =~ s~"~\\"~g;
	$imtext =~ s~@~\\@~g;
	$imsubject = $FORM{'imsubject'} || "Welcome to $mbname";
	$imsubject =~ s~"~\\"~g;
	$imsubject =~ s~[\n\r]~~g;
	$imsubject =~ s~\<BR\>~~gi;
	$imsubject =~ s~\A\s+~~;
	$imsubject =~ s~\s+\Z~~;
	$tlnomodtime = $FORM{'tlnomodtime'} || "0";
	$tlnomodtime =~ s~[^\d]~~g;
	$tlnodeltime = $FORM{'tlnodeltime'} || "0";
	$tlnodeltime =~ s~[^\d]~~g;
	$tllastmodtime = $FORM{'tllastmodtime'} || "0";
	$tllastmodtime =~ s~[^\d]~~g;

	my $filler  = q~                                                                               ~;
	my $setfile = << "EOF";
###############################################################################
# AdvSettings.txt                                                             #
###############################################################################

use utf8;

########## In-Thread Multi Delete ##########

\$mdadmin = $mdadmin;
\$mdglobal = $mdglobal;
\$mdmod = $mdmod;
\$adminbin = $adminbin;					# Skip recycle bin step for admins and delete directly

########## Moderation Update ##########

\$adminview = $adminview;				# Multi-admin settings for Administrators: 0=none, 1=icons 2=single checkbox 3=multiple checkboxes
\$gmodview = $gmodview;					# Multi-admin settings for Global Moderators: 0=none, 1=icons 2=single checkbox 3=multiple checkboxes
\$modview = $modview;					# Multi-admin settings for Moderators: 0=none, 1=icons 2=single checkbox 3=multiple checkboxes

########## Advanced Memberview Plus ###########

\$showallgroups = $showallgroups;
\$OnlineLogTime = $OnlineLogTime;


######### Polls ###########

\$numpolloptions = $numpolloptions;  			# Number of poll options
\$maxpq = $maxpq;  						# Maximum Allowed Characters in a Poll Qestion?
\$maxpo = $maxpo;  						# Maximum Allowed Characters in a Poll Option?
\$maxpc = $maxpc;  						# Maximum Allowed Characters in a Poll Comment?
\$useraddpoll = $useraddpoll;  				# Allow users to add polls to existing threads? (1 = yes)
\$ubbcpolls = $ubbcpolls;  					# Allow UBBC tags and smilies in polls? (1 = yes)

########## Advanced Instant Message Box ############

\$numposts = $numposts;					# Number of posts required to send Instant Messages
\$imspam = $imspam;					# Percent of Users a user is a allowed to send a message at once
\$numibox = $numibox;					# Number of maximum Messages in the IM-Inbox
\$numobox = $numobox;					# Number of maximum Messages in the IM-Outbox
\$numstore = $numstore;					# Number of maximum Messages in the Storage box
\$enable_imlimit = $enable_imlimit;			# Set to 1 to enable limitation of incoming and outgoing im messages
\$imtext = qq~$imtext~;
\$sendname = "$sendname";
\$imsubject = "$imsubject";
\$send_welcomeim = $send_welcomeim;

######### Topic Summary Cutter #############

\$cutamount  = "$cutamount";				# Number of posts to list in topic summary
\$tsreverse = $tsreverse;				# Reverse Topic Summaries (So most recent is first

############## Time Lock ###################

\$tlnomodflag = $tlnomodflag;				# Set to 1 limit time users may modify posts
\$tlnomodtime = $tlnomodtime;				# Time limit on modifying posts (days)
\$tlnodelflag = $tlnodelflag;				# Set to 1 limit time users may delete posts
\$tlnodeltime = $tlnodeltime;				# Time limit on deleting posts (days)
\$tllastmodflag = $tllastmodflag;			# Set to 1 allow users to modify posts up to the specified time limit w/o showing "last Edit" message
\$tllastmodtime = $tllastmodtime;			# Time limit to modify posts w/o triggering "last Edit" message (in minutes)

########## File Attachment Settings ##########

\$limit = $limit;  					# Set to the maximum number of kilobytes an attachment can be. Set to 0 to disable the file size check.
\$dirlimit = $dirlimit;  				# Set to the maximum number of kilobytes the attachment directory can hold. Set to 0 to disable the directory size check.
\$overwrite = $overwrite;				# Set to 0 to auto rename attachments if they exist, 1 to overwrite them or 2 to generate an error if the file exists already.
\@ext = qw($extensions);  				# The allowed file extensions for file attachements. Variable should be set in the form of "jpg bmp gif" and so on.
\$checkext = $checkext;  				# Set to 1 to enable file extension checking, set to 0 to allow all file types to be uploaded
\$amdisplaypics = $amdisplaypics;  			# Set to 1 to display attached pictures in posts, set to 0 to only show a link to them.
\$allowattach = $allowattach;				# Set to 1 to allow file attaching, set to 0 to disable file attaching.
\$allowguestattach = $allowguestattach;			# Set to 1 to allow guests to upload attachments, 0 to disable guest attachment uploading.

############# Error Logger #################

\$elmax  = "$elmax";					# Max number of log entries before rotation
\$elenable = $elenable;					# allow for error logging
\$elrotate = $elrotate;					# Allow for log rotation

1;
EOF

	$setfile =~ s~(.+\;)\s+(\#.+$)~$1 . substr( $filler, 0, (70-(length $1)) ) . $2 ~gem;
	$setfile =~ s~(.{64,}\;)\s+(\#.+$)~$1 . "\n   " . $2~gem;
	$setfile =~ s~^\s\s\s+(\#.+$)~substr( $filler, 0, 70 ) . $1~gem;

	fopen(FILE, ">$vardir/advsettings.txt");
	print FILE $setfile;
	fclose(FILE);

	$yySetLocation = qq~$adminurl~;
	&redirectexit;
}

1;
