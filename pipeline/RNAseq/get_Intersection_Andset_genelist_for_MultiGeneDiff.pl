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
	Usage: perl $0 <GeneDiffExpFilter.xls> ... <GeneDiffExpFilter.xls>

" if(@ARGV < 2);

my %hash;
my @file;

for(my $i = 0; $i < @ARGV; $i++){
	open IN, "< $ARGV[$i]" || die $!;
		while(<IN>){
			chomp;
			my @line = split /\t/;
			next if /GeneID/;
			$hash{$line[0]}++;
		}
	close IN;
	($file[$i] = $ARGV[$i]) =~ s/.GeneDiffExpFilter.xls//;
}

my $in_set = join "-all-", @ARGV;
my $an_set = join "-and-", @ARGV;
my $c = @ARGV;

open IN_GLIST, "> $in_set.glist" || die $!;
open AN_GLIST, "> $an_set.glist" || die $!;
foreach my $i (sort keys %hash){
	print IN_GLIST "$i\n";
	print AN_GLIST "$i\n" if($hash{$i} == $c);
}
close AN_GLIST;
close IN_GLIST;

for(my $i = 0; $i < @ARGV; $i++){
	open IN, "< $file[$i]" || die $!;
	$file[$i] =~ s/.GeneDiffExpFilter.xls//;
	open SP_GLIST, "> $file[$i].spe.glist" || die $!;
		while(<IN>){
			chomp;
			my @line = split /\t/;
			next if /GeneID/;
			print SP_GLIST "$line[0]\n" if(1 == $hash{$line[0]});
		}
	close SP_GLIST;
	close IN;
}
