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
	Usage: perl $0 <all.gene.rpkm.xls> <glist> ... <glist>

" if(@ARGV < 1);

my $file = shift(@ARGV);
my %hash;

open DESC, "< $file" || die $!;
my $line = <DESC>;
chomp $line;
my @line = split /\t/, $line;
while(<DESC>){
	chomp;
	my @parts = split /\t/;
	$hash{$parts[0]} = $_;
}
close DESC;

while(@ARGV){
	my %hash_col;
	$file = shift(@ARGV);
	open GLIST, "< $file" || die $!;
	open OUT, "> ${file}.xls" || die $!;
	$file =~ s/.glist//;
	my @tag = split /-VS-|-and-|-all-/i, $file;
	for(my $i = 0; $i < @tag; $i++){
		for(my $j = 0; $j < @line; $j++){
			if($line[$j] =~ /$tag[$i]/){
				$hash_col{$tag[$i]} = $j;
#print "$tag[$i]\t$j\n";
				last;
			}
		}
	}
	print OUT "GeneID\tLength";
	foreach my $i (sort keys %hash_col){
		print OUT "\t${i}_Uniq_reads_num\t${i}_Coverage\t${i}_RPKM"
	}
	print OUT "\tDescription\tPathway\tGO Component\tGO Function\tGO Process\n";
	while(<GLIST>){
		chomp;
		my @id = split /\t/;
		next if($id[0] =~ /GeneID/);
		my @parts = split /\t/, $hash{$id[0]};
		if(exists($hash{$parts[0]})){
			print OUT "$parts[0]\t$parts[1]";
			foreach my $i (sort keys %hash_col){
				print OUT "\t$parts[$hash_col{$i}]";
				print OUT "\t$parts[$hash_col{$i}+1]";
				print OUT "\t$parts[$hash_col{$i}+2]";
			}
			print OUT "\t$parts[$#parts-4]\t$parts[$#parts-3]\t$parts[$#parts-2]\t$parts[$#parts-1]\t$parts[$#parts]\n";
		}
	}
	close OUT;
	close GLIST;
}
