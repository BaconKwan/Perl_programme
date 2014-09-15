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
	Usage: perl $0 <glist> ... <glist>

" unless(@ARGV > 0);

my %hash;
my %hash_out;

foreach my $file (@ARGV){
	open IN, "< $file" || die $!;
	while(<IN>){
		chomp;
		my @line = split;
		$hash{$line[0]}++;
	}
	close IN;
}
foreach my $file (@ARGV){
	open IN, "< $file" || die $!;
	open OUT1, "> $file.specific" || die $!;
	while(<IN>){
		chomp;
		my @line = split;
		my $scale = @ARGV;
		print OUT1 "$line[0]\n" if(1 == $hash{$line[0]});
		$hash_out{$line[0]} = 0 if($scale == $hash{$line[0]});
	}
	close OUT1;
	close IN;
}
open OUT2, "> intersection" || die $!;
foreach my $name (keys %hash_out){
	print OUT2 "$name\n";
}
close OUT2;
