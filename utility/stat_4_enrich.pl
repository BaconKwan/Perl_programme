#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	pkguan@genedenovo.com
#	Version:	1.0
#	Create date:	
#	Usage:	

use utf8;
use strict;
use warnings;

my $total_gene = 0;
my %hash;

open WEGO, "$ARGV[0]" || die $!;
while(<WEGO>){
	chomp;
	my @line = split /\t/;
	my $id = shift(@line);
	my %v;
	$total_gene++;
	@line = grep {++$v{$_} < 2} @line;
	foreach my $go (@line){
		push(@{$hash{$go}}, $id);
	}
}
close WEGO;

print "GO_Term\tCount($total_gene)\tGene_List\n";
foreach my $go (sort keys %hash){
	my $txt = join "\t", $go, scalar(@{$hash{$go}}), @{$hash{$go}};
	print "$txt\n";
}
