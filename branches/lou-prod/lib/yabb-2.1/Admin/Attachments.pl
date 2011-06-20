###############################################################################
# Attachments.pl							                                  #
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

$attachmentsplver = 'YaBB 2.1 $Revision: 1.1 $';
if ($action eq 'detailedversion') { return 1; }

sub Attachments {
	&is_admin_or_gmod;
	my (@attachments, $remaining_space, $totalattachnum, $spaceleft, $fsize);
	fopen(AMS, "$vardir/attachments.txt");
	@attachments = <AMS>;
	fclose(AMS);
	$totalattachnum = @attachments;
	foreach $line (@attachments) {
		chomp $line;
		my ($dummy, $dummy, $dummy, $dummy, $dummy, $fsize, $dummy, $dummy) = split(/\|/, $line);
		$attachment_space += $fsize;
	}
	if (!$attachment_space) { $attachment_space = 0; }
	if ($dirlimit != 0) {
		$spaceleft       = ($dirlimit - $attachment_space);
		$remaining_space = "$spaceleft KB";
	} else {
		$remaining_space = "$fatxt{'23'}";
	}
	fopen(FILE, "$vardir/oldestattach.txt");
	$maxdaysattach = <FILE>;
	fclose(FILE);
	fopen(FILE, "$vardir/maxattachsize.txt");
	$maxsizeattach = <FILE>;
	fclose(FILE);
	$yymain .= qq~
<table border="0" width="70%" cellspacing="1" cellpadding="3" class="bordercolor" align="center">
<tr>
<td class="titlebg">
<img src="$imagesdir/xx.gif" alt="" />
<b>$fatxt{'24'}</b></td>
</tr><tr>
<td class="windowbg"><br /><span class="small">$fatxt{'25'}</span><br /><br /></td>
</tr><tr>
<td width="460" class="catbg"><b>$fatxt{'26'}<b></td>
</tr><tr>
<td class="windowbg" height="21">
<b>$fatxt{'27'}</b><br /></td>
</tr><tr>
<td class="windowbg2">
<table border="0" cellpadding="3" cellspacing="0"><tr>
<td><span class="small"><b>$fatxt{'28'}</b></span></td>
<td><span class="small">$totalattachnum</span></td>
</tr><tr>
<td><span class="small"><b>$fatxt{'29'}</b></span></td>
<td><span class="small">$attachment_space KB</span><br /></td>
</tr><tr>
<td><span class="small"><b>$fatxt{'30'}</b></span></td>
<td><span class="small">$remaining_space</span></td>
</tr>
</table><br />
</td>
</tr><tr>
<td class="windowbg" height="21">
<b>$fatxt{'31'}</b><br /></td>
</tr><tr>
<td class="windowbg2">
<table border="0" cellpadding="3" cellspacing="0">
<tr>
<form action="$adminurl?action=removeoldattachments" method="POST">
<td><span class="small">$fatxt{'32'}</span></td>
<td><span class="small"><input type="text" name="maxdaysattach" size="2" value="$maxdaysattach" /> $fatxt{'58'}&nbsp;</span></td>
<td><input type="submit" value="$admin_txt{'32'}" /></td>
</form>
</tr><tr>
<form action="$adminurl?action=removebigattachments" method="POST">
<td><span class="small">$fatxt{'33'}</span></td>
<td><span class="small"><input type="text" name="maxsizeattach" size="2" value="$maxsizeattach" /> KB&nbsp;</span></td>
<td><input type="submit" value="$admin_txt{'32'}" /></td>
</form>
</tr><tr>
<td colspan="3"><span class="small" style="font-weight: bold;"><a href="$adminurl?action=manageattachments2">$fatxt{'31a'}</a></span></td>
</tr>
</table>
</td>
</tr>
</table>
~;
	$yytitle     = "$fatxt{'36'}";
	$action_area = "manageattachments";
	&AdminTemplate;
	exit;
}

sub RemoveOldAttachments {
	&is_admin_or_gmod;
	fopen(FILE, ">$vardir/oldestattach.txt");
	print FILE "$FORM{'maxdaysattach'}";
	fclose(FILE);
	$date2 = $date;
	fopen(FILE, "$vardir/attachments.txt");
	@attachments = <FILE>;
	fclose(FILE);

	if (1 > @attachments) {
		$yymain .= qq~<center><b><i>$fatxt{'48'}</i></b></center>~;
	} else {
		fopen(FILE, ">$vardir/attachments.txt");
		for ($a = 0; $a < @attachments; $a++) {
			my ($dummy, $dummy, $dummy, $dummy, $dummy, $dummy, $tmpdate, $fn) = split(/\|/, $attachments[$a]);
			chomp $fn;
			$date1 = $tmpdate;
			&calcdifference;
			if ($result <= $FORM{'maxdaysattach'}) {

				# If the attachment is not too old
				print FILE $attachments[$a];
				$yymain .= qq~ $fn = $result $admin_txt{'122'}<br /> ~;
			} else {
				$yymain .= qq~ $fn = $result $admin_txt{'122'} ($admin_txt{'123'})<br /> ~;
				if (-e ("$uploaddir/$fn")) {
					unlink("$uploaddir/$fn");
				}
			}
		}
	}
	fclose(FILE);
	$yytitle     = "$fatxt{'34'} $FORM{'maxdaysattach'}";
	$action_area = "removeoldattachments";
	&AdminTemplate;
	exit;
}

sub RemoveBigAttachments {
	&is_admin_or_gmod;
	fopen(FILE, ">$vardir/maxattachsize.txt");
	print FILE "$FORM{'maxsizeattach'}";
	fclose(FILE);
	fopen(FILE, "$vardir/attachments.txt");
	@attachments = <FILE>;
	fclose(FILE);
	fopen(FILE, ">$vardir/attachments.txt");

	if (1 > @attachments) {
		$yymain .= qq~<center><b><i>$fatxt{'48'}</i></b></center>~;
	} else {
		for ($a = 0; $a < @attachments; $a++) {
			my ($dummy, $dummy, $dummy, $dummy, $dummy, $size, $dummy, $fn) = split(/\|/, $attachments[$a]);
			chomp $fn;
			if ($size <= $FORM{'maxsizeattach'}) {

				# If the attachment is not too big
				print FILE $attachments[$a];
				$yymain .= qq~ $fn = $size KB<br /> ~;
			} else {
				$yymain .= qq~ $fn = $size KB ($admin_txt{'123'})<br /> ~;
				if (-e ("$uploaddir/$fn")) {
					unlink("$uploaddir/$fn");
				}
			}
		}
	}
	fclose(FILE);
	$yytitle     = "$fatxt{'35'} $FORM{'maxsizeattach'} KB";
	$action_area = "removebigattachments";
	&AdminTemplate;
	exit;
}

sub Attachments2 {
	&is_admin_or_gmod;
	fopen(AML, "$vardir/attachments.txt");
	my @attachments = <AML>;
	$delnum = 1;
	fclose(AML);
	if (1 > @attachments) {
		$viewattachments .= qq~<tr><td class="windowbg2" colspan="6"><center><b><i>$fatxt{'48'}</i></b></center></td></tr>~;
	} else {
		$viewattachments .= qq~

		<script language="JavaScript1.2" type="text/javascript">
		<!-- Begin
			function checkAll() {
  				for (var i = 0; i < document.del_attachments.elements.length; i++) {
					document.del_attachments.elements[i].checked = true;
	  			}
			}
			function uncheckAll() {
  				for (var i = 0; i < document.del_attachments.elements.length; i++) {
					document.del_attachments.elements[i].checked = false;
	  			}
			}
		//-->
		</script>

		<form name="del_attachments" action="$adminurl?action=deleteattachment" method="POST" style="display: inline">
		~;
		foreach $row (@attachments) {
			chomp $row;
			my ($amthreadid, $amreplies, $amthreadsub, $amposter, $amcurrentboard, $amkb, $amdate, $amfn) = split(/\|/, $row);
			$amdate = &timeformat($amdate);
			if (length($amthreadsub) > 20) { $amthreadsub = substr($amthreadsub, 0, 20) . "..."; }
			$viewattachments .= qq~
		<tr>
		<td class="windowbg2" align="left" valign="middle"><a href="$uploadurl/$amfn" target="blank"> $amfn</a></td>
		<td class="windowbg2" align="left" valign="middle"> $amkb KB</td>
		<td class="windowbg2" align="left" valign="middle"> $amposter</td>
		<td class="windowbg2" align="left" valign="middle"> $amdate</td>
		<td class="windowbg2" align="left" valign="middle"><a href="$scripturl?num=$amthreadid/$amreplies#$amreplies" target="blank"> $amthreadsub</a></td>
		<td class="windowbg2" align="center" valign="middle"><input type="checkbox" name="delattach$delnum" value="$amfn" /></td>
		</tr>\n~;
			$delnum++;
		}
		$viewattachments .= qq~
		<tr>
		<td class="catbg" colspan="5" align="right">
		<input type="hidden" name="delnum" value="$delnum" />
		<input type="submit" value="Go" /><span class="small">&nbsp; Check all: &nbsp;</span>
		</td>
		<td class="catbg" align="center">
		<input type="checkbox" name="checkall" value="" onclick="if (this.checked) checkAll(); else uncheckAll();" />
		</td>
		</tr>
		</form>
		~;
	}
	$yymain .= qq~
<table border="0" cellspacing="1" cellpadding="3" class="bordercolor" align="center" width="90%">
<tr>
<td class="titlebg" colspan="6">
<img src="$imagesdir/xx.gif" alt="" border="0" />&nbsp;<b>$fatxt{'39'}</b>
</td>
</tr><tr>
<td class="windowbg" colspan="6">
<br />
<span class="small">$fatxt{'38'}</span>
<br /><br />
</td>
</tr><tr>
<td class="titlebg" colspan="6" align="center" width="100%">
<b>$fatxt{'55'}</b>
</td>
</tr><tr>
<td class="catbg" align="center"><b>$fatxt{'40'}</b></td>
<td class="catbg" align="center"><b>$fatxt{'41'}</b></td>
<td class="catbg" align="center"><b>$fatxt{'42'}</b></td>
<td class="catbg" align="center"><b>$fatxt{'43'}</b></td>
<td class="catbg" align="center"><b>$fatxt{'44'}</b></td>
<td class="catbg" align="center"><b>$fatxt{'45'}</b></td>
</tr>
$viewattachments
</table>
~;
	$yytitle     = "$fatxt{'37'}";
	$action_area = "manageattachments";
	&AdminTemplate;
	exit;
}

sub DeleteAttachments {
	&is_admin_or_gmod;
	my $delnumb = $FORM{"delnum"};
	fopen(AML, "$vardir/attachments.txt");
	my @attachments = <AML>;
	fclose(AML);
	fopen(AML, ">$vardir/attachments.txt");
	foreach $file (@attachments) {
		chomp $file;
		$att_found = 0;
		my ($amthreadid, $amreplies, $amthreadsub, $amposter, $amcurrentboard, $amkb, $amdate, $amfn) = split(/\|/, $file);
		for ($i = 1; $i < $delnumb; $i++) {
			my $attachment = $FORM{"delattach$i"};
			if (exists $FORM{"delattach$i"}) {
				if ($amfn eq $attachment) { $att_found = 1; }
			}
		}
		if ($att_found) {
			unlink("$uploaddir/$amfn");
		} else {
			print AML qq~$amthreadid|$amreplies|$amthreadsub|$amposter|$amcurrentboard|$amkb|$amdate|$amfn\n~;
		}
	}
	fclose(AML);
	$yySetLocation = qq~$adminurl?action=manageattachments2~;
	&redirectexit;
}
1;
