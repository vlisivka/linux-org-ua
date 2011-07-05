###############################################################################
# SetStatus.pl                                                                #
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

$setstatusplver = 'YaBB 2.1 $Revision: 1.1 $';
if ($action eq 'detailedversion') { return 1; }

sub SetStatus {
	my $start      = $INFO{'start'} || 0;
	my $thisstatus = "";
	my $status     = substr($INFO{'action'}, 0, 1) || substr($FORM{'action'}, 0, 1);

	&fatal_error("$txt{'93'}") unless ($iammod || $iamadmin || $iamgmod);

	my $threadid = $INFO{'thread'};
	&fatal_error ($maintxt{'337'}) if ($threadid =~ /\D/);
	my $ctbid    = $threadid;

	if (!$currentboard) {
		&MessageTotals("load", $threadid);
		$currentboard = ${$threadid}{'board'};
	}

	fopen(BOARDFILE, "$boardsdir/$currentboard.txt") || &fatal_error("test $txt{'23'} $currentboard.txt", 1);
	@boardfile = <BOARDFILE>;
	fclose(BOARDFILE);

	fopen(BOARDFILE, ">$boardsdir/$currentboard.txt") || &fatal_error("$txt{'23'} $currentboard.txt", 1);
	foreach my $line (@boardfile) {
		if ($line =~ m~\A$threadid\|~) {
			chomp $line;

			my ($mnum, $msub, $mname, $memail, $mdate, $mreplies, $musername, $micon, $mstate)
					= split(/\|/o, $line);
			
			$mstate .= "0" unless ($mstate =~ /0/o);

			if ($mstate =~ /$status/i) {
				$mstate =~ s/$status//ig;

				if ($status eq "s") {
					$yySetLocation = qq~$scripturl?board=$currentboard~;
				} else {
					$yySetLocation = qq~$scripturl?num=$threadid/$start~;
				}
			} else {
				$mstate  .= "$status";
				$yySetLocation = qq~$scripturl?board=$currentboard~;
			}
			$thisstatus = qq~$mstate~;

			print BOARDFILE
				"$mnum|$msub|$mname|$memail|$mdate|$mreplies|$musername|$micon|$mstate\n";
		} elsif ($line =~ /\|/o) {
			print BOARDFILE $line;
		}
	}
	fclose(BOARDFILE);

	fopen(CTBFILE, "$datadir/$ctbid.ctb");
	@ctbfile = <CTBFILE>;
	fclose(CTBFILE);

	$ctbfile[5] = qq~$thisstatus\n~;

	fopen(CTBFILE, ">$datadir/$ctbid.ctb");
	print CTBFILE @ctbfile;
	fclose(CTBFILE);

	&redirectexit if (!$INFO{'moveit'});
}

1;
