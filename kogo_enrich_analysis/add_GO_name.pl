#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	pkguan@genedenovo.com
#	Version:	1.0
#	Create date:	
#	Usage:	

use utf8;
use strict;
use warnings;

my %hash;

open GO, "$ARGV[0]" || die $!;
<GO>;
while(<GO>){
	chomp;
	my @line = split /\t/;
	my @gene = split /;/, $line[3];
	foreach my $id (@gene){
		push(@{$hash{$id}}, $line[1]);
	}
}
close GO;

open WEGO, "$ARGV[1]" || die $!;
while(<WEGO>){
	chomp;
	my $id = (split /\t/)[0];
	my $txt = "";
	$txt = join "\t", @{$hash{$id}} if(exists $hash{$id});
	print "$_\t$txt\n";
}
close WEGO;
