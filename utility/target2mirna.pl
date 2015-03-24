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
my %mi;

open IN, "$ARGV[0]" || die $!;
while(<IN>){
	chomp;
	my @line = split /\t/;
	my $mi = shift(@line);
	my $gene = shift(@line);
	$hash{$gene}{desc} = join "\t", @line;
	push(@{$hash{$gene}{mirna}}, $mi);
	push(@{$mi{$mi}}, $gene);
}
close IN;

open OUT1, "> $ARGV[0].gene2mirna" || die $!;
foreach my $id (sort keys %hash){
	my $txt = join "\t", $id, $hash{$id}{desc};
	my $mi = join ";", @{$hash{$id}{mirna}};
	print OUT1 "$txt\t$mi\n";
}
close OUT1;

open OUT2, "> $ARGV[0].mirna2gene" || die $!;
foreach my $id (sort keys %mi){
	my $txt = join ";", @{$mi{$id}};
	print OUT2 "$id\t$txt\n";
}
close OUT2;

