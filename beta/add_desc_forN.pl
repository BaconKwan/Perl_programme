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

open GO, "< $ARGV[1]" || die $!;
while(<GO>){
	s/\s+$//;
	my @line = split /\t/;
	my $go_desc = join ",", @line[1..$#line];
	$hash{$line[0]}{go} = $go_desc;
}
close GO;

open KO, "< $ARGV[2]" || die $!;
while(<KO>){
	chomp;
	my @line = split /\t/;
	next if($line[12] eq "--" && $line[14] eq "--");
	$hash{$line[0]}{ko} = "$line[12] $line[14]";
}
close KO;

open KAKS, "< $ARGV[0]" || die $!;
open OUT, "> $ARGV[0].kogo" || die $!;
my $line = <KAKS>;
chomp $line;
print OUT "$line\tKEGG-description\tGO-description\n";
while(<KAKS>){
	chomp;
	my @line = split /\t/;
	$line[0] =~ s/_\d+$//;
	print OUT "$_";
	if(exists $hash{$line[0]}{ko}){
		print OUT "\t$hash{$line[0]}{ko}";
	}
	else{
		print OUT "\t--";
	}
	if(exists $hash{$line[0]}{go}){
		print OUT "\t$hash{$line[0]}{go}";
	}
	else{
		print OUT "\t--";
	}
	print OUT "\n";
}
close OUT;
close KAKS;
