#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	pkguan@genedenovo.com
#	Version:	1.0
#	Create date:	
#	Usage:	

use utf8;
use strict;
use warnings;

my ($base_count, $read_count, $q20_count, $gc_count, $N_count) = (0, 0, 0, 0);
open IN, "bzip2 -cd $ARGV[0] |" || die $!;
while(<IN>){
	my $base = <IN>;
	<IN>;
	my $quality = <IN>;

	chomp $base;
	chomp $quality;

	my @base = split "", $base;
	my @quality = split "", $quality;

	$read_count++;
	$base_count += @base;
	$gc_count += $base =~ tr/GCgc/GCgc/;
	$N_count += $base =~ tr/Nn/Nn/;

	for(my $i = 0; $i < @quality; $i++){
		my $q = ord($quality[$i]) - 64;
		$q20_count++ if($q >= 20);
	}
	
}
close IN;

$ARGV[0] =~ s/\.fq\.bz2//;

open STAT, "> $ARGV[0].txt" || die $!;
print STAT "total reads:\t$read_count\n";
print STAT "total reads nt:\t$base_count\n";
print STAT "Q20 number:\t$q20_count\n";
$q20_count = sprintf("%.2f%%", 100 * $q20_count / $base_count);
print STAT "Q20 percentage\t$q20_count\n";
print STAT "GC  number\t$gc_count\n";
$gc_count = sprintf("%.2f%%", 100 * $gc_count / $base_count);
print STAT "GC  percentage\t$gc_count\n";
print STAT "N   number\t$N_count\n";
$N_count = sprintf("%.2f%%", 100 * $N_count / $base_count);
print STAT "N   percentage\t$N_count\n";
close STAT;
