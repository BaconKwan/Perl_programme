#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	terencest@gmail.com
#	Version:	1.0
#	Create date:	
#	Usage:	

use utf8;
use strict;
use warnings;

my %hash;

while(<>){
	chomp;
	my @line = split /\t/;
	if(exists $hash{$line[0]}){
		next;
	}
	else{
		$hash{$line[0]} = $_;
		print "$_\n";
	}
}
