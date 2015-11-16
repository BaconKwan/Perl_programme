#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	pkguan@genedenovo.com
#	Version:	1.0
#	Create date:	
#	Usage:	

use utf8;
use strict;
use warnings;
use Statistics::RankCorrelation;
use Statistics::Basic::Correlation;

open IN1, "$ARGV[0]" || die $!;
open IN2, "$ARGV[1]" || die $!;
my (%hash1, %hash2);
<IN1>;
<IN2>;
while(<IN1>){
	chomp;
	my @line = split /\t/;
	my $id = shift(@line);
	$hash1{$id} = \@line;
}
while(<IN2>){
	chomp;
	my @line = split /\t/;
	my $id = shift(@line);
	$hash2{$id} = \@line;
}
close IN2;
close IN1;

print "query_A\tquery_B\tCorrelation\tRankCorrelation\n";
foreach my $a (keys %hash1){
	foreach my $b (keys %hash2){
		my $cs = Statistics::RankCorrelation->new($hash1{$a}, $hash2{$b});
		my $s = $cs->spearman;
		my $c = Statistics::Basic::Correlation->new($hash1{$a}, $hash2{$b});
		print "$a\t$b\t$c\t$s\n";
	}
}
