#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	terencest@gmail.com
#	Version:	1.0
#	Create date:	
#	Usage:	

use utf8;
use strict;
use warnings;

my @matrix1;
my @matrix2;
my @line;
my $line_num = 0;

open MAT, "< $ARGV[0]" || die $!;
while(<MAT>){
	chomp;
	@line = split /\t/;
	for(my $i = 0; $i <= $#line; $i++){
		$matrix1[$line_num][$i] = $line[$i];
	}
	$line_num++;
}
close MAT;

for(my $i = 0; $i <= $#line; $i++){
	for(my $j = 0; $j <= $line_num - 1; $j++){
		print "$matrix1[$j][$i]\t";
	}
	print "\n";
}
