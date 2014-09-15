#! /usr/bin/perl -w
use utf8;
use strict;

open WEGO , '<' , $ARGV[0];

my %wegolist;

while (my $text = <WEGO>){
	$text =~ s/\s+$//;
	my @go_num = split /\t/ , $text;
	my $geneid = shift(@go_num);
	my $i = 0;
	foreach (@go_num){
		push (@{$wegolist{$geneid}}, $_);
	}
}

open ANNOT , '>' , "$ARGV[0].annot";

foreach my $geneid (sort keys %wegolist){
	foreach (@{$wegolist{$geneid}}){
		print ANNOT "$geneid\t$_\n";
	}
}
