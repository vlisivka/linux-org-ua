###############################################################################
# System.pl                                                                   #
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

$systemplver = 'YaBB 2.1 $Revision: 1.2 $';

sub BoardTotals {
	my ($job, @updateboards) = @_;
	my ($testboard, $line, @lines, $updateboard, @boardvars, $tag, $cnt);
	if (!@updateboards) { @updateboards = @allboards; }
	if ($job eq "convert") {
		fopen(FORUMTOTALS, ">>$boardsdir/forum.totals");
		foreach $testboard (@allboards) {
			chomp $testboard;
			fopen(BOARDTTL, "$boardsdir/$testboard.ttl");
			$line = <BOARDTTL>;
			fclose(BOARDTTL);
			chomp $line;
			print FORUMTOTALS "$testboard|$line|\n";
			unlink "$boardsdir/$testboard.ttl";
		}
		fclose(FORUMTOTALS);
	}
	if (@updateboards) {
		if ($job eq "load") {
			fopen(FORUMTOTALS, "$boardsdir/forum.totals");
			@lines = <FORUMTOTALS>;
			fclose(FORUMTOTALS);
			my @tags = qw(board threadcount messagecount lastposttime lastposter lastpostid lastreply lastsubject lasticon);
			foreach $line (@lines) {
				chomp $line;
				(@boardvars) = split(/\|/, $line);
				foreach $updateboard (@updateboards) {
					chomp $updateboard;
					if ($boardvars[0] eq $updateboard && exists($board{ $boardvars[0] })) {
						$loadedboards++;
						for ($cnt = 1; $cnt < $#tags; $cnt++) {
							${$uid.$updateboard}{ $tags[$cnt] } = $boardvars[$cnt];
						}
					}
				}
			}
		}
		if ($job eq "update") {
			fopen(FORUMTOTALS, "+<$boardsdir/forum.totals");
			seek FORUMTOTALS, 0, 0;
			@lines = <FORUMTOTALS>;
			truncate FORUMTOTALS, 0;
			seek FORUMTOTALS, 0, 0;
			my @tags = qw(board threadcount messagecount lastposttime lastposter lastpostid lastreply lastsubject lasticon);
			print FORUMTOTALS "$updateboards[0]|";
			for ($cnt = 1; $cnt <= $#tags; $cnt++) {
				print FORUMTOTALS ${$uid.$updateboards[0]}{ $tags[$cnt] };
				if ($cnt < $#tags) { print FORUMTOTALS "|"; }
			}
			print FORUMTOTALS "\n";
			foreach $line (@lines) {
				chomp $line;
				(@boardvars) = split(/\|/, $line);
				if ($boardvars[0] ne $updateboards[0] && exists($board{ $boardvars[0] })) {
					print FORUMTOTALS "$line\n";
					$loadedboards++;
				}
			}
			fclose(FORUMTOTALS);
		}
		if ($job eq "delete") {
			fopen(FORUMTOTALS, "$boardsdir/forum.totals");
			seek FORUMTOTALS, 0, 0;
			@lines = <FORUMTOTALS>;
			truncate FORUMTOTALS, 0;
			seek FORUMTOTALS, 0, 0;
			foreach $line (@lines) {
				chomp $line;
				(@boardvars) = split(/\|/, $line);
				if ($boardvars[0] ne $updateboards[0] && exists($board{ $boardvars[0] })) {
					print FORUMTOTALS "$line\n";
					$loadedboards++;
				}
			}
			fclose(FORUMTOTALS);
		}
		if ($job eq "add") {
			fopen(FORUMTOTALS, "$boardsdir/forum.totals");
			seek FORUMTOTALS, 0, 0;
			@lines = <FORUMTOTALS>;
			truncate FORUMTOTALS, 0;
			seek FORUMTOTALS, 0, 0;
			print FORUMTOTALS "$updateboards[0]|0|0|N/A|N/A||||\n";
			print FORUMTOTALS @lines;
			fclose(FORUMTOTALS);
		}
	}
}

sub BoardInfo {
	my (@boards) = @_;
	my ($lspostid, $lssub, $lsposttime, $lsposter, $lsreply, $lsdatetime, $lastthreadtime, $output, @loadboards);

	# first get all the boards based on the categories found in forum.master
	if ($boards[0] eq "all") {
		foreach $catid (@categoryorder) {
			if ($INFO{'catselect'} ne $catid && $INFO{'catselect'}) { next; }
			$boardlist = $cat{$catid};
			(@bdlist) = split(/\,/, $boardlist);
			my ($catname, $catperms, $catallowcol) = split(/\|/, $catinfo{"$catid"});

			# Category Permissions Check
			$cataccess = &CatAccess($catperms);
			if (!$cataccess) { next; }

			# next determine all the boards a user has access to
			foreach $curboard (@bdlist) {
				# now fill all the neccesary hashes to show all board index stuff
				chomp $curboard;
				my $access = &AccessCheck($curboard, '', $boardperms);
				if (!$iamadmin && $access ne "granted" && $boardview != 1) { next; }
				push(@loadboards, $curboard);
			}
		}
	} else {
		foreach $curboard (@boards) {
			# now fill all the neccesary hashes to show all board index stuff
			chomp $curboard;
			my $access = &AccessCheck($curboard, '', $boardperms);
			if (!$iamadmin && $access ne "granted" && $boardview != 1) { next; }
			push(@loadboards, $curboard);
		}
	}
	&BoardTotals("load", @loadboards);
	foreach $curboard (@loadboards) {
		chomp $curboard;
		$lastposttime = ${$uid.$curboard}{'lastposttime'};
		$lastposttime{$curboard} = &timeformat(${$uid.$curboard}{'lastposttime'});
		${$uid.$curboard}{'lastposttime'} = ${$uid.$curboard}{'lastposttime'} eq 'N/A' || !${$uid.$curboard}{'lastposttime'} ? $boardindex_txt{'470'} : ${$uid.$curboard}{'lastposttime'};
		$lastpostrealtime{$curboard} = ${$uid.$curboard}{'lastposttime'} eq 'N/A' || !${$uid.$curboard}{'lastposttime'} ? '' : ${$uid.$curboard}{'lastposttime'};
		if (${$uid.$curboard}{'lastposter'} =~ m~\AGuest-(.*)~) {
			${$uid.$curboard}{'lastposter'} = $1;
			$lastposterguest{$curboard} = 1;
		}
		${$uid.$curboard}{'lastposter'}   = ${$uid.$curboard}{'lastposter'} eq 'N/A' || !${$uid.$curboard}{'lastposter'} ? $boardindex_txt{'470'} : ${$uid.$curboard}{'lastposter'};
		${$uid.$curboard}{'messagecount'} = ${$uid.$curboard}{'messagecount'}        || 0;
		${$uid.$curboard}{'threadcount'}  = ${$uid.$curboard}{'threadcount'}         || 0;
		$totalm += ${$uid.$curboard}{'messagecount'};
		$totalt += ${$uid.$curboard}{'threadcount'};

		# determine the true last post on all the boards a user has access to
		if ($lastposttime > $lastthreadtime) {
			$lsdatetime     = &timeformat($lastposttime);
			$lsposter       = ${$uid.$curboard}{'lastposter'};
			$lssub          = ${$uid.$curboard}{'lastsubject'};
			$lspostid       = ${$uid.$curboard}{'lastpostid'};
			$lsreply        = ${$uid.$curboard}{'lastreply'};
			$lastthreadtime = $lastposttime;
			$output         = qq~$lastthreadtime|$lsposter|$lssub|$lspostid|$lsreply~;
		}
	}
	return $output;
}

#### THREAD MANAGEMENT ####

sub MessageTotals {
	# usage: &MessageTotals("task",<threadid>)
	# tasks: load, update, recover
	my ($job, $updatethread) = @_;
	my @tag = qw(board replies views lastposter lastpostdate threadstatus);
	my ($line, $views, $dummy, @msgs, @ctb, $data, $cnt);
	chomp $updatethread;
	if ($job eq "convert") {
		opendir(MSGDIR, $datadir);
		@msglist = grep { /\.data$/ } readdir(MSGDIR);
		closedir(MSGDIR);
		foreach $line (@msglist) {
			chomp $file;
			$line = substr($line, 0, length($file) - 5);
			push(@msgs, $line);
		}
		foreach $line (@msgs) {
			chomp $line;
			fopen(CTB, "$datadir/$line.ctb");
			@ctb = <CTB>;
			fclose(CTB);
			fopen(DATA, "$datadir/$line.data");
			$data = <DATA>;
			fclose(DATA);
			($views, $lastposter) = split(/\|/, $data);
			chomp $lastposter;
			fopen(CTB, ">$datadir/$line.ctb");
			print CTB @ctb;
			print CTB "$views\n";
			print CTB "$lastposter\n";
			print CTB "$lastpostdate\n";
			print CTB "0\n";
			fclose(CTB);
			unlink "$datadir/$line.data";
		}
	}
	if ($updatethread ne "") {
		if ($job eq "update") {
			fopen(CTB, ">$datadir/$updatethread.ctb");
			for ($cnt = 0; $cnt <= $#tag; $cnt++) {
				print CTB "${$updatethread}{$tag[$cnt]}\n";
			}
			foreach (@repliers) {
				print CTB "$_\n";
			}
			fclose(CTB);
		}
		if ($job eq "load") {
			fopen(CTB, "$datadir/$updatethread.ctb");
			@ctb = <CTB>;
			fclose(CTB);
			for ($cnt = 0; $cnt <= $#tag; $cnt++) {
				chomp $ctb[$cnt];
				# Remove Win linebreaks in case we've moved from win->*nix servers
				$ctb[$cnt] =~ s~\r~~g;
				${$updatethread}{ $tag[$cnt] } = $ctb[$cnt];
			}
			$repstart = $#tag + 1;
			$reps     = 0;
			@repliers = ();
			for ($repcnt = $repstart; $repcnt < @ctb; $repcnt++) {
				chomp $ctb[$repcnt];
				$repliers[$reps] = $ctb[$repcnt];
				$reps++;
			}
		}
		if ($job eq "incview") {
			fopen(CTB, "+<$datadir/$updatethread.ctb");
			seek CTB, 0, 0;
			@ctb = <CTB>;
			seek CTB, 0, 0;
			truncate CTB, 0;
			for ($cnt = 0; $cnt <= $#tag; $cnt++) {
				chomp $ctb[$cnt];
				${$updatethread}{ $tag[$cnt] } = $ctb[$cnt];
			}
			${$updatethread}{'views'}++;
			$repstart = $#tag + 1;
			$reps     = 0;
			@repliers = ();
			for ($repcnt = $repstart; $repcnt < @ctb; $repcnt++) {
				chomp $ctb[$repcnt];
				$repliers[$reps] = $ctb[$repcnt];
				$reps++;
			}
			for ($cnt = 0; $cnt <= $#tag; $cnt++) {
				print CTB "${$updatethread}{$tag[$cnt]}\n";
			}
			foreach (@repliers) {
				print CTB "$_\n";
			}
			fclose(CTB);
		}
		if ($job eq "incpost") {
			fopen(CTB, "+<$datadir/$updatethread.ctb");
			seek CTB, 0, 0;
			@ctb = <CTB>;
			seek CTB, 0, 0;
			truncate CTB, 0;
			for ($cnt = 0; $cnt <= $#tag; $cnt++) {
				chomp $ctb[$cnt];
				${$updatethread}{ $tag[$cnt] } = $ctb[$cnt];
			}
			${$updatethread}{'replies'}++;
			$repstart = $#tag + 1;
			$reps     = 0;
			@repliers = ();
			for ($repcnt = $repstart; $repcnt < @ctb; $repcnt++) {
				chomp $ctb[$repcnt];
				$repliers[$reps] = $ctb[$repcnt];
				$reps++;
			}
			for ($cnt = 0; $cnt <= $#tag; $cnt++) {
				print CTB "${$updatethread}{$tag[$cnt]}\n";
			}
			foreach (@repliers) {
				print CTB "$_\n";
			}
			fclose(CTB);
		}
		if ($job eq "decpost") {
			fopen(CTB, "+<$datadir/$updatethread.ctb");
			seek CTB, 0, 0;
			@ctb = <CTB>;
			seek CTB, 0, 0;
			truncate CTB, 0;
			for ($cnt = 0; $cnt <= $#tag; $cnt++) {
				chomp $ctb[$cnt];
				${$updatethread}{ $tag[$cnt] } = $ctb[$cnt];
			}
			${$updatethread}{'replies'}--;
			$repstart = $#tag + 1;
			$reps     = 0;
			@repliers = ();
			for ($repcnt = $repstart; $repcnt < @ctb; $repcnt++) {
				chomp $ctb[$repcnt];
				$repliers[$reps] = $ctb[$repcnt];
				$reps++;
			}
			for ($cnt = 0; $cnt <= $#tag; $cnt++) {
				print CTB "${$updatethread}{$tag[$cnt]}\n";
			}
			foreach (@repliers) {
				print CTB "$_\n";
			}
			fclose(CTB);
		}
		if ($job eq "recover" && $binboard) {
			fopen(MSG, "$datadir/$updatethread.txt");
			my @dummy = <MSG>;
			fclose(MSG);
			my $mreplies = $#dummy;
			my ($tmpa, $tmpa, $tmpa, $tmpa, $lastposter, $tmpa) = split(/\|/, $dummy[0]);
			if (-e "$datadir/$INFO{'thread'}.data") {
				fopen(FILE, "$datadir/$INFO{'thread'}.data");
				$tmpa = <FILE>;
				fclose(FILE);
				($datviews, $dummy) = split(/\|/, $tmpa);
				$views = $datviews || 0;
			}
			my (@ctb);
			$ctb[0] = "$binboard\n";
			$ctb[1] = "$mreplies\n";
			$ctb[2] = "$views\n";
			$ctb[3] = "$lastposter\n";
			$ctb[4] = "0\n";
			$ctb[5] = "0\n";
			fopen(CTB, ">$datadir/$updatethread.ctb");
			print CTB @ctb;
			fclose(CTB);
		}
	}
}

# NOBODY expects the Spanish Inquisition!
# - Monty Python

#### USER AND MEMBERSHIP MANAGEMENT ####

sub UserAccount {
	my ($user, $action, $pars) = @_;
	@labels = split(/\+/, $pars);
	if (!${$uid.$user}{'password'}) { return 0; }
	if (!${$uid.$user}{'timeformat'}) { ${$uid.$user}{'timeformat'} = qq~MM D+ YYYY @ HH:mm:ss*~; }
	if ($action eq "update") {
		foreach $label (@labels) {
			chomp $label;
			${$uid.$user}{$label} = $date;
		}
		$userext = "vars";
	}
	if ($action eq "preregister") {
		$userext = "pre";
	}
	if ($action eq "register") {
		$userext = "vars";
	}
	if ($action eq "delete") {
		if (-e "$memberdir/$user.vars") { unlink "$memberdir/$user.vars"; }
		return 0;
	}
	if (!$userext) { $userext = "vars"; }

	# using sequential tag writing as hashes do no sort the way we like them to
	my @tags = qw(password realname email regdate webtitle weburl signature postcount position addgroups icq aim yim gender usertext userpic regtime location bday timeselect timeoffset timeformat hidemail msn gtalk template language lastonline lastpost lastim im_ignorelist im_notify im_popup im_imspop cathide postlayout session sesquest sesanswer favorites dsttimeoffset pageindex);
	fopen(UPDATEUSER, ">$memberdir/$user.$userext");
	print UPDATEUSER "### User variables for ID: $user ###\n\n";
	for (my $cnt = 0; $cnt < @tags; $cnt++) {
		print UPDATEUSER "\'$tags[$cnt]\'\,\"${$uid.$user}{$tags[$cnt]}\"\n";
	}
	fclose(UPDATEUSER);
	if (-e "$memberdir/$user.dat") { unlink "$memberdir/$user.dat"; }
}

sub UserCheck {
	my ($user, $pars) = @_;
	%usercheck = "";
	$found     = 0;
	$pars =~ s/ //g;

	# Convert user to new file if dat file still exists
	if (-e "$memberdir/$user.dat") {
		&LoadUser($user);
		&UserAccount($user, "update");
	}
	@labels = split(/\+/, $pars);
	fopen(CHECKUSER, "$memberdir/$user.vars");
	my @settings = <CHECKUSER>;
	fclose(CHECKUSER);
	foreach $label (@labels) {
		chomp $label;
		foreach my $setting (@settings) {
			chomp $setting;
			$setting =~ m/\'(.+?)\'\,\"(.+?)\"/;
			my $tag   = $1;
			my $value = $2;
			if ($label eq $tag) { $usercheck{$tag} = $value; last; }
			if ($label eq "all") { $usercheck{$tag} = $value; }
		}
	}
}

sub MemberIndex {
	my ($memaction, $user) = @_;
	if ($memaction eq "add" && -e "$memberdir/$user.vars") {
		&UserCheck($user, "realname+email+regdate+position+postcount");
		$theregdate = &stringtotime($usercheck{'regdate'});
		$theregdate = sprintf("%010d", $theregdate);
		if (!$usercheck{'postcount'}) { $usercheck{'postcount'} = 0; }
		if (!$usercheck{'position'})  { $usercheck{'position'}  = &MemberPostGroup($usercheck{'postcount'}); }
		&ManageMemberlist("add", $user, $theregdate);
		&ManageMemberinfo("add", $user, $usercheck{'realname'}, $usercheck{'email'}, $usercheck{'position'}, $usercheck{'postcount'});
		fopen(TTL, "$memberdir/members.ttl");
		$buffer = <TTL>;
		fclose(TTL);
		($membershiptotal, undef) = split(/\|/, $buffer);
		$membershiptotal++;
		fopen(TTL, ">$memberdir/members.ttl");
		print TTL qq~$membershiptotal|$user~;
		fclose(TTL);
		return 0;
	}
	if ($memaction eq "remove" && $user) {
		&ManageMemberlist("delete", $user);
		&ManageMemberinfo("delete", $user);
		require "$sourcedir/Notify.pl";
		&removeNotifications($user);
		fopen(MEMLIST, "$memberdir/memberlist.txt");
		@memberlt = <MEMLIST>;
		fclose(MEMLIST);
		my $membershiptotal = @memberlt;
		my ($lastuser, undef) = split(/\t/, $memberlt[$#memberlt], 2);
		fopen(TTL, ">$memberdir/members.ttl");
		print TTL qq~$membershiptotal|$lastuser~;
		fclose(TTL);
		return 0;
	}
	if ($memaction eq "check_exist" && $user) {
		&ManageMemberinfo("load");
		while (($curmemb, $value) = each(%memberinf)) {
			($curname, $curmail, $curposition, $curpostcnt) = split(/\|/, $value);
			if    (lc $user eq lc $curmemb) { undef %memberinf; return $curmemb; }
			elsif (lc $user eq lc $curmail) { undef %memberinf; return $curmail; }
			elsif (lc $user eq lc $curname) { undef %memberinf; return $curname; }
		}
	}
	if ($memaction eq "rebuild") {
		&is_admin_or_gmod;
		$regcounter = 0;
		opendir(MEMBERS, $memberdir) || die "$txt{'230'} ($memberdir) :: $!";
		@contents = grep { /\.vars$/ } readdir(MEMBERS);
		closedir(MEMBERS);
		&ManageMemberlist("load");
		&ManageMemberinfo("load");
		foreach $member (@contents) {
			chomp $member;
			$member =~ s/\.vars$//g;
			if ($member) {
				$grpdel   = 0;
				$grpexist = "";
				&UserCheck($member, "realname+email+regdate+position+addgroups+postcount");
				(@addigroups) = split(/\,/, $usercheck{'addgroups'});
				foreach $addigrp (@addigroups) {
					if (!exists $NoPost{$addigrp}) { $grpdel = 1; }
					else { $grpexist .= qq~$addigrp,~; }
				}
				$actposition = $usercheck{'position'};
				if (!exists $Group{$actposition} && !exists $NoPost{$actposition}) {
					$usercheck{'position'} = "";
					$grpdel = 1;
				}
				if ($grpdel) {
					if (!${$uid.$member}{'password'}) { &LoadUser($member); }
					$grpexist =~ s/,\Z//;
					${$uid.$member}{'addgroups'} = qq~$grpexist~;
					${$uid.$member}{'position'}  = $usercheck{'position'};
					&UserAccount($member, "update");
				}
				$regtime = stringtotime($usercheck{'regdate'});
				$formatregdate = sprintf("%010d", $regtime);
				if (!$usercheck{'position'}) { $usercheck{'position'} = &MemberPostGroup($usercheck{'postcount'}); }
				$memberlist{$member} = qq~$formatregdate~;
				$memberinf{$member}  = qq~$usercheck{'realname'}\|$usercheck{'email'}\|$usercheck{'position'}\|$usercheck{'postcount'}\|${$uid.$member}{'addgroups'}~;
				$regcounter++;
			}
		}
		&ManageMemberlist("save");
		&ManageMemberinfo("save");
		&MembershipCountTotal;
		return 0;
	}
}

sub MemberPostGroup {
	$userpostcnt = $_[0];
	$grtitle     = "";
	foreach $postamount (sort { $b <=> $a } keys %Post) {
		if ($userpostcnt > $postamount) {
			($grtitle, undef) = split(/\|/, $Post{$postamount}, 2);
			last;
		}
	}
	return $grtitle;
}

sub MembershipCountTotal {
	fopen(MEMBERLISTREAD, "$memberdir/memberlist.txt");
	my @num = <MEMBERLISTREAD>;
	fclose(MEMBERLISTREAD);
	($latestmember, $meminfo) = split(/\t/, $num[$#num]);
	my $membertotal = $#num + 1;
	undef @num;

	fopen(MEMTTL, ">$memberdir/members.ttl");
	print MEMTTL qq~$membertotal|$latestmember~;
	fclose(MEMTTL);

	if (wantarray()) {
		&ManageMemberinfo("load");
		($latestrealname, undef) = split(/\|/, $memberinf{$latestmember}, 2);
		undef %memberinf;
		return ($membertotal, $latestmember, $latestrealname);
	} else {
		return $membertotal;
	}
}

#### TEMPLATE MANAGEMENT ####

sub UpdateTemplates {
	my ($tempelement, $tempjob) = @_;
	unless ($templatesloaded == 1) {
		require "$vardir/template.cfg";
	}
	if ($tempjob eq "new") {
		require "$templatesdir/$tempelement/$tempelement.cfg";
		if ($template_name !~ m^\A[0-9a-zA-Z_\Є\ \.\#\%\-\:\+\?\$\&\~\.\,\@/]+\Z^ || $template_name eq "") { $template_name = "Invalid Name in $tempelement.cfg"; }
		$testname = $template_name;
		$i        = 1;
		while (($curtemplate, $value) = each(%templateset)) {
			if (lc $curtemplate eq lc $testname) {
				$testname = qq~$template_name ($i)~;
				$i++;
			}
		}
		if ($template_css) { $templateset{"$testname"} = "$tempelement"; }
		else { $templateset{"$testname"} = "default"; }
		if ($template_images) { $templateset{"$testname"} .= "|$tempelement"; }
		else { $templateset{"$testname"} .= "|default"; }
		if ($template_head) { $templateset{"$testname"} .= "|$tempelement"; }
		else { $templateset{"$testname"} .= "|default"; }
		if ($template_board) { $templateset{"$testname"} .= "|$tempelement"; }
		else { $templateset{"$testname"} .= "|default"; }
		if ($template_message) { $templateset{"$testname"} .= "|$tempelement"; }
		else { $templateset{"$testname"} .= "|default"; }
		if ($template_display) { $templateset{"$testname"} .= "|$tempelement"; }
		else { $templateset{"$testname"} .= "|default"; }
		fopen(UPDATETEMPLATE, ">$vardir/template.cfg");
		print UPDATETEMPLATE "\$templatesloaded = 1;\n";

		while (($key, $value) = each(%templateset)) {
			print UPDATETEMPLATE qq~\$templateset{'$key'} = "$value";\n~;
		}
		fclose(UPDATETEMPLATE);
		unlink "$templatesdir/$tempelement/$tempelement.cfg";
	}
	if ($tempjob eq "save") {
		$template_name = $tempelement;
		$templateset{"$template_name"} = "$template_css";
		$templateset{"$template_name"} .= "|$template_images";
		$templateset{"$template_name"} .= "|$template_head";
		$templateset{"$template_name"} .= "|$template_board";
		$templateset{"$template_name"} .= "|$template_message";
		$templateset{"$template_name"} .= "|$template_display";
		fopen(UPDATETEMPLATE, ">$vardir/template.cfg");
		print UPDATETEMPLATE "\$templatesloaded = 1;\n";

		while (($key, $value) = each(%templateset)) {
			print UPDATETEMPLATE qq~\$templateset{'$key'} = "$value";\n~;
		}
		fclose(UPDATETEMPLATE);
	}
	if ($tempjob eq "delete") {
		fopen(UPDATETEMPLATE, ">$vardir/template.cfg");
		print UPDATETEMPLATE "\$templatesloaded = 1;\n";
		while (($key, $value) = each(%templateset)) {
			if ($key ne $tempelement) { print UPDATETEMPLATE qq~\$templateset{'$key'} = "$value";\n~; }
		}
		fclose(UPDATETEMPLATE);
	}
	$templatesloaded = 0;
}

sub CheckNewTemplates {
	opendir(TMPLDIR, "$templatesdir");
	@configs = readdir(TMPLDIR);
	closedir(TMPLDIR);
	foreach $file (@configs) {
		if (-e "$templatesdir/$file/$file.cfg") {
			&UpdateTemplates($file, "new");
		}
	}
}

sub MakeStealthURL {
	# Usage is simple - just call MakeStealthURL with any url, and it will stealthify it.
	# if stealth urls are turned off, it just gives you the same value back
	$theurl = $_[0];

	if ($stealthurl) {
		$theurl =~ s~([^\w\"\=\[\]]|[\n\b]|\A)\\*(\w+://[\w\~\.\;\:\,\$\-\+\!\*\?/\=\&\@\#\%]+\.[\w\~\;\:\$\-\+\!\*\?/\=\&\@\#\%]+[\w\~\;\:\$\-\+\!\*\?/\=\&\@\#\%])~$boardurl/YaBB.$yyext?action=dereferer;url=$2~isg;
		$theurl =~ s~([^\"\=\[\]/\:\.(\://\w+)]|[\n\b]|\A)\\*(www\.[^\.][\w\~\.\;\:\,\$\-\+\!\*\?/\=\&\@\#\%]+\.[\w\~\;\:\$\-\+\!\*\?/\=\&\@\#\%]+[\w\~\;\:\$\-\+\!\*\?/\=\&\@\#\%])~$boardurl/YaBB.$yyext?action=dereferer;url=http://$2~isg;
	}

	return $theurl;
}

sub arraysort {
	# usage: &arraysort(1,"|","R",@array_to_sort);

	my ($sortfield, $delimiter, $reverse, @in) = @_;
	my (@sk, @out, @sortkey, %newline, $oldline, $n);
	foreach $oldline (@in) {
		@sk = split(/$delimiter/, $oldline);
		$sk[$sortfield] = "$sk[$sortfield]-$n";    ## make sure that identical keys are avoided ##
		$n++;
		$newline{ $sk[$sortfield] } = $oldline;
	}
	@sortkey = sort keys %newline;
	if ($reverse) {
		@sortkey = reverse @sortkey;
	}
	foreach (@sortkey) {
		push(@out, $newline{$_});
	}
	return @out;
}

1;
