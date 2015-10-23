#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	terencest@gmail.com
#	Version:	1.0
#	Create date:	
#	Usage:	

use utf8;
use strict;
use warnings;

my $cnt = 1;

open WIG, "< $ARGV[0]" || die $!;
while(<WIG>){
	chomp;
	my $n = (split /\t/)[0];
	while($cnt < $n){
		print "$cnt\t0.0\n";
		$cnt++;
	}
	print "$_\n";
	$cnt++;
}
close WIG;
