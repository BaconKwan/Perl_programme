#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	terencest@gmail.com
#	Version:	1.0
#	Create date:	
#	Usage:	

use utf8;
use strict;

die"
	This programme is grabing species info which already maped with GI num from *.fa file 
	Usage:	perl $0 <database.fa> > result.list
	result.list format:	GI|########|xxx|######## \\t species info

"if(@ARGV < 1);

my %hash;

while(<>){
	if(/>/){
		chomp;
		my @line = split /\[/;
		$line[0] =~ s/>//;
		$line[0] =~ s/ .*//;
		$line[1] =~ s/\]//;
		print "$line[0]\t$line[1]\n";
	}
}
