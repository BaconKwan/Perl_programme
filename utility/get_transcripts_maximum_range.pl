#! /usr/bin/perl -w
use utf8;
use strict;

die
"
	search the longest transcripts for each gene
	Usage: perl $0 <transcripts-length_list> <gene-transcripts_list>

"if(@ARGV != 2);

open GTF, '<', $ARGV[0];

my %hash;
my %gen;

while(<GTF>){
	chomp;
	my @line = split;
	$hash{$line[0]} = $line[1];
}

close GTF;
open IN, '<', $ARGV[1];

while(<IN>){
	chomp;
	my @line = split;
	if(!exists($gen{$line[0]})){
		$gen{$line[0]} = $line[1];
	}
	elsif( $hash{$line[1]} > $hash{$gen{$line[0]}}){
		$gen{$line[0]} = $line[1];
	}
}

close IN;
open OUT, '>', "tmp";
foreach my $key (sort keys %gen){
	print OUT "$key\t$gen{$key}\n";
}
