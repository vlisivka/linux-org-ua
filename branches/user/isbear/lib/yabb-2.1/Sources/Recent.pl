###############################################################################
# Recent.pl                                                                   #
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

our $action;

our $recentplver = 'YaBB 2.1 $Revision: 1.1 $';
if ($action eq 'detailedversion') { return 1; }

use strict;
use warnings;
no strict qw(refs); # ${$uid.$username}{...}

our (%INFO, %FORM);
our (%img, %img_txt, %img_polltxt, %txt, %recent_txt, %maintxt);
our (%board, @categoryorder, %catinfo, %cat);
our ($mbname, $max_log_days_old, $tlnomodflag, $tlnomodtime, $tlnodelflag, $tlnodeltime, $enable_ubbc, $enable_notification);
our ($memberdir, $datadir, $imagesdir, $boardsdir, $uploaddir, $sourcedir);
our ($scripturl, $forumstylesurl, $uploadurl, $usestyle, $imgext, $menusep);
our ($yymain, $yytitle, $yyinlinestyle, %yyuserlog, $yySetLocation, $yyYaBBCloaded);
our ($iamguest, $iamadmin, $username, $uid, $date, %useraccount);
our ($mloaded, %loaded);

LoadLanguage ( 'Recent' );

# Sub RecentTopics shows all the most recently posted topics
# Meaning each thread will show up ONCE in the list.
# removed - have no use

# Sub RecentPosts will show the 10 last POSTS
# Even if they are all from the same thread

# Sub RecentTopicList is just a plain list (without body text)
# Same as Sub RecentTopics.

sub nm_user_struct {
	my $id = shift;
	my %retval;

	$retval{nick} = shift;

	# load user just to know, if he is ex... o_O
	# but... and this requires extra arg - date...
	# so, skipping that check - usually it is extra work to do
	if ( $id eq 'Guest' ) {
		$retval{type} = 'guest';
	} elsif ( -e "$memberdir/$id.vars" ) {
#		$retval{uid}  = $id;
		$retval{url}  = "$scripturl?action=viewprofile;username=$id";
		$retval{type} = 'user';
	} else {
		$retval{type} = 'ex';
	}

	return \%retval
}

# No big need in this sub, just lasting shorthand
sub nm_template_user {
	my $user   = shift;
	my $retval = $user->{nick};

	if ( $user->{type} eq 'guest' ) {
		$retval .= $recent_txt{guest};
	} elsif ( $user->{type} eq 'ex' ) {
		$retval .= $recent_txt{ex};
	}

	# Guest-check is actually a "control" - move from here?
	if ( exists $user->{url} and not $iamguest ) {
		$retval = qq(<a href="$user->{url}" >$retval</a>)
	}

	return $retval
}

# FIXME
sub nm_menu_struct {
	return map {
		\{
			url  => "$scripturl?action=$_",
			name => "$img{$_}",
		}
	} @_;
}

sub nm_template_menu {
	my $menu = shift;

	if ( not ref $menu or not @$menu ) {
		return '';
	}

	my $menusep = qq( | );
	my $retval  = '';

	foreach my $button ( @{$menu} ) {

		my $retbutt = $button->{name};

		if ( exists $button->{url} ) {
			$retbutt = qq(<a href="$button->{url}" >$retbutt</a>)
		}

		$retval .= $menusep if length $retval;

		$retval .= $retbutt;
	}

	return qq(<div class="menu">$retval</div>);
}

sub nm_poll_struct {
	
	my $tid = shift;

	if ( not fopen ( *POLL, "< $datadir/$tid.poll" ) ) {
		return undef;
	}

	my $line = <POLL>;
	chomp $line;

	# hmm, there can be 9, 11, 12, 13 fields. What is 13th?
	my ( $sub, $locked, $puid, $nick, $mail, $pdate,
	     $guest_vote, $hide_results, $multi_vote,
		 undef, undef, $comment, undef ) = split /\|/, $line;
	if (not defined $comment) {
		$comment = '';
	}

 	my @retopts;

 	while (<POLL>) {
		chomp;

		my ( $votes, $variant ) = split /\|/, $_;

		push @retopts, {
			name  => $variant,
			votes => $votes,
		}
	}
	
	fclose ( *POLL );

	# FIXME
	my @pollmenu;

	# FIXME
	our $have_poll_access;
	if ( not $locked and $puid eq $username and $have_poll_access ) { # FIXME
		if ( not $tlnomodflag or $pdate + $tlnomodtime * 60 * 60 * 24 > $date ) {
			push @pollmenu, {
				name => $img_polltxt{39},
				url  => qq($scripturl?action=modify;thread=$tid;message=Poll), # FIXME
			}
		}

		if ( not $tlnodelflag or $pdate + $tlnodeltime * 60 * 60 * 24 > $date ) {
			push @pollmenu, {
				name => $img_polltxt{27},
				url  => qq($scripturl?action=post;num=$tid;title=AddPoll), # FIXME
			}
		}
	}

	my %retpoll = (
		id    => $tid,
		name  => $sub,
		date  => $pdate,
		owner => nm_user_struct ( $puid, $nick ),
		text  => $comment,
		opts  => \@retopts,
	);

	$retpoll{menu} = \@pollmenu if @pollmenu;

	return \%retpoll;
}

# template - I separated this to see, how it will be,
# if we will use templatetoolkit, this is just code, that
# emulates that.

sub nm_template {

	my $a = shift;

	foreach my $err ( @{$a->{err}} ) {
		$yymain .= qq(
		<div class="error" >
			<div class="title">$recent_txt{'etitle_file'}$err->{src}$recent_txt{'etitle_sub'}$err->{func}</div>
			$err->{text}
		</div>);
	}

	if ( not exists $a->{content} or not @{$a->{content}} ) {
		$yymain .= qq(
		<div class="error" >
			$recent_txt{err_nonewposts}
		</div>);
		
		$yytitle = $recent_txt{'nonewmesg_title'};
		$yyinlinestyle = qq(<link rel="stylesheet" type="text/css" href="$forumstylesurl/$usestyle/new_messages.css" />);
		
		template;

		return;
	}

	my $navbar = qq(<a href="$scripturl" >$mbname</a>);
	my $nbsep  = q( &raquo; );

	$yymain .= qq(
	<form action="$scripturl?action=newmarkread;date=$date" method="post" >); #???

	foreach my $curcat ( @{$a->{content}} ){

		ToChars $curcat->{name};
		my $navbar = qq($navbar$nbsep<a href="$scripturl?catselect=$curcat->{id}">$curcat->{name}</a>);

		$yymain .= qq(
		<div class="category" >);

		foreach my $curboard ( @{$curcat->{n}} ) {

			ToChars $curboard->{name};
			my $navbar = qq($navbar$nbsep<a href="$scripturl?board=$curboard->{id}">$curboard->{name}</a>);

			$yymain .= qq(
			<div class="board" >);

			foreach my $curthread ( @{$curboard->{n}}) {

				ToChars $curthread->{name};
				my $navbar  = qq($navbar$nbsep<a href="$scripturl?num=$curthread->{id}">$curthread->{name}</a>);
				my $author  = nm_template_user $curthread->{owner};
				my $started = timeformat       $curthread->{date};
				# FIXME: add state handling?
				my $icon    = qq(<img src="$imagesdir/$curthread->{icon}.$imgext" class="icon" />);
				my $menu    = nm_template_menu $curthread->{menu};

				$yymain .= qq(
				<div class="thread" >
					<div class="title" >
						$icon <div class="subject" >$navbar</div>
						<div class="mark" >$recent_txt{mark}<input type="checkbox" name="tid$curthread->{id}" checked="checked" /></div>
						$recent_txt{started}$author$recent_txt{on}$started
					</div>);

				if ( exists $curthread->{poll} ) {
					my $curpoll = $curthread->{poll};

					ToChars $curpoll->{name};
					my $author = nm_template_user $curpoll->{owner};
					my $posted = timeformat       $curpoll->{date};
					my $menu   = nm_template_menu $curpoll->{menu};
					my $text   = $curpoll->{text}; # FIXME

					$yymain .= qq(
					<div class="poll" >
						<div class="title" >
							<div class="subject" >$curpoll->{name}</div>
							$recent_txt{posted}$author$recent_txt{on}$posted
						</div>
						<div class="message" >
							$text
						</div>);
					
					my $total = 0;

					foreach my $curopt ( @{$curpoll->{opts}} ) {
						$total += $curopt->{votes}
					}

					foreach my $curopt ( @{$curpoll->{opts}} ) {

						my $image = '';

						if ( $total ) { # FIXME that all :(
							my $percent = int ( $curopt->{votes} * 100 / $total );
							# all goes to css except width.
							$image = qq(<div class="image" style="width: 30%; height: 1em; margin-right: 10%; float: right" ><img src="$imagesdir/poll_left.gif" /><img src="$imagesdir/poll_middle.gif" style="width: $percent%; height: inherit" alt="$percent\%" /><img src="$imagesdir/poll_right.gif" /></div>);
						}

						$yymain .= qq(
						<div class="option">$image<div class="num" style="margin-right: 1em; width: 2em; font-weight: bold; float: right" >$curopt->{votes}</div> $curopt->{name}</div>);
					}

					$yymain .= qq(
						$menu
					</div>);
				}
				
				foreach my $curpost ( @{$curthread->{n}} ) {

					ToChars $curpost->{name};
					my $subject = Censor           $curpost->{name};
					my $author  = nm_template_user $curpost->{owner};
					my $posted  = timeformat       $curpost->{date};
					my $menu    = nm_template_menu $curpost->{menu};

					our $message = Censor $curpost->{text}; # damned globals
					wrap; # ...
					if ( $enable_ubbc ) {
						if ( not $loaded{'YaBBC.pl'} ) {
							require "$sourcedir/YaBBC.pl"
						}

						our $ns;
						if ( exists $curpost->{nosm} ) {
							$ns = 'NS'; # the same...
						} else {
							undef $ns
						}

						our $displayname = $curpost->{owner}->{nick}; # ...
						&DoUBBC;
					}
					wrap2; # >:(
					ToChars $message; # hate that...

					my $icon     = qq(<img src="$imagesdir/$curpost->{icon}.$imgext" class="icon" />);

					my $file = '';
					if ( exists $curpost->{file} ) {
						$file = qq(<div class="attachment" >
							<a href="$uploadurl/$curpost->{file}" target="_blank" >
								<img src="$imagesdir/paperclip.gif" class="icon" />
								$curpost->{file}
							</a>
						</div>);
					}
					
					$yymain .= qq(
					<div class="post" >
						<div class="title" >
							<div class="num" >$curpost->{num}</div>
							$icon
							<div class="subject" ><a href="$scripturl?num=$curthread->{id}/$curpost->{num}\#$curpost->{num}" >$subject</a></div>
							$recent_txt{posted}$author$recent_txt{on}$posted
						</div>
						<div class="message">
							$message
						</div>
						$file
						$menu
					</div>);
				}

				$yymain .= qq(
					$menu
				</div>);
			}

			$yymain .= qq(
			</div>);
		}

		$yymain .= qq(
		</div>);
	}

	$yymain .= qq(
		<input id="markreadsubmit" type="submit" name="markread" value="$recent_txt{markbutton}" />
	</form>);

	$yytitle = $recent_txt{'newmesg_title'};

	$yyinlinestyle = qq(<link rel="stylesheet" type="text/css" href="$forumstylesurl/$usestyle/new_messages.css" />);

	template;
}

sub new_messages {

	spam_protection;

	if ( $iamguest ) {
		fatal_error $recent_txt{'err_noguest'}
	}

	my %show_boards;
	my @retall;
	my @err;

	if ( exists $INFO{board} and exists $board{$INFO{board}} ) {

		$show_boards{$INFO{board}} = 1

	} elsif ( exists $INFO{catselect} and exists $cat{$INFO{catselect}} ) {

		%show_boards = map { $_ => 1 } split ( /,/, $cat{$INFO{catselect}} )

	} else {

		%show_boards = %board
	}

	my $oldest_date = $date - $max_log_days_old * 60 * 60 * 24;

	getlog;

	# cat:      id, name,
	#  board:   id, name
	#   thread: id = date, name, owner, menu, icon, state, poll
	#    poll:  id,  date, name, owner, menu, text
	#     opt:  name, votes
	#    post:  num, date, name, owner, menu, icon, text, nosm, file
	#
	# uid:      type, name, url
	#
	# menuitem: name, url # priority?

	foreach my $curcat ( @categoryorder ) {

		my ( $catname, $catperms ) = split /\|/, $catinfo{$curcat};

		if ( not CatAccess $catperms ) {
			next
		}

		my @retcat;

		NM_BOARD:
		foreach my $curboard ( split /,/, $cat{$curcat} ) {

			next if not exists $show_boards{$curboard};

			my ( $boardname, $boardperms, undef ) =	split /\|/, $board{$curboard};
			
			if ( AccessCheck ( $curboard, 0, $boardperms ) ne 'granted' ) {
				next
			}

			my $oldest_date = $oldest_date;

			if ( exists $yyuserlog{"$curboard--mark"} and $yyuserlog{"$curboard--mark"} > $oldest_date ) {
				$oldest_date = $yyuserlog{"$curboard--mark"}
			}
			
			if ( not fopen ( *BOARD, "< $boardsdir/$curboard.txt" ) ) {

				push @err, {
					func => 'new_messages',
					src  => 'Recent.pl',
					text => "$recent_txt{'err_cantopen'}'$boardsdir/$curboard.txt'"
				}; # FIXME: this can be generated in some way
				
				next NM_BOARD;
			};

			my ( $have_post_access, $have_reply_access );
			our $have_poll_access; # :( FIXME

			if ( AccessCheck ( $curboard, 1, $boardperms ) eq 'granted' ) {
				$have_post_access = 1
			}

			if ( AccessCheck ( $curboard, 2 ) eq 'granted' ) {
				$have_reply_access = 1
			}

			if ( AccessCheck ( $curboard, 3 ) eq 'granted' ) {
				$have_poll_access = 1
			}

			my @retboard;

			NM_THREAD:
			while ( <BOARD> ) {
				chomp;

				my ( $tid, $tsub, $tnick, $tmail, $lpdate, $replies,
				     $tuid, $ticon, $state ) = split /\|/, $_;
				if ( not defined $state ) {
					$state = '';
				}

				my $oldest_date = $oldest_date;

				# o_O
				if ( exists $yyuserlog{$tid} and
				     ( not exists $yyuserlog{"$tid--unread"} or
				       $yyuserlog{"$tid--unread"} < $yyuserlog{$tid} ) and
				     $yyuserlog{$tid} > $oldest_date ) {

					$oldest_date = $yyuserlog{$tid}
				}

				if ( $lpdate < $oldest_date ) {
					last # ?
				}
				
				if ( $state =~ /[mh]/ ) {
					next
				}

				my $retpoll;

				if ( -e "$datadir/$tid.poll" ) {

					$retpoll = nm_poll_struct $tid;

					if ( not $retpoll ) {
						# FIXME
						push @err, {
							func => 'new_messages',
							src  => 'Recent.pl',
							text => "$recent_txt{'err_cantopen'}'$datadir/$tid.poll'",
						}
					}
				}

				if ( not fopen ( *THREAD, "< $datadir/$tid.txt" ) ) {

					push @err, {
						func => 'new_messages',
						src  => 'Recent.pl',
						text => "$recent_txt{'err_cantopen'}'$datadir/$tid.txt'"
					}; # FIXME
						
					next NM_THREAD;
				};

				my $prev;
				my @retthread;
				my $postnum = 0;

				while ( <THREAD> ) {
					chomp;
					
					my ( $sub, $nick, undef, $pdate, $puid, $icon, undef,
					     undef, $text, $nosmil, undef, undef, $attfile )
									= split /\|/, $_;
					if (not defined $nosmil) {
						$nosmil = '';
					}
					if (not defined $attfile) {
						$attfile = '';
					}

					my %retpost = (
						num   => $postnum,
						date  => $pdate,
						name  => $sub,
						icon  => $icon,
						text  => $text,
						owner => nm_user_struct ( $puid, $nick )
					);

					$retpost{nosm} = 1 if $nosmil;

					if ( $attfile and -e "$uploaddir/$attfile" ) {

						$retpost{file} = $attfile

					} elsif ( $attfile ) {

						push @err, {
							func => 'new_messages',
							src  => 'Recent.pl',
							text => "$tid/$postnum$recent_txt{'err_delattach'}$attfile"
						}; # FIXME
					};

					# FIXME
					my @postmenu;

					if ( $state !~ m/l/i ) {
						if ( $have_reply_access ) {
							push @postmenu, {
								name => $img_txt{145},
								url  => qq($scripturl?action=post;num=$tid;quote=$postnum;title=PostReply)
							};

							if ( $puid eq $username ) {
								if ( not $tlnomodflag or
								     $pdate + $tlnomodtime * 60 * 60 * 24 > $date ) {
									push @postmenu, {
										name => $img_txt{66},
										url  => qq($scripturl?action=modify;board=$curboard;thread=$tid;message=$postnum)
									}
								}
							}
						}
						
						if ( $have_post_access and
						     $puid eq $username ) {
							if ( not $tlnodelflag or
							     $pdate + $tlnodeltime * 60 * 60 * 24 > $date ) {
								push @postmenu, {
									name => $img_txt{121},
									url  => qq($scripturl?action=multidel;thread=$tid;message=$postnum)
								}
							}
						}
					}

					$retpost{menu} = \@postmenu if @postmenu;

					$postnum++;

					if ( $pdate < $oldest_date ) {
						$prev = \%retpost;
						next;
					}

					if ( $prev ) {
						push @retthread, $prev;
						undef $prev;
					}

					push @retthread, \%retpost;
				}

				fclose ( *THREAD );

				next if not @retthread;

				# FIXME
				my @threadmenu = (
					{
						name => $img_txt{627},
						url  => qq($scripturl?action=markunread;board=$curboard;thread=$tid),
					},
					{ # FIXME: Check for presence of fav and reverse to 72/remfav
						name => $img_txt{71},
						url  => qq($scripturl?action=addfav;fav=$tid),
					},
					{ # FIXME: Check for presence
						name => $img_txt{131},
						url  => qq($scripturl?action=notify;thread=$tid),
					},
					{
						name => $img_txt{707},
						url  => qq($scripturl?action=sendtopic;thread=$tid),
					},
					{
						name => $img_txt{465},
						url  => qq($scripturl?action=print;num=$tid),
					}
				);

				if ( $state !~ m/l/i ) {
					if ( $have_reply_access ) {
						push @threadmenu, {
							name => $img_txt{146},
							url  => qq($scripturl?action=post;num=$tid;title=PostReply),
						}
					}

					if ( $have_poll_access and not -e "$datadir/$tid.poll" ) {	
						push @threadmenu, {
							name => $img_polltxt{2},
							url  => qq($scripturl?action=post;num=$tid;title=AddPoll),
						}
					}
				}

				my %retthread = (
					id    => $tid,
					date  => $tid,
					name  => $tsub,
					owner => nm_user_struct ( $tuid, $tnick ),
					icon  => $ticon,
					state => $state, # instead, supply possible actions?
					menu  => \@threadmenu,
					n     => \@retthread,
				);

				$retthread{poll} = $retpoll if $retpoll;

				push @retboard, \%retthread;
			}

			fclose ( *BOARD );

			next if not @retboard;

			push @retcat, {
				id   => $curboard,
				name => $boardname,
				n    => \@retboard,
			}
		}

		next if not @retcat;

		push @retall, {
			id   => $curcat,
			name => $catname,
			n    => \@retcat,
		}
	}

	nm_template {
		err     => \@err,
		content => \@retall,
	};

	exit;
}

sub nm_mark_read {
	
	if ( $iamguest ) {
		fatal_error ( $recent_txt{'err_noguest'} );
	}

	my $mark_with = $INFO{'date'};
	$mark_with =~ s/\D//g;

	if ( $mark_with !~ /\d/ or
	     $mark_with > $date or
 	     $mark_with < $date - $max_log_days_old * 60 * 60 * 24 ) {

		$mark_with = $date;
	}

	getlog;

	foreach my $key ( keys %FORM ) {

		next if $key !~ m/\Atid(\d+)\Z/s;
		next if $FORM{$key} eq '';
		next if not -e "$datadir/$1.txt";

		modlog $1, $mark_with;
	}

	dumplog;

	$yySetLocation = "$scripturl?action=newmesg";
	redirectexit;
}

sub RecentPosts {
	&spam_protection;
	my $display = $INFO{'display'} ||= 10;
	my (@data, %boardname, %catid, @memset, @categories, %data, $curcat, %catname, %cataccess, %catboards, $openmemgr, @membergroups, %openmemgr, $curboard, @threads, @boardinfo, $i, $c, @messages, $tnum, $tsub, $tname, $temail, $tdate, $treplies, $tusername, $ticon, $tstate, $mname, $memail, $mdate, $musername, $micon, $mattach, $mip, $mns, $mtime, $counter, $board);

	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }
	foreach my $catid (@categoryorder) {
		my $boardlist = $cat{$catid};

		my (@bdlist) = split(/\,/, $boardlist);
		my ($catname, $catperms) = split(/\|/, $catinfo{"$catid"});
		my $cataccess = &CatAccess($catperms);
		if (!$cataccess) { next; }

		foreach my $curboard (@bdlist) {
			my ($boardperms, $boardview);
			($boardname{$curboard}, $boardperms, $boardview) = split(/\|/, $board{"$curboard"});

			my $access = &AccessCheck($curboard, '', $boardperms);
			if (!$iamadmin && $access ne "granted") { next; }

			$catname{$curboard} = $catname;
			$catid{$curboard} = $catid;

			fopen(*REC_BDTXT, "$boardsdir/$curboard.txt");
			my $buffer;
			for ($i = 0; $i < $display && ($buffer = <REC_BDTXT>); $i++) {
				
				chomp $buffer;
				# There are still many records with 8 fields in it.
				($tnum, $tsub, $tname, $temail, $tdate, $treplies, $tusername, $ticon, $tstate) = split ( /\|/, $buffer );
				if (not defined $tstate) {
						$tstate = '';
				}

				unless ($tstate =~ /[hm]/) {
					$mtime = $tdate;
					push @data, "$mtime|$curboard|$tnum|$treplies|$tusername|$tname|$tstate";
				}
			}
			fclose(*REC_BDTXT);
		}
	}

	@data = reverse sort @data;

	my $numfound    = 0;
	my $threadfound = @data > $display ? $display : @data;

	for ($i = 0; $i < $threadfound; $i++) {
		($mtime, $curboard, $tnum, $treplies, $tusername, $tname, $tstate) = split(/\|/, $data[$i]);
		unless ($tstate =~ /h/) {
			my $tstart = $mtime;
			fopen(*REC_THRETXT, "$datadir/$tnum.txt") || next;
			my @mess = <REC_THRETXT>;
			fclose(*REC_THRETXT);

			my $threadfrom = @mess > $display ? @mess - $display : 0;
			for (my $ii = $threadfrom; $ii < @mess + 1; $ii++) {
				next if not $mess[$ii];

				chomp $mess[$ii];
				# There situation is more complicated. There are 9, 10, 12 and 13-field records.
				my ( $msub, $mname, $memail, $mdate, $musername, $micon, $mattach, $mip, $message, $mns, $mlm, $mlmb, $mfn ) = split ( /\|/, $mess[$ii] );
				if (not defined $mns) {
						$mns = '';
				}
				if (not defined $mfn) {
						$mfn = '';
				}
				
				$messages[$numfound] = "$mdate|$curboard|$tnum|$ii|$tusername|$tname|$msub|$mname|$memail|$mdate|$musername|$micon|$mip|$message|$mns|$mfn|$tstate|$tstart";
				$numfound++;
			}
		}
	}

	@messages = reverse sort @messages;

	if ($numfound > 0) {
		if ($numfound > $display) { $numfound = $display; }
		$counter = 1;
		&LoadCensorList;
	} else {
		$yymain .= qq~<hr class="hr"><b>$txt{'170'}</b><hr>~;
	}
	for ($i = 0; $i < $numfound; $i++) {
		my ( undef, $board, $tnum, $c, $tusername, $tname, $msub, $mname, $memail, $mdate, $musername, $micon, $mip, $text, $mns, $mfn, $tstate, $trstart )
					= split /\|/, $messages[$i];
		my $registrationdate;
		our $displayname = $mname; # for DoUBBC

		if ($tusername ne 'Guest' && -e ("$memberdir/$tusername.vars")) { &LoadUser($tusername); }
		if (${$uid.$tusername}{'regtime'}) {
			$registrationdate = ${$uid.$tusername}{'regtime'};
		} else {
			$registrationdate = int(time);
		}
		if (${$uid.$tusername}{'regdate'} && $trstart > $registrationdate) {
			$tname = qq~<a href="$scripturl?action=viewprofile;username=$tusername">${$uid.$tusername}{'realname'}</a>~;
		} elsif ($tusername !~ m~Guest~ && $trstart < $registrationdate) {
			$tname = qq($tusername$recent_txt{ex});
		} else {
			$tname .= $recent_txt{guest};
		}

		if ($musername ne 'Guest' && -e ("$memberdir/$musername.vars")) { &LoadUser($musername); }
		if (${$uid.$musername}{'regtime'}) {
			$registrationdate = ${$uid.$musername}{'regtime'};
		} else {
			$registrationdate = int(time);
		}
		if (${$uid.$musername}{'regdate'} && $mdate > $registrationdate) {
			$mname = qq~<a href="$scripturl?action=viewprofile;username=$musername">${$uid.$musername}{'realname'}</a>~;
		} elsif ($musername !~ m~Guest~ && $mdate < $registrationdate) {
			$mname = qq($musername$recent_txt{ex});
		} else {
			$mname .= $recent_txt{guest};
		}

		our $message = &Censor($text); # damned global...
		$msub    = &Censor($msub);
		&wrap;
		if ($enable_ubbc) {
			our $ns = $mns;
			if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; }
			&DoUBBC;
		}
		&wrap2;
		&ToChars($msub);
		&ToChars($message);
		&ToChars($boardname{$board});
		&ToChars($catname{$board});

		my $attach='';
		if ( $mfn and -e "$uploaddir/$mfn" ) {
			$attach = qq~
			<hr class="hr" style="width: 100%" />
			<span class="small" style="float: left; width: 49%" ><a href="$uploadurl/$mfn" target="_blank"><img src="$imagesdir/paperclip.gif" border="0" align="middle" alt="" /> $mfn</a></span>
~; #"
		}

		$mdate = &timeformat($mdate);
		$yymain .= qq~
<table border="0" width="100%" cellspacing="1" class="bordercolor" style="table-layout: fixed;">
	<tr>
		<td width="5%" align="center" class="titlebg">$counter</td>
		<td width="95%" class="titlebg">&nbsp;<a href="$scripturl?catselect=$catid{$board}">$catname{$board}</a> / <a href="$scripturl?board=$board">$boardname{$board}</a> / <a href="$scripturl?num=$tnum/$c#$c">$msub</a><br />
		<span class="small">$recent_txt{on}$mdate</span></td>
	</tr><tr>
		<td colspan="2" class="catbg">$recent_txt{started}$tname | $recent_txt{posted}$mname</td>
	</tr><tr>
		<td colspan="2" class="windowbg2" valign="top"><span class="message">$message</span>$attach</td>
	</tr><tr>
		<td colspan="2" class="catbg" align="right">~;
		my $notify = 0;
		if ($enable_notification and not $iamguest) {
				$notify = 1;
		}
		if ($tstate !~ /l/) {
			if ( $notify ) {
				$yymain .= qq~
				<a href="$scripturl?board=$board;action=post;num=$tnum;title=PostReply">$img{'reply'}</a>$menusep
				<a href="$scripturl?board=$board;action=post;num=$tnum;quote=$c;title=PostReply">$img{'recentquote'}</a>$menusep
				<a href="$scripturl?board=$board;action=notify;thread=$tnum">$img{'notify'}</a> &nbsp;~;
			} else {
				$yymain .= qq~
				<a href="$scripturl?board=$board;action=post;num=$tnum;title=PostReply">$img{'reply'}</a>$menusep
				<a href="$scripturl?board=$board;action=post;num=$tnum;quote=$c;title=PostReply">$img{'recentquote'}</a> &nbsp;~;
			}
		} elsif ( $notify ) {
				$yymain .= qq~<a href="$scripturl?board=$board;action=notify;thread=$tnum">$img{'notify'}</a> &nbsp;~;
		}
		$yymain .= qq~</td>
	</tr>
</table><br />
~; #/
		++$counter;
	}

	$yytitle = $display . $recent_txt{recent_title};
	&template;
	exit;
}

sub RecentTopicsList {
	&spam_protection;

	# Can pass items to this sub, to decide what to show:
	my ($show_count, $show_board, $show_poster, $show_date) = @_;

	my $display = $INFO{'display'} ||= 10;
	if    ($display < 0)   { $display = 5; }
	elsif ($display > 100) { $display = 100; }

	my (@data, %boardname, @memset, @categories, %data, $numfound, $curcat, %catname, %cataccess, %catboards, $openmemgr, @membergroups, %openmemgr, $curboard, @threads, @boardinfo, $i, $c, @messages, $tnum, $tsub, $tname, $temail, $tdate, $treplies, $tusername, $ticon, $tstate, $mname, $memail, $mdate, $musername, $micon, $mattach, $mip, $mns, $mtime, $counter, $board, $notify);
	$numfound = 0;

	foreach my $catid (@categoryorder) {
		my $boardlist = $cat{$catid};

		my (@bdlist) = split(/\,/, $boardlist);
		my ($catname, $catperms) = split(/\|/, $catinfo{"$catid"});
		my $cataccess = &CatAccess($catperms);
		if (!$cataccess) { next; }

		foreach my $curboard (@bdlist) {
			my ($boardperms, $boardview);
			($boardname{$curboard}, $boardperms, $boardview) = split(/\|/, $board{"$curboard"});

			my $access = &AccessCheck($curboard, '', $boardperms);
			if (!$iamadmin && $access ne "granted") { next; }

			$catname{$curboard} = $catname;

			fopen(*REC_BDTXT, "$boardsdir/$curboard.txt");
			my $buffer;
			for ($i = 0; $i < $display && ($buffer = <REC_BDTXT>); $i++) {
				($tnum, $tsub, $tname, $temail, $tdate, $treplies, $tusername, $ticon, $tstate) = split(/\|/, $buffer);
				unless ($tstate =~ /[hm]/) {
					$mtime = $tdate;
					$data[$numfound] = "$mtime|$curboard|$tnum|$treplies";
					$numfound++;
				}
			}
			fclose(*REC_BDTXT);
		}
	}

	@data     = reverse sort @data;
	$numfound = 0;

	for ($i = 0; $i < @data; $i++) {
		our $message;
		($mtime, $curboard, $tnum, $treplies) = split(/\|/, $data[$i]);

		fopen(*REC_THRETXT, "$datadir/$tnum.txt") || next;
		while (<REC_THRETXT>) { $message = $_; }

		# get only the last post for this thread.
		fclose(*REC_THRETXT);
		chomp $message;

		if ($message) {
			my ($msub, $mname, $memail, $mdate, $musername, $micon, $mattach, $mip, $message, $mns) = split(/\|/, $message);
			$messages[$numfound] = "$curboard|$tnum|$treplies|$msub|$mname|$mdate|$musername";
			$numfound++;
		}
		if ($numfound == $display) { last; }
	}
	&LoadCensorList;

	$counter = 1;

	$yymain .= qq~
    <div class="bordercolor">
        <div class="titlebg" align="center">
        <b>$display most recent topics</b></td>
		</div>
        <table width="100%" cellpadding="0" align="center" class="windowbg2">
~;
	for ($i = 0; $i < $numfound; $i++) {
		my ($board, $tnum, $c, $msub, $mname, $mdate, $musername) = split(/\|/, $messages[$i]);
		$msub = &Censor($msub);
		&ToChars($msub);
		if ($musername ne 'Guest' && -e "$memberdir/$musername.vars") {
			&LoadUser($musername);
			$mname = exists ${$uid.$musername}{'realname'} ? ${$uid.$musername}{'realname'} : $mname;
			$mname ||= $txt{'470'};
			$mname = qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$musername}" title="$txt{'27'}: $musername">$mname</a>~;
		} else {
			$mname .= " ($maintxt{'28'})";
		}
		$mdate = &timeformat($mdate);

		# Strip all Re: from subject lines
		# only if it occurs at the start.
		$msub =~ s/\ARe: //ig;

		# Change [m] to Moved:
#		$msub =~ s/\A\[m\]/$maintxt{'758'}/;

		$yymain .= qq~          <tr>~;

		if ($show_count) {
			$yymain .= qq~

            <td valign="top" align="left"><span class="small">
                $counter.</span>
            </td>
~;
		}

		if ($show_board) {
			$yymain .= qq~
             <td valign="top" align="left"><span class="small">
                &nbsp; &nbsp; $boardname{$board} &nbsp;
				</span>
            </td>
~;
		}

		$yymain .= qq~
       	    <td valign="top" align="left"><span class="small">
                <a href="$scripturl?num=$tnum/$c#$c" class="nav" target="_parent">$msub</a> $txt{'525'}
~;

		if ($show_poster) {
			$yymain .= qq~$mname
~;
		}

		$yymain .= qq~
				</span>
            </td>
~;

		if ($show_date) {
			$yymain .= qq~
       	    <td valign="top" align="right"><font size="1">
				$mdate &nbsp;
            </td>
          </tr>
~;
		}

		++$counter;
	}

	$yymain .= qq~
        </table>
      </div><br />
~;
	&template;
	exit;

}

1;

# vim: se ts=4: #
