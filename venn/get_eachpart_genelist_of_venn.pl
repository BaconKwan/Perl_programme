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
	Usage: perl $0 <header> <suffix> <GeneDiffExpFilter.xls> ... <GeneDiffExpFilter.xls>

" if(@ARGV < 3);

my (%hash, %out);
my @samples;
my $header = shift(@ARGV);
my $suffix = shift(@ARGV);

while( my $file = shift(@ARGV)){
	open IN, "$file" || die $!;
	<IN> if($header);
	$file =~ s/$suffix//;
	push(@samples, $file);
	while(<IN>){
		my @line = split /\t/;
		$hash{$line[0]}{$file} = 1;
	}
	close IN;
}

open OUT, "> venn.stat" || die $!;
my $sample_head = join "\t", "GeneID", @samples;
print OUT "$sample_head\n";
foreach my $gene (sort keys %hash){
	my @tmp = sort keys %{$hash{$gene}};
	my $out = join "_", @tmp;
	push(@{$out{$out}}, $gene);
	print OUT "$gene";
	foreach my $s (@samples){
		$hash{$gene}{$s} = 0 unless(exists $hash{$gene}{$s});
		print OUT "\t$hash{$gene}{$s}";
	}
	print OUT "\n";
}
close OUT;

foreach my $name (sort keys %out){
	open OUT, "> $name.glist" || die $!;
	my $txt = join "\n", @{$out{$name}};
	print OUT "$txt\n";
	close OUT;
}
