###############################################################################
# Maintenance.pl                                                              #
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

$maintenanceplver = 'YaBB 2.1 $Revision: 1.1 $';
if ($action eq 'detailedversion') { return 1; }

sub InMaintenance {
	if ($maintenancetext ne "") { $maintxt{'157'} = $maintenancetext; }
	require "$sourcedir/LogInOut.pl";
	$sharedLogin_title = "$maintxt{'114'}";
	$sharedLogin_text  = "<b>$maintxt{'156'}</b><br />$maintxt{'157'}";
	$yymain .= &sharedLogin;

	$yytitle = "$maintxt{'155'}";
	&template;
	exit;
}

1;
