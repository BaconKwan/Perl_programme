#! /usr/bin/perl -w
use utf8;
use strict;

die 
"
	Search target gene in total geneDescription file for printing a <target_gene>\\t<Description> list
	Usage: perl $0 <description_file> <target_genelist>
	
"if(@ARGV ne 2);

my $inResult = $ARGV[0];
my $indesc = $ARGV[1];
my $out = $inResult . ".txt";
my %hash_desc;

if(! open IND, '<', $indesc){
	die "Cannot open file: $indesc\n";
}
if(! open INR, '<', $inResult){
	die "Cannot open file: $inResult\n";
}

while(<IND>){
	if(m/^\w+/){
		$hash_desc{$&} = $';
	}
}

open OUT, '>' , $out;
while(<INR>){
	if(m/^\w+/){
		print OUT "$&\t$hash_desc{$&}";
	}
}
