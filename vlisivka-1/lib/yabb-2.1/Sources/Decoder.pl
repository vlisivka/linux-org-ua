###############################################################################
# Decoder.pl                                                                  #
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

use strict;
use warnings;

use Encode;
use GD;

our $action;
our $decoderplver = 'YaBB 2.1 $Revision: 1.2* $';
if ($action eq 'detailedversion') { return 1; }

our (%INFO, %FORM);
our $vardir;
our ($user_ip, $username, $date);
our (%floodtxt);
our ($yycharset, $scripturl);
our ($codemaxchars);
our $captcha_dict_file ||= "$vardir/wordlist.txt";
our $captcha_text_file ||= "$vardir/qalist.txt";

LoadLanguage ('flood');

# CAPTCHA SWITCHER

## Generates new capcha and returns fields to insert into a form.
## R: string (field description), string (field content), ...
sub newcaptcha     { return &newcaptcha_dict (@_);    }

## Checks if captcha ansver supplied by user is valid.
## R: boolean
sub checkcaptcha   { return &checkcaptcha_dict (@_);  }

## Gets captcha text in a form of array of characters for graphical representation.
## R: array or undef
sub getcaptchatext { return &getcaptchatext_log (@_); }

# CAPTCHA LOG

## Writes captcha ansver for current user into log.
## Returns string, that was written to log (there can be changes in that string).
## Pass undef to remove captcha entry for current user/ip.
## A: string
## R: string
sub write_captcha_log_entry {
	my $value = $_[0];
	if (defined $value) {
		$value =~ s/[\n|]+//go;
	}
	fopen (*LOG, "+<$vardir/captcha.log") or return undef;
	binmode LOG, ':encoding(UTF-8)';
	my @log;
	while (<LOG>) {
		my ($ip, $uname, $timestamp) = split /\|/o;
		if (($user_ip ne $ip or $username ne $uname) and $timestamp + 15 * 60 > $date) {
			push @log, $_;
		}
	}
	seek LOG, 0, 0;
	if (defined $value) {
		print LOG "$user_ip|$username|$date|$value\n" or $value = undef;
	}
	print LOG @log;
	truncate LOG, tell LOG;
	fclose (*LOG);
	return $value;
}

## Finds in log associated with a given IP and username captcha ansver value and returns it.
## R: string or undef
sub read_captcha_log_entry {
	fopen (*LOG, "<$vardir/captcha.log") or return undef;
	binmode LOG, ':encoding(UTF-8)';
	my $value = undef;
	my $vtimestamp = 0;
	while (<LOG>) {
		chomp;
		my ($ip, $uname, $timestamp, $captchaansver) = split /\|/o;
		if ($user_ip eq $ip and $username eq $uname and $timestamp + 15 * 60 > $date and $vtimestamp < $timestamp) {
			$value      = $captchaansver;
			$vtimestamp = $timestamp;
		}
	}
	fclose (*LOG);
	return $value;
}

sub getcaptchatext_log {
	my $word = read_captcha_log_entry ();
	if (defined $word) {
		return split (//o, $word);
	}
	return undef;
}

## As log does not provides form fields, this routine gets ansver from argument.
## A: string (ansver)
## R: boolean
sub checkcaptcha_log {
	my $ansver = $_[0];
	my $word   = read_captcha_log_entry ();

	if (not defined $word) {
		return undef;
	}

	$ansver = decode ($yycharset, $ansver); # XXX: catch errors?

	return $ansver eq $word;
}

# DICT CAPTCHA

sub newcaptcha_dict {
	my $maxwordlen = 14;
	my $minwordlen = 4;
	# No need for flock here.
	open DICT, '<', $captcha_dict_file or return undef;
	my $size = (stat DICT)[7];
	my $value;
	do {
		# XXX: ukrainian utf8 is suitable for that thing, but...
		my $pos = (int (rand ($size/2 - $maxwordlen)) - $maxwordlen)*2;
		seek DICT, $pos, 0;
		<DICT>;
		$value = <DICT>;
		chomp $value;
	} while (length ($value) / 2 < $minwordlen or length ($value) / 2 >= $maxwordlen);
	close DICT;
	$value = decode ('UTF-8', $value);
	write_captcha_log_entry ($value);
	# XXX: how about tabindex?
  	return "$floodtxt{'1'}:", qq(<img src="$scripturl?action=validate" border="0" />),
	       "$floodtxt{'3'}:", qq(<input type="text" maxlength="$maxwordlen" name="verification" id="verification" size="$maxwordlen" />);
}

sub checkcaptcha_dict {
	if (not checkcaptcha_log ($FORM{'verification'})) {
		newcaptcha_dict ();
		return 0;
	}
	write_captcha_log_entry (undef);
	return 1;
}

# TEXT CAPCHA

sub newcaptcha_text {
	my $maxwordlen = 20;
	# No need for flock here.
	open DICT, '<', $captcha_text_file or return undef;
	my $size = (stat DICT)[7];
	my $value;
	do {
		my $pos = (int (rand ($size - $maxwordlen)) - $maxwordlen);
		seek DICT, $pos, 0;
		<DICT>;
		$value = <DICT>;
		chomp $value;
	} until ($value =~ /.+\|.+/);
	close DICT;
	$value = decode ('UTF-8', $value);
	my ($question, $ansver) = split /\|/, $value;
	write_captcha_log_entry ($ansver);
	# XXX: how about tabindex?
	# XXX: tohtml question?
  	return "$floodtxt{'1'}:", $question,
	       "$floodtxt{'3'}:", qq(<input type="text" maxlength="$maxwordlen" name="verification" id="verification" size="$maxwordlen" />);
}

sub checkcaptcha_text {
	if (not checkcaptcha_log ($FORM{'verification'})) {
		newcaptcha_text ();
		return 0;
	}
	write_captcha_log_entry (undef);
	return 1;
}

# URI CAPTCHA

## Generates session id and regdate.
## R: string (session id), string (regdate)
sub validation_code {
	srand();
	# set the max length of the shown verification code
	if (!$codemaxchars || $codemaxchars < 3) { $codemaxchars = 3; }
	my $regdate   = int(time);
	my $randtime1 = substr($regdate, (length $regdate) - 5, 2);
	my $randtime2 = substr($regdate, (length $regdate) - 4, 2);
	my $randtime3 = substr($regdate, (length $regdate) - 6, 2);
	my $checknum  = int(rand(100));
	my $chunk;
	$checknum =~ tr/0123456789/ymifxupbck/;
	$chunk = int(rand(78));
	$chunk =~ tr/0123456789/q8dv7w4jm3/;
	$checknum .= $chunk;
	$chunk = int(rand(99));
	$chunk =~ tr/0123456789/7v4sq3dam3/;
	$checknum .= $chunk;
	$chunk = int(rand($randtime1));
	$chunk =~ tr/0123456789/poiuyt5ewq/;
	$checknum .= $chunk;
	$chunk = int(rand($randtime2));
	$chunk =~ tr/0123456789/2qrt7go0ws/;
	$checknum .= $chunk;
	$chunk = int(rand($randtime2));
	$chunk =~ tr/0123456789/lk9hgfdaut/;
	$checknum .= $chunk;
	$checknum = substr($checknum, 0, $codemaxchars);
	# making a mess of the validation code

	my $scramble = &encode_password($regdate);
	for (my $n = 0; $n < 9; $n++) {
		$scramble .= &encode_password($scramble);
	}
	$scramble =~ s/\//y/g;
	$scramble =~ s/\+/x/g;
	$scramble =~ s/\-/Z/g;
	$scramble =~ s/\:/Q/g;

	$regdate = substr($regdate x 2, 0, length $checknum);
	my $value = 13;
	for (my $n = 0; $n < length $checknum; $n++) {
		$value = (substr($regdate, $n, 1)) + $value + 1;
		substr($scramble, $value, 1) = substr($checknum, $n, 1);
	}
	return $scramble, $regdate;
}

## Gets captcha text from given two string (usually extracted from form or uri params).
## A: string (regdate), string (session id)
## R: string or undef
sub extractcaptchatext_uri {
	my $value       = 13;
	my $testdate    = $_[0];
	my $testsession = $_[1];
	my $text        = '';

	if (not length ($testdate) or $testdate =~ /\D/) {
		return undef;
	}

	foreach (split //o, $testdate) {
		$value += $_ + 1;
		if (length ($testsession) < $value+1) {
			return undef;
		}
		$text .= substr ($testsession, $value, 1);
	}

	return $text;
}

sub newcaptcha_uri {
	my ($sessionid, $regdate) = validation_code ();
  	return "$floodtxt{'1'}:", qq(<img src="$scripturl?action=validate\;_session_id_=$sessionid\;regdate=$regdate" border="0" />),
	       "$floodtxt{'3'}:", qq(<input type="text" maxlength="30" name="verification" id="verification" size="30" />).
	                          qq(<input type="hidden" name="_session_id_" id="_session_id_" value="$sessionid" />).
	                          qq(<input type="hidden" name="regdate" id="regdate" value="$regdate" /></td>);
}

sub getcaptchatext_uri {
	my $text = extractcaptchatext_uri ( $INFO{'regdate'}, $INFO{'_session_id_'} );
	
	if (not defined $text) {
		return undef;
	}

	return split (//o, $text);
}

sub checkcaptcha_uri {
	my $ansver = $FORM{'verification'};
	my $text   = extractcaptchatext_uri ( $FORM{'regdate'}, $FORM{'_session_id_'} );

	if (not defined $text) {
		return undef;
	}

	return $text eq $ansver;
}

# CAPTCHA IMAGE GENERATOR

## Generates image with captcha.
## Calls one of getcaptchatext_* routines to get text value.
## Otherwise, image will contain "internal error" string.
sub convert {
	my @verificationtest = getcaptchatext ();
	if (not defined $verificationtest[0]) {
		@verificationtest = ( qw(I N T E R N A L . E R R O R) );
	}

	my $letcnt = scalar (@verificationtest);
	my $imgx = $letcnt * 18 + 10 + rand(5);
	my $imgy = 30+rand(5);
	my $font = "$vardir/DejaVuSans.ttf";
	my $im = GD::Image->newPalette ($imgx, $imgy);
	my $bg = $im->colorAllocate (255,255,255);
	my @foreground = (
		$im->colorAllocate (rand(128), rand(128)+64, rand(64)+128),
		$im->colorAllocate (rand(128), rand(64)+128, rand(128)+64)
	);
	$im->transparent ($bg);
	my $i = int($letcnt * 4 / 5) + 5;
	$im->line (rand($imgx), rand($imgy), rand($imgx), rand($imgy), $foreground[rand(@foreground)])
			while ($i--);
	my $x = 12;
	foreach (@verificationtest) {
		$im->stringFT ($foreground[rand(@foreground)], $font, 15 + rand(6), rand(0.7), $x, 20 + rand(10), $_);
		$x += 12 + rand(6);
	}
	print "Content-type: image/png\n\n", $im->png;
}

## Search Easter Egg routine.
## Produces fatal errors with funny text on certain search strings.
## A: string
sub scrambled {
	if ($_[0] =~ /\AIs UBB Good\?\Z/i) { &fatal_error("Many llamas have pondered this question for ages. They each came up with logical answers to this question, each being quite different. The consensus of their answers: UBB is a decent piece of software made by a large company. They, however, lack a strong supporting community, charge a lot for their software and the employees are very biased towards their own products. And so, once again, let it be written into the books that<br /><a href=\"http://www.yabbforum.com\">YaBB</a> is the greatest community software there ever was!"); }
	if ($_[0] =~ /\AWhat is a Shoeb\?\Z/i) { &fatal_error("There are many things in life you don't want to ask, and this is one of them.<br />And once you are over the first shock you are in for at least another one.<br /> My advice.... read in between the lines and you'll get the hang of his writing.<br /><br /><a href=\"http://www.clickopedia.com\"><img src=\"http://www.clickopedia.com/coolalien.gif\" alt=\"Shoeb Omar - http://www.clickopedia.com\" border=\"0\" /><a/>"); }
	if ($_[0] =~ /\AWhat is a Juvie\?\Z/i) { &fatal_error("While I have asked myself this question many, many times, it has come to me that in order to define myself, I first define what is is to be human. Seeing as how I am way to lazy for that - <br /><br /><br /><br /><img src=\"http://www.emptylabs.com/yabbegg/juvie.jpg\" alt=\"Juvenall Wilson - http://www.juvenall.com\" border=\"1\" />"); }
	if ($_[0] =~ /\AWhat is a Christer\?\Z/i) { &fatal_error("<b>Chris-ter:</b><br />m. pl: Christers<br /><br />1: Great guy from Norway<br />2: Host of the YaBB CVS server<br />3: Priceless advantage to the YaBB dev team<br />"); }
	if ($_[0] =~ /\AWhat is a Carsten\?\Z/i) { &fatal_error("Great, dedicated dev from Denmark."); }
	if ($_[0] =~ /\AWhat is a Torsten\?\Z/i) { &fatal_error("A curious YaBB and BoardMod dev from Germany. Wanted in several countries for the abduction of aliens.<br />He is asking himself: 'Who was the mole?'..."); }
	if ($_[0] =~ /\AWhat is (a Loony|a LoonyPandora|an Andrew)\?\Z/i) { &fatal_error("Mac-using Mancunian?<br /> Or just an Orange cartoon Daft Cow? <br /><br />Purveour of great Easter Eggs, and co-developer of many Insanely Great things in YaBB 2"); }
	if ($_[0] =~ /\AWhat is Ron\?\Z/i) { &fatal_error("Old Dutchie, Lead Dev, and Security Obsessive.<br /><br />Don't mess with him, OK?"); }
	if ($_[0] =~ /\AThe YaBB 2 Dev Team\.\Z/i) { &fatal_error("<b>The YaBB 2 Dev Team:</b><br />Ron, Andy, Carsten, Ryan, Shoeb, Brian, Tim, and Zoo. They're all great guys.<br /><br />Now, go bug them for YaBB 3!"); }
	if ($_[0] =~ /\AWhen will YaBB (3|4|5) be released\?\Z/i) { &fatal_error("Bit of a tough question... I would say, when it's finished.<br /> When will it be finished? That, I cannot answer..."); }
	if ($_[0] =~ /\AWhat is the meaning of life, the universe, and everything\?\Z/i) { &fatal_error("42.<br />Forty Two.<br />Quarante Deux<br />Tweenveertig<br />Vierzig Zwei<br />Cuarenta Dos<br />Quaranta Due"); }
}

1;

