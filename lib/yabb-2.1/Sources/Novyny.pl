
#
# (c) 2007-2009 Myhailo Danylenko <isbear@ukrpost.net>
#
# Main page generator
#

# TODO:
# * fix start urlparam
# * add footer navbar

use strict;
use warnings;

our %INFO;
our (%img);
our (%board, %cat, @categoryorder);
our ($forumstylesdir, $forumstylesurl);
our ($scripturl, $iamguest, $user_ip, $username);
# template stuff
our ($novynynewsitem, $novynyboardtopic, $novynyboard, $novynyimage, $novynypolloption, $novynypoll, $novyny_template);

sub Novyny {

	if ($INFO{'help'}) {
		&fatal_error ("help = 1|0 <br />board = boardid <br /> display = 5..50 <br /> sidedisplay = 1..10 <br /> sideimages = 1..10 <br /> start = startfrom (wet!)");
	}

	our (%novyny_txt, @novyny_post);
	&LoadLanguage ('Novyny');

	our ($boardsdir, $datadir, $vardir, $sourcedir, $imagesdir, $templatesdir, $uploadurl);
	our $usestyle ||= 'default';
	if (-e "$templatesdir/$usestyle/Novyny.template") {
		require "$templatesdir/$usestyle/Novyny.template";
	} elsif (-e "$templatesdir/default/Novyny.template") {
		require "$templatesdir/default/Novyny.template";
	} else {
		&fatal_error ($novyny_txt{'templateerr'}, 'Novyny.template');
	}

	our ($message, $yyYaBBCloaded);
	if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; }

	my $thumbsurl    = '/thumbs';
	my $newsboard    = 'novyny';
	my $maxshowpages = 7;
	my $display      = 15;
	my $start        = 0;

	if (exists $INFO{'board'} && exists $board{$INFO{'board'}}) {
		$newsboard = $INFO{'board'};
	}

	if (exists $INFO{'display'} && $INFO{'display'} !~ /\D/) {
		$display = $INFO{'display'};
		$display = 5  if ($display < 5);
		$display = 50 if ($display > 50);
	}

	if (exists $INFO{'start'} && $INFO{'start'} !~ /\D/) {
		$start = $INFO{'start'};
	}

	my %ignore      = ('recyclebin' => 1, 'adm-requests' => 1, 'test_ph' => 1, 'news' => 1, 'problems' => 1, $newsboard => 1);
	my $sidedisplay = 3;
	my $sideimages;

	if (exists $INFO{'sidedisplay'} && $INFO{'sidedisplay'} !~ /\D/) {
		$sidedisplay = $INFO{'sidedisplay'};
		$sidedisplay = 1 if ($sidedisplay < 1);
		$sidedisplay = 10 if ($sidedisplay > 10);
	}

	if (exists $INFO{'sideimages'} && $INFO{'sideimages'} !~ /\D/) {
		$sideimages = $INFO{'sideimages'};
		$sideimages = 1 if ($sideimages < 1);
		$sideimages = 10 if ($sideimages > 10);
	} else {
		$sideimages = $sidedisplay;
	}

	## NEWS ##

	my $nynews = '';

	fopen (*NOVYNY, "<$boardsdir/$newsboard.txt");
	my @novyny = reverse sort grep /\|[^m\|]*?$/, <NOVYNY>;
	fclose (*NOVYNY);

	if ($start > $#novyny) {
		$start = $display < $#novyny ? $#novyny - $display : 0;
	}

	my $end = ($#novyny > $start + $display) ? $start + $display - 1 : $#novyny;

	foreach (@novyny[$start .. $end]) {
		my ($tid, $topic, $unick, undef, $lastpostdate, $replies, $uname, $icon, $status)
				= split /\|/, $_;

		my $startdate = &timeformat ($tid);
	
		$unick = qq~<a href="$scripturl?action=viewprofile;username=$uname">$unick</a>~
			unless ($iamguest || $uname eq 'Guest');

		$topic = &Censor ($topic);

		$message = $novyny_txt{'threaderr'};
		if (-e "$datadir/$tid.txt") {
			fopen (*MSG, "<$datadir/$tid.txt");
			$message = (split /\|/, <MSG>, 10)[8];
			fclose (*MSG);
			$message =~ s/\s*\[hr\].*?$//; # cut hr'ed comments
			$message = &Censor ($message);
			our $linewrap=76;
			&wrap;
			&DoUBBC;
			&wrap2;
		}

		my $replieslink = '';
		if ($replies) {
			$lastpostdate = &timeformat ($lastpostdate);
			$replieslink = qq~<a href="$scripturl?num=$tid/1#1">$replies $novyny_post[ &plural ($replies) ]</a>$novyny_txt{ $replies == 1 ? 'laston' : 'laston_m' }<a href="$scripturl?num=$tid/$replies#$replies">$lastpostdate</a>~;
		}

		my $item = $novynynewsitem;
		$item =~ s~<novyny news topic>~<a href="$scripturl?num=$tid">$topic</a>~sig;
		$item =~ s~<novyny news icon>~<img src="$imagesdir/$icon.gif" alt="*" />~sig;
		$item =~ s~<novyny news author>~$unick~sig;
		$item =~ s~<novyny news start>~$startdate~sig;
		$item =~ s~<novyny news replies>~$replieslink~sig;
		$item =~ s~<novyny news message>~$message~is;
			
		$nynews .= $item;
	}

	&ToChars ($nynews);

	## PAGES ##

	my $nypages = '';
	if ($#novyny > $display || $start) {
		my $page  = 2;
		my $max   = $maxshowpages * $display;
		my $extra = $start % $display;
	
		unless ($start) {
			$nypages = qq~$novyny_txt{'pages'}<b>1</b>~;
		} elsif ($extra  == $start) {
			$nypages = qq~$novyny_txt{'pages'}<a href="$scripturl?action=novyny;board=$newsboard;display=$display;start=0">1</a> <b>2</b>~;
			$page    = 3;
		} elsif ($extra) {
			$nypages = qq~$novyny_txt{'pages'}<a href="$scripturl?action=novyny;board=$newsboard;display=$display;start=0">1</a> <a href="$scripturl?action=novyny;board=$newsboard;display=$display;start=$extra">2</a>~;
			$page    = 3;
		} else {
			$nypages = qq~$novyny_txt{'pages'}<a href="$scripturl?action=novyny;board=$newsboard;display=$display;start=0">1</a>~;
		}
		
		my $killed = 0;
		for (my $pos = $display + $extra; $pos < $#novyny; ++$page, $pos += $display) {
			if ($pos > $start - $max && $pos < $start + $max) {
				if ($pos == $start) {
					# Here it can't be killed
					$nypages .= qq~ <b>$page</b>~;
				} else {
					$nypages .= qq~ <a href="$scripturl?action=novyny;board=$newsboard;display=$display;start=$pos">$page</a>~;
					$killed   = 0;
				}
			} elsif ($page <= $maxshowpages || $pos >= $#novyny - $max - $extra) {
				$nypages .= qq~ <a href="$scripturl?action=novyny;board=$newsboard;display=$display;start=$pos">$page</a>~;
				$killed   = 0;
			} elsif (!$killed) {
				$nypages .= q~ ...~;
				$killed   = 1;
			}
		}
	}

	## THREADS ##

	my $nyboards = '';
	foreach my $board (split /,/, join ',', @cat{@categoryorder}) {
		next if (exists $ignore{$board});

		my $display = $sidedisplay;
		my $nyboardtopics = '';
		fopen (*BRD, "<$boardsdir/$board.txt");
		while (<BRD>) {
			my ($tid, $topic, undef, undef, undef, $replies, undef, $icon, $status)
					= split /\|/, $_;
		
			next if ( defined $status && $status =~ /m/);

			$topic = &Censor ($topic);

			my $item = $novynyboardtopic;
			$item =~ s~<novyny topic icon>~<img src="$imagesdir/$icon.gif" alt="*" />~sig;
			$item =~ s~<novyny topic name>~<a href="$scripturl?num=$tid/$replies#$replies">$topic</a>~is;
			$nyboardtopics .= $item;

			last unless (--$display);
		}
		fclose (*BRD);

		my ($boardname, undef) = split /\|/, $board{$board};

		my $item = $novynyboard;
		$item =~ s~<novyny board name>~<a href="$scripturl?board=$board">$boardname</a>~sig;
		$item =~ s~<novyny board topics>~$nyboardtopics~is;
		$nyboards .= $item;
	}

	&ToChars ($nyboards);

	## IMAGES ##

	my $nyimages = '';

	fopen (*ATT, "<$vardir/attachments.txt");
	# FIXME: fails if not enough images
	my @images = (sort {(split /\|/, $b)[6] <=> (split /\|/, $a)[6]} grep /\.(gif|jpg|jpeg|png)$/i, <ATT>)[0..$sideimages-1];
	fclose (*ATT);
	chomp @images;

	foreach (@images) {
		my ($tid, $reply, $topic, undef, undef, undef, undef, $fname) = split /\|/, $_;

		$topic = &Censor ($topic);
		&ToChars ($topic);

		my $item = $novynyimage;
		$item =~ s~<novyny img descr>~<a href="$scripturl?num=$tid/$reply#$reply">$topic</a>~isg;
		$item =~ s~<novyny img>~<a href="$uploadurl/$fname"><img src="$thumbsurl/$fname" /></a>~is;
		$nyimages .= $item;
	}

	## POLL ##

	# FIXME
	my $nypoll = '';

	opendir  POLLIST, $datadir;
	my $poll = pop @{[sort grep (/\.poll$/, readdir POLLIST)]};
	closedir POLLIST;
	
	if ( $poll ) {
		my $pollnum  = substr ($poll, 0, length ($poll) - 5);
		my $hasvoted = 0;

		fopen (*POLL, "<$datadir/$poll");
		my ($question, $locked, undef, undef, undef, undef, $guestvote, undef, $multivote, undef, undef, $comment, undef)
					= split /\|/, <POLL>;

		if ($locked || ($iamguest && !$guestvote)) {
			$hasvoted = 1;
		} else {
			fopen (*POLLED, "<$datadir/$pollnum.polled");
			while (<POLLED>) {
				my ($ip, $uname, undef) = split /\|/, $_;
				if (($ip eq $user_ip && $iamguest) || (!$iamguest && lc $uname eq lc $username)) {
					$hasvoted = 1;
					last;
				}
			}
			fclose (*POLLED);
		}

		my $nypollopts = '';
		if ($hasvoted) {
			my $max = 1;
			my @poll = <POLL>;
			foreach (@poll) {
				my ($voted, undef) = split /\|/, $_;
				$max = $voted if ($voted > $max);
			}
			foreach (@poll) {
				chomp;
				my ($voted, $variant) = split /\|/, $_;
				my $width = int(100 * $voted / $max);

				my $item = $novynypolloption;
				$item =~ s~<novyny poll variant>~$variant~sig; 
				$item =~ s~<novyny poll control>~<img src="$imagesdir/poll_left.gif" alt="[ " /><img src="$imagesdir/poll_middle.gif" height="12" width="$width" alt="$voted" /><img src="$imagesdir/poll_right.gif" alt=" ]" />~is; #"
				$nypollopts .= $item;
			}
		} else {
			$nypollopts = qq~<form action="$scripturl?action=vote;num=$pollnum" method="post">~;

			my $i = 0;
			while (<POLL>) {
				chomp;
				my (undef, $variant) = split /\|/, $_;

				my $item = $novynypolloption;
				$item =~ s~<novyny poll variant>~$variant~sig; 
				if ($multivote) {
					$item =~ s~<novyny poll control>~<input type="checkbox" name="option$i" value="$i" />~is; #/
				} else {
					$item =~ s~<novyny poll control>~<input type="radio" name="option" value="$i" />~is; #/
				}
				$nypollopts .= $item;
				$i++;
			}

			$nypollopts .= qq~
				<input type="submit" value="$novyny_txt{'vote_butt'}" />
			</form>~;
		}
		fclose (*POLL);

		$question  = qq~[url=$scripturl?num=$pollnum]$question\[/url\]~;
		$question .= qq~ [i]$comment\[/i\]~ if ($comment ne '');
		$message   = &Censor($question);
		&DoUBBC;

		$nypoll = $novynypoll;
		$nypoll =~ s~<novyny poll question>~$message~sig;
		$nypoll =~ s~<novyny poll variants>~$nypollopts~is;
		&ToChars ($nypoll);
	}

	## LOGIN ##

	my $nylogin = qq~<a href="$scripturl?action=logout">$img{'logout'}</a>~;
	$nylogin = qq~<form action="$scripturl?action=login2" method="post">
			<input type="text" name="username" maxlength="30" title="$novyny_txt{'logintip'}" />
			<input type="password" name="passwrd" maxlength="30" title="$novyny_txt{'passtip'}" />
			<input type="hidden" name="cookielength" value="1" />
			<input type="submit" value="$novyny_txt{'login_butt'}" />
		</form>~ if ($iamguest);

	
	## FOOT ##

	my $nyfoot = qq~
	<a href="$scripturl?action=post;board=$newsboard;title=StartNewTopic">[Add news]</a>
	<a href="yabb2rss?group=$newsboard">[RSS]</a>
	<a href="yabb2rss?group=$newsboard&body=yes">[RSS/FULL]</a>
	<a class="blind" href="http://www.tsua.net"><img style="border:0;width:88px;height:31px" src="/images/tsua.gif" alt="Hosted by TSUA" title="Hosted by TSUA" /></a>~;

	## MAIN ##

	our $yymain =  "<h1>Status: 184 Under Constructon</h1><br />$novyny_template";
	$yymain =~ s/<novyny poll>/$nypoll/is;
	$yymain =~ s/<novyny pages>/$nypages/isg;
	$yymain =~ s/<novyny news>/$nynews/is;
	$yymain =~ s/<novyny login>/$nylogin/is;
	$yymain =~ s/<novyny boards>/$nyboards/is;
	$yymain =~ s/<novyny images>/$nyimages/is;
	$yymain =~ s/<novyny foot>/$nyfoot/is;


	if (-e "$forumstylesdir/$usestyle/novyny.css") {
		our $yyinlinestyle = qq~
<link rel="stylesheet" href="$forumstylesurl/$usestyle/novyny.css" type="text/css" />
~; #/
	} elsif (-e "$forumstylesdir/default/novyny.css") {
		our $yyinlinestyle = qq~
<link rel="stylesheet" href="$forumstylesurl/default/novyny.css" type="text/css" />
~; #/
	} else {
		our $yyinlinestyle = qq~
<!-- :( Here should be a css link, but css cannot be found. -->
~;
	}


	&template;
}

1;

