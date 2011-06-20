###############################################################################
# RemoveOldTopics.pl                                                          #
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

$removeoldthreadsplver = 'YaBB 2.1 $Revision: 1.1 $';
if ($action eq 'detailedversion') { return 1; }

sub RemoveOldThreads {
	&is_admin_or_gmod;
	my (@threads, $num, $status, $keep_sticky, %attachfile);

	if ($FORM{'maxdays'} !~ /\A[0-9]+\Z/) { &admin_fatal_error("$admin_txt{'337'}."); }

	$yytitle = "$admin_txt{'120'} $FORM{'maxdays'}";
	fopen(FILE, ">$vardir/oldestmes.txt");
	print FILE "$FORM{'maxdays'}";
	fclose(FILE);

	require "$boardsdir/forum.master";

	foreach $catid (@categoryorder) {
		$boardlist = $cat{$catid};
		(@bdlist) = split(/\,/, $boardlist);

		foreach $curboard (@bdlist) {
			if ($FORM{ $curboard . 'check' } == 1) {

				fopen(BOARDFILE, "$boardsdir/$curboard.txt");
				@threads = <BOARDFILE>;
				fclose(BOARDFILE);

				$keep_sticky = $FORM{'keep_them'} == 1 ? 1 : 0;

				fopen(BOARDFILE, ">$boardsdir/$curboard.txt", 1);
				for ($a = 0; $a < @threads; $a++) {
					($num, $dummy, $dummy, $dummy, $date1, $dummy, $dummy, $dummy, $status) = split(/\|/, $threads[$a]);

					# Check if original thread was sticky
					if ($keep_sticky && $status =~ /s/i) {
						print BOARDFILE $threads[$a];
						$yymain .= "$num : Sticky topic<br />";
					} else {
						&calcdifference;
						if ($result <= $FORM{'maxdays'}) {

							# If the message is not too old
							print BOARDFILE $threads[$a];
							$yymain .= "$num = $result $admin_txt{'122'}<br />";
						} else {
							$yymain .= "$num = $result $admin_txt{'122'} ($admin_txt{'123'})<br />";
							&RemoveThreadFiles($num);

							# now storing, quick rewrite boardfile!, after delete attached file
							$attachfile{$num} = 1;
						}
					}
				}
			}
			fclose(BOARDFILE);
			&BoardCountTotals($curboard);
			&BoardSetLastInfo($currentboard);
		}
	}

	# remove attachments on old topics if present
	fopen(AMP, "+<$vardir/attachments.txt", 1) || &admin_fatal_error("$txt{'23'} $vardir/attachments.txt", 1);
	seek AMP, 0, 0;
	my @buffer = <AMP>;
	truncate AMP, 0;
	for ($a = 0; $a < @buffer; $a++) {
		chomp $buffer[$a];
		($num, $dummy, $dummy, $dummy, $dummy, $dummy, $dummy, $amfn) = split(/\|/, $buffer[$a]);
		if (exists($attachfile{$num})) {
			$buffer[$a] = "";
			unlink("$uploaddir/$amfn");
		}
	}
	seek AMP, 0, 0;
	print AMP @buffer;
	fclose(AMP);
	undef %attachfile;
	$action_area = "removeoldthreads";
	&AdminTemplate;
	exit;
}

1;
