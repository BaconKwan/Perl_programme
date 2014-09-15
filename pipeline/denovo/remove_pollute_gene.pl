#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	terencest@gmail.com
#	Version:	1.0
#	Create date:	
#	Usage:	

use utf8;
use strict;
use warnings;

die "
	Usage: perl $0 <list> <ref.fa>

" if(@ARGV < 2);

my %hash;

open LIST, "< $ARGV[0]" || die $!;
while(<LIST>){
		chomp;
			$hash{$_} = 0;
}
close LIST;

$/ = "\n>";
open FA, "< $ARGV[1]" || die $!;
while(<FA>){
	my @line = split;
	next if(exists $hash{$line[0]});
	s/>//g;
	print ">$_";
}
close FA;
$/ = "\n";
