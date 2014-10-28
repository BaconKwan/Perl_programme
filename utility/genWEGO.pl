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
	perl $0 <annotTable> <wego.col>
" unless(@ARGV eq 2);

my %hash;

open IN, "< $ARGV[0]" || die $!;
while(<IN>){
	chomp;
	my ($id, $wego) = (split /\t/)[0,$ARGV[1]];
	@{$hash{$id}} = split /;/, $wego;
}
close IN;

foreach my $id (keys %hash){
	my $wego = join "\t", @{$hash{$id}};
	next if($wego eq "_");
	print "$id\t$wego\n";
}
