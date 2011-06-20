#! /usr/bin/perl

use strict;
use warnings;
use Carp;
use Fcntl qw( :flock :seek );

my $vardir = '/var/www/vhosts/linux.org.ua/var/yabb-2.1/Variables';

my %modified = (
	starlog => 0
);

my @log;

if ( not open STARLOG, '+<', "$vardir/hunting.dat" ) {
	croak "Can't open huntdatas"
}

if ( not flock STARLOG, LOCK_EX ) {
	close STARLOG;
	croak "Can't lock huntdata";
}

while ( <STARLOG> ) {
	chomp;

	my ( $login,
		$life,
		$max_life,
		$ammo,
		$death_date,
		$shot_date,
		$killed_by,
		$has_killed,
		$deaths_count ) = split /\|/, $_;
	
	if ( $life and $life < $max_life ) {

		$life += 3;
		if ( $life > $max_life ) {
			$life = $max_life
		}
		$modified{starlog} = 1;
	}

	push @log, $login     . '|' .
		$life         . '|' .
		$max_life     . '|' .
		$ammo         . '|' .
		$death_date   . '|' .
		$shot_date    . '|' .
		$killed_by    . '|' .
		$has_killed   . '|' .
		$deaths_count . "\n";
}

if ( $modified{starlog} ) {
	if ( not seek STARLOG, 0, SEEK_SET ) {
		carp "Can't seek file"
	} elsif ( not print STARLOG join '', @log ) {
		carp "Cat't write data back"
	} elsif ( not truncate STARLOG, tell STARLOG ) {
		carp "Can't truncate file"
	}
}

if ( not flock STARLOG, LOCK_UN ) {
	carp "Can't lock huntdata!"
}

if ( not close STARLOG ) {
	carp "Can't close huntdata"
}

# The End
