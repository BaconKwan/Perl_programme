#!/usr/bin/perl

use utf8;
use strict;
use warnings;

my %g;
my @order;

open IN, "$ARGV[0]" || die $!;
while(<IN>){
	next if(/^GeneID/);
	chomp;
	my @line = split /\t/;
	$g{$line[0]} = $line[1];
}
close IN;

open IN, "$ARGV[1]" || die $!;
open XLS, "> $ARGV[1].xls" ||die $!;
#open STAT, "> $ARGV[1].stat" || die $!;
print XLS "Order\tPathway\tGene\tClass\n";
#print STAT "Order\tPathway\n";
my $head = <IN>;
my @head = split /\t/, $head;
my ($tag) = $head[1] =~ /(\S+)/;
my $order = 1;
my $txt;
while(<IN>){
	chomp;
	my @line = split /\t/;
	my (@up, @down);
	my @gene = split /\;/, $line[6];
	foreach my $id (@gene){
		if($g{$id} >= 0){
			push(@up, $id);
		}
		else{
			push(@down, $id);
		}
	}
	my ($up, $down);
	(scalar(@up) == 0) ? ($up = 0.001) : ($up = scalar(@up));
	(scalar(@down) == 0) ? ($down = 0.001) : ($down = scalar(@down));
	$txt = join "\t", $order, $line[0], $up, $tag . "_up";
	print XLS "$txt\n";
	$txt = join "\t", $order, $line[0], $down, $tag . "_down";
	print XLS "$txt\n";
	$order++;
}
close IN;
close XLS;
#for(my $i = 0; $i < @order; $i++){
	#my $txt = join "\t", $i + 1, $order[$i];
	#print STAT "$txt\n";
#}
#close STAT;
