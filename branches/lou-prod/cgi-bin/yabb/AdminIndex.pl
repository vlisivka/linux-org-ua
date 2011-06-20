#!/usr/bin/perl --

###############################################################################
# AdminIndex.pl                                                               #
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
$indexplver = 'YaBB 2.1 $Revision: 1.3 $';
$indexplver =~ s/\$Revision\: (.*?) \$/Build $1/ig;
$YaBBversion = 'YaBB 2.1';

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

$adminscreen = "1";

# Check for Time::HiRes
eval { require Time::HiRes; import Time::HiRes qw(time); };
if ($@) { $START_TIME = 0; }
else { $START_TIME = time; }

### Requirements and Errors ###
$script_root = $ENV{'SCRIPT_FILENAME'};
$script_root =~ s/\/AdminIndex\.(pl|cgi)//ig;

if (-e "Paths.pl") { require "Paths.pl"; }
elsif (-e "$script_root/Paths.pl") { require "$script_root/Paths.pl"; }

require "$vardir/Settings.pl";
require "$sourcedir/Subs.pl";
require "$sourcedir/System.pl";
require "$sourcedir/DateTime.pl";
require "$sourcedir/Load.pl";
require "$vardir/advsettings.txt";
require "$vardir/secsettings.txt";
require "$vardir/membergroups.txt";

if (!$ENV{'HTTP_USER_AGENT'}) {
	&spoofed;
}

&LoadCookie;          # Load the user's cookie (or set to guest)
&LoadUserSettings;
&WhatTemplate;
&WhatLanguage;

# Check if the action is allowed from an external domain
if ($referersecurity) { &referer_check; }

if (!-e "$boardsdir/forum.totals") { &BoardTotals("convert"); }

require "$sourcedir/Security.pl";

$adminurl = "$boardurl/AdminIndex.$yyaext";

&banning;   # Check for banned people
&WriteLog;

$action = $INFO{'action'};
$SIG{__WARN__} = sub { &admin_fatal_error("@_"); };
eval { &yymain; };
if ($@) { &admin_fatal_error("Untrapped Error:<br />$@"); }

sub yymain {
	# Choose what to do based on the form action
	if ($maintenance == 1 && $action eq 'login2') { require "$sourcedir/LogInOut.pl"; &Login2; }
	if ($maintenance == 1 && !$iamadmin) { require "$sourcedir/Maintenance.pl"; &InMaintenance; }

	# Guest can do the very few following actions.
	if ($iamguest || !$iamadmin && !$iamgmod) {
		$yySetLocation = qq~$scripturl~;
		&redirectexit;
	}

	# Do Sessions Checking also
	if ($sessions == 1 && $sessionvalid != 1) {
		$yySetLocation = qq~$scripturl~;
		&redirectexit;
	}

	if ($iamgmod) {
		require "$vardir/gmodsettings.txt";
		if (!$allow_gmod_admin) {
			$yySetLocation = qq~$scripturl~;
			&redirectexit;
		}
	}

	if ($action ne "") {
		require "$admindir/AdminSubList.pl";
		if ($director{$action}) {
			@act = split(/&/, $director{$action});
			$aa = $act[1];
			require "$admindir/$act[0]";
			&$aa;
		} else {
			require "$admindir/Admin.pl";
			&Admin;
		}
	} else {
		&TrackAdminLogins;
		require "$admindir/Admin.pl";
		&Admin;
	}

	exit;
}

sub ParseNavArray {
	foreach $element (@_) {

		chomp $element;
		($action_to_take, $vistext, $whatitdoes, $isheader) = split(/\|/, $element);

		if ($action_area eq "$action_to_take") {
			$currentclass = "class=\"current\"";
		} else {
			$currentclass = "";
		}

		if ($isheader) {
			$started_ul = 1;
			$leftmenu .= qq~		<h3><a href="javascript:toggleList('$isheader')" title="$whatitdoes">$vistext</a></h3>
		  <ul id="$isheader">
~;
			next;
		}

		if ($iamgmod && $gmod_access{"$action_to_take"} ne "on") {
			next;
		}

		if ($action_to_take ne "#") {
			$leftmenu .= qq~			<li><a href="$adminurl?action=$action_to_take" title="$whatitdoes" $currentclass>$vistext</a></li>~;
		} else {
			$leftmenu .= qq~			<li><a name="none" title="none">$vistext</a></li>~;
		}
	}

	if ($started_ul) {
		$leftmenu .= qq~
		  </ul>
~;
	}
}

sub AdmImgLoc {
	if (!-e "$forumstylesdir/$useimages/$_[0]") { $thisimgloc = qq~img src="$forumstylesurl/default/$_[0]"~; }
	else { $thisimgloc = qq~img src="$imagesdir/$_[0]"~; }
	return $thisimgloc;
}

sub AdminTemplate {
	$admin_template = ${ $uid . $username }{'template'};
	if (!-d "$adminstylesdir/$admin_template" || $admin_template eq "") { $admin_template = "default"; }

	$adminstyle = qq~<link rel="stylesheet" href="$adminstylesurl/$admin_template.css" type="text/css" />~;
	$adminstyle =~ s~$admin_template\/~~g;

	$adminimages = qq~$adminstylesurl/$admin_template~;
	$adminimages =~ s~$admin_template\/~~g;
	require "$templatesdir/$admin_template/AdminCentre.template";
	require "$vardir/gmodsettings.txt";

	@forum_settings = ("|$admintxt{'a1_title'}|$admintxt{'a1_label'} - $admintxt{'34'}|a1", "modsettings|$admintxt{'a1_sub1'}|$admintxt{'a1_label1'}|", "advsettings|$admintxt{'a1_sub2'}|$admintxt{'a1_label2'}|", "editpaths|$admintxt{'a1_sub3'}|$admintxt{'a1_label3'}|",);

	@general_controls = ("|$admintxt{'a2_title'}|$admintxt{'a2_label'} - $admintxt{'34'}|a2", "editnews|$admintxt{'a2_sub1'}|$admintxt{'a2_label1'}|", "smilies|$admintxt{'a2_sub2'}|$admintxt{'a2_label2'}|", "setcensor|$admintxt{'a2_sub3'}|$admintxt{'a2_label3'}|", "modagreement|$admintxt{'a2_sub4'}|$admintxt{'a2_label4'}|", "gmodaccess|$admintxt{'a2_sub5'}|$admintxt{'a2_label5'}|",);

	@security_settings = ("|$admintxt{'a3_title'}|$admintxt{'a3_label'} - $admintxt{'34'}|a3", "referer_control|$admintxt{'a3_sub1'}|$admintxt{'a3_label1'}|", "flood_control|$admintxt{'a3_sub2'}|$admintxt{'a3_label2'}|", "setup_guardian|$admintxt{'a3_sub3'}|$admintxt{'a3_label3'}|",);

	@forum_controls = ("|$admintxt{'a4_title'}|$admintxt{'a4_label'} - $admintxt{'34'}|a4", "managecats|$admintxt{'a4_sub1'}|$admintxt{'a4_label1'}|", "manageboards|$admintxt{'a4_sub2'}|$admintxt{'a4_label2'}|", "helpadmin|$admintxt{'a4_sub3'}|$admintxt{'a4_label3'}|",);

	@forum_layout = ("|$admintxt{'a5_title'}|$admintxt{'a5_label'} - $admintxt{'34'}|a5", "modskin|$admintxt{'a5_sub1'}|$admintxt{'a5_label1'}|", "modcss|$admintxt{'a5_sub2'}|$admintxt{'a5_label2'}|", "modtemp|$admintxt{'a5_sub3'}|$admintxt{'a5_label3'}|",);

	@member_controls = ("|$admintxt{'a6_title'}|$admintxt{'a6_label'} - $admintxt{'34'}|a6", "addmember|$admintxt{'a6_sub1'}|$admintxt{'a6_label1'}|", "viewmembers|$admintxt{'a6_sub2'}|$admintxt{'a6_label2'}|", "modmemgr|$admintxt{'a6_sub3'}|$admintxt{'a6_label3'}|", "mailing|$admintxt{'a6_sub4'}|$admintxt{'a6_label4'}|", "ipban|$admintxt{'a6_sub5'}|$admintxt{'a6_label5'}|", "setreserve|$admintxt{'a6_sub6'}|$admintxt{'a6_label6'}|",);

	@maintence_controls = ("|$admintxt{'a7_title'}|$admintxt{'a7_label'} - $admintxt{'34'}|a7", "clean_log|$admintxt{'a7_sub1'}|$admintxt{'a7_label1'}|", "boardrecount|$admintxt{'a7_sub2'}|$admintxt{'a7_label2'}|", "rebuildmesindex|$admintxt{'a7_sub2a'}|$admintxt{'a7_label2a'}|", "membershiprecount|$admintxt{'a7_sub3'}|$admintxt{'a7_label3'}|", "rebuildmemlist|$admintxt{'a7_sub4'}|$admintxt{'a7_label4'}|", "rebuildmemhist|$admintxt{'a7_sub4a'}|$admintxt{'a7_label4a'}|", "deleteoldthreads|$admintxt{'a7_sub5'}|$admintxt{'a7_label5'}|", "manageattachments|$admintxt{'a7_sub6'}|$admintxt{'a7_label6'}|",);

	@forum_stats = ("|$admintxt{'a8_title'}|$admintxt{'a8_label'} - $admintxt{'34'}|a8", "detailedversion|$admintxt{'a8_sub1'}|$admintxt{'a8_label1'}|", "stats|$admintxt{'a8_sub2'}|$admintxt{'a8_label2'}|", "showclicks|$admintxt{'a8_sub3'}|$admintxt{'a8_label3'}|", "errorlog|$admintxt{'a8_sub4'}|$admintxt{'a8_label4'}|", "view_reglog|$admintxt{'a8_sub5'}|$admintxt{'a8_label5'}|",);

	@boardmod_mods = ("|$admintxt{'a9_title'}|$admintxt{'a9_label'} - $admintxt{'34'}|a9", "modlist|$mod_list{'6'}|$mod_list{'7'}|",);

	# To add new items for your mods settings, add a new row below here, pushing
	# your item onto the @boardmod_mods array. Example below:
	# 	$my_mod = "action_to_take|Name_Displayed|Tooltip_Title|";
	#	push (@boardmod_mods, "$my_mod");
	# before the first pipe character is the action that will appear in the URL
	# Next is the text that is displayed in the admin centre
	# Finally, you have the tooltip text, necessary for XHTML compliance

	# Also note, you should pick a unique name instead of "$my_mod".
	# If you mod is called "SuperMod For Doing Cool Things"
	# You could use "$SuperMod_CoolThings"

### BOARDMOD ANCHOR ###

### END BOARDMOD ANCHOR ###

	&ParseNavArray(@forum_settings);
	&ParseNavArray(@general_controls);
	&ParseNavArray(@security_settings);
	&ParseNavArray(@forum_controls);
	&ParseNavArray(@forum_layout);
	&ParseNavArray(@member_controls);
	&ParseNavArray(@maintence_controls);
	&ParseNavArray(@forum_stats);
	&ParseNavArray(@boardmod_mods);

	$topmenu_one  = qq~<span style="font-size: 12px; font-family: tahoma, sans-serif;"><a href="$boardurl/YaBB.$yyext">$admintxt{'15'}</a></span>~;
	$topmenu_two  = qq~<span style="font-size: 12px; font-family: tahoma, sans-serif;"><a href="$adminurl">$admintxt{'33'}</a></span>~;
	$topmenu_tree = qq~<span style="font-size: 12px; font-family: tahoma, sans-serif;"><a href="$scripturl?action=help">$admintxt{'35'}</a></span>~;
	$topmenu_four = qq~<span style="font-size: 12px; font-family: tahoma, sans-serif;"><a href="http://www.yabbforum.com">$admintxt{'36'}</a></span>~;

	if ($maintenance) {
		$maintenance_mode = qq~<br /><span style="font-size: 12px; background-color: #FFFF33;"><b>$load_txt{'616'}</b></span><br /><br />~;
	} else {
		$maintenance_mode = "";
	}

	print qq~Content-Type: text/html\n\n~;
	$header =~ s/<yabb style>/$adminstyle/g;
	$header =~ s/<yabb charset>/$yycharset/g;

	print qq~$header~;
	$leftmenutop =~ s/<yabb images>/$adminimages/g;
	$leftmenutop =~ s/<yabb maintenance>/$maintenance_mode/g;
	$topnav      =~ s/<yabb topmenu_one>/$topmenu_one/;
	$topnav      =~ s/<yabb topmenu_two>/$topmenu_two/;
	$topnav      =~ s/<yabb topmenu_tree>/$topmenu_tree/;
	$topnav      =~ s/<yabb topmenu_four>/$topmenu_four/;
	print qq~$leftmenutop~;
	print qq~$leftmenu~;
	print qq~$leftmenubottom~;
	print qq~$topnav~;
	&AdminDebug;
	$mainbody =~ s/<yabb main>/$yymain/g;
	$mainbody =~ s/<yabb_admin debug>/$yydebug/g;

	$mainbody =~ s~img src\=\"$imagesdir\/(.+?)\"~&AdmImgLoc($1)~eisg;

	print qq~$mainbody~;

	exit;
}

sub TrackAdminLogins {
	if (-e "$vardir/adminlog.txt") {
		fopen(ADMINLOG, "$vardir/adminlog.txt");
		@adminlog = <ADMINLOG>;
		fclose(ADMINLOG);
	}
	fopen(ADMINLOG, ">$vardir/adminlog.txt");
	print ADMINLOG qq~$username|$user_ip|$date\n~;
	for ($i = 0; $i < 4; $i++) {
		if ($adminlog[$i]) {
			chomp $adminlog[$i];
			print ADMINLOG qq~$adminlog[$i]\n~;
		}
	}
	fclose(ADMINLOG);
}

sub AdminDebug {
	if ($debug == 1) {
		if (eval "require Time::HiRes") {
			$time_running = time - $START_TIME;
			if ($time_running > 1000) {
				$yytimeclock = "Your server probably does not have Time::Hires installed or does not support the local module for it";
			} else {
				$time_running = sprintf("%.4f", $time_running);
				$yytimeclock = "Page completed in $time_running seconds";
			}
		}
		$yyfileactions = "Opened $file_open files and Closed $file_close files. (should be equal numbers)";
		$openfiles =~ s~\+\<~~g;
		$yyfilenames = $openfiles;
		$yydebug     = qq~<span class="small"><br /><u>Debugging Information</u><br /><br /><u>benchmarking</u><br />$yytimeclock<br /><br /><u>Your IP address is</u><br />$user_ip<br /><br /><u>Your Browser Agent:</u><br />$ENV{'HTTP_USER_AGENT'}<br /><br /><u>File Check on Open/Close</u><br />$yyfileactions<br /><br /><u>Filehandle/Files Opened:</u><br />$openfiles</span>~;
	}
}

1;
