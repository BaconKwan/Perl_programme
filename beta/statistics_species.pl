#! /usr/bin/perl -w

#	Author:	BaconKwan
#	Email:	terencest@gmail.com
#	Version:	1.0
#	Create date:	
#	Usage:	

use utf8;
use strict;

die"
	perl $0 <speciesInfo.list> <blast_result>

"if(@ARGV ne 2);

my %hash;

open SIL, "< $ARGV[0]" || die $!;
while(<SIL>){
	chomp;
	my @line = split /\t/;
	$hash{$line[0]} = $line[1];
}
close SIL;

my %cnt;

open BR, "< $ARGV[1]" || die $!;
while(<BR>){
	chomp;
	my @line = split /\t/;
	if(!exists $cnt{$line[0]}{$hash{$line[1]}}){
		$cnt{$line[0]}{$hash{$line[1]}} = 1;
	}
	else{
		$cnt{$line[0]}{$hash{$line[1]}}++;
	}
}
close BR;

foreach my $i (sort {$a cmp $b} keys %cnt){
	my $n = 0;
	foreach my $j(sort {$cnt{$i}{$b} <=> $cnt{$i}{$a}} keys %{$cnt{$i}}){
		last if($n>=5);
		$n++;
		print "$i\t$j\t$cnt{$i}{$j}\n";
	}
}

