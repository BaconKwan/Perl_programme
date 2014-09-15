#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	terencest@gmail.com
#	Version:	1.0
#	Create date:	
#	Usage:	

use utf8;
use strict;
use warnings;

my %hash_ref;
my %hash;

open REF, "< $ARGV[0]" || die $!;
while(<REF>){
	chomp;
	my @line = split;
	$hash_ref{$line[0]} = 0;
}
close REF;

open IN, "< $ARGV[1]" || die $!;
while(<IN>){
	chomp;
	my @line = split;
	$hash{$line[0]} = 0;
}
close IN;

foreach my $id (keys %hash_ref){
	next if(exists $hash{$id});
	print "$id\n";
}
