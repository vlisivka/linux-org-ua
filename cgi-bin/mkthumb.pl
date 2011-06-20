#!/usr/bin/perl -wT

# Automatic thumbnail generator, v0.1, 16-02-2004 17:15:52 +0200
# Author: Volodymyr M. Lisivka
# License: GNU General Public License version 2,
#          as published by Free Software Foundation

# Modified by Myhailo Danylenko, Wed Oct  3 17:15:29 EEST 2007:
# * changed -sample 128x128 to -resize 128x (I think, it looks better)
# * changed /bin/cat execution to internal print while.
# Wed Nov  7 00:47:44 EET 2007
# * added http status codes
# * now src and dst dirs and they should be different

#Usage:
# put that line into your .htaccess in directory with images and change
# paths above.
# .htaccess:
# ErrorDocument 404 /cgi-bin/mkthumb.pl

use strict;
#use CGI::Debug;

my $srcdir = '/var/www/vhosts/linux.org.ua/htdocs/yabbfiles/Attachments';
my $dstdir = '/var/www/vhosts/linux.org.ua/htdocs/thumbs';
my $prefix = '/thumbs/'; # Place '/' here at least.

my $convert   = '/usr/bin/convert';
my $operation = 'resize';
my $size      = '128x';

my %mimetype = (
'gif'  => 'image/gif',
'jpg'  => 'image/jpeg',
'jpeg' => 'image/jpeg',
'png'  => 'image/png',
);

my $file = $ENV{'REQUEST_URI'};
unless (defined $file) {
	print "Status: 400 Bad Request\r\nContent-type: text/plain\r\n\r\nNo REQUEST_URI\n";
	exit(1);
}

$file =~ m~${prefix}([^/]+\.(gif|jpg|jpeg|png))$~i;
$file = $1;

unless (defined $file) {
	print "Status: 406 Not Acceptable\r\nContent-type: text/plain\r\n\r\nBad REQUEST_URI\n";
	exit(1);
}

my $mime = $mimetype{$2};

unless (-f "$dstdir/$file") {
	unless (-f "$srcdir/$file") {
		print "Status: 404 Not Found\r\nContent-type: text/plain\r\n\r\nFile Not Found\n";
		exit(1);
	}
  
	$ENV{'PATH'}='';
	$ENV{'BASH_ENV'}='';
	system ($convert, "-$operation", $size, "$srcdir/$file", "$dstdir/$file");
}

unless (-f "$dstdir/$file") {
	print "Status: 500 Internal Server Error\r\nContent-type: text/plain\r\n\r\nCan't create thumbnail\n";
	exit(1);
}

unless (open THUMB, '<', "$dstdir/$file") {
	print "Status: 500 Internal Server Error\r\nContent-type: text/plain\r\n\r\nCan't open thumbnail\n";
	exit(1);
}

print "Status: 200 OK\r\nContent-Type: $mime\r\n\r\n";
while (<THUMB>) { print; }
close THUMB;

