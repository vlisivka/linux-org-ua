#!/usr/bin/perl -wT --
use strict;
use locale;
use utf8;
#use encoding 'utf-8', STDOUT => 'utf-8';

our $vardir;
require "./Paths.pl" unless (defined $vardir);

my $MAX_PICTURES=3;
open(ATTACHMENTS, '<', "$vardir/attachments.txt");
my @attachments=<ATTACHMENTS>;
close(ATTACHMENTS);
chomp @attachments;

@attachments = sort {(split ('\|', $b))[6] <=> (split ('\|', $a))[6]} @attachments;

my $count=0;
foreach my $attachmentLine (@attachments) {
	my ($ctime, $deleted, $subject, $userName, $group, $views, $date, $fileName)
			= split '\|', $attachmentLine;

	if ($fileName =~ m/\.(gif|jpg|jpeg|png)$/i) {
		print <<THUMBNAIL;
<div class="thumbnail" align="center">
	<a class="blind" href="YaBB.pl?num=$ctime">
		<img class="thumbnailImage" src="/thumbs/$fileName" alt="$fileName" title="$fileName" border="0" />
		<br />
		<span class="thumbnailTitle">$subject</span>
	</a>
</div>
THUMBNAIL

		last if (++$count >= $MAX_PICTURES);
	}
}

1;

