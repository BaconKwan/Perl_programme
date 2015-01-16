#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	pkguan@genedenovo.com
#	Version:	1.0
#	Create date:	
#	Usage:	

use utf8;
use strict;
use warnings;

my $file;
my @id;
my %hash;

while($file = shift(@ARGV)){
	open IN, $file || die $!;
	$file =~ s/\.rpkm\.xls//;
	push(@id, $file);
	while(<IN>){
		chomp;
		my @line = split /\t/;
		$hash{$line[0]}{$file} = $line[1];
	}
	close IN;
}

my $header = join "\t", "GeneID", @id;
print "$header\n";
foreach my $i (sort keys %hash){
	print "$i";
	foreach my $j (@id){
		if(exists $hash{$i}{$j}){
			print "\t$hash{$i}{$j}";
		}
		else{
			print "\t0.001";
		}
	}
	print "\n";
}
