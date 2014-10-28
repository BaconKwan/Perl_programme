#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	pkguan@genedenovo.com
#	Version:	1.0
#	Create date:	
#	Usage:	

use utf8;
use strict;
use warnings;

die 
"
	perl $0 <annotTable> <ko.col>
" unless(@ARGV eq 2);

my %hash;

open IN, "< $ARGV[0]" || die $!;
while(<IN>){
	chomp;
	my ($id, $ko) = (split /\t/)[0,$ARGV[1]];
	@{$hash{$id}} = split /;/, $ko;
#push(@{$hash{$id}}, $ko);
}
close IN;

foreach my $id (keys %hash){
	foreach my $ko (@{$hash{$id}}){
		next if($ko eq "None");
		print "$id\t$ko\n";
	}
}
