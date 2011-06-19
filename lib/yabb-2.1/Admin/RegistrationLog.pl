###############################################################################
# RegistrationLog.pl                                                          #
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

$registrationlogplver = 'YaBB 2.1 $Revision: 1.2 $';
if ($action eq 'detailedversion') { return 1; }

LoadLanguage("Register");

sub view_reglog {
	&is_admin_or_gmod;
	$yytitle = "$prereg_txt{'15a'}";
	if (-e "$vardir/registration.log") {
		fopen(LOGFILE, "$vardir/registration.log");
		@logentries = <LOGFILE>;
		fclose(LOGFILE);
		@logentries = reverse @logentries;
		fopen(FILE, "$memberdir/memberlist.txt");
		@memberlist = <FILE>;
		fclose(FILE);
		# If a pre-registration list exists load it
		if (-e "$memberdir/memberlist.inactive") {
			fopen(INACT, "$memberdir/memberlist.inactive");
			@reglist = <INACT>;
			fclose(INACT);
		}
		# grab pre regged user activationkey for admin activation
		foreach $regline (@reglist) {
			chomp $regline;
			($dummy, $actcode, $regmember, $dummy) = split(/\|/, $regline);
			$actkey{$regmember} = $actcode;
		}
	} else {
		$servertime = $date;
		push(@logentries, "$servertime|LD|admin");
	}
	@memberlist = reverse @memberlist;
	foreach $logentry (@logentries) {
		($logtime, $status, $userid) = split(/\|/, $logentry);
		chomp $userid;
		$is_member  = &check_member($userid);
		$reclogtime = &timeformat($logtime);
		if ($status eq "N" && $is_member == 0 && $actkey{$userid} ne "") { 
			$delrecord = qq~<a href="$adminurl?action=del_regentry;userid=$userid;">$prereg_txt{'16'}</a>~; 
			$delrecord .= qq~<br /><a href="$scripturl?action=activate;username=$userid;activationkey=$actkey{$userid};">$prereg_txt{'16a'}</a>~; 
		} else { 
			$delrecord = ""; 
		}
		$loglist .= qq~
		<tr>
		<td class="windowbg" width="30%" align="center">$reclogtime</td>
		<td class="windowbg2" width="30%" align="center">$prereg_txt{$status}</td>
		<td class="windowbg" width="30%" align="center">$userid</td>
		<td class="windowbg2" width="10%" align="center">$delrecord</td>
		</tr>~;
	}

	$yymain .= qq~
	<script language="JavaScript1.2" src="$ubbcjspath" type="text/javascript"></script>
	<form name="reglog_form" action="$adminurl?action=clean_reglog" method="post" onsubmit="return submitproc()">
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg" colspan="4">
<img src="$imagesdir/xx.gif" alt="" border="0" /> <b>$yytitle</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2" colspan="4"><br />
		 $prereg_txt{'20'}<br /><br />
	   </td>
     </tr>
     <tr valign="middle">
       <td align="center" class="catbg" width="30%">
		 <b>$prereg_txt{'17'}</b>
	   </td>
       <td align="center" class="catbg" width="30%">
		 <b>$prereg_txt{'18'}</b>
	   </td>
       <td align="center" class="catbg" width="30%">
		 <b>$prereg_txt{'19'}</b>
	   </td>
       <td align="center" class="catbg" width="10%">
		 <b>$prereg_txt{'16'}</b>
	   </td>
     </tr>
	$loglist
   </table>
 </div>

<br />
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="center" class="catbg">
		 <input type="submit" value="$prereg_txt{'9'}" onclick="return confirm('$prereg_txt{'8'}')" />
	   </td>
     </tr>
   </table>
 </div>

</form>
~;
	$action_area = "view_reglog";
	&AdminTemplate;
	exit;
}

sub check_member {
	my $is_member = 0;
	foreach $lstmember (@memberlist) {
		chomp $lstmember;
		($listmember, undef) = split(/\t/, $lstmember, 2);
		if ($_[0] eq $listmember) {
			$is_member = 1;
			last;
		}
	}
	return $is_member;
}

sub clean_reglog {
	&is_admin_or_gmod;
	if (-e ("$vardir/registration.log")) { unlink("$vardir/registration.log") || die "$!" }
	$yySetLocation = qq~$adminurl?action=view_reglog~;
	&redirectexit;
}

sub kill_registration {
	&is_admin_or_gmod;
	$changed = 0;
	$timer   = $date;
	$deluser = $INFO{'userid'};
	fopen(INFILE, "$memberdir/memberlist.inactive");
	@actlist = <INFILE>;
	fclose(INFILE);

	# check if user is in pre-registration and check activation key
	foreach $regline (@actlist) {
		($regtime, $dummy, $regmember, $dummy) = split(/\|/, $regline);
		if ($deluser eq $regmember) {
			$changed = 1;
			unlink "$memberdir/$regmember.pre";

			# add entry to registration log
			fopen(REG, ">>$vardir/registration.log", 1);
			print REG "$timer|D|$regmember\n";
			fclose(REG);
		} else {
			# update non activate user list
			# write valid registration to the list again
			push(@outlist, $regline);
		}
	}
	if ($changed) {

		# re-open inactive list for update if changed
		fopen(OUTFILE, ">$memberdir/memberlist.inactive", 1);
		print OUTFILE @outlist;
		fclose(OUTFILE);
	}
	$yySetLocation = qq~$adminurl?action=view_reglog~;
	&redirectexit;
}

1;
