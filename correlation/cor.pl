#!/usr/bin/perl

use warnings;
use strict;
use Math::NumberCruncher;

open FA, $ARGV[0] or die $!;
open FB, $ARGV[1] or die $!;
<FA>;
<FB>;
my @af = <FA>;
my @bf = <FB>;

foreach my $i(@af)
{
	my @ai = split /\t/, $i;
	my @a = @ai[1..$#ai];
	foreach my $j(@bf)
	{
		my @bj = split /\t/, $j;
		my @b = @bj[1..$#bj];
		my $co = Math::NumberCruncher::Correlation(\@a, \@b);
		print "$ai[0]\t$bj[0]\t$co\n";
	}
}
