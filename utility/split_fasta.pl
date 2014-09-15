#!/usr/bin/env perl
use warnings;
use strict;

die "Usage: perl $0 <fasta> <split number> <outprefix>\n" if(@ARGV ne 3);

open FA, $ARGV[0] or die $!;
$/ = "\n>";
my @fa;
while(<FA>)
{
	chomp;
	s/^>//;
	push @fa, $_;
}

my $n = int(@fa / $ARGV[1]);
for(my $i = 0; $i < $ARGV[1]; $i ++)
{
	open OUT, "> $ARGV[2].$i.fasta" or die $!;
	for(my $j = 0; $j < $n; $j ++)
	{
		my $a = shift @fa;
		print OUT ">$a\n";
	}
}
foreach(@fa)
{
	print OUT ">$_\n";
}
