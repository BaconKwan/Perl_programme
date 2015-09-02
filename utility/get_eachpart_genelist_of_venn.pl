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
	Usage: perl $0 <list> ... <list>

" if(@ARGV < 2);

my (%hash, %group);
my @file;

for(my $i = 0; $i < @ARGV; $i++){
	$file[$i] = $ARGV[$i];
	$ARGV[$i] =~ s/\..*//;
	open IN, "< $file[$i]" || die $!;
		while(<IN>){
			chomp;
			my @line = split /\t/;
			next if /(GeneID)|(test_id)/;
			$hash{$line[0]}{$ARGV[$i]} = 1;
		}
	close IN;
}

foreach my $i (keys %hash){
	my $c = join "-and-", sort keys %{$hash{$i}};
	push(@{$group{$c}}, $i);
}

foreach my $i (sort keys %group){
	open OUT, "> $i.glist" || die $!;
	my $list = join "\n", @{$group{$i}};
	print OUT "$list\n";
	close OUT;
}
