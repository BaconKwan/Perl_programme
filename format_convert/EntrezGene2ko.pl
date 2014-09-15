#! /usr/bin/perl -w
use utf8;
use strict;

open IN, $ARGV[0] || die $!;
open GT, $ARGV[1] || die $!;

my %hash;
my %gen;

while(<IN>){
	chomp;
	my @line = split;
	$hash{$line[0]} = $line[1];
}
while(<GT>){
	chomp;
	my @line = split;
	$gen{$line[1]} = $line[0];
}

close IN;
close GT;

open EIN, $ARGV[2] || die $!;
open OUT, '>', "Sample.ko";

<EIN>;
=cut
while(<EIN>){
	chomp;
	my @id = split;
	print OUT "$id[1]\t$hash{$id[2]}\n";
}
=cut
while(<EIN>){
	chomp;
	my @line = split;
	print OUT "$gen{$line[1]}\t$hash{$line[2]}\n" if(exists $gen{$line[1]});
}
