#
# Banning users with a special groups.
#
# б╘ 2007-2009 Myhailo Danylenko <isbear@ukrpost.net>
#

use strict;
use warnings;
no strict qw(refs); # >:( ${$uid.$login}{...}
use Encode;

our (%FORM, %INFO);
our ($yySetLocation, $yycharset, $scripturl, $uid, $date);
our ($username, $iamadmin, $iamgmod, $iammod, $sessionvalid);
our (%Group, %Post, %NoPost);
our (%bangroup_txt);
our ($vardir);
our %loaded;

return if $loaded{'BanWithGroup.pl'};
$loaded{'BanWithGroup.pl'} = 1;

LoadLanguage ( 'BanWithGroup' ) if not $loaded{'BanWithGroup.lng'};

# TODO
#
# change lng: bangroup_txt{nomain} -> {nogroup}, generalize text accordingly
# add records into banlog about safety lock?
# move group_id and save_groups to Subs.pl?
# FIXME we should define upper limit for ban termin.

# UTILITY ROUTINES

## group_gid
## Searches for No Post group and returns it's id. Case does not matter.
## A: string (group name)
## R: number (group id) or undef
sub group_gid {
	my $name = quotemeta $_[0];
	foreach my $id ( keys %NoPost ) {
		if ($NoPost{$id} =~ /^$name\|/i) {
			return $id
		}
	};
	return undef;
}

## push_ban_log
## Writes record about taken action into banlog, additionally providing timestamp.
## A: string (who acts), string (object of action), number (group id), number (ban termin), string (message)
## R: boolean
sub push_ban_log {
	my ( $who, $whom, $gid, $termin, $reason ) = @_;
	$reason = decode ( $yycharset, $reason ); # XXX
	fopen ( *BANLOG, ">> $vardir/banwithgroup.log" ) or return 0;
	binmode BANLOG, ":encoding(UTF-8)"; # XXX
	print BANLOG "$date|$who|$whom|$gid|$termin|$reason\n";
	fclose ( *BANLOG );
	return 1
}

## save_groups
## Saves current state of membergroups into $vardir/membergroups.txt
sub save_groups {
	fopen ( *GRP, ">$vardir/membergroups.txt" )
		or fatal_error $bangroup_txt{'cof'} . "$vardir/membergroups.txt";
#	binmode GRP, ":encoding($yycharset)"; # XXX
	print GRP map "\$Group{'$_'} = '$Group{$_}';\n",   keys %Group;
	print GRP map "\$NoPost{'$_'} = '$NoPost{$_}';\n", keys %NoPost;
	print GRP map "\$Post{'$_'} = '$Post{$_}';\n",     keys %Post;
	print GRP     "\n1;\n";
	fclose ( *GRP );
}

## safety_lock
## Adds current user (admin or gmod) to group 'Safety Lock'
sub safety_lock {

	unless ( $iamadmin or $iamgmod or $iammod ) {
		fatal_error $bangroup_txt{'notallowed'};
	}

	unless ( exists ${$uid.$username}{'addgroups'} ) {
		# generally, this should be not necessary, just for sure..
		LoadUser ( $username )
			or fatal_error ( $bangroup_txt{'cannotloaduser'} . $username );
	}

	my $lockgid = group_gid ( 'Safety Lock' );
	if ( not defined $lockgid ) {
		fatal_error ( $bangroup_txt{'nogroup'} . 'Safety Lock' );
	}

	unless ( ${$uid.$username}{'addgroups'} =~ /(^|,)$lockgid(,|$)/ ) {
		${$uid.$username}{'addgroups'} = join ',', ( split ( /,/, ${$uid.$username}{'addgroups'} ), $lockgid );
		UserAccount ( $username, 'update' );
	}
	
#	$yySetLocation = "$scripturl?action=viewprofile;username=$username";
	$yySetLocation = $ENV{'HTTP_REFERER'};
	redirectexit ();
}

## safety_unlock
## Removes group 'Safety Lock' from a list of current user groups
sub safety_unlock {

	unless ( exists ${$uid.$username}{'addgroups'} ) {
		# generally, this should be not necessary, just for sure..
		LoadUser ( $username )
			or fatal_error ( $bangroup_txt{'cannotloaduser'} . $username );
	}

	my $lockgid = group_gid ( 'Safety Lock' );
	if ( not defined $lockgid ) {
		fatal_error ( $bangroup_txt{'nogroup'} . 'Safety Lock' );
	}

	if ( ${$uid.$username}{'addgroups'} =~ /(^|,)$lockgid(,|$)/ ) {
		${$uid.$username}{'addgroups'} =~ s/(^|,)$lockgid(,|$)/$1/;
		UserAccount ( $username, 'update' );
	}
	
#	$yySetLocation = "$scripturl?action=viewprofile;username=$username";
	$yySetLocation = $ENV{'HTTP_REFERER'};
	redirectexit;
}


## ban_with_group
## Processes request to ban 'username' for 'termin' with 'reason'.
sub ban_with_group {
	my $login  = $FORM{'username'} || $INFO{'username'};
	my $termin = $FORM{'termin'}   || $INFO{'termin'};
	my $reason = $FORM{'reason'}   || $INFO{'reason'} || '';

	if ( $login !~ /^[A-Za-z0-9\@#_\-.]+$/ ) {
		fatal_error ( $bangroup_txt{'invaluname'} . $login );
	}

	if ( $termin =~ /[^0-9 mhdM]/ ) {
		fatal_error ( $bangroup_txt{'invalterm'} . $termin );
	}

	if ( $termin !~ /[0-9mhdM]/ ) {
		$termin = '0';
	}

	# XXX
	if ( $reason =~ /[\x00-\x1F\x7F]/ ) {
		fatal_error ( $bangroup_txt{'invalreason'} . $reason );
	}

	FromChars ( $reason );
	ToHTML    ( $reason );

	unless ( ( $iamadmin or $iamgmod or $iammod ) and $sessionvalid ) {
		fatal_error ( $bangroup_txt{'notallowed'} );
	}

	if ( $login eq 'admin' ) {
		fatal_error ( $bangroup_txt{'nobadmin'} );
	}

	$termin =~ s/(\d)\s+(\D)/$1$2/g;
	$termin =~ s/(\d)(\s+|$)/$1h /g;
	$termin =~ s/(\D)\s*/$1 /g;
	$termin =~ s/(^|\s+)(\D)/ 1$2/g;
	$termin =~ s/m/*60+/g;
	$termin =~ s/h/*60*60+/g;
	$termin =~ s/d/*60*60*24+/g;
	$termin =~ s/M/*60*60*24*30+/g;
	$termin .= $date;
	$termin  = eval "int($termin)"; # XXX

	if ( $termin > 4000000000 ) {
		$termin = 4000000000; # XXX this value is determined by experiment...
	}

	my $mainbanid = group_gid ( 'Banned' );
	if ( not defined $mainbanid ) {
		fatal_error ( $bangroup_txt{'nogroup'} . 'Banned' );
	}

	unless ( exists ${$uid.$login}{'addgroups'} ) {
		LoadUser ( $login )
			or fatal_error ( $bangroup_txt{'cannotloaduser'} . $login );
	}

	if ( ${$uid.$login}{'addgroups'} =~ /(^|,)$mainbanid(,|$)/ ) {
		if ( $NoPost{${$uid.$login}{'position'}} =~ /^\[banned=(\d+),(.*?)\]\|/i ) {
			if ( $1 > $termin ) {
				fatal_error ( $bangroup_txt{'nolower'} . int ( ( $1 - $date ) / 60 + 1 ) );
			}

			$NoPost{${$uid.$login}{'position'}} =~ s/^\[banned=\d+,(.*?)\]\|/[banned=$termin,$1]|/i;
			save_groups ();
	
			push_ban_log ( $username, $login, ${$uid.$login}{'position'}, $termin, $reason )
					or fatal_error $bangroup_txt{'cannotlog'};

			$yySetLocation = "$scripturl?action=bwglog";
			redirectexit ();
		}

		${$uid.$login}{'addgroups'} =~ s/(^|,)$mainbanid(,|$)/$1/
	}

	my $newid = keys %NoPost;

	++$newid while exists $NoPost{$newid};

	$NoPost{$newid} = "[banned=$termin,${$uid.$login}{'position'}]|1|ban.png||0|0|0|0|0|0|0";
	save_groups ();

	${$uid.$login}{'addgroups'} = join ',', ( split ( /,/, ${$uid.$login}{'addgroups'} ), $mainbanid );
	${$uid.$login}{'position'}  = $newid;
	UserAccount ( $login, 'update' );

	push_ban_log ( $username, $login, $newid, $termin, $reason )
			or fatal_error ( $bangroup_txt{'cannotlog'} );

	$yySetLocation = "$scripturl?action=bwglog";
	redirectexit ();
}

## unban_with_group
## Forcely unbans 'username' (before termin expiration) (admin, gmod)
sub unban_with_group {
	my $login = $INFO{'username'};

	if ( $login !~ /^[A-Za-z0-9\@#_\-.]+$/ ) {
		fatal_error ( $bangroup_txt{'invaluname'} . $login );
	}

	if ( not ( $iamadmin or $iamgmod ) ) {
		fatal_error ( $bangroup_txt{'notallowed'} );
	}

	my $mainbanid = group_gid ( 'Banned' );
	if ( not defined $mainbanid ) {
		fatal_error ( $bangroup_txt{'nogroup'} . 'Banned' );
	}
	
	unless ( exists ${$uid.$login}{'addgroups'} ) {
		LoadUser ( $login )
			or fatal_error ( $bangroup_txt{'cannotloaduser'} . $login );
	}

	if ( ${$uid.$login}{'addgroups'} !~ /(^|,)$mainbanid(,|$)/ ) {
		fatal_error ( $bangroup_txt{'notbanned'} );
	}
	
	my $addid = ${$uid.$login}{'position'};

	if ( $NoPost{$addid} !~ /^\[banned=\d+,(.*?)\]\|/i ) {
		fatal_error ( $bangroup_txt{'noaddid'} );
	}

	${$uid.$login}{'position'}  =  $1;
	${$uid.$login}{'addgroups'} =~ s/(^|,)$mainbanid(,|$)/$1/;
	UserAccount ( $login, 'update' );

	delete $NoPost{$addid};
	save_groups;

	push_ban_log ( $username, $login, $addid, 'unban', '' )
			or fatal_error ( $bangroup_txt{'cannotlog'} );

	our $yySetLocation = "$scripturl?action=bwglog";
	redirectexit ();
}

## ban_with_group_passthrough
## Shows form to send request for banning 'username'.
sub ban_with_group_passthrough {

	my $login  = $INFO{'username'};
	my $termin = $INFO{'termin'} || 1;
	my $reason = $INFO{'reason'} || '';

	$login  =~ s/[^A-Za-z0-9\@#_\-.]+//g;
	$termin =~ s/[^\dmhdM]+/ /g;
	$reason =~ s/[\x00-\x1F\x7F]+//g; # XXX

	ToHTML ( $reason );
	
	my  @ti = $login ? ( 4, 1, 2, 3 ) : ( 1, 2, 3, 4 );

	our $yytitle = $bangroup_txt{ $login ? 'titleuser' : 'title' } . $login;
	our $yymain  = qq~
	<form action="$scripturl?action=bwg" method="post" >
	<table cellpadding="4" cellspacing="1" border="0" width="60%" align="center" class="bordercolor" style="margin: 1em 20%;"><tr>
		<td colspan="2" class="titlebg"><b>$yytitle</b></td>
	</tr><tr>
		<td class="windowbg">$bangroup_txt{'unamefield'}</td>
		<td class="windowbg2"><input type="text" name="username" value="$login" tabindex="$ti[0]" style="width: 100%" /></td>
	</tr><tr>
		<td class="windowbg">$bangroup_txt{'terminfield'}</td>
		<td class="windowbg2"><input type="text" name="termin" value="$termin" tabindex="$ti[1]" style="width: 100%" /></td>
	</tr><tr>
		<td class="windowbg">$bangroup_txt{'reasonfield'}</td>
		<td class="windowbg2"><input type="text" name="reason" value="$reason" tabindex="$ti[2]" style="width: 100%" /></td>
	</tr><tr>
		<td colspan="2" class="catbg"><input type="submit" name="submit" value="$bangroup_txt{'bansubmit'}" tabindex="$ti[3]" style="width: 100%" /></td>
	</tr></table>
	</form>
~;

	template ();

	exit;
}

## bwg_message_form
## Shows form to add message to bwglog.
sub bwg_message_form {
	my $message = $INFO{'message'} || '';

	$message =~ s/[\x00-\x1F\x7F]+//g; # XXX

	ToHTML ( $message );
	
	our $yytitle = $bangroup_txt{'titlemesg'};
	our $yymain  = qq~
	<form action="$scripturl?action=mbwg" method="post" >
	<table cellpadding="4" cellspacing="1" border="0" width="60%" align="center" class="bordercolor" style="margin: 1em 20%;"><tr>
		<td colspan="2" class="titlebg"><b>$yytitle</b></td>
	</tr><tr>
		<td class="windowbg">$bangroup_txt{'mesgfield'}</td>
		<td class="windowbg2"><input type="text" name="message" value="$message" tabindex="1" style="width: 100%" /></td>
	</tr>v<tr>
		<td colspan="2" class="catbg"><input type="submit" name="submit" value="$bangroup_txt{'mesgsubmit'}" tabindex="2" style="width: 100%" /></td>
	</tr></table>
	</form>
~;

	template ();

	exit;
}

## bwg_add_message
## Processes request to add message to log.
sub bwg_add_message {
	my $message = $FORM{'message'} || $INFO{'message'} || '';

	# XXX
	if ( $message =~ /[\x00-\x1F\x7F]/ ) {
		fatal_error ( $bangroup_txt{'invalreason'} . $message ); # FIXME
	}

	FromChars ( $message );
	ToHTML    ( $message );

	unless ( ( $iamadmin or $iamgmod or $iammod ) and $sessionvalid ) {
		fatal_error ( $bangroup_txt{'notallowed'} );
	}

	push_ban_log ( $username, '', '', 'message', $message )
			or fatal_error ( $bangroup_txt{'cannotlog'} );

	our $yySetLocation = "$scripturl?action=bwglog";
	redirectexit ();
}

## expire_ban_with_group
## Removes expired ban from 'username'.
sub expire_ban_with_group {

	my $login = $INFO{'username'};

	if ( $login !~ /^[A-Za-z0-9\@#_\-.]+$/ ) {
		fatal_error $bangroup_txt{'invaluname'} . $login
	}

	my $mainbanid = group_gid ( 'Banned' );
	if ( not defined $mainbanid ) {
		fatal_error ( $bangroup_txt{'nogroup'} . 'Banned' );
	}

	unless ( exists ${$uid.$login}{'addgroups'} ) {
		LoadUser ( $login )
		or fatal_error $bangroup_txt{'cannotloaduser'} . $login
	}

	if ( ${$uid.$login}{'addgroups'} !~ /(^|,)$mainbanid(,|$)/ ) {
		fatal_error $bangroup_txt{'notbanned'}
	}

	my $addid = ${$uid.$login}{'position'};

	if ( $NoPost{$addid} !~ /^\[banned=(\d+),(.*?)\]\|/i ) {
		fatal_error $bangroup_txt{'noaddid'}
	}

	if ( $date < $1 ) {
		fatal_error $bangroup_txt{'notexpired'} . &timeformat ( $1 )
	}

	${$uid.$login}{'position'}  =  $2;
	${$uid.$login}{'addgroups'} =~ s/(^|,)$mainbanid(,|$)/$1/;
	UserAccount ( $login, 'update' );

	delete $NoPost{$addid};
	save_groups;

	push_ban_log ( $username, $login, $addid, 'expire', '' )
			or fatal_error $bangroup_txt{'cannotlog'};
	
	our $yySetLocation = "$scripturl?action=bwglog";
	redirectexit ();
}

## show_ban_log
## Generates ban log page
sub show_ban_log {

	fopen ( *BANLOG, "< $vardir/banwithgroup.log" )
			or fatal_error ( $bangroup_txt{'cof'} . "$vardir/banwithgroup.log" );
	binmode BANLOG, ":encoding(UTF-8)"; # XXX

	our $yytitle = $bangroup_txt{'banlogtitle'};
	our $yymain  = qq(<div class="windowbg"><div class="catbg">$bangroup_txt{'banlogtitle'}</div>);
	while ( <BANLOG> ) {
		chomp;

		my ( $cdate, $who, $whom, $gid, $termin, $reason ) = split /\|/, $_;
		$reason = encode ( $yycharset, $reason ); # XXX
		
		LoadUser ( $who )  if not exists ${$uid.$who}{'realname'};
		LoadUser ( $whom ) if not exists ${$uid.$whom}{'realname'};
		$who   = ${$uid.$who}{'realname'}  || $bangroup_txt{'nonick'};
		$whom  = ${$uid.$whom}{'realname'} || $bangroup_txt{'nonick'};
		$cdate = timeformat $cdate;
		ToChars   $reason;

		# FIXME: organize as table? make it template?
		if ( $termin eq 'expire' or $termin eq 'unban' ) {
			$yymain .= qq([$cdate] $who$bangroup_txt{'blog4'}$whom$bangroup_txt{'blog3'}$gid<br/>\n);
		} elsif ( $termin eq 'message' ) {
			$yymain .= qq([$cdate] $who: $reason<br/>\n);
		} else {
			$termin = timeformat $termin;
			$yymain .= qq([$cdate] $who$bangroup_txt{'blog1'}$whom$bangroup_txt{'blog2'}$termin$bangroup_txt{'blog3'}$gid$bangroup_txt{'blog5'}$reason<br/>\n);
		}
	}
	$yymain .= qq(</div>);

	fclose ( *BANLOG );

	template ();
	exit;
}

1;

