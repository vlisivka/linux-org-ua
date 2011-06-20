#!/usr/bin/perl -wT
use strict;
use locale;
use utf8;
#use encoding 'utf-8', STDOUT => 'utf-8';
use encoding 'utf-8';

our $boardsdir;
if (! defined $boardsdir) {
	require "./Paths.pl";
}

our %board;
if (! defined %board) { # we can use $mloaded....
	require "$boardsdir/forum.master";
}

my @ignore = qw(test_ph recyclebin lost news problems novyny);
foreach (@ignore) {
	delete $board{$_};
}

sub insertWbrs {
	my $line=shift;
	$line=~s/([^\s]{40})/$1<wbr>/g;
	return $line;
}

foreach my $group (sort keys %board) {
	open(BOARD,"<$boardsdir/$group.txt");
	my ($gname, undef) = split (/\|/, $board{$group},2);
	print <<GROUP;
<h4 class="latestGroup"><a href="YaBB.pl?board=$group">$gname</a></h4>
GROUP
	my $i=0;
	while (<BOARD>) {
		chomp;
		my ($ctime,$subject,$userName,$userEmail,$date1,$replies,$login,$icon,$status)=split('\|',$_);
		next if($status =~ /m/);
      
		$subject=insertWbrs($subject);
    
		print<<MESSAGE;
<div class="latestMessage"><a href="YaBB.pl?num=$ctime">$subject</a></div>
MESSAGE
		last if (++$i >= 3);
	}
	close(BOARD);
}

1;
