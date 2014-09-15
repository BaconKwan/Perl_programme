#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	terencest@gmail.com
#	Version:	1.0
#	Create date:	
#	Usage:	

use utf8;
use strict;
use warnings;

my @sortList;
my %hash;

open BED, "$ARGV[0]" || die $!;;
while(<BED>){
	chomp;
	my @line = split /\t/;
	$hash{$line[3]} = $_;
}
close BED;

open LIST, "$ARGV[1]" || die $!;
while(<LIST>){
	chomp;
	my @line = split;
	push(@sortList, $line[0]);
}
close LIST;

for(my $i = 0; $i <= $#sortList; $i++){
	print "$hash{$sortList[$i]}\n" if(exists $hash{$sortList[$i]});
}
