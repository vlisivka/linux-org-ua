#!/usr/bin/perl --
###############################################################################
# YaBB.pl                                                                     #
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

### Version Info ###
$YaBBversion = 'YaBB 2.1';
$YaBBplver   = 'YaBB 2.1 $Revision: 1.3 $';

if ($action eq 'detailedversion') { return 1; }

use utf8;

binmode STDIN,  ':utf8';
binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';

# XXX
use Encode;

@ARGV = map { decode ( 'utf8', $_ ) } @ARGV;

# Make sure the module path is present
# Some servers need all the subdirs in @INC too.
push(@INC, "./Modules");
push(@INC, "./Modules/Upload");
push(@INC, "./Modules/Digest");

if ($ENV{'SERVER_SOFTWARE'} =~ /IIS/) {
	$yyIIS = 1;
	$0 =~ m~(.*)(\\|/)~;
	$yypath = $1;
	$yypath =~ s~\\~/~g;
	chdir($yypath);
	push(@INC, $yypath);
}

# Check for Time::HiRes
#eval { require Time::HiRes; import Time::HiRes qw(time); };
#if ($@) { $START_TIME = 0; }
#else { $START_TIME = time; }

### Requirements and Errors ###
$script_root = $ENV{'SCRIPT_FILENAME'};
$script_root =~ s/\/YaBB\.(pl|cgi)//ig;

if (-e "Paths.pl") { require "Paths.pl"; }
elsif (-e "$script_root/Paths.pl") { require "$script_root/Paths.pl"; }

require "$vardir/Settings.pl";
require "$vardir/advsettings.txt";
require "$vardir/secsettings.txt";
require "$vardir/membergroups.txt";
require "$sourcedir/Subs.pl";
require "$sourcedir/DateTime.pl";
require "$sourcedir/Load.pl";

# Those who write software only for pay should go hurt some other field.
# - Erik Naggum

&LoadCookie;          # Load the user's cookie (or set to guest)
&LoadUserSettings;    # Load user settings
&WhatTemplate;        # Figure out which template to be using.
&WhatLanguage;        # Figure out which language file we should be using! :D

require "$sourcedir/Guardian.pl";
&guard;

# Check if the action is allowed from an external domain
if ($referersecurity) { &referer_check; }

my $inactsize = -s "$memberdir/memberlist.inactive";

if ((-e "$memberdir/memberlist.inactive") && $inactsize > 2 && $preregister) {
	require "$sourcedir/Register.pl";
	&activation_check;
}

require "$boardsdir/forum.master";
require "$sourcedir/Security.pl";
require "$vardir/Smilies.txt";

&banning;     # Check for banned people
&WriteLog;    # Write to the log
&LoadIMs;     # Load IM's

$action = $INFO{'action'};
$SIG{__WARN__} = sub { &fatal_error("@_"); };
eval { &yymain; };
if ($@) { &fatal_error("Untrapped Error:<br />$@"); }

sub yymain {
	# Choose what to do based on the form action
	if ($maintenance == 1) {
		if ($action eq 'login2') { require "$sourcedir/LogInOut.pl"; &Login2; }

		# Allow password reminders in case admins (or just Corey)
		# forgets their admin password...
		if ($action eq 'reminder') {
			require "$sourcedir/LogInOut.pl";
			&Reminder;
		}
		if ($action eq 'validate') {
			require "$sourcedir/Decoder.pl";
			&convert;
		}
		if ($action eq 'reminder2') {
			require "$sourcedir/LogInOut.pl";
			&Reminder2;
		}
		if ($action eq 'resetpass') {
			require "$sourcedir/LogInOut.pl";
			&Reminder3;
		}

		if (!$iamadmin) { require "$sourcedir/Maintenance.pl"; &InMaintenance; }
	}

	# Guest can do the very few following actions.
	if ($iamguest && $guestaccess == 0) {
		if (!(($action eq 'login') || ($action eq 'login2') || ($action eq 'register') || ($action eq 'register2') || ($action eq 'reminder') || ($action eq 'reminder2') || ($action eq 'validate') || ($action eq 'activate') || ($action eq 'resetpass'))) {
			&KickGuest;
		}
	}

	if ($action ne "") {
		require "$sourcedir/SubList.pl";
		if ($director{$action}) {
			@act = split(/&/, $director{$action});
			$aa = $act[1];
			require "$sourcedir/$act[0]";
			&$aa;
		} else {
			require "$sourcedir/BoardIndex.pl";
			&BoardIndex;
		}
	} elsif ($INFO{'num'} ne "") {
		require "$sourcedir/Display.pl";
		&Display;
	} elsif ($currentboard eq "") {
		require "$sourcedir/BoardIndex.pl";
		&BoardIndex;
	} else {
		require "$sourcedir/MessageIndex.pl";
		&MessageIndex;
	}

	exit;
}
