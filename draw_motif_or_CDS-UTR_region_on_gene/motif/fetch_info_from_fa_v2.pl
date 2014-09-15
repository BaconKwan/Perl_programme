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
	Usage: perl $0 <fasta> <color> <motif>

" unless(3 == @ARGV);

my %color;
my %fa;

open FA, "< $ARGV[0]" || die $!;
open OUT1, "> fasta.len" || die $!;
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
open MOTIF, "< $ARGV[2]" || die $!;
while(<MOTIF>){
	chomp;
	if(/BL\s+MOTIF/){
		my @parts = split;
		my $flag = "motif" . $parts[2];
		my $l = $1 if($parts[3] =~ /width=(\d+)/);
		while(<MOTIF>){
			chomp;
			last if(/\/\//);
			my @line = split;
			$line[2] =~ s/\)//;
			my $e = ($line[2] + $l) - 1;
			print OUT2 "$line[0]\t$line[2]\t$e\tfill=$color{$flag}\n";
		}
	}
}
close MOTIF;
close OUT2;
