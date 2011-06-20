###############################################################################
# DateTime.pl                                                                 #
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

$datetimeplver = 'YaBB 2.1 $Revision: 1.8 $';

if ($action eq 'detailedversion') { return 1; }

use Time::Local 'timelocal';

sub calcdifference {    # Input: $date1 $date2
	$result = int($date2 / 86400) - int($date1 / 86400);
}

sub calctime {          # Input: $date1 $date2
	$result = $date2 - $date1;
}

sub timetostring {
	unless ($_[0]) { return 0; }
	$thedate = $_[0];
	if (!$maintxt{'107'}) { $maintxt{'107'} = "at"; }
	(undef, undef, undef, undef, undef, undef, undef, undef, $isdst) = localtime($thedate + (3600 * $timeoffset));
	if ($isdst > 0 && $dstoffset)  { $thedate += 3600; }
	($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, undef) = gmtime($thedate + (3600 * $timeoffset));
	$mon_num = $mon + 1;
	$hour = sprintf("%02d", $hour);
	$min = sprintf("%02d", $min);
	$sec = sprintf("%02d", $sec);
	$saveyear = ($year % 100);
	$year = 1900 + $year;
	$mon_num = sprintf("%02d", $mon_num);
	$mday = sprintf("%02d", $mday);
	$saveyear = sprintf("%02d", $saveyear);
	return "$mon_num/$mday/$saveyear $maintxt{'107'} $hour\:$min\:$sec";
}

sub stringtotime {
	unless ($_[0]) { return 0; }
	$splitvar = $_[0];
	$splitvar =~ m~(\d{2})\/(\d{2})\/(\d{2}).*?(\d{2})\:(\d{2})\:(\d{2})~;
	$amonth = int($1) || 1;
	$aday   = int($2) || 1;
	$ayear  = int($3) || 0;
	$ahour  = int($4) || 0;
	$amin   = int($5) || 0;
	$asec   = int($6) || 0;

	# Uses 1904 and 2036 as the default dates, as both are leap years.
	# If we used the real extremes (1901 and 2038) - there would be problems
	# As timelocal dies if you provide 29th Feb as a date in a non-leap year
	# Using leap years as the default years prevents this from happening.

	if    ($ayear >= 36 && $ayear <= 99) { $ayear += 1900; }
	elsif ($ayear >= 00 && $ayear <= 35) { $ayear += 2000; }
	if    ($ayear < 1904) { $ayear = 1904; }
	elsif ($ayear > 2036) { $ayear = 2036; }

	if    ($amonth < 1)  { $amonth = 0; }
	elsif ($amonth > 12) { $amonth = 11; }
	else { --$amonth; }

	if($amonth == 3 || $amonth == 5 || $amonth == 8 || $amonth == 10) { $max_days = 30; }
	elsif($amonth == 1 && $ayear % 4 == 0) { $max_days = 29; }
	elsif($amonth == 1 && $ayear % 4 != 0) { $max_days = 28; }
	else { $max_days = 31; }
	if($aday > $max_days) { $aday = $max_days; }

	if    ($ahour < 1)  { $ahour = 0; }
	elsif ($ahour > 23) { $ahour = 23; }
	if    ($amin < 1)   { $amin  = 0; }
	elsif ($amin > 59)  { $amin  = 59; }
	if    ($asec < 1)   { $asec  = 0; }
	elsif ($asec > 59)  { $asec  = 59; }

	return (timelocal($asec, $amin, $ahour, $aday, $amonth, $ayear));
}

sub timeformat {
	$oldformat = $_[0];
	chomp $oldformat;
	if (!$oldformat) { return $oldformat; }

	$dontusetoday = $_[1];

	(undef, undef, undef, undef, undef, undef, undef, undef, $newisdst) = localtime($oldformat);
	if ($newisdst > 0) {
		if ($iamguest) {
			if($dstoffset) { $oldformat += 3600; }
		} else {
			if(${$uid.$username}{'dsttimeoffset'} != 0) { $oldformat += 3600; }
		}
	}

	# we find out what time the date of the post is according to the users timezone.
	if ($iamguest) { $toffs = $timeoffset; }
	else { $toffs = ${$uid.$username}{'timeoffset'}; }

	my ($newsecond, $newminute, $newhour, $newday, $newmonth, $newyear, $newweekday, $newyearday, $dummy) = gmtime($oldformat + (3600 * $toffs));

	# Calculate number of full weeks this year
	$newweek = int(($newyearday + 1 - $newweekday) / 7) + 1;

	# Add 1 if today isn't Saturday
	if ($newweekday < 6) { $newweek = $newweek + 1; }
	$newweek = sprintf("%02d", $newweek);
	$newmonth++;
	$newweekday++;
	$newyear += 1900;
	$newshortyear = substr($newyear, 2, 2);
	$newmonth = sprintf("%02d", $newmonth);
	if ($mytimeselected != 4) { $newday = sprintf("%02d", $newday); }
	$newhour   = sprintf("%02d", $newhour);
	$newminute = sprintf("%02d", $newminute);
	$newsecond = sprintf("%02d", $newsecond);

	$newtime = $newhour . ":" . $newminute . ":" . $newsecond;

	($secx, $minx, $hourx, $dd, $mm, $yy, $tmpx, $yd, $tmpx) = gmtime($date + (3600 * $toffs));

	$mm = $mm + 1;
	$yy = ($yy % 100);

	$daytxt = "";

	#the today yesterday problem was here... =(
	if (!$dontusetoday) {
		if ($yd == $newyearday && $yy == $newshortyear) {

			# today
			$daytxt = qq~<b>$maintxt{'769'}</b>~;
		} elsif (($yd == $newyearday + 1 && $yy == $newshortyear) || ($yd == 1 && $dd == 31 && $yy == $newshortyear + 1)) {

			# yesterday
			$daytxt = qq~<b>$maintxt{'769a'}</b>~;
		} elsif (($yd == $newyearday - 365 && $yy == $newshortyear + 1) || ($yd == $newyearday - 366 && $yy == $newshortyear + 1)) {

			# yesterday, over a year end.
			$daytxt = qq~<b>$maintxt{'769a'}</b>~;
		}
	}

	if (!$maintxt{'107'}) { $maintxt{'107'} = $admin_txt{'107'}; }

	$mytimeselected = ${$uid.$username}{'timeselect'} || $timeselected;

	if ($mytimeselected == 7) {
		$mytimeformat = ${$uid.$username}{'timeformat'};
		if ($mytimeformat =~ m/MM/) { $usefullmonth = 1; }
		if ($mytimeformat =~ m/hh/) { $hourstyle    = 12; }
		if ($mytimeformat =~ m/HH/) { $hourstyle    = 24; }
		$mytimeformat =~ s/\@/$maintxt{'107'}/g;
		$mytimeformat =~ s/mm/$newminute/g;
		$mytimeformat =~ s/ss/$newsecond/g;
		$mytimeformat =~ s/ww/$newweek/g;

		if ($mytimeformat =~ m/\+/) {
			if ($newday > 10 && $newday < 20) {
				$dayext = "<sup>$timetxt{'4'}</sup>";
			} elsif ($newday % 10 == 1) {
				$dayext = "<sup>$timetxt{'1'}</sup>";
			} elsif ($newday % 10 == 2) {
				$dayext = "<sup>$timetxt{'2'}</sup>";
			} elsif ($newday % 10 == 3) {
				$dayext = "<sup>$timetxt{'3'}</sup>";
			} else {
				$dayext = "<sup>$timetxt{'4'}</sup>";
			}
		}
		if ($hourstyle == 12) {
			$ampm = $newhour > 11 ? 'pm' : 'am';
			$newhour2 = $newhour % 12 || 12;
			$mytimeformat =~ s/hh/$newhour2/g;
			$mytimeformat =~ s/\#/$ampm/g;
		} elsif ($hourstyle == 24) {
			$mytimeformat =~ s/HH/$newhour/g;
		}
		if ($daytxt eq "") {
			$mytimeformat =~ s/YYYY/$newyear/g;
			$mytimeformat =~ s/YY/$newshortyear/g;
			$mytimeformat =~ s/DD/$newday/g;
			$mytimeformat =~ s/D/$newday/g;
			$mytimeformat =~ s/\+/$dayext/g;
			if ($usefullmonth == 1) {
				$mytimeformat =~ s/MM/$months[$newmonth-1]/g;
			} else {
				$mytimeformat =~ s/M/$newmonth/g;
			}
		} else {
			$mytimeformat =~ s/DD/$daytxt/g;
			$mytimeformat =~ s/D/$daytxt/g;
			$mytimeformat =~ s/YY//g;
			$mytimeformat =~ s/M//g;
			$mytimeformat =~ s/\+//g;
		}
		if ($newisdst && ${$uid.$username}{'dsttimeoffset'} != 0) {
			$mytimeformat =~ s/\*/$maintxt{'dst'}/g;
		} else {
			$mytimeformat =~ s/\*//g;
		}
		$newformat = $mytimeformat;
	} elsif ($mytimeselected == 1) {
		$newformat = $daytxt ? qq~$daytxt $maintxt{'107'} $newtime~ : qq~$newmonth/$newday/$newshortyear $maintxt{'107'} $newtime~;
	} elsif ($mytimeselected == 2) {
		$newformat = $daytxt ? qq~$daytxt $maintxt{'107'} $newtime~ : qq~$newday.$newmonth.$newshortyear $maintxt{'107'} $newtime~;
	} elsif ($mytimeselected == 3) {
		$newformat = $daytxt ? qq~$daytxt $maintxt{'107'} $newtime~ : qq~$newday.$newmonth.$newyear $maintxt{'107'} $newtime~;
	} elsif ($mytimeselected == 4) {
		$ampm = $newhour > 11 ? 'pm' : 'am';
		$newhour2 = $newhour % 12 || 12;
		$newmonth2 = $months[$newmonth - 1];
		if ($newday > 10 && $newday < 20) {
			$newday2 = "<sup>$timetxt{'4'}</sup>";
		} elsif ($newday % 10 == 1) {
			$newday2 = "<sup>$timetxt{'1'}</sup>";
		} elsif ($newday % 10 == 2) {
			$newday2 = "<sup>$timetxt{'2'}</sup>";
		} elsif ($newday % 10 == 3) {
			$newday2 = "<sup>$timetxt{'3'}</sup>";
		} else {
			$newday2 = "<sup>$timetxt{'4'}</sup>";
		}
		$newformat = $daytxt ? qq~$daytxt $maintxt{'107'} $newhour2:$newminute$ampm~ : qq~$newmonth2 $newday$newday2, $newyear, $newhour2:$newminute$ampm~;
	} elsif ($mytimeselected == 5) {
		$ampm = $newhour > 11 ? 'pm' : 'am';
		$newhour2 = $newhour % 12 || 12;
		$newformat = $daytxt ? qq~$daytxt $maintxt{'107'} $newhour2:$newminute$ampm~ : qq~$newmonth/$newday/$newshortyear $maintxt{'107'} $newhour2:$newminute$ampm~;
	} elsif ($mytimeselected == 6) {
		$newmonth2 = $months[$newmonth - 1];
		$newformat = $daytxt ? qq~$daytxt $maintxt{'107'} $newhour:$newminute~ : qq~$newday. $newmonth2 $newyear $maintxt{'107'} $newhour:$newminute~;
	}
	return $newformat;
}

sub CalcAge {
	$currentdate = timetostring(int(time));
	my ($usermonth, $userday, $useryear, $act);
	my $user = $_[0];
	my $act  = $_[1];

	if (${$uid.$user}{'bday'} ne '') {
		($usermonth, $userday, $useryear) = split(/\//, ${$uid.$user}{'bday'});

		if ($act eq "calc") {
			if (length(${$uid.$user}{'bday'}) <= 2) { $age = ${$uid.$user}{'bday'}; }
			else {
				$age = $year - $useryear;
				if ($usermonth > $mon_num || ($usermonth == $mon_num && $userday > $mday)) { --$age; }
			}
		}
		if ($act eq "parse") {
			if (length(${$uid.$user}{'bday'}) <= 2) { return; }
			$umonth = $usermonth;
			$uday   = $userday;
			$uyear  = $useryear;
		}
		if ($act eq "isbday") {
			if ($usermonth == $mon_num && $userday == $mday) { $isbday = "yes"; }
		}
	} else {
		$age    = "";
		$isbday = "";
	}
}

1;
