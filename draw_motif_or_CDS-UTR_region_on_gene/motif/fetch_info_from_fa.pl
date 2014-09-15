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
	Usage: perl $0 <fasta> <color> <motif1> ... <motifN>

" if(@ARGV < 3);

my %color;
my %fa;

open FA, "< $ARGV[0]" || die $!;
open OUT1, "> $ARGV[0].len" || die $!;
$/ = "\n>";
while(<FA>){
	s/>//g;
	if(/\S+/){
		my $t = $&;
		my @parts = split /\n/;
		my $seq = join "\n", @parts[1..$#parts];
		$seq =~ s/\s+//g;
		my $len = length($seq);
		print OUT1 "$t\t$t\t1\t$len\tchr1\n";

		$fa{$t} = "";
	}
}
$/ = "\n";
close OUT1;
close FA;

open COLOR, "< $ARGV[1]" || die $!;
while(<COLOR>){
	chomp;
	my @line = split;
	$color{$line[0]} = $line[1];
}
close COLOR;

open OUT2, "> motif.range" || die $!;
for(my $i = 2; $i <= $#ARGV; $i++){
	open MOTIF, "< $ARGV[$i]" || die $!;
	my %record;
	my $l;
	my $flag = $ARGV[$i];
	$flag =~ s/\.txt//;
	while(<MOTIF>){
	next if(/\/\//);
	next if(/MOTIF/i);
		chomp;
		my @line = split /\s+/;
		my $s = $line[2];
		$s =~ s/\)//;
		$l = length($line[3]);
		my $e = $s + $l;
		$s += 1;
		print OUT2 "$line[0]\t$s\t$e\tfill=$color{$flag}\n";

		$fa{$line[0]} .= $line[3];
		$record{$line[0]} = 0;
	}
	foreach my $id (sort keys %fa){
		next if(exists $record{$id});
		$fa{$id} .= ("-"x$l);
	}
	close MOTIF;
}
close OUT2;

open OUT3, "> motif.fa" || die $!;
foreach my $id (sort keys %fa){
	print OUT3 ">$id\nM$fa{$id}\n";
}
close OUT3;
