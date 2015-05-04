#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	pkguan@genedenovo.com
#	Version:	1.0
#	Create date:	
#	Usage:	

use utf8;
use strict;
use warnings;

open IN, "< $ARGV[0]" || die $!;
while(<IN>){
	chomp;
	my @line = split;
	if($line[1] != 0){
		$line[1] = log($line[1]) / log(2);
	}
	$line[1] = sprintf("%.1f", $line[1]);
	my $txt = join "\t", @line;
	print "$txt\n";
}
close IN;
