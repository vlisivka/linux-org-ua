
# TODO:
# * Think of dead and offline cases. They are different.
# * snarks & boojims
# * add probability of hit? (instead of two area damages)
# * add more advanced damage description? like "hp-100%,am-2d10"? (this applies to cost as well)
# * report action results to user!
# * de-hardcode amount of posts to get hp increase
# * add slow auto-healing? # with cron ;)
# * implement mathematic in damage and cost calculations - like 2d10+30%? or even 30%d2? ;)
# * some centralized place to handle options.
# * add refcounter to starlog? or add non-blocking ro-loading?
# * translate
# * 'tis must be silly
# * classical *+! damage scheme ([*] + [+] = [+])? (area = -2)
# * add offline-shooting enabling flag - for giggles and so on.
# * add self-shooting enabling flag - to not shoot yourself with certain types of guns.
# * OMG, we urgently need TT - hard-generated html code adds great part of hacky look

# CSS classes:
# huntlog
# snarkstars
# snarkpanel
# snarkpanelgun
# gundsccontainer
# http actions:
# rmgwogu (revive)
# ghd (shot)
# showguns
# huntlog

use Fcntl qw( :flock :seek );

=pod
	fake definitions to allow synatx check

sub fatal_error {
}
our $date;
our %loaded = (
online_users => 0,
);
our %online_users;
sub load_online_users {
}
sub is_online {
}
=cut

return if $loaded{'Snark.pl'};
$loaded{'Snark.pl'} = 1;

=pod

	%snark_txt contains text strings for localization purposes. Amongst them there are
	some special strings:
	gdscX - parts of gun description message
	gdscX_Y - strings to describe value Y of correxponding parameter
	dscgun_X - full description for weapon
	gunname_X - one-line name for gun
	gunsign_X - short mark (can contain HTML markup) for use as button in weapon panel
	logevt_X - reference to array with strings to describe log event. Can contain
	        pseudo-tags <date> <actor> <target> <place></place> <amount>

	%damage describes the weapons:
	amount - damage to object, in stars of life, can be negative!
	cost - cost to shooting subject, in stars of ammo, can be negative!
	load - load time in seconds, can be negative! :D
	area - object selection mechanism:
	  -1 damage applies to shooting subject itself
	   0 usual damage to specified person
	   1 damage to specified object and random list from other present this time
	   2 damage to all present at that moment
	   3 damage to all, listed in starlog
	dead - if dead targets are ok
	termin - death time, caused by weapon, seconds. Can be negative =)
	self - if shooting to shooter itself allowed
	level - required level to use 'tis weapon:
	  -1 only specified in 'owner' uid can do it
	   0 anyone, even guest
	   1 only users
	   2 only mods, gmods, and admins
	   3 only gmods and admins
	   4 only admin
	owner - one uid, for use with level -1

	%online_users - login => timestamp|ip from log.txt. use load_online_users first

	@hunting_log - contains unwritten log entries to implement log writes caching
	       and transactions. Use write_log to actually write log.
	       Log entries format (@hunting_log contains no date and formatted version):
	       date | who        | whom(request) | weapon     | where  | format
	       date | who        | whom          | "damage"   | amount | format
	       date | who        | whom          | "kill"     | termin | format
	       date | who        | whom          | "rekill"   | termin | format
	       date | who        | weapon        | "cost"     | amount | format
	       date | "I'z-chan" | who           | "izrevive" | amount | format

	%starlog - contents of huntlog.dat, that contains info about users:
	life - HP
	max_life - Max HP
	ammo - ammo
	death_date - last death date - convert to revivification date?
	shot_date - next shot time
	killed_by - last killer
	has_killed - frags counter
	deaths_count - deaths counter
	You MUST use open_starlog and close_starlog in pairs, or you lock down your forum.

=cut

our %modified = (
	starlog => 0
);

&LoadLanguage ('Snark') if not $loaded{'Snark.lng'};

our %damage = (
	giggle => { amount => 0,       cost => 0,         load => 60,  area => 0,  dead => 1, termin => 0,   self => 1, offline => 1, level => 0 },
	boyan  => { amount => 0,       cost => 0,         load => 120, area => 0,  dead => 1, termin => 0,   self => 1, offline => 1, level => 0 },
	star   => { amount => 1,       cost => 1,         load => 40,  area => 0,  dead => 0, termin => 300, self => 0, offline => 0, level => 1 },
	plus   => { amount => 3,       cost => 3,         load => 60,  area => 0,  dead => 0, termin => 420, self => 0, offline => 0, level => 2 },
	ban    => { amount => '100%',  cost => 'damage',  load => 900, area => 0,  dead => 0, termin => 900, self => 0, offline => 0, level => 4 },
	bomb   => { amount => '2d13',  cost => 25,        load => 90,  area => 1,  dead => 1, termin => 600, self => 1, offline => 0, level => 1 },
	minus  => { amount => -3,      cost => 3,         load => 30,  area => -1, dead => 0, termin => 0,   self => 1, offline => 1, level => 1 },
	heal   => { amount => '-34%',  cost => 3,         load => 90,  area => 0,  dead => 0, termin => 0,   self => 0, offline => 1, level => 2 },
	revive => { amount => '-100%', cost => 20,        load => 180, area => 1,  dead => 1, termin => 0,   self => 1, offline => 1, level => 3 },

	# old cthulhu - lvm scene
	messiah   => { amount => '-100%', cost => 0,        load => 180,  area => 0,  dead => 1, termin => 0,   self => 1, offline => 1, level => -1, owner => 'lvm' },
	# just what forum admin needs
	ungrave   => { amount => '-100%', cost => '33%',    load => 1900, area => 3,  dead => 1, termin => 0,   self => 1, offline => 1, level => -1, owner => 'ISBear' },
	# I like SSG
	ssb       => { amount => '14d2',  cost => 22,       load => 300,  area => 0,  dead => 0, termin => 720, self => 0, offline => 0, level => -1, owner => 'ISBear' },
	# big bro, noblesse oblige
	watch     => { amount => 0,       cost => 0,        load => 10,   area => 0,  dead => 1, termin => 0,   self => 0, offline => 1, level => -1, owner => 'Praporshic' },
	# second-time given plusgun
	chainplus => { amount => 3,       cost => 3,        load => 10,   area => 0,  dead => 0, termin => 420, self => 0, offline => 0, level => -1, owner => 'Praporshic' },
	# just for ease of self-shooting
	backplus  => { amount => 3,       cost => -3,       load => 10,   area => -1, dead => 0, termin => 300, self => 1, offline => 1, level => -1, owner => 'Cthulhu' },
	# old saying about moderator-mojohead
	patrick   => { amount => '100%',  cost => 100,      load => 360,  area => 2,  dead => 0, termin => 600, self => 1, offline => 0, level => -1, owner => 'Cthulhu' },
	# frequently-discussed question
	znewad    => { amount => '-100%', cost => 10,       load => 60,   area => 0,  dead => 0, termin => 0,   self => 1, offline => 1, level => -1, owner => 'DalekiyObriy' },
	# the only person, about which I know, that he has breaked into some machine
	tristar   => { amount => '30d2',  cost => 70,       load => 720,  area => 1,  dead => 0, termin => 720, self => 0, offline => 0, level => -1, owner => 'Abram' },
	# according to avatar, by request of working peoples...
	rlsaber   => { amount => '6d4',   cost => '6d4',    load => 90,   area => 0,  dead => 0, termin => 360, self => 0, offline => 0, level => -1, owner => 'Piktor' },
	# the only active female being on forum (except early anatolijd =) )
	# just the way to show to someone, that his (probably, target is male) actions are not good
	escalibur => { amount => '100%',  cost => 'damage', load => 100,  area => 0,  dead => 0, termin => 30,  self => 0, offline => 0, level => -1, owner => 'myroslava' },
	# each stick have two ends
	esca_res  => { amount => '-100%', cost => 'damage', load => 100,  area => 0,  dead => 1, termin => 0,   self => 0, offline => 0, level => -1, owner => 'myroslava' },
	# cost - depending on damage, namely, on durability of someone's head
	pjata     => { amount => '34%',   cost => 'damage', load => 20,   area => 0,  dead => 0, termin => 60,  self => 0, offline => 0, level => -1, owner => 'Olexandr_Kravchuk' },
	# 
	flambring => { amount => '1d3',   cost => 1,        load => 5,    area => 1,  dead => 0, termin => 360, self => 0, offline => 0, level => -1, owner => 'Olexandr_Kravchuk' },
);

$loaded{guns} = 1;

our @hunting_log = ( );

our %starlog = ( );

$loaded{starlog} = 0;
$loaded{starlog_write} = 0;

=pod
	gets login (any), returns nickname
=cut
sub get_nickname {
	my $login = shift;

	if ( $login =~ m/^Guest-(.*)$/i ) {
		return $1 . $snark_txt{'guest_paren'}
	}

	if ( $login eq 'Guest' ) {
		return $snark_txt{'guest'}
	}

	if ( not -f "$memberdir/$login.vars" ) {
		return $login
	}

	LoadUser $login if not exists ${$uid.$login}{realname};

	return ${$uid.$login}{realname} || $login
}

=pod
	gets damage description string and (optionally) maximum value - used in % calculations
=cut
sub calc_damage {
	my $dmg = shift;

	if ( $dmg =~ m/^([+-]?)(\d+)d(\d+)$/ ) {
		my $count = $2;
		my $max = $3;
		my $sign = $1 . '1';

		$dmg = 0;
		while ( $count-- ) {
			$dmg += int ( rand $max ) + 1;
		}

		return $dmg * $sign

	} elsif ( $dmg =~ m/^([+-]?\d+)\%$/ ) {
		my $max = shift || 9;

		return int ( $max * $1 / 100 )

	} else {
		return $dmg
	}
}

=pod
	gets gun name, returns string for displaying in HTML
=cut
sub gun_dsc {
	my $gun = shift;

	if ( not exists $damage{$gun} ) {
		return $snark_txt{'wronggun'} . $gun
	}
	
	return	$snark_txt{'gdsc1'} . $snark_txt{'gunname_'.$gun} .
		$snark_txt{'gdsc2'} . $snark_txt{'dscgun_'.$gun} .
		$snark_txt{'gdsc3'} . $damage{$gun}{amount} .
		$snark_txt{'gdsc4'} . $damage{$gun}{cost} .
		$snark_txt{'gdsc5'} . $damage{$gun}{load} .
		$snark_txt{'gdsc6'} . $snark_txt{'gdsc6_'.$damage{$gun}{area}} .
		$snark_txt{'gdsc7'} . $snark_txt{'gdsc7_'.$damage{$gun}{dead}} .
		$snark_txt{'gdsc11'} . $snark_txt{'gdsc7_'.$damage{$gun}{self}} .
		$snark_txt{'gdsc12'} . $snark_txt{'gdsc7_'.$damage{$gun}{offline}} .
		$snark_txt{'gdsc8'} . $damage{$gun}{termin} .
		( $damage{$gun}{level} != -1 ? 
			$snark_txt{'gdsc9'} . $damage{$gun}{level} :
			$snark_txt{'gdsc10'} . get_nickname $damage{$gun}{owner}
		) . $snark_txt{'gdscend'};
}

sub show_guns {

	$yymain = qq( <div class="gundsccontainer">\n);

	foreach my $gun ( sort keys %damage ) {
		
		my $dsc = gun_dsc $gun;
		$dsc =~ s/\n/ <br \/> /g;
		$yymain .= qq(<div class="windowbg" >\n$dsc\n</div>);
	}

	$yymain .= qq(\n</div>);

	$yyinlinestyle = qq(<link rel="stylesheet" href="$forumstylesurl/default/snark.css" type="text/css" />);
	
	&template;
}

=pod
	formats and returns provided log row for displaying in html
=cut
sub huntlog_format {
	my ( $edate, $who, $whom, $act, $arg, $num ) = split /\|/, scalar shift;

	my $row = $snark_txt{'logevt_'.$act};
	if ( $num =~ m/^\d+$/ ) {
		$row = $row->[ $num % @{$row} ];
	} else {
		return $num;
	}

	$edate = timeformat $edate, 1;
	$row =~ s/<date>/$edate/g;
	$row =~ s/<actor>/ get_nickname $who /eg;
	$row =~ s/<target>/ get_nickname $whom /eg;

	if ( $arg =~ s/\/(\d+)$/\/$1#$1/ ) { # :(
		$row =~ s/<place>(.*?)<\/place>/<a href=\"$scripturl?num=$arg\">$1<\/a>/g;
	} elsif ( $arg =~ /^[+-]?\d+$/) {
		$row =~ s/<amount>/$arg/g;
	}

	return $row
}

=pod
	adds string to log writing transaction
=cut
sub huntlog_add {
	push @hunting_log, shift
}

=pod
	writes transaction into the log
=cut
sub huntlog_write {
	if ( not @hunting_log ) {
		return 1
	}

	if ( not fopen HUNTLOG, ">> $vardir/hunting.log" ) {
		return 0
	}

#	my $cdate = $date + ( 3600 * $timeoffset );

#	print  HUNTLOG map { "$date|$_|" . huntlog_format ( "$date|$_" ) . "\n" } @hunting_log;
	print  HUNTLOG map { "$date|$_|" . int ( rand 100 ) . "\n" } @hunting_log;
	fclose ( HUNTLOG );

	@hunting_log = ( )
}

=pod
	reads specified number of records from log, (only event types, matching first parameter)
	returns list of formatted records
=cut
sub huntlog_get {
	my $filter = shift || qr/.*/;
	my $num = shift || 10;

	if ( not fopen HUNTLOG, "< $vardir/hunting.log" ) {
		return ''
	}

	my @retval;

	while ( <HUNTLOG> ) {
		chomp;
		my ( $date, $who, $whom, $act, $arg, $row ) = split /\|/, $_;

		next if not $act =~ m/$filter/;

		push @retval, "$date|$who|$whom|$act|$arg|$row";
#		push @retval, $row;
	}

	fclose ( HUNTLOG );

	@retval = reverse @retval;
	$#retval = $num if $num < $#retval;
	return  map { huntlog_format $_ } @retval
}

sub huntlog_show {
	my $count = $INFO{'display'} || 500;
	$count =~ s/\D+//g;

	if ( $count > 500 ) {
		$count = 500
	} elsif ( $count < 10 ) {
		$count = 10
	}

	$yymain = qq( <div class="huntlog" ><div class="windowbg" ><div class="catbg" >$snark_txt{'huntlog_header'}</div>\n) .
			join ( qq( <br />\n), huntlog_get qr/.*/, $count ) .
			qq(\n</div></div>);
	
	$yyinlinestyle = qq(<link rel="stylesheet" href="$forumstylesurl/default/snark.css" type="text/css" />);
	
	&template;
}

=pod
	hacky sub to not double code, assumes opened FD STARLOG
=cut
sub read_huntdata {

	%starlog = map {
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

			$login => {
				life          => $life,
				max_life      => $max_life,
				ammo          => $ammo,
				death_date    => $death_date,
				shot_date     => $shot_date,
				killed_by     => $killed_by,
				has_killed    => $has_killed,
				deaths_count  => $deaths_count,
			}

		} <STARLOG>;
}

=pod
	loads datas w/o locking
=cut
sub load_huntdata {
	if ( $loaded{starlog} or $loaded{starlog_write} ) {
		return 1
	}

	if ( not open STARLOG, '<', "$vardir/hunting.dat" ) {
		return 0
	}

	read_huntdata;

	close STARLOG;

	$loaded{starlog} = 1;
}

=pod
	loads and locks hunting datas - begins transaction
=cut
sub open_huntdata {
	if ( $loaded{starlog_write} ) {
		return 0
	}

	if ( not open ( STARLOG, '+<', "$vardir/hunting.dat" ) ) {
		return 0
	}

	flock STARLOG, LOCK_EX;

	read_huntdata;

	$loaded{starlog_write} = 1;
	$modified{starlog}     = 0;

	return 1
}

=pod
	unlocks hunting datas and writes changes, if necessary
=cut
sub close_huntdata {
	if ( not $loaded{starlog_write} ) {
		return 0
	}

	if ( $modified{starlog} ) {
	
		seek STARLOG, 0, SEEK_SET;

		foreach my $login ( keys %starlog ) {
			print STARLOG	$login                         . '|' .
					$starlog{$login}{life}         . '|' .
					$starlog{$login}{max_life}     . '|' .
					$starlog{$login}{ammo}         . '|' .
					$starlog{$login}{death_date}   . '|' .
					$starlog{$login}{shot_date}    . '|' .
					$starlog{$login}{killed_by}    . '|' .
					$starlog{$login}{has_killed}   . '|' .
					$starlog{$login}{deaths_count} . "\n";
		}

		truncate STARLOG, tell STARLOG;
	}

	flock STARLOG, LOCK_UN;
	close STARLOG;

	$loaded{starlog}       = 1;
	$loaded{starlog_write} = 0;
	$modified{starlog}     = 0;

	return 1
}

=pod
	call it only on postcount increase - increases ammo and life if necessary
=cut
sub snark_ammo_up {
	my $login = shift;

	open_huntdata or fatal_error $snark_txt{'erropendata'};
	
	if ( exists $starlog{$login} ) {

		LoadUser $login if not exists ${$uid.$login}{postcount};

		if ( ${$uid.$login}{postcount} % 50 == 0 ) {

			$starlog{$login}{max_life}++;
			$starlog{$login}{life}++;
		}

		$starlog{$login}{ammo}++;

		$modified{starlog} = 1;
	}

	close_huntdata or fatal_error $snark_txt{'errclosedata'};
}

=pod
	tries to add user to stardata log. assumes, that transaction is already opened
=cut
sub try_add_to_data {
	my $login = shift;

	if ( not -f "$memberdir/$login.vars" ) {
		return 0
	}

	LoadUser $login unless exists ${$uid.$login}{postcount};

	my $hp = 9 + int ( ${$uid.$login}{postcount} / 50 )
		+ ( ${$uid.$login}{position} eq 'Administrator' ? 8 :
		( ${$uid.$login}{position} eq 'Global Moderator' ? 5 : 0 ) );

	$starlog{$login} = {
			life => $hp,
			max_life => $hp,
			ammo => ${$uid.$login}{postcount} > 50 ? ${$uid.$login}{postcount} : 50,
			death_date => 0,
			shot_date => 0,
			killed_by  => '',
			has_killed => 0,
			deaths_count => 0,
	};
	
	$modified{starlog} = 1;
}

=pod
	returns panel for post - life bar and weapons
	FIXME: how to flexibly template all this?
	How to translate?
	Add tooltips? It's useful!
=cut
sub snark_panel {
	my $target  = shift;
	my $place   = shift;
	my $variant = shift || 0;

	load_huntdata;

	if ( not exists $starlog{$target} ) {
		if ( not try_add_to_data $target ) {
			return ''
		}
	}

	my $retval = qq(<div class="snarkstars">)
		. ( qq(<img src="$imagesdir/snark_lstar.png" alt="*" />\n) x
									$starlog{$target}{life} )
		. ( qq(<img src="$imagesdir/snark_dstar.png" alt="*" />\n) x
					( $starlog{$target}{max_life} - $starlog{$target}{life} ) )
		. qq(</div>\n<div class="snarkfrags">$snark_txt{'snarkpanelfrags'}$starlog{$target}{has_killed}/$starlog{$target}{deaths_count}</div>);

	if ( not exists $starlog{$username} ) {
		if ( not try_add_to_data $username ) {
			return $retval
		}
	}

	load_online_users;

	if ( not $starlog{$username}{life} ) {
		return $retval .
		qq(<img src="$imagesdir/snark_panel_closed.png" style="width: 133px" />)
	}

#	my $cdate = $date + ( 3600 * $timeoffset );

	$retval .= qq~<div class="snarkpanel"><img src="$imagesdir/snark_panel_up${variant}.png" />~;

	foreach my $gun ( keys %damage ) {
		if ( ( $damage{$gun}{level} == -1 and $username ne $damage{$gun}{owner} )
		  or ( $damage{$gun}{level}  > 0  and $iamguest )
		  or ( $damage{$gun}{level}  > 1  and not ( $iamadmin or $iamgmod or $iammod ) )
		  or ( $damage{$gun}{level}  > 2  and not ( $iamadmin or $iamgmod ) )
		  or ( $damage{$gun}{level}  > 3  and not ( $iamadmin ) ) ) {
			next
		}
		
		my $active = 1;
		
		if ( not $damage{$gun}{offline} and not is_online $target ) {
			next
		}

		if ( $username eq $target and not $damage{$gun}{self} ) {
			next
		}

		if ( not $starlog{$target}{life} and not $damage{$gun}{dead} ) {
			next
		}

		if ( $damage{$gun}{load} > $date - $starlog{$username}{shot_date} ) {
			$active = 0
		}

		my $cost = $damage{$gun}{cost};

		if ( $cost eq 'damage' ) {

			$cost = calc_damage $cost, $starlog{$target}{life}

		} else {

			$cost = calc_damage $cost, $starlog{$username}{ammo} < 100 ?
								100 : $starlog{$username}{ammo}
		}

		if ( $starlog{$username}{ammo} < $cost ) {
			$active = 0
		}

		if ( $active ) {

			$retval .=
			qq( <a href="$scripturl?action=ghd;t=$target;g=$gun;p=$place" title=")
			. gun_dsc ($gun) .
			qq(" class="snarkpanelgun">$snark_txt{'gunsign_'.$gun}</a> );

		} else {

			$retval .= qq( <div class="snarkpanelgun">$snark_txt{'gunsign_'.$gun}</div> )
		}
	}

	$retval .= qq(<img src="$imagesdir/snark_panel_dn${variant}.png" /></span></div>);

	return $retval
}

sub snark_header {

	load_huntdata;

#	my $cdate = $date + ( 3600 * $timeoffset );
	my $head;

	if ( not exists $starlog{$username} and not try_add_to_data $username ) {
		$head = $snark_txt{'head_no'}
	} elsif ( $starlog{$username}{life} ) {
		$head = $snark_txt{'head_live'}
	} elsif ( $starlog{$username}{death_date} < $date ) {
		$head = $snark_txt{'head_revive'}
	} else {
		$head = $snark_txt{'head_dead'}
	}

	$head =~ s/<user>/ get_nickname $username /ieg;
	$head =~ s/<ammo>/$starlog{$username}{ammo}/ig; # FIXME: link to gun descs
	$head =~ s/<life>/$starlog{$username}{life}\/$starlog{$username}{max_life}/ig;
	if ( $starlog{$username}{killed_by} ) {
		$head =~ s/<killer>/ get_nickname $starlog{$username}{killed_by} /ige;
	} else {
		$head =~ s/<killer>/$snark_txt{'notkilled'}/ig;
	}

	return $head;
}

=pod
sub test_panel {
	my $target = $INFO{'target'} || $username;
	my $place = $INFO{'place'} || '1234/12';

	open_huntdata or fatal_error $snark_txt{'erropendata'};

	my $result = snark_panel $target, $place;
	my $header = snark_header;

	$yymain = qq(<div class="message">Header: <b>$header</b> <br /> $result</div>);
	$yyinlinestyle = qq(<link rel="stylesheet" href="$forumstylesurl/default/snark.css" type="text/css" />);

	close_huntdata or fatal_error $snark_txt{'errclosedata'};

	my @guns = keys %damage;
	my $gun = $guns[ int rand @guns ];
	huntlog_add "$username|$target|$gun|$place";
	huntlog_add "$username|$target|damage|0";
	huntlog_write;
	
	&template;
}
=cut

=pod
	called on any weapon use. params t (target), g (weapon id), p (tid/postnum)
=cut
sub give_him_damage {
	my $login = $INFO{'t'};
	my $dtype = $INFO{'g'} || 'star';
	my $place = $INFO{'p'};

	if ( $place !~ m/^\d+\/\d+$/ ) {
		$place = '0/0'
	}

	fatal_error $snark_txt{'invaluname'} . $login
			if $login !~ m/^[A-Za-z0-9\@#_.-]+$/;
	
	fatal_error $snark_txt{'invaldmg'} . $dtype
			if $dtype !~ m/^\w+$/ or not exists $damage{$dtype};

#	my $cdate = $date + ( 3600 * $timeoffset );
#	my ( $lsec, $lmin, $lhour, $ldate, $lmon, undef ) = gmtime $cdate;
	fatal_error $snark_txt{'nosnarks'}
			unless $snark_enable;
#			unless $lmon == 4 and $ldate == 1;


	if ( ( $damage{$dtype}{level} == -1 and $username ne $damage{$dtype}{owner} )
	  or ( $damage{$dtype}{level}  > 0  and $iamguest )
	  or ( $damage{$dtype}{level}  > 1  and not ( $iamadmin or $iamgmod or $iammod ) )
	  or ( $damage{$dtype}{level}  > 2  and not ( $iamadmin or $iamgmod ) )
	  or ( $damage{$dtype}{level}  > 3  and not ( $iamadmin ) ) ) {
		fatal_error $snark_txt{'havenogun'} . $snark_txt{'gunname_'.$dtype}
	}


	open_huntdata or fatal_error $snark_txt{'erropendata'};

	my $err;

	if ( not exists $starlog{$username} and not try_add_to_data $username ) {
		$err = $snark_txt{'cantloaduser'} . $username
	}

	if ( not $err and $starlog{$username}{shot_date} + $damage{$dtype}{load} > $date ) {
		$err = $snark_txt{'loading'}
	}

	if ( not $err and not $starlog{$username}{life} ) {
		$err = $snark_txt{'youdead'}
	}


	if ( not $err and $login eq 'yurchor' and $username ne 'yurchor' ) {

		my $dmg = $starlog{$username}{life};

		$starlog{$username}{life} = 0;
		$starlog{$username}{death_date} = $date + 600;
		$starlog{$username}{deaths_count}++;
		$starlog{$username}{killed_by} = 'Boojum';
		# Should'we apply cost?

		$modified{starlog} = 1;

		huntlog_add "$username|Boojum|$dtype|$place";
		huntlog_add "Boojum|$username|damage|$dmg";
		huntlog_add "Boojum|$username|kill|600";

	} elsif ( not $err ) {

		huntlog_add "$username|$login|$dtype|$place";

		my @targets;
		load_online_users;
			
		if ( $damage{$dtype}{area} == -1 ) {

			@targets = ( $username )

		} elsif ( $damage{$dtype}{area} == 0 ) {

			if ( is_online $login or $damage{$dtype}{offline} ) {

				@targets = ( $login );
			# 
			# } else {
			# 
			# 	produce error here?
			}

		} elsif ( $damage{$dtype}{area} == 1 ) {

			@targets = ( $login, grep {
					m/^($login|\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})$/
									? 0 : int rand 3
				} keys %online_users );

		} elsif ( $damage{$dtype}{area} == 2 ) {

			@targets = grep !m/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/, keys %online_users;

		} elsif ( $damage{$dtype}{area} == 3 ) {

			@targets = keys %starlog;
		}


		my $full_damage = 0;

		foreach my $target ( @targets ) {

			if ( $target eq $username and not $damage{$dtype}{self} ) {
				next
			}
	
			if ( not exists $starlog{$target} and not try_add_to_data $target ) {
				next
			}

			my $dmg = calc_damage $damage{$dtype}{amount}, $starlog{$target}{max_life};
			
			if ( $starlog{$target}{life} and $starlog{$target}{life} - $dmg <= 0 ) {
				
				$dmg = $starlog{$target}{life};

				$starlog{$target}{life}       = 0;
				$starlog{$target}{killed_by}  = $username;
				$starlog{$target}{death_date} = $date + $damage{$dtype}{termin};
				$starlog{$target}{deaths_count}++;
			
				if ( $target ne $username ) {
					$starlog{$username}{has_killed}++;
				}

				$modified{starlog} = 1;
				huntlog_add "$username|$target|damage|$dmg";
				$full_damage += $dmg;

				huntlog_add "$username|$target|kill|$damage{$dtype}{termin}";

			} elsif ( $starlog{$target}{life} ) {

				$starlog{$target}{life} -= $dmg;

				if ( $starlog{$target}{life} > $starlog{$target}{max_life} ) {

					$dmg -= $starlog{$target}{max_life} - $starlog{$target}{life};
					$starlog{$target}{life} = $starlog{$target}{max_life};
				}

				if ( $dmg ) {

					$modified{starlog} = 1;
					huntlog_add "$username|$target|damage|$dmg";
					$full_damage += $dmg;
				}

			} elsif ( $damage{$dtype}{dead} ) {

				$starlog{$target}{life} -= $dmg;

				if ( $starlog{$target}{life} < 0 ) {

					$dmg += $starlog{$target}{life};
					$starlog{$target}{life} = 0;

				} elsif ( $starlog{$target}{life} > $starlog{$target}{max_life} ) {

					$dmg -= $starlog{$target}{max_life} - $starlog{$target}{life};
					$starlog{$target}{life} = $starlog{$target}{max_life};
				}

				if ( $dmg ) {

					$starlog{$target}{shot_date} = $date;

					$modified{starlog} = 1;
					huntlog_add "$username|$target|damage|$dmg";
					$full_damage += $dmg;
				}
				
				if ( not $starlog{$target}{life} and $damage{$dtype}{termin} and
				$starlog{$target}{death_date} < $date + $damage{$dtype}{termin} ) {
					
					$starlog{$target}{death_date} = $date + $damage{$dtype}{termin};
					huntlog_add "$username|$target|rekill|$damage{$dtype}{termin}"
				}
			}
		}

		my $cost = $damage{$dtype}{cost};

		if ( $cost eq 'damage' ) {

			$cost = $full_damage

		} else {

			$cost = calc_damage $cost, $starlog{$username}{ammo} < 100 ?
								100 : $starlog{$username}{ammo}
		}

		if ( $starlog{$username}{ammo} < $cost ) {

			$err = $snark_txt{'outofammo'};

			$modified{starlog} = 0;

		} else {
			
			if ( $cost ) {
				$starlog{$username}{ammo} -= $cost;

				huntlog_add "$username|$dtype|cost|$cost"
			}

			$starlog{$username}{shot_date} = $date;

			$modified{starlog} = 1;
		}
	}

	
	close_huntdata or fatal_error $snark_txt{'errclosedata'};

	if ( $err ) {

		fatal_error $err

	} else {

		huntlog_write
	}

	our $yySetLocation = "$scripturl?action=huntlog";
	&redirectexit;
}

=pod
	self-revivification function after die time replenishment.
=cut
sub revive_me_gwog {

	open_huntdata or fatal_error $snark_txt{'erropendata'};

	my $err;

	if ( not exists $starlog{$username} ) {
		$err = $snark_txt{'cantloaduser'} . $username
	}

	if ( not $err and $starlog{$username}{life} ) {
		$err = $snark_txt{'younotdead'}
	}

#	my $cdate = $date + ( 3600 * $timeoffset );

	if ( not $err and $starlog{$username}{death_date} > $date ) {
		$err = $snark_txt{'restmore'}
	}

	if ( not $err ) {
		$starlog{$username}{life}      = $starlog{$username}{max_life};
		$starlog{$username}{shot_date} = $date;
		$modified{starlog} = 1;

		huntlog_add "I'z-chan|$username|izrevive|$starlog{$username}{life}"
	}

	close_huntdata or fatal_error $snark_txt{'errclosedata'};

	if ( $err ) {
		fatal_error $err
	} else {
		huntlog_write
	}

	our $yySetLocation = "$scripturl?action=huntlog";
	&redirectexit;
}

sub regenfullog {

	if ( not $iamadmin or not $sessionvalid ) {
		fatal_error "You must be admin to use this"
	}

	if ( not fopen ( HUNTLOG, "< $vardir/hunting.log" ) ) {
		fatal_error "Can't load huntlog"
	}

	my %colors;
	my $curcolor = 0;
	my $prevactor = '';
	my $log = '';

	my %gstr = (
		damage => '',
		kill => '',
		izrevive => '',
		rekill => '',
		cost => '',
	);

	foreach my $gun ( keys %damage ) {
		$gstr{$gun} = qq(<div class="gun">$snark_txt{'gunsign_'.$gun}</div>)
	}

	while ( <HUNTLOG> ) {
		chomp;

		my ( $date, $actor, $target, $act, $arg, $row ) = split /\|/, $_;

		my $string = huntlog_format $_;

		if ( not exists $colors{$actor} ) {
			LoadUser ( $actor );
			$colors{$actor} = $curcolor++;
		}

		my $gunstr = $gstr{$act};
		if ( $gunstr ) {
			$gunstr = qq(<div class="gun">$gunstr</div>)
		}
		
		my $imagestr = ${$uid.$actor}{userpic};
		if ( $imagestr and $imagestr ne '' ) {
			if ( $imagestr !~ m^/^ ) {
				$imagestr = "$facesurl/$imagestr"
			}

			$imagestr=qq(<div class="av"><img src="$imagestr" /></div>);
		}

		if ( $prevactor ne $actor or $gunstr ) {
			$prevactor = $actor;

			$log .= qq(</div></div>\n<div class="ac${colors{$actor}}">$imagestr$gunstr<div class="st">$string);
		} else {
			$log .= qq(<br />\n$string)
		}
	}

	fclose ( HUNTLOG );

	if ( not fopen ( FULLOG, "> $vardir/fullsnarklog.html" ) ) {
		fatal_error "Cannot open fullog for writing"
	}

	print FULLOG <<FULLOGHDR
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<title>Linux.org.ua - battle log</title>
<meta http-equiv="Content-Type" content="text/html; charset=$yycharset" />
<style>
body {
font-family: monospace;
}
.av {
width: 9%;
text-align: center;
margin-right: -100%;
float: left;
padding: 0;
}
.av img {
max-width: 100%;
max-height: 3em;
}
.gun {
width: 4%;
text-align: center;
float: left;
margin-left: 10%;
}
.st {
width: 80%;
margin-left: 20%;
min-height: 3em;
}
FULLOGHDR
;

	foreach my $actor ( keys %colors ) {
		LoadUser ( $actor );

		my $fg = unpack ( "H6", pack ( "c3", int rand 256, int rand 256, int rand 256 ) );
		my $bg = unpack ( "H6", pack ( "c3", int rand 256, int rand 256, int rand 256 ) );
		
		print FULLOG <<FULLOGSTYLE
.ac$colors{$actor} { /* $actor */
color: #$fg;
background-color: #$bg;
}
.acl$colors{$actor} {
	color: #$fg;
}
FULLOGSTYLE
;
		my $change = ${$uid.$actor}{realname};
		if ( $change ) {
			$change = quotemeta $change;
			$log =~ s^(\s$change)\b^<span class="acl$colors{$actor}">$1</span>^g;
		}
	}

	print FULLOG ".ac" . join ( ", .ac", values %colors ) . " {\n";
	print FULLOG <<FULLOGEND
clear: both;
padding: 0.3em;
margin: 0;
}
</style></header><body><div><div>\n$log\n</div></div></body></html>
FULLOGEND
;
	fclose ( FULLOG );

	$yymain = "Done";

	&template;
}

1;

