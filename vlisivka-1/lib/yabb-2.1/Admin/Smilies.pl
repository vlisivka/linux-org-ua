###############################################################################
# Smilies.pl                                                                  #
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

$smiliesplver = 'YaBB 2.1 $Revision: 1.1 $';
if ($action eq 'detailedversion') { return 1; }

if (!-e ("$vardir/Smilies.txt")) {
	fopen(ADMIN_SMILIES, ">>$vardir/Smilies.txt");
	print ADMIN_SMILIES "1;";
	fclose(ADMIN_SMILIES);
}

require "$vardir/Smilies.txt";

sub SmiliePanel {
	&is_admin_or_gmod;
	if    ($smiliestyle eq 1) { $ss1    = " selected"; }
	elsif ($smiliestyle eq 2) { $ss2    = " selected"; }
	if    ($showadded   eq 1) { $sa1    = " selected"; }
	elsif ($showadded   eq 2) { $sa2    = " selected"; }
	elsif ($showadded   eq 3) { $sa3    = " selected"; }
	elsif ($showadded   eq 4) { $sa4    = " selected"; }
	if    ($showsmdir   eq 1) { $ssm1   = " selected"; }
	elsif ($showsmdir   eq 2) { $ssm2   = " selected"; }
	elsif ($showsmdir   eq 3) { $ssm3   = " selected"; }
	elsif ($showsmdir   eq 4) { $ssm4   = " selected"; }
	if    ($detachblock eq 1) { $dblock = " checked"; }
	opendir(DIR, "$smiliesdir");
	@contents = readdir(DIR);
	closedir(DIR);
	$smilieslist = "";

	foreach $line (sort { uc($a) cmp uc($b) } @contents) {
		($name, $extension) = split(/\./, $line);
		if ($extension =~ /gif/i || $extension =~ /jpg/i || $extension =~ /jpeg/i || $extension =~ /png/i) {
			if ($line !~ /banner/i) {
				$smilieslist .= qq~  <tr>
    <td class="windowbg2" width="22%" align="center">[smiley=$line]</td>
    <td class="windowbg2" width="22%" align="center">$line</td>
    <td class="windowbg2" width="22%" align="center">$name</td>
    <td class="windowbg2" colspan="4" width="34%" align="center"><img src="$smiliesurl/$line" alt="$name" /></td>
  </tr>~;
			}
		}
	}
	$yymain .= qq~
    <form action="$adminurl?action=addsmilies" method="post">
<table border="0" width="100%" cellspacing="1" cellpadding="4" class="bordercolor" align="center">
  <tr>
    <td class="titlebg" colspan="7"><b>&nbsp;<img src="$imagesdir/grin.gif" alt="" />&nbsp;$asmtxt{'11'}</b></td>
  </tr><tr>
    <td class="catbg" width="22%" align="center"><b>$asmtxt{'02'}</b></td>
    <td class="catbg" width="22%" align="center"><b>$asmtxt{'03'}</b></td>
    <td class="catbg" width="22%" align="center"><b>$asmtxt{'04'}</b></td>
    <td class="catbg" width="12%" align="center"><b>$asmtxt{'05'}</b></td>
    <td class="catbg" width="10%" align="center"><b>$asmtxt{'06'}</b></td>
    <td class="catbg" width="6%" align="center"><b>$asmtxt{'07'}</b></td>
    <td class="catbg" width="6%" align="center"><b>$asmtxt{'12'}</b></td>
  </tr>
~;

	$i = 0;
	while ($SmilieURL[$i]) {
		undef $box;
		if ($SmilieLinebreak[$i] eq "<br />") { $box = " checked"; }
		if ($SmilieURL[$i] =~ /\//i) { $tmpurl = $SmilieURL[$i]; }
		else { $tmpurl = qq~$imagesdir/$SmilieURL[$i]~; }
		$j = $i + 1;
		if ($i != 0) {
			$up = qq~<a href="$adminurl?action=smiliemove;index=$i"><img src="$imagesdir/smiley_up.gif" border="0" alt="$asmtxt{'13'}" /></a>~;
		} else {
			$up = qq~<img src="$imagesdir/smiley_up.gif" border="0" alt="" />~;
		}
		if ($SmilieURL[$i + 1]) {
			$down = qq~<a href="$adminurl?action=smiliemove;index=$j"><img src="$imagesdir/smiley_down.gif" border="0" alt="$asmtxt{'14'}" /></a>~;
		} else {
			$down = qq~<img src="$imagesdir/smiley_down.gif" border="0" alt="" />~;
		}
		$yymain .= qq~  <tr>
    <td class="windowbg2" width="22%" align="center"><input type="text" name="scd[$i]" value="$SmilieCode[$i]" /></td>
    <td class="windowbg2" width="22%" align="center"><input type="text" name="smimg[$i]" value="$SmilieURL[$i]" /></td>
    <td class="windowbg2" width="22%" align="center"><input type="text" name="sdescr[$i]" value="$SmilieDescription[$i]" /></td>
    <td class="windowbg2" width="12%" align="center"><input type="checkbox" name="smbox[$i]" value="1"$box /></td>
    <td class="windowbg2" width="10%" align="center"><img src="$tmpurl" alt="" /></td>
    <td class="windowbg2" width="6%" align="center"><input type="checkbox" name="delbox[$i]" value="1" /></td>
    <td class="windowbg2" width="6%" align="center">$up $down</td>
  </tr>~;
		$i++;
	}
	$yymain .= qq~  <tr>
    <td class="titlebg" colspan="7"><b>&nbsp;<img src="$imagesdir/grin.gif" alt="" />&nbsp;$asmtxt{'08'}</b></td>
  </tr>~;
	$inew = 0;
	while ($inew <= "5") {
		$yymain .= qq~  <tr>
    <td class="windowbg2" width="22%" align="center"><input type="text" name="scd[$i]" /></td>
    <td class="windowbg2" width="22%" align="center"><input type="text" name="smimg[$i]" /></td>
    <td class="windowbg2" width="22%" align="center"><input type="text" name="sdescr[$i]" /></td>
    <td class="windowbg2" width="12%" align="center"><input type="checkbox" name="smbox[$i]" value="1" /></td>
    <td class="windowbg2" width="22%" align="center" colspan="3"></td>
  </tr>~;
		$i++;
		$inew++;
		if ($inew == 5) {
			$yymain .= qq~  <tr>
    <td colspan="7" class="titlebg"><b>&nbsp;<img src="$imagesdir/grin.gif" alt="" />&nbsp;$smiltxt{'2'}</b></td>
  </tr><tr>
    <td class="catbg" width="22%" align="center"><b>$asmtxt{'02'}</b></td>
    <td class="catbg" width="22%" align="center"><b>$asmtxt{'03'}</b></td>
    <td class="catbg" width="22%" align="center"><b>$asmtxt{'04'}</b></td>
    <td class="catbg" colspan="4" width="34%" align="center"><b>$asmtxt{'06'}</b></td>
  </tr>
$smilieslist
  <tr>
    <td class="titlebg" colspan="7" height="22"><b>&nbsp;<img src="$imagesdir/grin.gif" alt="" />&nbsp;$smiltxt{'3'}</b><br /></td>
  </tr><tr>
    <td class="windowbg2" colspan="3"><b>$smiltxt{'4'}</b></td>
    <td class="windowbg2" colspan="4" align="right">
      <select name="smiliestyle">
        <option value="1"$ss1>$smiltxt{'5'}</option>
        <option value="2"$ss2>$smiltxt{'6'}</option>
      </select>
    </td>
  </tr><tr>
    <td class="windowbg2" colspan="3"><b>$smiltxt{'7'}</b></td>
    <td class="windowbg2" colspan="4" align="right">
      <select name="showadded">
        <option value="1"$sa1>$smiltxt{'8'}</option>
        <option value="2"$sa2>$smiltxt{'9'}</option>
        <option value="3"$sa3>$smiltxt{'10'}</option>
        <option value="4"$sa4>$smiltxt{'11'}</option>
      </select>
    </td>
  </tr><tr>
    <td class="windowbg2" colspan="3"><b>$smiltxt{'2'}</b></td>
    <td class="windowbg2" colspan="4" align="right">
      <select name="showsmdir">
        <option value="1"$ssm1>$smiltxt{'8'}</option>
        <option value="2"$ssm2>$smiltxt{'9'}</option>
        <option value="3"$ssm3>$smiltxt{'10'}</option>
        <option value="4"$ssm4>$smiltxt{'11'}</option>
      </select>
    </td>
  </tr><tr>
    <td class="windowbg2" colspan="3"><b>$smiltxt{'12'}</b><br /> $smiltxt{'13'} </td>
    <td class="windowbg2" colspan="4" align="right"><input type="checkbox" name="detachblock" value="1"$dblock /></td>
  </tr><tr>
    <td class="windowbg2" colspan="3"><b>$smiltxt{'14'}</b></td>
    <td class="windowbg2" colspan="4" align="right"><input type="text" size="10" name="winwidth" value="$winwidth" /></td>
  </tr><tr>
    <td class="windowbg2" colspan="3"><b>$smiltxt{'15'}</b></td>
    <td class="windowbg2" colspan="4" align="right"><input type="text" size="10" name="winheight" value='$winheight' /></td>
  </tr><tr>
    <td class="windowbg2" colspan="3"><b>$smiltxt{'18'}</b></td>
    <td class="windowbg2" colspan="4" align="left">$smiliesurl</td>
  </tr><tr>
    <td class="windowbg2" colspan="3"><b>$smiltxt{'20'}</b></td>
    <td class="windowbg2" colspan="4" align="right"><input type="text" size="10" name="popback" value="$popback" /></td>
  </tr><tr>
    <td class="windowbg2" colspan="3"><b>$smiltxt{'19'}</b></td>
    <td class="windowbg2" colspan="4" align="right"><input type="text" size="10" name="poptext" value="$poptext" /></td>
  </tr><tr>
    <td class="catbg" align="center" colspan="7"><input type="submit" value="$asmtxt{'09'}" />&nbsp;<input type="reset" value="$asmtxt{'10'}" /></td>
  </tr>
</table>
</form>
~;

			$yytitle     = "$asmtxt{'01'}";
			$action_area = "smilies";
			&AdminTemplate;
			exit;
		}
	}

}

sub AddSmilies {
	&is_admin_or_gmod;
	$option1  = qq(\$smiliestyle = "$FORM{'smiliestyle'}";);
	$option2  = qq(\$showadded = "$FORM{'showadded'}";);
	$option3  = qq(\$showsmdir = "$FORM{'showsmdir'}";);
	$option4  = qq(\$detachblock = "$FORM{'detachblock'}";);
	$option5  = qq(\$winwidth = "$FORM{'winwidth'}";);
	$option6  = qq(\$winheight = "$FORM{'winheight'}";);
	$option9  = qq(\$popback = "$FORM{'popback'}";);
	$option10 = qq(\$poptext = "$FORM{'poptext'}";);

	$count = 0;
	$tempA = 0;
	fopen(FILE, ">$vardir/Smilies.txt", 1);
	while ($FORM{"scd[$tempA]"}) {
		$delcheck = $FORM{"delbox[$tempA]"};
		$var1     = $FORM{"smimg[$tempA]"};
		$var2     = $FORM{"scd[$tempA]"};
		$var3     = $FORM{"sdescr[$tempA]"};
		$var4     = $FORM{"smbox[$tempA]"};
		if ($var4 eq "1") { $var4 = "<br />"; }
		else { $var4 = ""; }
		&ToHTML($var2);
		$var2 =~ s/\$/&#36;/g;
		$var2 =~ s/\@/&#64;/g;
		&ToHTML($var3);
		$var3 =~ s/\$/&#36;/g;
		$var3 =~ s/\@/&#64;/g;
		$img = qq(\$SmilieURL[$count] = "$var1";);
		$scd = qq(\$SmilieCode[$count] = "$var2";);
		$sdr = qq(\$SmilieDescription[$count] = "$var3";);
		$smb = qq(\$SmilieLinebreak[$count] = "$var4";);

		if ($delcheck ne "1") {
			print FILE "$img\n";
			print FILE "$scd\n";
			print FILE "$sdr\n";
			print FILE "$smb\n\n";
			++$count;
		}
		++$tempA;
	}
	print FILE "$option1\n";
	print FILE "$option2\n";
	print FILE "$option3\n";
	print FILE "$option4\n";
	print FILE "$option5\n";
	print FILE "$option6\n";
	print FILE "$option9\n";
	print FILE "$option10\n\n";
	print FILE "1;";
	fclose(FILE);

	$yySetLocation = qq~$adminurl?action=smilies~;
	&redirectexit;
}

sub SmilieMove {
	&is_admin_or_gmod;
	$index    = $INFO{'index'};
	$newindex = $index - 1;

	if ($SmilieURL[$index] ne "" && $SmilieURL[$newindex] ne "") {
		fopen(FILE, "$vardir/Smilies.txt");
		@tmpsmilies = <FILE>;
		fclose(FILE);
		if ($newindex >= 0 && $newindex <= $#tmpsmilies) {
			$i = 0;
			foreach (@tmpsmilies) {
				if    ($tmpsmilies[$i] =~ /\[$newindex\] \=/i) { $tmpsmilies[$i] =~ s/\[$newindex\] \=/\[$index\] \=/g; }
				elsif ($tmpsmilies[$i] =~ /\[$index\] \=/i)    { $tmpsmilies[$i] =~ s/\[$index\] \=/\[$newindex\] \=/g; }
				$i++;
			}
			fopen(FILE, ">$vardir/Smilies.txt", 1);
			print FILE @tmpsmilies;
			fclose(FILE);
		}
	}

	$yySetLocation = qq~$adminurl?action=smilies~;
	&redirectexit;
}

1;
