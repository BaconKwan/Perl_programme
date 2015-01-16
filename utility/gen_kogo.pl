#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	pkguan@genedenovo.com
#	Version:	1.0
#	Create date:	
#	Usage:	

use utf8;
use strict;
use warnings;

die "perl $0 <desc.xls> \n" unless(@ARGV eq 1);

my %hash;

open IN, "$ARGV[0]" || die $!;
while(<IN>){
	chomp;
	my @line = split /\t/;
	my $id = shift(@line);
#foreach(1..$ARGV[1]-2){
#shift(@line);
#}
	my $txt = join "\t", @line;
	while($txt =~ s/K\d\d\d\d\d//){
		$hash{$id}{KO} = $&;
	}
	while($txt =~ s/GO:\d\d\d\d\d\d\d//){
		push(@{$hash{$id}{GO}}, $&);
	}
}
close IN;

open KO, "> $ARGV[0].ko" || die $!;
open WEGO, "> $ARGV[0].wego" || die $!;
open ANNOT, "> $ARGV[0].annot" || die $!;
foreach my $i (sort keys %hash){
	print KO "$i\t$hash{$i}{KO}\n" if(exists $hash{$i}{KO});
	if(exists $hash{$i}{GO}){
		my $wego = join "\t", @{$hash{$i}{GO}};
		print WEGO "$i\t$wego\n";
		foreach(@{$hash{$i}{GO}}){
			print ANNOT "$i\t$_\n";
		}
	}
}
close ANNOT;
close WEGO;
close KO;
