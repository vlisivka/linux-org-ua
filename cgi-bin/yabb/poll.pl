#!/usr/bin/perl -w
use strict;
use locale;
use utf8;
#use encoding 'utf-8', STDOUT => 'utf-8';

our $group;
if(not defined $group)
{
 $group="test_ph";
 require "./bbcode.pl";
}


# Find latst modified poll
my ($question,$variants,$multiVote,$id)=('',undef,-1);
my $latestPollMtime=-1;
opendir(MESSAGES, '/var/www/vhosts/linux.org.ua/var/yabb-2.1/Messages');
while(defined(my $entry=readdir MESSAGES))
{
  next if(not $entry=~m/^([0-9]+)\.poll$/);
  my $messageId=$1;

  my ($pollQuestion, $closed, $pollMultiVote, $pollVariants)=parsePoll("/var/www/vhosts/linux.org.ua/var/yabb-2.1/Messages/$entry");
  next if ($closed);

  my ($entryMtime)=(stat("/var/www/vhosts/linux.org.ua/var/yabb-2.1/Messages/$messageId.txt"))[9];
  if(defined($entryMtime) and $entryMtime>$latestPollMtime)
  {
    $latestPollMtime=$entryMtime;
    $question=$pollQuestion;
    $variants=$pollVariants;
    $id=$messageId;
    $multiVote=$pollMultiVote;
  }
}
closedir(MESSAGES);

if($id>0)
{



print <<FORM;
<form name="poll" method="post" action="/cgi-bin/yabb/YaBB.pl?action=vote;board=polls;num=$id" style="display: inline; margin:0;">
<span class="voteQuestion">@{[parseBBCode($question)]}</span>
<input type="submit" value="голосую" class="voteButton" />
<a class="voteResultsLink" href="/cgi-bin/yabb/YaBB.pl?num=$id">результат</a>

<div class="voteOptions">
FORM

if($multiVote)
{
  for(my $i=0;$i<scalar(@$variants);$i++)
  {
    print '<span style="white-space: nowrap;"><input name="option'.$i.'" value="'.$i.'" type="checkbox"/>'.parseBBCode(${$variants}[$i])."</span>\n";
  }
}else
{
  for(my $i=0;$i<scalar(@$variants);$i++)
  {
    print '<span style="white-space: nowrap;"><input name="option" value="'.$i.'" type="radio"/>'.parseBBCode(${$variants}[$i])."</span>\n";
  }
}
print <<FORM;
</div>
<input type="hidden" name="formsession" value="738F93999B509092864C927D274539" /></form>
FORM

}

sub parsePoll
{
  my $fileName=shift;
  open(FILE,'<', $fileName);
  my $headerLine=<FILE>;
#($poll_question, $poll_locked, $poll_uname, $poll_name, $poll_email, $poll_date,
# $guest_vote, $hide_results, $multi_vote, 
# $poll_mod, $poll_modname, $poll_comment)

  chomp $headerLine;
  my ($question,$closed,$postedBy,$postedByName,$postedByEmail,$ctime,
  $guestVote,$hideResults,$multiVote,
  $unknown4,$unknown5,$description)=split(/\|/,$headerLine);
  my @variants=();
  while(<FILE>)
  {
    chomp;
    my ($count,$variant)=split(/\|/,$_,2);
    push @variants, $variant;
  }
  close(FILE);
  return ($question, $closed, $multiVote, \@variants);
}


1;
