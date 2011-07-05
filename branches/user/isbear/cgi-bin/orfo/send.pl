#!/usr/bin/perl -w
use strict;
use utf8;

use CGI::Carp qw(fatalsToBrowser);
use CGI qw(param);

print "Content-Type: text/plain; charset=utf-8\r\n\r\n";

my $subject=param('subject');
my $referrer=param('referrer');
my $address=param('address');
my $context=param('context');


die "subject required" if( (not defined $subject) or ($subject eq "") );
die "referrer required" if( (not defined $referrer) or ($referrer eq "") );
die "address required" if( (not defined $address) or ($address eq "") );
die "context required" if( (not defined $context) or ($context eq "") );

my $message=<<MESSAGE;
На сайті знайшлася орфографічна помилка, адреса:
$address
(зайшли з $referrer)

================================================
$context
================================================

MESSAGE

my $mailtype=0;
my $smtp_server='localhost';
my $mailprog='/usr/sbin/sendmail';

sendmail('vlisivka@gmail.com',$subject,$message,'vlisivka@gmail.com') || die "Can't send email";

#########################################################################
sub sendmail
{
	my ($to, $subject, $message, $webmaster_email) = @_;
	if ($mailtype==1) { use Socket; }
	$to =~ s/[ \t]+/, /g;
	$webmaster_email =~ s/.*<([^\s]*?)>/$1/;
	$message =~ s/^\./\.\./gm;
	$message =~ s/\r\n/\n/g;
	$message =~ s/\n/\r\n/g;
	$message =~ s/<\/*b>//g;
	$smtp_server =~ s/^\s+//g;
	$smtp_server =~ s/\s+$//g;
	if (!$to) { return(-8); }

 	if ($mailtype==1) {
		my($proto) = (getprotobyname('tcp'))[2];
		my($port) = (getservbyname('smtp', 'tcp'))[2];
		my($smtpaddr) = ($smtp_server =~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/) ? pack('C4',$1,$2,$3,$4) : (gethostbyname($smtp_server))[4];

		if (!defined($smtpaddr)) { return(-1); }
		if (!socket(MAIL, AF_INET, SOCK_STREAM, $proto)) { return(-2); }
		if (!connect(MAIL, pack('Sna4x8', AF_INET, $port, $smtpaddr))) { return(-3); }

		my($oldfh) = select(MAIL);
		$| = 1;
		select($oldfh);

		$_ = <MAIL>;
		if (/^[45]/) {
			close(MAIL);
			return(-4);
		}

		print MAIL "helo $smtp_server\r\n";
		$_ = <MAIL>;
		if (/^[45]/) {
			close(MAIL);
			return(-5);
		}

		print MAIL "mail from: <$webmaster_email>\r\n";
		$_ = <MAIL>;
		if (/^[45]/) {
			close(MAIL);
			return(-5);
		}

		foreach (split(/, /, $to)) {
			print MAIL "rcpt to: <$_>\r\n";
			$_ = <MAIL>;
			if (/^[45]/) {
				close(MAIL);
				return(-6);
			}
		}

		print MAIL "data\r\n";
		$_ = <MAIL>;
		if (/^[45]/) {
			close(MAIL);
			return(-5);
		}

	}

	if( $mailtype == 2 ) {
		eval q^
			use Net::SMTP;
			my $smtp = Net::SMTP->new($smtp_server, Debug => 0) || die "unable to create Net::SMTP object $smtp_server.";
			$smtp->mail($webmaster_email);
			$smtp->to($to);
			$smtp->data();
			$smtp->datasend("From: $webmaster_email\n");
			$smtp->datasend("X-Mailer: Perl Powered Socket Net::SMTP Mailer\n");
			$smtp->datasend("Subject: $subject\n");
			$smtp->datasend("Content-Type: text/plain; charset=utf-8\n");
			$smtp->datasend("\n");
			$smtp->datasend($message);
			$smtp->dataend();
			$smtp->quit();
		^;
		if($@) {
			&fatal_error("\n<br>Net::SMTP fatal error: $@\n<br>");
			return -77;
		}
		return 1;
	}

	if ($mailtype==0) { open(MAIL,"| $mailprog -t"); }

	print MAIL "To: $to\n";
	print MAIL "From: $webmaster_email\n";
	print MAIL "X-Mailer: YaBB Perl-Powered Socket Mailer\n";
	print MAIL "Content-Type: text/plain; charset=utf-8\n";
	print MAIL "Subject: $subject\n\n";
	print MAIL "$message";
	print MAIL "\n.\n";
	if ($mailtype==1) {
		$_ = <MAIL>;
		if (/^[45]/) {
			close(MAIL);
			return(-7);
		}
		print MAIL "quit\r\n";
		$_ = <MAIL>;
	}
	close(MAIL);
	return(1);
}
